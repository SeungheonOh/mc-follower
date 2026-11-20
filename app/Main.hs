{-# LANGUAGE RecordWildCards #-}

-- | Command-line entry point: @sync@ builds and follows the index; the other
-- commands are smoke and fixture tools for the block source.
module Main (main) where

import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (SlotNo (..))
import Cardano.Slotting.Time (SystemStart (..))
import Control.Exception (Exception, throwIO, try)
import Control.Monad (when)
import Control.Tracer (Tracer (..), emit)
import Data.Foldable (for_)
import Data.IORef (atomicModifyIORef', newIORef)
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
import McFollower.EraHistory (GenesisParams (..), eraHistory, genesisParams)
import McFollower.Extract (TxFeatures (..), blockFeatures)
import McFollower.LocalStateQuery (QueryTarget (..), querySystemStart)
import McFollower.Network
  ( NetworkConfig (..)
  , NetworkName (..)
  , RelayAddress
  , codecConfig
  , networkConfig
  , parseNetworkName
  , parseRelayAddress
  )
import McFollower.Store (StoreIdentity (..), getStartPoint, setStartPoint, withStore)
import McFollower.Sync (Progress (..), SyncConfig (..), SyncTrace (..), runSync)
import McFollower.WatchSet (renderWatchConfig, startPointPreset, watchFilter, watchPreset)
import Options.Applicative
import Ouroboros.Consensus.Block (Point, blockHash, blockNo, blockPoint, blockPrevHash, blockSlot)
import Ouroboros.Network.Magic (NetworkMagic (..))
import Data.Word (Word64)
import System.Exit (die, exitFailure)
import System.FilePath ((</>))
import System.IO (BufferMode (..), hPutStrLn, hSetBuffering, stderr, stdout)

data Command
  = Sync !SyncOptions
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
sync SyncOptions {soNetwork, soUpstream, soDatabase, soStart, soLimit} = do
  let cfg = networkConfig soNetwork
      watch = watchPreset soNetwork
      identity =
        StoreIdentity
          { siNetworkMagic = unNetworkMagic (ncMagic cfg)
          , siWatchSet = renderWatchConfig watch
          , siSecurityParam = gpSecurityParam (genesisParams soNetwork)
          }
  wf <- either (die . ("invalid watch set: " <>)) pure (watchFilter watch)
  withStore soDatabase identity $ \store -> do
    stored <- getStartPoint store
    case (stored, soStart <|> startPointPreset soNetwork) of
      (Nothing, Nothing) ->
        die ("no start point is known for " <> show soNetwork <> "; pass --from")
      (Nothing, Just start) -> setStartPoint store start
      (Just _, Just start) | Just _ <- soStart -> setStartPoint store start
      (Just _, _) -> pure ()
    runSync
      (Tracer (emit (hPutStrLn stderr . Text.unpack . renderSyncTrace)))
      SyncConfig
        { scWatchFilter = wf
        , scEraHistory = eraHistory soNetwork
        , scStopAfter = soLimit
        , scProgressEvery = 10
        , scOnUpstreamTip = \_ -> pure ()
        }
      (blockSource cfg soUpstream)
      store

renderSyncTrace :: SyncTrace -> Text
renderSyncTrace = \case
  TraceIntersecting points ->
    "intersecting at " <> Text.intercalate ", " (map renderPoint (take 3 points))
      <> (if length points > 3 then ", ... (" <> showText (length points) <> " points)" else "")
  TraceRolledBack point undone ->
    "rolled back to " <> renderPoint point <> " (" <> showText undone <> " blocks undone)"
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
