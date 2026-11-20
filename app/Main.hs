{-# LANGUAGE RecordWildCards #-}

-- | Command-line entry point: @sync@ builds and follows the index, @serve@
-- does the same while serving it over gRPC (or only serves it); the other
-- commands are smoke and fixture tools for the block source.
module Main (main) where

import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (EpochNo (..), SlotNo (..))
import Cardano.Slotting.Time (SystemStart (..))
import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (race_)
import Control.Exception (AsyncException (..), Exception, throwIO, try)
import Control.Monad (forever, when)
import Control.Tracer (Tracer (..), emit)
import Data.Foldable (for_)
import Data.IORef (IORef, atomicModifyIORef', atomicWriteIORef, newIORef, readIORef)
import Data.List.NonEmpty (nonEmpty)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import Data.Void (absurd)
import McFollower.Block
  ( Block
  , Era (..)
  , blockEra
  , blockTxCount
  , parsePoint
  , renderChainHash
  , renderHash
  , renderPoint
  , renderTip
  )
import McFollower.BlockFile (writeBlockFile)
import McFollower.BlockSource
  ( BlockEvent
  , BlockSource (..)
  , BlockSourceTrace (..)
  , ChainEvent (..)
  )
import McFollower.BlockSource.N2C (LocalNodeConfig (..), n2cBlockSource)
import McFollower.BlockSource.N2N (n2nBlockSource)
import Data.ByteString qualified as BS
import Data.Set qualified as Set
import Data.Word (Word32)
import McFollower.EpochData.Driver (DriverStartError (..), DriverState (..), renderDriverState, startDriverState)
import McFollower.EpochData.MaxTxSize (MaxTxSizeTable (..), ProposalRef, maxTxSizePreset, parseProposalRef)
import McFollower.EpochData.Mithril (Aggregator (..), aggregatorFor)
import McFollower.EpochData.Producer (MithrilSource (..), ProducerConfig (..), ProducerHealth (..), noProblems, runProducers)
import McFollower.EpochData.Serve (EpochDataConfig (..), EpochHealth (..))
import McFollower.EpochData.Store (EpochDataStore (..))
import McFollower.EpochNonceTable (nonceTable)
import McFollower.EraHistory (ChainParams (..), SlotInfo (..), presetHistory, slotInfo)
import McFollower.LocalStateQuery (queryProtocolState)
import McFollower.Nonce (nonceConfig)
import McFollower.Nonce.TrustedState (TrustedState (..), parseTrustedState)
import McFollower.Extract (TxFeatures (..), blockFeatures)
import McFollower.LocalStateQuery (QueryTarget (..), querySystemStart)
import McFollower.Network
  ( NetworkConfig (..)
  , NetworkName (..)
  , RelayAddress
  , chainParams
  , codecConfig
  , networkConfig
  , parseNetworkName
  , parseRelayAddress
  )
import McFollower.Server (ServerConfig (..), SyncStatus (..), interruptOnTerminate, notFollowing, withServer)
import McFollower.Store (Store, StoreError, StoreIdentity (..), checkIdentity, closeStore, getStartPoint, openStoreReadOnly, setStartPoint, tipPoint, withEpochData, withStore)
import McFollower.Sync (Progress (..), SyncConfig (..), SyncEpochData (..), SyncTrace (..), UpstreamTip (..), runSync)
import McFollower.WatchSet (WatchConfig, WatchFilter, renderWatchConfig, startPointPreset, watchFilter, watchPreset)
import Network.Socket (HostName, PortNumber)
import Options.Applicative
import Ouroboros.Consensus.Block (Point, blockHash, blockNo, blockPoint, blockPrevHash, blockSlot)
import Ouroboros.Network.Magic (NetworkMagic (..))
import Data.Word (Word64)
import System.Directory (doesFileExist)
import System.Exit (die, exitFailure)
import System.FilePath ((</>))
import System.IO (BufferMode (..), hPutStrLn, hSetBuffering, stderr, stdout)
import Text.Read (readMaybe)

data Command
  = Sync !SyncOptions
  | Serve !ServeOptions
  | Follow !FollowOptions
  | FetchBlocks !FetchOptions
  | SystemStartQuery !QueryOptions

data Upstream
  = Relays ![RelayAddress]
  -- ^ Node-to-node; the network's bootstrap relays if empty.
  | LocalSocket !FilePath

data StartFrom = FromRecent | FromPoint !(Point Block)

data FollowOptions = FollowOptions
  { foNetwork :: !NetworkName
  , foUpstream :: !Upstream
  , foStart :: !StartFrom
  , foLimit :: !(Maybe Int)
  }

data SyncOptions = SyncOptions
  { soNetwork :: !NetworkName
  , soUpstream :: !Upstream
  , soDatabase :: !FilePath
  , soStart :: !(Maybe (Point Block))
  , soLimit :: !(Maybe Word64)
  , soEpoch :: !EpochOptions
  }

data ServeOptions = ServeOptions
  { svoNetwork :: !NetworkName
  , svoUpstream :: !(Maybe Upstream)
  -- ^ 'Nothing': serve the database without syncing it.
  , svoDatabase :: !FilePath
  , svoStart :: !(Maybe (Point Block))
  , svoListen :: !(HostName, PortNumber)
  , svoEpoch :: !EpochOptions
  }

-- | Epoch nonce and epoch data configuration.
data EpochOptions = EpochOptions
  { eoTrustedState :: !(Maybe FilePath)
  , eoMaxTxSize :: ![(EpochNo, Word32)]
  -- ^ Entries added to the network's @maxTxSize@ table.
  , eoAcknowledged :: ![ProposalRef]
  , eoMithril :: !(Maybe Bool)
  -- ^ Default: on for node-to-node, off with a local node.
  , eoAggregator :: !(Maybe Text)
  , eoBackfill :: !Word32
  }

data FetchOptions = FetchOptions
  { fetchNetwork :: !NetworkName
  , fetchUpstream :: !Upstream
  , fetchStart :: !(Point Block)
  , fetchCount :: !Int
  , fetchOut :: !(Maybe FilePath)
  , fetchSelect :: ![Text]
  }

data QueryOptions = QueryOptions
  { qoNetwork :: !NetworkName
  , qoSocket :: !FilePath
  , qoTarget :: !QueryTarget
  }

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  cmd <- execParser (info (commandParser <**> helper) (fullDesc <> progDesc "Cardano indexer for Midnight"))
  case cmd of
    Sync opts -> sync opts
    Serve opts -> serve opts
    Follow opts -> follow opts
    FetchBlocks opts -> fetchBlocks opts
    SystemStartQuery opts -> systemStart opts

data LimitReached = LimitReached
  deriving stock (Show)

instance Exception LimitReached

blockSource :: NetworkConfig -> Upstream -> BlockSource
blockSource cfg = \case
  Relays relays -> n2nBlockSource traceToStderr cfg (fromMaybe (ncRelays cfg) (nonEmpty relays))
  LocalSocket path -> n2cBlockSource traceToStderr (LocalNodeConfig cfg path)

sync :: SyncOptions -> IO ()
sync SyncOptions {soNetwork, soUpstream, soDatabase, soStart, soLimit, soEpoch} = do
  let (identity, watch) = storeIdentity soNetwork
  wf <- either (die . ("invalid watch set: " <>)) pure (watchFilter watch)
  withStore soDatabase identity $ \store -> do
    prepareStart soNetwork soStart store
    driverVar <- newIORef DriverOff
    healthVar <- newIORef noProblems
    index soNetwork soUpstream soEpoch soDatabase identity wf soLimit (\_ -> pure ()) driverVar healthVar store

-- | Follow the chain into the store, with the nonce driver and the epoch
-- data producers, until the sync loop returns (after @--blocks@) or fails.
index
  :: NetworkName
  -> Upstream
  -> EpochOptions
  -> FilePath
  -> StoreIdentity
  -> WatchFilter
  -> Maybe Word64
  -> (Maybe UpstreamTip -> IO ())
  -> IORef DriverState
  -> IORef ProducerHealth
  -> Store
  -> IO ()
index network upstream eo database identity wf limit onTip driverVar healthVar store = do
  let cp = chainParams network
      nonceCfg = nonceConfig cp
      table = nonceTable network
      cfg = networkConfig network
  trusted <- trustedStateFor network upstream eo store
  start <- startDriverState nonceCfg table store trusted >>= either (die . renderStartError) pure
  atomicWriteIORef driverVar start
  hPutStrLn stderr ("nonce driver: " <> Text.unpack (renderDriverState start))
  upstreamVar <- newIORef Nothing
  let history = presetHistory cp
      tipEpoch = do
        up <- readIORef upstreamVar
        case up of
          Just UpstreamTip {utSlot} | Right SlotInfo {siEpoch} <- slotInfo history (SlotNo utSlot) -> pure (Just siEpoch)
          _ -> pure Nothing
      mithril = case (eoMithril eo, upstream) of
        (Just False, _) -> Nothing
        (Nothing, LocalSocket _) -> Nothing
        _ ->
          Just
            MithrilSource
              { msAggregator = maybe (aggregatorFor network) Aggregator (eoAggregator eo)
              , msWindow = eoBackfill eo
              }
      producers =
        runProducers
          ProducerConfig
            { pcDatabase = database
            , pcIdentity = identity
            , pcNonceConfig = nonceCfg
            , pcNode = case upstream of
                LocalSocket path -> Just (LocalNodeConfig cfg path)
                Relays _ -> Nothing
            , pcMithril = mithril
            , pcFirstShelleyEpoch = firstShelleyEpoch network
            , pcMaxTxSizeTable = maxTxSizeTable network eo
            , pcTipEpoch = tipEpoch
            , pcHealth = healthVar
            , pcLog = hPutStrLn stderr . Text.unpack
            , pcPoll = 30
            , pcNodeRefresh = 600
            }
      syncEpoch = SyncEpochData {sedNonceConfig = nonceCfg, sedNonceTable = table, sedDriver = driverVar}
  race_
    ( runSync
        syncTracer
        (syncConfig network wf limit (\t -> atomicWriteIORef upstreamVar t >> onTip t) syncEpoch)
        (blockSource cfg upstream)
        store
    )
    producers

-- | The trusted protocol state to start the nonce driver from, if it has
-- no stored checkpoints: with a local node, the node's own state at the
-- stored tip if the node still has that point in its volatile window;
-- otherwise the @--trusted-state@ file, if given.
trustedStateFor :: NetworkName -> Upstream -> EpochOptions -> Store -> IO (Maybe TrustedState)
trustedStateFor network upstream eo store = do
  stored <- withEpochData store loadCheckpoints
  if not (null stored)
    then do
      for_ (eoTrustedState eo) $ \path ->
        hPutStrLn stderr ("nonce driver: resuming from its stored checkpoints; " <> path <> " is not used")
      pure Nothing
    else do
      fromNode <- case upstream of
        Relays _ -> pure Nothing
        LocalSocket path ->
          tipPoint store >>= \case
            Nothing -> pure Nothing
            Just tip ->
              queryProtocolState (LocalNodeConfig (networkConfig network) path) (AtPoint tip) >>= \case
                Right ts -> do
                  hPutStrLn stderr ("nonce driver: starting from the node's protocol state at " <> Text.unpack (renderPoint tip))
                  pure (Just ts)
                Left e -> do
                  hPutStrLn stderr ("nonce driver: the node has no protocol state at " <> Text.unpack (renderPoint tip) <> " (" <> show e <> ")")
                  pure Nothing
      case (fromNode, eoTrustedState eo) of
        (Just ts, _) -> pure (Just ts)
        (Nothing, Nothing) -> pure Nothing
        (Nothing, Just path) -> either (die . (("cannot read the trusted state in " <> path <> ": ") <>)) (pure . Just) . parseTrustedState =<< BS.readFile path

renderStartError :: DriverStartError -> String
renderStartError = \case
  CheckpointsOutOfStep cp tip ->
    "the stored nonce driver checkpoints end at " <> pt cp <> " but the index ends at " <> pt tip <> "; the database is inconsistent"
  TrustedStateAlreadyPassed ts tip ->
    "the trusted state is for " <> pt ts <> ", which the index has already passed (it ends at " <> pt tip
      <> "); the nonce driver can only start at or after the index tip. Use a trusted state at or after the tip, or a new database whose start point precedes it"
  TrustedStateNotOnChain ts tip ->
    "the trusted state is for " <> pt ts <> ", which is not on the indexed chain (it ends at " <> pt tip <> ")"
  TrustedStateBeforeStart ts start ->
    "the trusted state is for " <> pt ts <> ", before the index's start point " <> pt start
  StartFailed e -> "the nonce driver cannot start from the trusted state: " <> show e
 where
  pt = Text.unpack . renderPoint

firstShelleyEpoch :: NetworkName -> EpochNo
firstShelleyEpoch network = case cpHardForks (chainParams network) of
  e : _ -> e
  [] -> EpochNo maxBound

maxTxSizeTable :: NetworkName -> EpochOptions -> MaxTxSizeTable
maxTxSizeTable network eo = let MaxTxSizeTable preset = maxTxSizePreset network in MaxTxSizeTable (preset <> eoMaxTxSize eo)

epochDataConfig :: NetworkName -> EpochOptions -> IO EpochHealth -> EpochDataConfig
epochDataConfig network eo health =
  EpochDataConfig
    { edcNonceTable = nonceTable network
    , edcMaxTxSize = maxTxSizeTable network eo
    , edcAcknowledged = Set.fromList (eoAcknowledged eo)
    , edcFirstShelleyEpoch = firstShelleyEpoch network
    , edcHealth = health
    }

-- | The identity a database of a network is created with and checked
-- against, and the network's watch set.
storeIdentity :: NetworkName -> (StoreIdentity, WatchConfig)
storeIdentity network =
  ( StoreIdentity
      { siNetworkMagic = unNetworkMagic (ncMagic (networkConfig network))
      , siWatchSet = renderWatchConfig watch
      , siSecurityParam = cpSecurityParam (chainParams network)
      }
  , watch
  )
 where
  watch = watchPreset network

-- | Record the start point of a new database; check it when resuming.
prepareStart :: NetworkName -> Maybe (Point Block) -> Store -> IO ()
prepareStart network from store = do
  stored <- getStartPoint store
  case (stored, from <|> startPointPreset network) of
    (Nothing, Nothing) ->
      die ("no start point is known for " <> show network <> "; pass --from")
    (Nothing, Just start) -> setStartPoint store start
    (Just _, Just start) | Just _ <- from -> setStartPoint store start
    (Just _, _) -> pure ()

syncConfig :: NetworkName -> WatchFilter -> Maybe Word64 -> (Maybe UpstreamTip -> IO ()) -> SyncEpochData -> SyncConfig
syncConfig network wf limit onTip epochData =
  SyncConfig
    { scWatchFilter = wf
    , scEraHistory = presetHistory (chainParams network)
    , scStopAfter = limit
    , scProgressEvery = 10
    , scOnUpstreamTip = onTip
    , scEpochData = epochData
    }

syncTracer :: Tracer IO SyncTrace
syncTracer = Tracer (emit (hPutStrLn stderr . Text.unpack . renderSyncTrace))

-- | Serve the index over gRPC, following the chain in the same process
-- unless @--no-sync@ is given. SIGINT and SIGTERM stop both; a block being
-- applied is rolled back, never half written.
serve :: ServeOptions -> IO ()
serve ServeOptions {svoNetwork, svoUpstream, svoDatabase, svoStart, svoListen = (host, port), svoEpoch} = do
  interruptOnTerminate
  let (identity, watch) = storeIdentity svoNetwork
      server status health =
        ServerConfig
          { svHost = host
          , svPort = port
          , svDatabase = svoDatabase
          , svIdentity = identity
          , svWatch = watch
          , svConnections = 16
          , svSyncStatus = status
          , svEpochData = epochDataConfig svoNetwork svoEpoch health
          , svLog = hPutStrLn stderr . Text.unpack
          }
      listening bound = hPutStrLn stderr ("serving gRPC on " <> host <> ":" <> show bound)
  stopped <- try $ case svoUpstream of
    Nothing -> do
      checkExisting identity
      let health = pure (EpochHealth "not run by this process" [] Nothing)
      withServer (server (pure notFollowing) health) $ \bound -> do
        listening bound
        forever (threadDelay maxBound)
    Just upstream -> do
      wf <- either (die . ("invalid watch set: " <>)) pure (watchFilter watch)
      withStore svoDatabase identity $ \store -> do
        prepareStart svoNetwork svoStart store
        upstreamTip <- newIORef Nothing
        driverVar <- newIORef DriverOff
        healthVar <- newIORef noProblems
        let status = SyncStatus True <$> readIORef upstreamTip
            health = do
              driver <- readIORef driverVar
              ProducerHealth {phMissingStake, phNonceDivergence} <- readIORef healthVar
              pure (EpochHealth (renderDriverState driver) phMissingStake phNonceDivergence)
        withServer (server status health) $ \bound -> do
          listening bound
          index svoNetwork upstream svoEpoch svoDatabase identity wf Nothing (atomicWriteIORef upstreamTip) driverVar healthVar store
  case stopped of
    Left UserInterrupt -> hPutStrLn stderr "stopped"
    Left e -> throwIO e
    Right () -> pure ()
 where
  -- Refuse a database of another network or watch set up front; a missing
  -- one is answered with UNAVAILABLE until a sync creates it.
  checkExisting identity =
    doesFileExist svoDatabase >>= \case
      False -> hPutStrLn stderr ("no database at " <> svoDatabase <> " yet; requests fail with UNAVAILABLE until it exists")
      True -> do
        store <- openStoreReadOnly svoDatabase
        try (checkIdentity store identity) >>= \case
          Left e -> closeStore store >> die ("cannot serve " <> svoDatabase <> ": " <> show (e :: StoreError))
          Right () -> closeStore store

renderSyncTrace :: SyncTrace -> Text
renderSyncTrace = \case
  TraceIntersecting points ->
    "intersecting at " <> Text.intercalate ", " (map renderPoint (take 3 points))
      <> (if length points > 3 then ", ... (" <> showText (length points) <> " points)" else "")
  TraceRolledBack point undone ->
    "rolled back to " <> renderPoint point <> " (" <> showText undone <> " blocks undone)"
  TraceDriverStarted p -> "nonce driver started from its trusted state at " <> renderPoint p
  TraceDriverStopped p pending ->
    "rolled back to " <> renderPoint p <> ", before the nonce driver's start; "
      <> (if pending then "waiting for its trusted state's point again" else "its trusted state is unknown, so it is off")
  TraceEpochNonce (EpochNo e) p -> "epoch nonce of epoch " <> showText e <> " produced at " <> renderPoint p
  TraceSightings ss -> "maxTxSize proposals sighted: " <> showText ss
  TraceProgress Progress {..} ->
    Text.unwords
      [ "synced to slot " <> showText pSlot
      , "block " <> maybe "-" showText pBlockNo
      , "epoch " <> showText pEpoch <> ","
      , "upstream block " <> maybe "-" showText pUpstreamBlockNo <> ";"
      , showText pBlocks <> " blocks, " <> showText pTxs <> " txs, " <> showText pOutputs <> " watched outputs in"
      , showText (round pSeconds :: Int) <> "s"
      ]

-- | Follow the chain from a point and print what each block contains;
-- optionally write blocks (all, or those with selected features) to files.
fetchBlocks :: FetchOptions -> IO ()
fetchBlocks FetchOptions {fetchNetwork, fetchUpstream, fetchStart, fetchCount, fetchOut, fetchSelect} = do
  let cfg = networkConfig fetchNetwork
  forwards <- newIORef (0 :: Int)
  let handler = \case
        RollBackward {} -> pure ()
        RollForward blk _ -> do
          let (isBoundary, txs) = blockFeatures blk
              tags = blockTags isBoundary (blockEra blk) txs
          Text.putStrLn (Text.unwords (renderPoint (blockPoint blk) : showText (blockEra blk) : tags))
          for_ fetchOut $ \dir ->
            when (null fetchSelect || any (`elem` tags) fetchSelect) $
              writeBlockFile (codecConfig cfg) (dir </> Text.unpack (renderPoint (blockPoint blk)) <> ".cbor") blk
          n <- atomicModifyIORef' forwards (\n -> (n + 1, n + 1))
          when (n == fetchCount) (throwIO LimitReached)
  try (runBlockSource (blockSource cfg fetchUpstream) [fetchStart] handler) >>= \case
    Left LimitReached -> pure ()
    Right v -> absurd v

-- | Feature tags of a block, as accepted by @fetch-blocks --select@.
blockTags :: Bool -> Era -> [TxFeatures] -> [Text]
blockTags isBoundary era txs =
  ["ebb" | isBoundary]
    <> ["byron" | era == Byron, not isBoundary]
    <> ["txs=" <> showText (length txs) | not (null txs)]
    <> ["invalid" | any (not . tfValid) txs]
    <> ["collateral-return" | any tfCollateralReturn txs]
    <> ["inline-datum" | any ((> 0) . tfInlineDatums) txs]
    <> ["datum-hash" | any ((> 0) . tfDatumHashes) txs]
    <> ["witness-datum" | any ((> 0) . tfWitnessDatums) txs]
    <> ["witnessed-datum-hash" | any ((> 0) . tfWitnessedDatumHashes) txs]
    <> ["multi-asset" | any ((> 0) . tfMultiAssetOutputs) txs]
    <> ["byron-address" | any ((> 0) . tfByronAddresses) txs]
    <> ["metadata" | any (not . null . tfMetadataLabels) txs]

follow :: FollowOptions -> IO ()
follow FollowOptions {foNetwork, foUpstream, foStart, foLimit} = do
  let cfg = networkConfig foNetwork
      source = blockSource cfg foUpstream
      start = case foStart of
        FromRecent -> [ncRecentPoint cfg]
        FromPoint p -> [p]
  forwards <- newIORef (0 :: Int)
  let handler ev = do
        Text.putStrLn (renderEvent ev)
        case ev of
          RollForward {} -> do
            n <- atomicModifyIORef' forwards (\n -> (n + 1, n + 1))
            when (Just n == foLimit) (throwIO LimitReached)
          RollBackward {} -> pure ()
  try (runBlockSource source start handler) >>= \case
    Left LimitReached -> pure ()
    Right v -> absurd v

systemStart :: QueryOptions -> IO ()
systemStart QueryOptions {qoNetwork, qoSocket, qoTarget} =
  querySystemStart (LocalNodeConfig (networkConfig qoNetwork) qoSocket) qoTarget >>= \case
    Left e -> hPutStrLn stderr (show e) >> exitFailure
    Right (SystemStart t) -> print t

renderEvent :: BlockEvent -> Text
renderEvent = \case
  RollForward blk tip ->
    Text.unwords
      [ "forward"
      , "era=" <> showText (blockEra blk)
      , "slot=" <> showText (unSlotNo (blockSlot blk))
      , "block=" <> showText (unBlockNo (blockNo blk))
      , "hash=" <> renderHash (blockHash blk)
      , "prev=" <> renderChainHash (blockPrevHash blk)
      , "txs=" <> showText (blockTxCount blk)
      , "tip=" <> renderTip tip
      ]
  RollBackward p tip ->
    Text.unwords ["backward", "point=" <> renderPoint p, "tip=" <> renderTip tip]

traceToStderr :: Tracer IO BlockSourceTrace
traceToStderr = Tracer (emit (hPutStrLn stderr . Text.unpack . renderTrace))

renderTrace :: BlockSourceTrace -> Text
renderTrace = \case
  TraceConnecting upstream -> "connecting to " <> upstream
  TraceIntersectFound p tip -> "intersected at " <> renderPoint p <> ", upstream tip " <> renderTip tip
  TraceNoBlocks from to ->
    "relay has no blocks for " <> renderPoint from <> " .. " <> renderPoint to <> ", waiting for rollback"
  TraceDisconnected e -> "disconnected: " <> showText e <> "; reconnecting"

showText :: Show a => a -> Text
showText = Text.pack . show

commandParser :: Parser Command
commandParser =
  hsubparser $
    command "sync" (info (Sync <$> syncOptions) (progDesc "Build the index in a database and keep it following the chain"))
      <> command
        "serve"
        (info (Serve <$> serveOptions) (progDesc "Serve the index over gRPC while keeping it following the chain"))
      <> command "follow" (info (Follow <$> followOptions) (progDesc "Follow the chain and print one line per event"))
      <> command
        "fetch-blocks"
        (info (FetchBlocks <$> fetchOptions) (progDesc "Print what blocks contain and optionally save them as fixtures"))
      <> command
        "system-start"
        (info (SystemStartQuery <$> queryOptions) (progDesc "Query a local node's system start"))

followOptions :: Parser FollowOptions
followOptions =
  FollowOptions
    <$> networkOption
    <*> upstreamOption
    <*> startOption
    <*> optional
      (option auto (long "blocks" <> metavar "N" <> help "Stop after N blocks"))

syncOptions :: Parser SyncOptions
syncOptions =
  SyncOptions
    <$> networkOption
    <*> upstreamOption
    <*> strOption (long "db" <> metavar "PATH" <> help "SQLite database (created if missing)")
    <*> optional
      ( option
          (eitherReader (parsePoint . Text.pack))
          ( long "from"
              <> metavar "origin|SLOT.HASH"
              <> help
                "Start point of a new database (default: the network's preset, if it has one). \
                \The first block indexed is the one after it. Must match when resuming."
          )
      )
    <*> optional
      (option auto (long "blocks" <> metavar "N" <> help "Stop after applying N blocks"))
    <*> epochOptions

serveOptions :: Parser ServeOptions
serveOptions =
  ServeOptions
    <$> networkOption
    <*> ( Nothing <$ flag' () (long "no-sync" <> help "Only serve an existing database; do not follow the chain")
            <|> Just <$> upstreamOption
        )
    <*> strOption (long "db" <> metavar "PATH" <> help "SQLite database (created if missing, unless --no-sync)")
    <*> optional
      ( option
          (eitherReader (parsePoint . Text.pack))
          (long "from" <> metavar "origin|SLOT.HASH" <> help "Start point of a new database, as for sync")
      )
    <*> option
      (eitherReader parseListen)
      ( long "listen"
          <> metavar "HOST:PORT"
          <> value ("127.0.0.1", 50051)
          <> help "Where to serve gRPC over plain HTTP/2 (default: 127.0.0.1:50051)"
      )
    <*> epochOptions
 where
  parseListen s = case break (== ':') (reverse s) of
    (rport, ':' : rhost)
      | Just p <- readMaybe (reverse rport)
      , p >= 0
      , p < (65536 :: Integer)
      , not (null rhost) ->
          Right (unbracket (reverse rhost), fromIntegral p)
    _ -> Left "expected HOST:PORT"
  unbracket h = case h of
    '[' : rest | not (null rest), last rest == ']' -> init rest
    _ -> h

epochOptions :: Parser EpochOptions
epochOptions =
  EpochOptions
    <$> optional
      ( strOption
          ( long "trusted-state"
              <> metavar "FILE"
              <> help
                "Trusted Praos protocol state to start the nonce driver from (JSON: point, praos_state_cbor). \
                \Its point must be at or after the index tip"
          )
      )
    <*> many
      ( option
          (eitherReader parseMaxTxSize)
          ( long "max-tx-size"
              <> metavar "EPOCH:BYTES"
              <> help "maxTxSize from EPOCH on, added to the network's table (repeatable)"
          )
      )
    <*> many
      ( option
          (eitherReader (parseProposalRef . Text.pack))
          ( long "acknowledge-proposal"
              <> metavar "TXID#INDEX|TXID@GENESISKEYHASH"
              <> help "A reviewed proposal that changes maxTxSize; it no longer gates serving (repeatable)"
          )
      )
    <*> optional
      ( flag' True (long "mithril" <> help "Fetch stake distributions from Mithril (default with --relay)")
          <|> flag' False (long "no-mithril" <> help "Do not fetch stake distributions from Mithril")
      )
    <*> optional
      (strOption (long "mithril-aggregator" <> metavar "URL" <> help "Mithril aggregator (default: the network's)"))
    <*> option
      auto
      ( long "stake-backfill-epochs"
          <> metavar "N"
          <> value 6
          <> help "Keep the stake distributions of the N epochs before the tip epoch (default: 6)"
      )
 where
  parseMaxTxSize s = case break (== ':') s of
    (e, ':' : v) | Just epoch <- readMaybe e, Just size <- readMaybe v -> Right (EpochNo epoch, size)
    _ -> Left "expected EPOCH:BYTES"

fetchOptions :: Parser FetchOptions
fetchOptions =
  FetchOptions
    <$> networkOption
    <*> upstreamOption
    <*> option
      (eitherReader (parsePoint . Text.pack))
      (long "from" <> metavar "origin|SLOT.HASH" <> help "Point to start after")
    <*> option auto (long "blocks" <> metavar "N" <> help "Number of blocks")
    <*> optional (strOption (long "out" <> metavar "DIR" <> help "Write blocks to DIR/SLOT.HASH.cbor"))
    <*> many
      ( strOption
          ( long "select"
              <> metavar "TAG"
              <> help "With --out, write only blocks with this tag (repeatable), e.g. invalid, inline-datum, ebb"
          )
      )

queryOptions :: Parser QueryOptions
queryOptions =
  QueryOptions
    <$> networkOption
    <*> socketOption
    <*> option
      (eitherReader parseTarget)
      ( long "at"
          <> metavar "immutable|volatile|SLOT.HASH"
          <> value AtVolatileTip
          <> help "Ledger state to query (default: volatile)"
      )
 where
  parseTarget = \case
    "immutable" -> Right AtImmutableTip
    "volatile" -> Right AtVolatileTip
    s -> AtPoint <$> parsePoint (Text.pack s)

networkOption :: Parser NetworkName
networkOption =
  option
    (eitherReader (parseNetworkName . Text.pack))
    (long "network" <> metavar "mainnet|preprod|preview" <> help "Network to follow")

socketOption :: Parser FilePath
socketOption = strOption (long "socket" <> metavar "PATH" <> help "cardano-node socket")

upstreamOption :: Parser Upstream
upstreamOption =
  LocalSocket <$> socketOption
    <|> Relays
      <$> many
        ( option
            (eitherReader (parseRelayAddress . Text.pack))
            ( long "relay"
                <> metavar "HOST:PORT"
                <> help "Relay to follow over node-to-node; repeatable (default: the network's bootstrap relays)"
            )
        )

startOption :: Parser StartFrom
startOption =
  option
    (eitherReader parseStart)
    ( long "from"
        <> metavar "origin|recent|SLOT.HASH"
        <> value FromRecent
        <> help "Where to start (default: recent, a built-in recent block)"
    )
 where
  parseStart = \case
    "recent" -> Right FromRecent
    s -> FromPoint <$> parsePoint (Text.pack s)
