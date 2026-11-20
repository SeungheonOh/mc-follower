{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE RecordWildCards #-}

-- | The gRPC server of @proto/mc_follower.proto@, over plain HTTP/2 (no TLS).
--
-- Every handler is a thin adapter over "McFollower.Query": it validates and
-- decodes the request, runs the query against one read snapshot of the store
-- (one SQLite read transaction for the whole call, streams included) and
-- converts the rows. Streamed RPCs send each row as the statement produces
-- it. Each request borrows a read-only connection of its own
-- ("McFollower.Server.Pool").
--
-- Status codes:
--
-- * @INVALID_ARGUMENT@: a malformed request (a hash, policy id or asset name
--   of the wrong length, a missing required message, a limit or offset of
--   2^31 or more).
-- * @FAILED_PRECONDITION@: the request names an address or policy whose
--   outputs the watch set does not index ("McFollower.WatchSet"), so the
--   index cannot answer as db-sync would.
-- * @UNAVAILABLE@: the store cannot be opened (missing, not yet initialised,
--   another network or watch set), no block is indexed yet, or the request
--   names a block number or epoch beyond the indexed tip. Every block number
--   a node sends is derived from earlier answers of this indexer (its latest
--   block or a block found by hash), so a bound beyond the tip means the
--   index lost blocks in between (a rollback), and answering with what is
--   indexed would silently drop rows. Also: epoch data the indexer does not
--   know yet (an epoch nonce or stake distribution it expects to obtain, a
--   @maxTxSize@ gated by an unacknowledged proposal); see
--   "McFollower.EpochData.Serve".
-- * @INTERNAL@: anything else.
--
-- Absent rows are ordinary responses: unset optional fields or empty
-- streams.
module McFollower.Server
  ( -- * Configuration
    ServerConfig (..)
  , SyncStatus (..)
  , notFollowing

    -- * Running
  , withServer
  , interruptOnTerminate
  ) where

import Control.Concurrent (myThreadId, throwTo)
import Control.Exception
  ( AsyncException (UserInterrupt)
  , SomeAsyncException
  , SomeException
  , catch
  , displayException
  , finally
  , fromException
  , throwIO
  , toException
  , try
  )
import Control.Monad (unless, when)
import Data.Bits (shiftR, (.&.))
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Base16 qualified as Base16
import Data.ProtoLens.Labels ()
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import Data.Word (Word16, Word32, Word64)
import Cardano.Slotting.Slot (EpochNo (..))
import McFollower.EpochData.Serve
  ( EpochAnswer (..)
  , EpochDataConfig (..)
  , EpochHealth (..)
  , answerEpochNonce
  , answerMaxTxSize
  , answerStake
  )
import McFollower.EpochData.Store (EpochDataStore (..))
import McFollower.Query qualified as Q
import McFollower.Server.Pool (Pool, closePool, newPool, withPooled)
import McFollower.Server.Proto qualified as P
import McFollower.Store (Snapshot, StoreIdentity (..), checkIdentity, closeStore, openStoreReadOnly, snapshotEpochData, withSnapshot)
import McFollower.Sync (UpstreamTip (..))
import McFollower.WatchSet (BridgeWatch (..), WatchConfig (..), isWatchedAddress, isWatchedPolicy, recordsInputLists)
import Network.GRPC.Common (GrpcError (..), GrpcException (..), NextElem (..), def)
import Network.GRPC.Common.Protobuf (Proto (..), defMessage, getProto, (&), (.~), (^.))
import Network.GRPC.Server (RequestHandler, ServerParams (..), SomeRpcHandler, mkGrpcServer)
import Network.GRPC.Server.Protobuf (ProtobufMethodsOf)
import Network.GRPC.Server.Run (InsecureConfig (..), forkServer, getServerPort)
import Network.GRPC.Server.Run qualified as Run
import Network.GRPC.Server.StreamType (Methods (..), fromMethods, mkNonStreaming, mkServerStreaming)
import Network.Socket (HostName, PortNumber)
import System.Posix.Signals (Handler (..), installHandler, sigTERM)

-- | What the server serves, and where.
data ServerConfig = ServerConfig
  { svHost :: !HostName
  , svPort :: !PortNumber
  -- ^ 0 picks a free port ('withServer' passes the one bound).
  , svDatabase :: !FilePath
  , svIdentity :: !StoreIdentity
  -- ^ The store must have been created for this network and watch set;
  -- 'siSecurityParam' is the @k@ reported by @GetStatus@.
  , svWatch :: !WatchConfig
  , svConnections :: !Int
  -- ^ At most this many requests are answered at once.
  , svSyncStatus :: !(IO SyncStatus)
  , svEpochData :: !EpochDataConfig
  , svLog :: !(Text -> IO ())
  -- ^ Requests that failed other than with a status the server chose
  -- (internal errors, disconnects).
  }

-- | The sync loop's view of the upstream, for @GetStatus@.
data SyncStatus = SyncStatus
  { ssFollowing :: !Bool
  -- ^ A sync loop runs in this process.
  , ssUpstreamTip :: !(Maybe UpstreamTip)
  -- ^ As last reported by chain-sync; 'Nothing' before the first exchange.
  }

-- | No sync loop: the server only serves what the database holds.
notFollowing :: SyncStatus
notFollowing = SyncStatus False Nothing

-- | Run the server while an action runs; the action gets the bound port.
-- Requests still running when the action returns are cancelled.
withServer :: ServerConfig -> (PortNumber -> IO a) -> IO a
withServer cfg@ServerConfig {..} k = do
  pool <- newPool svConnections openStore
  server <- mkGrpcServer def {serverTopLevel = topLevel} (handlers (Env cfg pool))
  forkServer
    def
    Run.ServerConfig
      { Run.serverInsecure = Just (InsecureConfig (Just svHost) svPort)
      , Run.serverSecure = Nothing
      }
    server
    (\running -> getServerPort running >>= k)
    `finally` closePool pool
 where
  -- grapesy's default logs every exception, including the statuses the
  -- handlers answer with on purpose.
  topLevel :: RequestHandler () -> RequestHandler ()
  topLevel h unmask req resp =
    h unmask req resp `catch` \(e :: SomeException) -> case fromException e of
      Just GrpcException {grpcError} | grpcError /= GrpcInternal -> pure ()
      _ -> svLog ("request failed: " <> Text.pack (displayException e))
  openStore =
    try (openStoreReadOnly svDatabase) >>= \case
      Left e -> unavailable ("the index cannot be opened: " <> showException e)
      Right store ->
        try (checkIdentity store svIdentity) >>= \case
          Left e -> closeStore store >> unavailable ("the index cannot be used: " <> showException e)
          Right () -> pure store

-- | Make SIGTERM interrupt the calling thread as SIGINT does (with
-- 'UserInterrupt'), so that a server stops the same way on either.
interruptOnTerminate :: IO ()
interruptOnTerminate = do
  thread <- myThreadId
  _ <- installHandler sigTERM (Catch (throwTo thread UserInterrupt)) Nothing
  pure ()

data Env = Env
  { envConfig :: !ServerConfig
  , envPool :: !Pool
  }

handlers :: Env -> [SomeRpcHandler IO]
handlers env = fromMethods methods
 where
  -- In the order of the service's methods in the generated code (by name).
  methods :: Methods IO (ProtobufMethodsOf P.McFollower)
  methods =
    Method (mkServerStreaming (streaming getAssetCreates))
      . Method (mkServerStreaming (streaming getAssetSpends))
      . Method (mkNonStreaming (unary getBlockByHash))
      . Method (mkServerStreaming (streaming getBlocksByNumberRange))
      . Method (mkServerStreaming (streaming getBridgeTxs))
      . Method (mkNonStreaming (unary getEpochNonce))
      . Method (mkNonStreaming (unary getHighestBlockInWindow))
      . Method (mkNonStreaming (unary getLatestBlock))
      . Method (mkNonStreaming (unary getLatestBlockForEpoch))
      . Method (mkNonStreaming (unary getLatestGovernanceOutput))
      . Method (mkNonStreaming (unary getLatestStableEpoch))
      . Method (mkNonStreaming (unary getLatestTokenOutputForEpoch))
      . Method (mkServerStreaming (streaming getMappingDeregistrations))
      . Method (mkServerStreaming (streaming getMappingRegistrations))
      . Method (mkNonStreaming (unary getMaxTxSize))
      . Method (mkServerStreaming (streaming getStakeDistribution))
      . Method (mkNonStreaming (unary getStatus))
      . Method (mkNonStreaming (unary getTxPosition))
      . Method (mkServerStreaming (streaming getUnspentOutputsAtAddress))
      $ NoMoreMethods

  unary :: (Env -> req -> IO resp) -> Proto req -> IO (Proto resp)
  unary h req = internalErrors (Proto <$> h env (getProto req))

  streaming :: (Env -> req -> (resp -> IO ()) -> IO ()) -> Proto req -> (NextElem (Proto resp) -> IO ()) -> IO ()
  streaming h req send = internalErrors $ do
    h env (getProto req) (send . NextElem . Proto)
    send NoNextElem

-- | Report an unexpected exception as @INTERNAL@; status exceptions and
-- cancellation pass through.
internalErrors :: IO a -> IO a
internalErrors action =
  action `catch` \(e :: SomeException) -> case () of
    _
      | Just (_ :: GrpcException) <- fromException e -> throwIO e
      | Just (_ :: SomeAsyncException) <- fromException e -> throwIO e
      | otherwise -> failWith GrpcInternal (showException e)

showException :: SomeException -> Text
showException = Text.pack . show

failWith :: GrpcError -> Text -> IO a
failWith code message = throwIO (toException (GrpcException code (Just message) Nothing []))

unavailable, invalid, notIndexed :: Text -> IO a
unavailable = failWith GrpcUnavailable
invalid = failWith GrpcInvalidArgument
notIndexed = failWith GrpcFailedPrecondition

{-------------------------------------------------------------------------------
  Reading
-------------------------------------------------------------------------------}

-- | Run reads against one snapshot.
reading :: Env -> (Snapshot -> IO a) -> IO a
reading Env {envPool} f = withPooled envPool (`withSnapshot` f)

-- | Run reads against one snapshot of an index that has at least one block,
-- given its tip.
answering :: Env -> (Q.BlockInfo -> Snapshot -> IO a) -> IO a
answering env f =
  reading env $ \snap ->
    Q.getLatestBlock snap >>= \case
      Nothing -> unavailable "no block is indexed yet"
      Just tip -> f tip snap

-- | A block number bound must not exceed the tip.
withinTip :: Q.BlockInfo -> Text -> Word32 -> IO ()
withinTip Q.BlockInfo {biNumber} what n =
  when (n > biNumber) $
    unavailable (what <> " is block " <> showText n <> " but the index ends at block " <> showText biNumber)

-- | An epoch bound must not exceed the tip's epoch.
withinTipEpoch :: Q.BlockInfo -> Word32 -> IO ()
withinTipEpoch Q.BlockInfo {biEpoch} e =
  when (e > biEpoch) $
    unavailable ("epoch " <> showText e <> " is beyond the index, which ends in epoch " <> showText biEpoch)

{-------------------------------------------------------------------------------
  Request validation
-------------------------------------------------------------------------------}

required :: Text -> Maybe a -> IO a
required what = maybe (invalid ("missing " <> what)) pure

bytesOfLength :: Int -> Text -> ByteString -> IO ByteString
bytesOfLength n what bytes = do
  unless (BS.length bytes == n) $
    invalid (what <> " has " <> showText (BS.length bytes) <> " bytes, expected " <> showText n)
  pure bytes

hash32 :: Text -> ByteString -> IO ByteString
hash32 = bytesOfLength 32

policyId :: ByteString -> IO ByteString
policyId = bytesOfLength 28 "policy id"

assetId :: Text -> Maybe P.AssetId -> IO Q.AssetId
assetId what msg = do
  asset <- required what msg
  policy <- policyId (asset ^. #policyId)
  let name = asset ^. #assetName
  when (BS.length name > 32) $ invalid (what <> " name has " <> showText (BS.length name) <> " bytes, at most 32")
  pure (Q.AssetId policy name)

watchedAddress :: Env -> Text -> IO ()
watchedAddress env address =
  unless (isWatchedAddress (svWatch (envConfig env)) address) $
    notIndexed ("address " <> address <> " is not indexed")

watchedPolicy :: Env -> ByteString -> IO ()
watchedPolicy env policy =
  unless (isWatchedPolicy (svWatch (envConfig env)) policy) $
    notIndexed ("policy " <> hexText policy <> " is not indexed")

window :: Maybe P.PositionWindow -> IO Q.Window
window msg = do
  w <- required "window" msg
  Q.Window
    <$> (position <$> required "window start" (w ^. #maybe'fromInclusive))
    <*> (position <$> required "window end" (w ^. #maybe'toExclusive))

position :: P.Position -> Q.Position
position p = Q.Position (p ^. #blockNo) (p ^. #txIndex)

page :: Word32 -> Word32 -> IO Q.Page
page limit offset = do
  when (limit >= 2 ^ (31 :: Int)) $ invalid "limit must be below 2^31"
  when (offset >= 2 ^ (31 :: Int)) $ invalid "offset must be below 2^31"
  pure (Q.Page limit offset)

{-------------------------------------------------------------------------------
  Handlers
-------------------------------------------------------------------------------}

getStatus :: Env -> P.GetStatusRequest -> IO P.GetStatusResponse
getStatus env@Env {envConfig = ServerConfig {..}} _ = do
  let k = siSecurityParam svIdentity
  Q.IndexStatus {..} <- reading env (Q.getIndexStatus (fromIntegral k))
  SyncStatus {..} <- svSyncStatus
  EpochHealth {ehMissingStake} <- edcHealth svEpochData
  let behind = ssFollowing && maybe True (\up -> maybe True ((< utBlockNo up) . fromIntegral . Q.biNumber) isTip) ssUpstreamTip
      -- Stake distributions being fetched are backfills in the proto's
      -- sense: GetStakeDistribution for them answers UNAVAILABLE.
      stakeBackfills = ["stake-distribution:epoch:" <> showText e | EpochNo e <- ehMissingStake]
      syncing = behind || not (null stakeBackfills)
  pure $
    defMessage
      & #maybe'tip .~ fmap block isTip
      & #maybe'immutableTip .~ fmap block isImmutableTip
      & #securityParameter .~ fromIntegral k
      & #syncing .~ syncing
      & #maybe'upstreamTipSlot .~ fmap utSlot ssUpstreamTip
      & #maybe'upstreamTipBlockNo .~ fmap (fromIntegral . utBlockNo) ssUpstreamTip
      & #maybe'startBlock .~ fmap block isStartBlock
      & #backfilling .~ stakeBackfills
      & #networkMagic .~ siNetworkMagic svIdentity

getLatestBlock :: Env -> P.GetLatestBlockRequest -> IO P.OptionalBlock
getLatestBlock env _ = answering env $ \tip _ -> pure (optionalBlock (Just tip))

getBlocksByNumberRange :: Env -> P.GetBlocksByNumberRangeRequest -> (P.Block -> IO ()) -> IO ()
getBlocksByNumberRange env req send = do
  let from = req ^. #fromBlockNo
      to = req ^. #toBlockNo
  answering env $ \tip snap -> when (from <= to) $ do
    withinTip tip "the range end" to
    Q.eachBlockByNumberRange from to snap (send . block)

getHighestBlockInWindow :: Env -> P.GetHighestBlockInWindowRequest -> IO P.OptionalBlock
getHighestBlockInWindow env req =
  answering env $ \tip snap -> do
    withinTip tip "the window's highest block" (req ^. #maxBlockNo)
    optionalBlock
      <$> Q.getHighestBlockInWindow
        Q.HighestBlockWindow
          { hbMaxBlock = req ^. #maxBlockNo
          , hbMinSlot = req ^. #minSlot
          , hbMaxSlot = req ^. #maxSlot
          , hbMinTimeMillis = req ^. #minTimeUnixMillis
          , hbMaxTimeMillis = req ^. #maxTimeUnixMillis
          }
        snap

getBlockByHash :: Env -> P.GetBlockByHashRequest -> IO P.OptionalBlock
getBlockByHash env req = do
  hash <- hash32 "block hash" (req ^. #hash)
  answering env $ \_ snap -> optionalBlock <$> Q.getBlockByHash hash snap

getTxPosition :: Env -> P.GetTxPositionRequest -> IO P.GetTxPositionResponse
getTxPosition env req = do
  hash <- hash32 "tx hash" (req ^. #txHash)
  answering env $ \_ snap -> do
    pos <- Q.getTxPosition hash snap
    pure (defMessage & #maybe'position .~ fmap positionMessage pos)

getBridgeTxs :: Env -> P.GetBridgeTxsRequest -> (P.BridgeTxRow -> IO ()) -> IO ()
getBridgeTxs env req send = do
  token <- assetId "token" (req ^. #maybe'token)
  lower <-
    required "lower bound" (req ^. #maybe'lower) <&> \case
      P.GetBridgeTxsRequest'AfterBlockNo n -> Q.AfterBlock n
      P.GetBridgeTxsRequest'AfterPosition p -> Q.AfterPosition (position p)
      P.GetBridgeTxsRequest'FromPosition p -> Q.FromPosition (position p)
  let ics = req ^. #icsAddress
      reserve = req ^. #reserveAddress
      toBlock = req ^. #toBlockNo
  watchedAddress env ics
  watchedAddress env reserve
  answering env $ \tip snap -> do
    withinTip tip "the upper bound" toBlock
    Q.eachBridgeTx
      (bridgeLabel env)
      Q.BridgeTxsRequest
        { btrIcsAddress = ics
        , btrReserveAddress = reserve
        , btrToken = token
        , btrLower = lower
        , btrToBlock = toBlock
        , btrMaxTxs = req ^. #maybe'maxTxs
        }
      snap
      (\row -> bridgeTxRow row >>= send)
 where
  (<&>) = flip fmap

getLatestBlockForEpoch :: Env -> P.GetLatestBlockForEpochRequest -> IO P.OptionalBlock
getLatestBlockForEpoch env req =
  answering env $ \tip snap -> do
    withinTipEpoch tip (req ^. #epochNo)
    optionalBlock <$> Q.getLatestBlockForEpoch (req ^. #epochNo) snap

getLatestStableEpoch :: Env -> P.GetLatestStableEpochRequest -> IO P.GetLatestStableEpochResponse
getLatestStableEpoch env req =
  answering env $ \_ snap -> do
    epoch <- Q.getLatestStableEpoch (req ^. #securityParameter) snap
    pure (defMessage & #maybe'epochNo .~ epoch)

getStakeDistribution :: Env -> P.GetStakeDistributionRequest -> (P.StakePoolEntry -> IO ()) -> IO ()
getStakeDistribution env req send =
  answering env $ \_ snap -> do
    let epoch = EpochNo (fromIntegral (req ^. #epochNo))
        EpochDataConfig {edcFirstShelleyEpoch} = svEpochData (envConfig env)
    stored <- loadStake (snapshotEpochData snap) epoch
    rows <- epochAnswer (answerStake edcFirstShelleyEpoch stored epoch)
    mapM_ (\(pool, stake) -> send (defMessage & #poolHash .~ pool & #stake .~ stake)) rows

getLatestTokenOutputForEpoch :: Env -> P.GetLatestTokenOutputForEpochRequest -> IO P.GetLatestTokenOutputForEpochResponse
getLatestTokenOutputForEpoch env req = do
  asset <- assetId "asset" (req ^. #maybe'asset)
  watchedPolicy env (Q.assetPolicy asset)
  answering env $ \tip snap -> do
    withinTipEpoch tip (req ^. #epochNo)
    out <- Q.getLatestTokenOutputForEpoch asset (req ^. #epochNo) snap
    pure (defMessage & #maybe'output .~ fmap tokenOutput out)
 where
  tokenOutput Q.TokenOutput {..} =
    defMessage
      & #originTxHash .~ toTxHash
      & #utxoIndex .~ outputIndex toIndex
      & #txEpochNo .~ toEpoch
      & #txBlockNo .~ toBlockNo
      & #txSlotNo .~ toSlot
      & #txBlockIndex .~ toTxIndex
      & #maybe'datum .~ fmap datum toDatum

getEpochNonce :: Env -> P.GetEpochNonceRequest -> IO P.GetEpochNonceResponse
getEpochNonce env req =
  answering env $ \_ snap -> do
    let epoch = EpochNo (fromIntegral (req ^. #epochNo))
        EpochDataConfig {edcNonceTable, edcHealth} = svEpochData (envConfig env)
    EpochHealth {ehNonceDivergence} <- edcHealth
    fromDriver <- loadEpochNonce (snapshotEpochData snap) epoch
    nonce <- epochAnswer (answerEpochNonce edcNonceTable ehNonceDivergence fromDriver epoch)
    pure (defMessage & #maybe'nonce .~ nonce)

getUnspentOutputsAtAddress :: Env -> P.GetUnspentOutputsAtAddressRequest -> (P.AddressOutputRow -> IO ()) -> IO ()
getUnspentOutputsAtAddress env req send = do
  let address = req ^. #address
  watchedAddress env address
  unless (recordsInputLists (svWatch (envConfig env)) address) $
    notIndexed ("the input lists of transactions creating outputs at " <> address <> " are not indexed")
  answering env $ \tip snap -> do
    withinTip tip "the bound" (req ^. #blockNo)
    Q.eachUnspentOutputAtAddress address (req ^. #blockNo) snap $ \Q.AddressOutput {..} ->
      send $
        defMessage
          & #utxoTxHash .~ aoTxHash
          & #utxoIndex .~ outputIndex aoIndex
          & #txBlockNo .~ aoBlockNo
          & #txSlotNo .~ aoSlot
          & #txEpochNo .~ aoEpoch
          & #txIndexInBlock .~ aoTxIndex
          & #address .~ aoAddress
          & #maybe'datum .~ fmap datum aoDatum
          & #txInputs .~ map outputRef aoInputs

getMappingRegistrations :: Env -> P.GetMappingRegistrationsRequest -> (P.RegistrationRow -> IO ()) -> IO ()
getMappingRegistrations env req send = do
  let address = req ^. #mappingValidatorAddress
  authToken <- assetId "auth token" (req ^. #maybe'authToken)
  w <- window (req ^. #maybe'window)
  p <- page (req ^. #limit) (req ^. #offset)
  watchedAddress env address
  answering env $ \tip snap -> do
    withinTip tip "the window end" (Q.posBlock (Q.wTo w))
    Q.eachMappingRegistration address authToken w p snap $ \Q.RegistrationRow {..} ->
      send $
        defMessage
          & #datum .~ datum rgDatum
          & #blockNo .~ rgBlockNo
          & #blockHash .~ rgBlockHash
          & #blockTimeUnixMillis .~ rgBlockTimeMillis
          & #txIndex .~ rgTxIndex
          & #txHash .~ rgTxHash
          & #utxoIndex .~ outputIndex rgIndex

getMappingDeregistrations :: Env -> P.GetMappingDeregistrationsRequest -> (P.DeregistrationRow -> IO ()) -> IO ()
getMappingDeregistrations env req send = do
  let address = req ^. #mappingValidatorAddress
  w <- window (req ^. #maybe'window)
  p <- page (req ^. #limit) (req ^. #offset)
  watchedAddress env address
  answering env $ \tip snap -> do
    withinTip tip "the window end" (Q.posBlock (Q.wTo w))
    Q.eachMappingDeregistration address w p snap $ \Q.DeregistrationRow {..} ->
      send $
        defMessage
          & #datum .~ datum drDatum
          & #blockNo .~ drBlockNo
          & #blockHash .~ drBlockHash
          & #blockTimeUnixMillis .~ drBlockTimeMillis
          & #txIndex .~ drTxIndex
          & #txHash .~ drTxHash
          & #utxoTxHash .~ Q.refTxHash drSpent
          & #utxoIndex .~ outputIndex (Q.refIndex drSpent)

getAssetCreates :: Env -> P.GetAssetCreatesRequest -> (P.AssetCreateRow -> IO ()) -> IO ()
getAssetCreates env req send = do
  asset <- assetId "asset" (req ^. #maybe'asset)
  w <- window (req ^. #maybe'window)
  p <- page (req ^. #limit) (req ^. #offset)
  watchedPolicy env (Q.assetPolicy asset)
  answering env $ \tip snap -> do
    withinTip tip "the window end" (Q.posBlock (Q.wTo w))
    Q.eachAssetCreate asset w p snap $ \Q.AssetCreateRow {..} ->
      send $
        defMessage
          & #blockNo .~ acBlockNo
          & #blockHash .~ acBlockHash
          & #blockTimeUnixMillis .~ acBlockTimeMillis
          & #txIndex .~ acTxIndex
          & #quantity .~ acQuantity
          & #holderAddress .~ acHolderAddress
          & #txHash .~ acTxHash
          & #utxoIndex .~ outputIndex acIndex

getAssetSpends :: Env -> P.GetAssetSpendsRequest -> (P.AssetSpendRow -> IO ()) -> IO ()
getAssetSpends env req send = do
  asset <- assetId "asset" (req ^. #maybe'asset)
  w <- window (req ^. #maybe'window)
  p <- page (req ^. #limit) (req ^. #offset)
  watchedPolicy env (Q.assetPolicy asset)
  answering env $ \tip snap -> do
    withinTip tip "the window end" (Q.posBlock (Q.wTo w))
    Q.eachAssetSpend asset w p snap $ \Q.AssetSpendRow {..} ->
      send $
        defMessage
          & #blockNo .~ asBlockNo
          & #blockHash .~ asBlockHash
          & #blockTimeUnixMillis .~ asBlockTimeMillis
          & #txIndex .~ asTxIndex
          & #quantity .~ asQuantity
          & #holderAddress .~ asHolderAddress
          & #utxoTxHash .~ Q.refTxHash asSpent
          & #utxoIndex .~ outputIndex (Q.refIndex asSpent)
          & #spendingTxHash .~ asSpendingTxHash

getMaxTxSize :: Env -> P.GetMaxTxSizeRequest -> IO P.GetMaxTxSizeResponse
getMaxTxSize env req =
  answering env $ \tip snap -> do
    withinTip tip "the block" (req ^. #blockNo)
    let EpochDataConfig {edcMaxTxSize, edcAcknowledged} = svEpochData (envConfig env)
        eds = snapshotEpochData snap
    size <-
      Q.getBlockEpoch (req ^. #blockNo) snap >>= \case
        -- db-sync: no block, no row.
        Nothing -> pure Nothing
        Just e -> do
          let epoch = EpochNo (fromIntegral e)
          fromNode <- loadMaxTxSize eds epoch
          sightings <- loadSightings eds
          epochAnswer (answerMaxTxSize edcMaxTxSize edcAcknowledged sightings fromNode epoch)
    pure (defMessage & #maybe'maxTxSize .~ size)

getLatestGovernanceOutput :: Env -> P.GetLatestGovernanceOutputRequest -> IO P.GetLatestGovernanceOutputResponse
getLatestGovernanceOutput env req = do
  let address = req ^. #address
  policy <- policyId (req ^. #policyId)
  watchedAddress env address
  answering env $ \tip snap -> do
    withinTip tip "the bound" (req ^. #blockNo)
    out <- Q.getLatestGovernanceOutput address policy (req ^. #blockNo) snap
    pure (defMessage & #maybe'output .~ fmap governanceOutput out)
 where
  governanceOutput Q.GovernanceOutput {..} =
    defMessage
      & #datum .~ datum goDatum
      & #blockNo .~ goBlockNo
      & #blockHash .~ goBlockHash
      & #txIndex .~ goTxIndex
      & #txHash .~ goTxHash
      & #utxoIndex .~ outputIndex goIndex

-- | An epoch data answer, or the status it calls for.
epochAnswer :: EpochAnswer a -> IO a
epochAnswer = \case
  Answer a -> pure a
  NotAvailable why -> unavailable why
  Inconsistent why -> failWith GrpcInternal why

{-------------------------------------------------------------------------------
  Rows to messages
-------------------------------------------------------------------------------}

block :: Q.BlockInfo -> P.Block
block Q.BlockInfo {..} =
  defMessage
    & #blockNo .~ biNumber
    & #hash .~ biHash
    & #epochNo .~ biEpoch
    & #slotNo .~ biSlot
    & #timeUnixSeconds .~ biTime
    & #txCount .~ biTxCount

optionalBlock :: Maybe Q.BlockInfo -> P.OptionalBlock
optionalBlock b = defMessage & #maybe'block .~ fmap block b

positionMessage :: Q.Position -> P.Position
positionMessage (Q.Position b t) = defMessage & #blockNo .~ b & #txIndex .~ t

datum :: ByteString -> P.Datum
datum cbor = defMessage & #cbor .~ cbor

outputIndex :: Word16 -> Word32
outputIndex = fromIntegral

outputRef :: Q.OutRef -> P.OutputRef
outputRef ref = defMessage & #txHash .~ Q.refTxHash ref & #index .~ outputIndex (Q.refIndex ref)

bridgeTxRow :: Q.BridgeTxRow -> IO P.BridgeTxRow
bridgeTxRow Q.BridgeTxRow {..} = do
  bridgeIn <- uint128 "bridge_in" btBridgeIn
  bridgeOut <- uint128 "bridge_out" btBridgeOut
  reserveIn <- uint128 "reserve_in" btReserveIn
  reserveOut <- uint128 "reserve_out" btReserveOut
  pure $
    defMessage
      & #blockNo .~ Q.posBlock btPosition
      & #txIndex .~ Q.posTx btPosition
      & #txHash .~ btTxHash
      & #maybe'c2mMetadatumCbor .~ btMetadatum
      & #bridgeIn .~ bridgeIn
      & #bridgeOut .~ bridgeOut
      & #reserveIn .~ reserveIn
      & #reserveOut .~ reserveOut

-- | A sum that the wire carries as two 64-bit halves; always set.
uint128 :: Text -> Integer -> IO P.Uint128
uint128 what n
  | n < 0 || n >= 2 ^ (128 :: Int) = failWith GrpcOutOfRange (what <> " " <> showText n <> " does not fit 128 bits")
  | otherwise =
      pure (defMessage & #hi .~ fromInteger (n `shiftR` 64) & #lo .~ fromInteger (n .&. (2 ^ (64 :: Int) - 1)))

bridgeLabel :: Env -> Word64
bridgeLabel = bwMetadataLabel . wcBridge . svWatch . envConfig

{-------------------------------------------------------------------------------
  Rendering
-------------------------------------------------------------------------------}

showText :: Show a => a -> Text
showText = Text.pack . show

hexText :: ByteString -> Text
hexText = Text.decodeLatin1 . Base16.encode
