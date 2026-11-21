{-# LANGUAGE RecordWildCards #-}

-- | The sync loop: follow a 'BlockSource' from the store's intersection
-- points, extract every block and apply it, and undo blocks on rollback.
--
-- Every applied block also goes, in the same store transaction, through
-- the @maxTxSize@ tripwire scan (proposals and constitutional committee
-- votes) and the nonce driver
-- ("McFollower.EpochData.Driver"); every rollback undoes both (the store
-- drops what the undone blocks produced, the driver returns to its state at
-- the rollback point).
module McFollower.Sync
  ( SyncConfig (..)
  , UpstreamTip (..)
  , SyncTrace (..)
  , Progress (..)
  , SyncStopped (..)
  , SyncEpochData (..)
  , runSync
  ) where

import Cardano.Slotting.Slot (EpochNo (..))
import Control.Exception (Exception, throwIO, try)
import Control.Monad (when)
import Control.Tracer (Tracer, traceWith)
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Data.Time.Clock (NominalDiffTime, UTCTime, diffUTCTime, getCurrentTime)
import Data.Void (absurd)
import Data.Word (Word64)
import McFollower.Block (Block)
import McFollower.BlockSource (BlockSource (..), ChainEvent (..))
import McFollower.EpochData.Driver (DriverState (..), feedBackward, feedForward)
import Cardano.Ledger.Conway.Governance (Vote (..))
import McFollower.EpochData.MaxTxSize
  ( CommitteeVote (..)
  , MaxTxSizeSighting (..)
  , gateFrom
  , scanBlock
  , scanCommitteeVotes
  )
import McFollower.EpochData.Store (EpochDataError, EpochDataStore (..))
import McFollower.EpochNonceTable (NonceTable)
import McFollower.EraHistory (EraHistory)
import McFollower.Extract (BlockRows (..), TxRows (..), extractBlock)
import McFollower.Nonce (Checkpoint (..), EpochNonce (..), NonceConfig, driverTip)
import McFollower.Store (Store, applyBlockWith, intersectionPoints, rollBackTo)
import McFollower.WatchSet (WatchFilter)
import Ouroboros.Consensus.Block (Point, blockPoint, getHeader)
import Ouroboros.Consensus.Cardano.Node ()
import Ouroboros.Consensus.HardFork.History (PastHorizonException)
import Ouroboros.Network.Block (Tip (..), getTipBlockNo)
import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (SlotNo (..), WithOrigin (..))

data SyncConfig = SyncConfig
  { scWatchFilter :: !WatchFilter
  , scEraHistory :: !EraHistory
  , scStopAfter :: !(Maybe Word64)
  -- ^ Stop after applying this many blocks.
  , scProgressEvery :: !NominalDiffTime
  , scOnUpstreamTip :: !(Maybe UpstreamTip -> IO ())
  -- ^ Called with the upstream's tip after each event has been applied to
  -- the store ('Nothing' while the upstream chain is empty).
  , scEpochData :: !SyncEpochData
  }

-- | The nonce driver and tripwire side of the sync loop.
data SyncEpochData = SyncEpochData
  { sedNonceConfig :: !NonceConfig
  , sedNonceTable :: !NonceTable
  , sedDriver :: !(IORef DriverState)
  -- ^ The driver's state, starting from 'McFollower.EpochData.Driver.startDriverState'
  -- and kept up to date by the loop (others may read it).
  }

-- | The upstream's tip as chain-sync last reported it.
data UpstreamTip = UpstreamTip
  { utSlot :: !Word64
  , utBlockNo :: !Word64
  }
  deriving stock (Eq, Show)

-- | Counts since the previous progress report.
data Progress = Progress
  { pSlot :: !Word64
  , pBlockNo :: !(Maybe Word64)
  , pEpoch :: !Word64
  , pUpstreamBlockNo :: !(Maybe Word64)
  , pBlocks :: !Word64
  , pTxs :: !Word64
  , pOutputs :: !Word64
  -- ^ Watched outputs.
  , pSeconds :: !NominalDiffTime
  }
  deriving stock (Show)

data SyncTrace
  = TraceIntersecting ![Point Block]
  | TraceRolledBack !(Point Block) !Int
  -- ^ Blocks undone.
  | TraceProgress !Progress
  | TraceDriverStarted !(Point Block)
  -- ^ The nonce driver started from its trusted state at this block.
  | TraceDriverStopped !(Point Block) !Bool
  -- ^ A rollback to this point went below the driver's start: pending on
  -- its trusted state again ('True'), or off (it is no longer known).
  | TraceEpochNonce !EpochNo !(Point Block)
  -- ^ The driver produced the nonce of an epoch at this block.
  | TraceSightings ![MaxTxSizeSighting]
  -- ^ Proposals that could change @maxTxSize@.
  | TraceCommitteeApproval ![(MaxTxSizeSighting, EpochNo)]
  -- ^ A constitutional committee member voted @Yes@ on these proposals in
  -- the block just applied: each now gates @maxTxSize@ from the epoch
  -- given, unless acknowledged.

data SyncStopped
  = StoppedAfter !Word64
  | SlotOutsideEraHistory !(Point Block) !PastHorizonException
  | EpochDataFailed !(Point Block) !EpochDataError
  -- ^ The nonce driver or the shipped nonce table refused the block or
  -- rollback at this point.
  deriving stock (Show)

instance Exception SyncStopped

data Counters = Counters
  { cSince :: !UTCTime
  , cLast :: !(Maybe BlockRows)
  , cUpstream :: !(Maybe Word64)
  , cBlocks :: !Word64
  , cTxs :: !Word64
  , cOutputs :: !Word64
  , cTotal :: !Word64
  }

-- | Run until the source fails, the handler fails, or 'scStopAfter' blocks
-- were applied (then returns normally).
runSync :: Tracer IO SyncTrace -> SyncConfig -> BlockSource -> Store -> IO ()
runSync tracer SyncConfig {..} source store = do
  points <- intersectionPoints store
  traceWith tracer (TraceIntersecting points)
  now <- getCurrentTime
  countersVar <- newIORef (Counters now Nothing Nothing 0 0 0 0)
  let SyncEpochData {sedNonceConfig, sedNonceTable, sedDriver} = scEpochData
      handler = \case
        RollBackward point tip -> do
          undone <- rollBackTo store point
          before <- readIORef sedDriver
          after <- either (throwIO . EpochDataFailed point) pure (feedBackward point before)
          writeIORef sedDriver after
          case (before, after) of
            (DriverActive {}, DriverPending _) -> traceWith tracer (TraceDriverStopped point True)
            (DriverActive {}, DriverOff) -> traceWith tracer (TraceDriverStopped point False)
            _ -> pure ()
          traceWith tracer (TraceRolledBack point undone)
          noteUpstream countersVar tip
        RollForward blk tip -> do
          rows <- either (throwIO . SlotOutsideEraHistory (blockPoint blk)) pure (extractBlock scWatchFilter scEraHistory blk)
          let epoch = EpochNo (brEpoch rows)
              sightings = scanBlock epoch blk
              votes = scanCommitteeVotes epoch blk
          before <- readIORef sedDriver
          (after, approvals) <- applyBlockWith store rows $ \eds -> do
            storeSightings eds sightings
            storeCommitteeVotes eds votes
            approvals <- committeeApprovals eds votes
            d <-
              feedForward sedNonceConfig sedNonceTable eds (getHeader blk) before
                >>= either (throwIO . EpochDataFailed (blockPoint blk)) pure
            pure (d, approvals)
          writeIORef sedDriver after
          case (before, after) of
            (DriverPending _, DriverActive {}) -> traceWith tracer (TraceDriverStarted (blockPoint blk))
            _ -> pure ()
          case after of
            DriverActive _ d
              | Checkpoint {cpPoint, cpNewEpochNonce = Just en} <- driverTip d
              , cpPoint == blockPoint blk ->
                  traceWith tracer (TraceEpochNonce (enEpoch en) cpPoint)
            _ -> pure ()
          when (not (null sightings)) $ traceWith tracer (TraceSightings sightings)
          when (not (null approvals)) $ traceWith tracer (TraceCommitteeApproval approvals)
          noteUpstream countersVar tip
          total <- recordBlock countersVar rows
          report countersVar False
          when (Just total == scStopAfter) $ do
            report countersVar True
            throwIO (StoppedAfter total)
  try (runBlockSource source points handler) >>= \case
    Left (StoppedAfter _) -> pure ()
    Left e -> throwIO e
    Right v -> absurd v
 where
  -- The sighted proposals a Yes vote of this block is on, with the epoch
  -- they now gate from.
  committeeApprovals eds votes
    | not (any ((== VoteYes) . cvVote) votes) = pure []
    | otherwise = do
        sighted <- loadSightings eds
        stored <- loadCommitteeVotes eds
        let approved s = any (\v -> cvProposal v == mssProposal s && cvVote v == VoteYes) votes
        pure [(s, from) | s <- sighted, approved s, Just from <- [gateFrom stored s]]

  noteUpstream var tip = do
    c <- readIORef var
    writeIORef var c {cUpstream = upstreamBlockNo tip}
    scOnUpstreamTip (upstreamTip tip)

  recordBlock var rows@BlockRows {brTxs} = do
    c@Counters {..} <- readIORef var
    writeIORef
      var
      c
        { cLast = Just rows
        , cBlocks = cBlocks + 1
        , cTxs = cTxs + fromIntegral (length brTxs)
        , cOutputs = cOutputs + fromIntegral (sum (map (length . trOutputs) brTxs))
        , cTotal = cTotal + 1
        }
    pure (cTotal + 1)

  report :: IORef Counters -> Bool -> IO ()
  report var force = do
    now <- getCurrentTime
    c@Counters {..} <- readIORef var
    let elapsed = diffUTCTime now cSince
    case cLast of
      Just BlockRows {..}
        | force || elapsed >= scProgressEvery -> do
            traceWith tracer . TraceProgress $
              Progress
                { pSlot = brSlot
                , pBlockNo = brNumber
                , pEpoch = brEpoch
                , pUpstreamBlockNo = cUpstream
                , pBlocks = cBlocks
                , pTxs = cTxs
                , pOutputs = cOutputs
                , pSeconds = elapsed
                }
            writeIORef var c {cSince = now, cBlocks = 0, cTxs = 0, cOutputs = 0}
      _ -> pure ()

upstreamTip :: Tip Block -> Maybe UpstreamTip
upstreamTip = \case
  TipGenesis -> Nothing
  Tip (SlotNo slot) _ (BlockNo n) -> Just (UpstreamTip slot n)

upstreamBlockNo :: Tip Block -> Maybe Word64
upstreamBlockNo tip = case getTipBlockNo tip of
  Origin -> Nothing
  At (BlockNo n) -> Just n
