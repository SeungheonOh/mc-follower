{-# LANGUAGE RecordWildCards #-}

-- | The epoch data producers: fill the store with what no block carries.
--
-- * With a local node (node-to-client): at startup, at every new epoch and
--   every 'pcNodeRefresh' while following, one ledger state query at the
--   node's immutable tip ('McFollower.LocalStateQuery.queryEpochData')
--   gives the stake distributions of epochs @e - 1@, @e@ and @e + 1@ (go,
--   set and mark; complete since the state is immutable), @maxTxSize@ of
--   @e@, and the node's Praos state, which is compared with the nonce
--   driver's checkpoint for the same block. A disagreement is logged at
--   every check and withholds the driver's nonces from serving
--   ('ehNonceDivergence').
--
-- * From a Mithril aggregator (by default in node-to-node mode, optionally
--   with a node for epochs outside its three-epoch window): the stake
--   distributions of a bounded window of epochs, @[e - w, e + 1]@ around the
--   upstream's tip epoch @e@, that are not stored complete yet (label @L@
--   is the distribution for epoch @L + 2@).
--
-- @maxTxSize@ without a node comes from the configured table at serving
-- time ("McFollower.EpochData.Serve"), gated by the sightings the sync loop
-- records.
--
-- Failures (network, node, aggregator) are logged and retried with
-- exponential backoff; they never reach the sync loop, and what they
-- would have produced stays unavailable meanwhile.
module McFollower.EpochData.Producer
  ( ProducerConfig (..)
  , MithrilSource (..)
  , ProducerHealth (..)
  , noProblems
  , runProducers
  ) where

import Cardano.Slotting.Slot (EpochNo (..))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException, SomeException, bracket, displayException, fromException, throwIO, try)
import Control.Monad (filterM, forM_, forever, when)
import Data.Foldable (for_)
import Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef, writeIORef)
import Data.List.NonEmpty (nonEmpty)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (isJust, isNothing)
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Time.Clock (NominalDiffTime, UTCTime, addUTCTime, getCurrentTime)
import Data.Void (Void)
import Data.Word (Word32)
import McFollower.Block (renderPoint)
import McFollower.BlockSource.N2C (LocalNodeConfig)
import McFollower.EpochData.MaxTxSize (MaxTxSizeTable, tableLookup)
import McFollower.EpochData.Mithril (Aggregator (..), fetchStakeForEpoch, labelForStakeEpoch, newMithrilManager)
import McFollower.EpochData.Stake (EpochStake (..))
import McFollower.EpochData.Store (EpochDataStore (..))
import McFollower.LocalStateQuery (NodeEpochData (..), QueryTarget (..), nodeEpochStake, queryEpochData)
import McFollower.Nonce (CrossCheck (..), NonceConfig, crossCheck, resumeDriver)
import McFollower.Store (Store, StoreIdentity, closeStore, openStore, withEpochData)
import Network.HTTP.Client (Manager)

data ProducerConfig = ProducerConfig
  { pcDatabase :: !FilePath
  , pcIdentity :: !StoreIdentity
  , pcNonceConfig :: !NonceConfig
  , pcNode :: !(Maybe LocalNodeConfig)
  -- ^ A local node to query (node-to-client mode).
  , pcMithril :: !(Maybe MithrilSource)
  , pcFirstShelleyEpoch :: !EpochNo
  , pcMaxTxSizeTable :: !MaxTxSizeTable
  -- ^ Compared with the node's values, which win.
  , pcTipEpoch :: !(IO (Maybe EpochNo))
  -- ^ The upstream's current epoch (or the indexer's, before the upstream
  -- reported a tip).
  , pcHealth :: !(IORef ProducerHealth)
  , pcLog :: !(Text -> IO ())
  , pcPoll :: !NominalDiffTime
  -- ^ How often to look for work.
  , pcNodeRefresh :: !NominalDiffTime
  -- ^ How often to query the node within an epoch.
  }

data MithrilSource = MithrilSource
  { msAggregator :: !Aggregator
  , msWindow :: !Word32
  -- ^ How many epochs before the tip epoch to keep stake for.
  }

-- | What the producers report for @GetStatus@ and serving.
data ProducerHealth = ProducerHealth
  { phMissingStake :: ![EpochNo]
  , phNonceDivergence :: !(Maybe Text)
  }
  deriving stock (Eq, Show)

noProblems :: ProducerHealth
noProblems = ProducerHealth [] Nothing

data Retry = Retry
  { rNext :: !UTCTime
  , rFailures :: !Int
  }

data State = State
  { sNode :: !(Maybe Retry)
  -- ^ When to query the node next ('Nothing': now).
  , sNodeEpoch :: !(Maybe EpochNo)
  -- ^ The tip epoch at the last successful node query.
  , sMithril :: !(Map EpochNo Retry)
  -- ^ Epochs whose fetch failed, and when to try again.
  }

-- | Run forever. Uses its own connection to the database.
runProducers :: ProducerConfig -> IO Void
runProducers cfg@ProducerConfig {..} =
  bracket (openStore pcDatabase pcIdentity) closeStore $ \store -> do
    manager <- if isJust pcMithril then Just <$> newMithrilManager else pure Nothing
    stateVar <- newIORef (State Nothing Nothing Map.empty)
    forever $ do
      tipEpoch <- pcTipEpoch
      for_ pcNode $ \node -> step "node query" $ nodeStep cfg store node stateVar tipEpoch
      for_ ((,) <$> pcMithril <*> manager) $ \(ms, m) ->
        step "Mithril" $ mithrilStep cfg store ms m stateVar tipEpoch
      step "status" $ do
        missing <- missingStake cfg store tipEpoch
        atomicModifyIORef' pcHealth (\h -> (h {phMissingStake = missing}, ()))
      threadDelay (round (pcPoll * 1000000))
 where
  -- A failure of one step is logged; the loop goes on.
  step what action =
    try action >>= \case
      Right () -> pure ()
      Left (e :: SomeException)
        | Just (_ :: SomeAsyncException) <- fromException e -> throwIO e
        | otherwise -> pcLog ("epoch data: " <> what <> " failed: " <> Text.pack (displayException e))

nodeStep :: ProducerConfig -> Store -> LocalNodeConfig -> IORef State -> Maybe EpochNo -> IO ()
nodeStep ProducerConfig {..} store node stateVar tipEpoch = do
  now <- getCurrentTime
  st <- readIORef stateVar
  let due = maybe True ((<= now) . rNext) (sNode st) || (isJust tipEpoch && tipEpoch /= sNodeEpoch st)
  when due $
    queryEpochData node AtImmutableTip >>= \case
      Left e -> do
        let failures = maybe 0 rFailures (sNode st) + 1
        pcLog ("epoch data: node query failed (attempt " <> showText failures <> "): " <> showText e)
        writeIORef stateVar st {sNode = Just (Retry (addUTCTime (backoff failures) now) failures)}
      Right ned -> do
        let stakes = nodeEpochStake ned
            EpochNo e = nedEpoch ned
        withEpochData store $ \eds -> do
          mapM_ (storeStake eds) stakes
          storeMaxTxSize eds (nedEpoch ned) (nedMaxTxSize ned)
        case tableLookup pcMaxTxSizeTable (nedEpoch ned) of
          Just v
            | v /= nedMaxTxSize ned ->
                pcLog
                  ( "epoch data: WARNING the node's maxTxSize for epoch " <> showText e <> " is "
                      <> showText (nedMaxTxSize ned) <> ", the configured table says " <> showText v
                      <> "; the node's value is served; update the table for node-to-node use"
                  )
          _ -> pure ()
        pcLog
          ( "epoch data: node at " <> renderPoint (nedPoint ned) <> " (epoch " <> showText e <> "): stake of epochs "
              <> Text.intercalate ", " [showText n | EpochStake {esEpoch = EpochNo n} <- stakes]
              <> ", maxTxSize " <> showText (nedMaxTxSize ned)
          )
        crossCheckNode ned
        writeIORef stateVar st {sNode = Just (Retry (addUTCTime pcNodeRefresh now) 0), sNodeEpoch = tipEpoch}
 where
  crossCheckNode ned = do
    cps <- withEpochData store loadCheckpoints
    case nonEmpty cps of
      Nothing -> pcLog "epoch data: nonce cross-check skipped: the nonce driver has no checkpoints"
      Just stored ->
        case crossCheck (nedPoint ned) (nedProtocolState ned) (resumeDriver pcNonceConfig stored) of
          Agree p -> do
            pcLog ("epoch data: nonce driver agrees with the node at " <> renderPoint p)
            atomicModifyIORef' pcHealth (\h -> (h {phNonceDivergence = Nothing}, ()))
          NotInWindow p ->
            pcLog ("epoch data: nonce cross-check skipped: no driver checkpoint for the node's immutable tip " <> renderPoint p)
          Diverge p fields -> do
            let msg = "at " <> renderPoint p <> ": " <> showText fields
            pcLog ("epoch data: ERROR the nonce driver DIVERGES from the node " <> msg <> "; its nonces are withheld")
            atomicModifyIORef' pcHealth (\h -> (h {phNonceDivergence = Just msg}, ()))

mithrilStep :: ProducerConfig -> Store -> MithrilSource -> Manager -> IORef State -> Maybe EpochNo -> IO ()
mithrilStep cfg@ProducerConfig {..} store MithrilSource {msAggregator} manager stateVar tipEpoch = do
  missing <- missingStake cfg store tipEpoch
  now <- getCurrentTime
  retries <- sMithril <$> readIORef stateVar
  forM_ [e | e <- missing, maybe True ((<= now) . rNext) (Map.lookup e retries), isJust (labelForStakeEpoch e)] $ \e ->
    fetchStakeForEpoch manager msAggregator e >>= \case
      Right es -> do
        withEpochData store (\eds -> storeStake eds es)
        pcLog ("epoch data: stake of epoch " <> epochText e <> " from Mithril (" <> showText (Map.size (esPools es)) <> " pools)")
        atomicModifyIORef' stateVar (\s -> (s {sMithril = Map.delete e (sMithril s)}, ()))
      Left err -> do
        let failures = maybe 0 rFailures (Map.lookup e retries) + 1
        pcLog ("epoch data: Mithril stake of epoch " <> epochText e <> " not obtained (attempt " <> showText failures <> "): " <> showText err)
        atomicModifyIORef' stateVar (\s -> (s {sMithril = Map.insert e (Retry (addUTCTime (backoff failures) now) failures) (sMithril s)}, ()))

-- | Epochs around the tip whose stake the indexer expects and has not
-- stored complete: the Mithril window if there is one, else the node's
-- three epochs.
missingStake :: ProducerConfig -> Store -> Maybe EpochNo -> IO [EpochNo]
missingStake ProducerConfig {..} store = \case
  Nothing -> pure []
  Just (EpochNo e) -> do
    let back = case pcMithril of
          Just MithrilSource {msWindow} -> fromIntegral msWindow
          Nothing -> if isJust pcNode then 1 else 0
        firstExpected = unEpochNo pcFirstShelleyEpoch + if isJust pcMithril then 2 else 0
        window
          | isNothing pcMithril && isNothing pcNode = []
          | otherwise = map EpochNo [max firstExpected (e - min e back) .. e + 1]
    withEpochData store $ \eds -> filterM (fmap isNothing . loadStake eds) window

-- | 30 seconds, doubling, at most 30 minutes.
backoff :: Int -> NominalDiffTime
backoff failures = min 1800 (30 * 2 ^ min 6 (max 0 (failures - 1)))

showText :: Show a => a -> Text
showText = Text.pack . show

epochText :: EpochNo -> Text
epochText (EpochNo e) = showText e
