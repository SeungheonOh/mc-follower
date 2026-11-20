-- | The nonce driver's life cycle inside the indexer: whether it runs, and
-- how it starts, resumes, follows the chain and survives rollbacks.
--
-- Chain indexing starts at the watch set's start point, usually long
-- before any point a trusted protocol state is available for, and the
-- driver can only start at the point its trusted state belongs to. So the
-- driver has three states:
--
-- * 'DriverOff': no trusted state. Nonces come from the shipped table only
--   ("McFollower.EpochNonceTable"); later epochs are not available.
-- * 'DriverPending': a trusted state for a point the sync has not reached
--   yet. Blocks before it are indexed without the driver. When the block at
--   that point is applied, the driver starts from the trusted state, in the
--   same transaction as the block ('feedForward'). A block at a later slot
--   arriving first means the point is not on the followed chain: that is
--   an error ('TrustedPointNotOnChain'), never a silent start elsewhere.
-- * 'DriverActive': every applied header goes through the driver; its
--   checkpoint and any epoch nonce it starts are written in the block's
--   transaction.
--
-- At startup ('startDriverState'): stored checkpoints win (the driver
-- resumes exactly where it stopped); otherwise a trusted state at the
-- stored tip starts the driver at once, one after it is pending, and one
-- at or before the tip is refused ('DriverStartError'): the sync has
-- already passed it, and the headers since are not kept to catch up.
module McFollower.EpochData.Driver
  ( DriverState (..)
  , renderDriverState
  , feedForward
  , feedBackward
  , DriverStartError (..)
  , startDriverState
  ) where

import Data.List.NonEmpty (nonEmpty)
import Data.List.NonEmpty qualified as NonEmpty
import Data.Text (Text)
import McFollower.Block (Block, renderPoint)
import McFollower.EpochData.Store
  ( EpochDataError (..)
  , EpochDataStore (..)
  , recordStart
  )
import McFollower.EpochNonceTable (NonceTable, checkAgainstTable)
import McFollower.Nonce
  ( Checkpoint (..)
  , NonceConfig
  , NonceDriver
  , NonceError (..)
  , applyHeader
  , currentEpochNonce
  , driverCheckpoints
  , driverTip
  , resumeDriver
  , rollBackTo
  , startDriver
  )
import McFollower.Nonce.TrustedState (TrustedState (..))
import McFollower.Store (Store, getStartPoint, hasBlock, tipPoint, withEpochData)
import Ouroboros.Consensus.Block (Header, Point, blockSlot, headerPoint, pointSlot, pattern NotOrigin)

-- Orphan instances that make 'Header Block' a 'HasHeader'.
import Ouroboros.Consensus.Cardano.Node ()

data DriverState
  = DriverOff
  | DriverPending !TrustedState
  | DriverActive !(Maybe TrustedState) !NonceDriver
  -- ^ With the trusted state it started from, while that is still known:
  -- a rollback to before it makes the driver pending again.

renderDriverState :: DriverState -> Text
renderDriverState = \case
  DriverOff -> "off (no trusted state; nonces from the shipped table only)"
  DriverPending ts -> "waiting for the sync to reach " <> renderPoint (tsPoint ts)
  DriverActive _ d -> "following, at " <> renderPoint (cpPoint (driverTip d))

-- | The driver's part of applying a block, inside the block's transaction.
-- Sightings are not the driver's business and are recorded by the caller.
feedForward
  :: Monad m
  => NonceConfig
  -> NonceTable
  -> EpochDataStore m
  -> Header Block
  -> DriverState
  -> m (Either EpochDataError DriverState)
feedForward cfg table store hdr = \case
  DriverOff -> pure (Right DriverOff)
  DriverPending ts
    | headerPoint hdr == tsPoint ts ->
        fmap (DriverActive (Just ts)) <$> startRecorded cfg table store ts
    | NotOrigin (blockSlot hdr) >= pointSlot (tsPoint ts) ->
        pure (Left (TrustedPointNotOnChain (tsPoint ts) (headerPoint hdr)))
    | otherwise -> pure (Right (DriverPending ts))
  DriverActive ts d -> case applyHeader hdr d of
    Left e -> pure (Left (DriverError e))
    Right (d', cp) -> case traverse (checkAgainstTable table) (cpNewEpochNonce cp) of
      Left c -> pure (Left (TableConflict c))
      Right _ -> do
        storeCheckpoint store cp
        pure (Right (DriverActive ts d'))

-- | The driver's part of a rollback to a point; the store's rollback has
-- already undone the stored epoch data. A rollback to before the point the
-- driver started from makes it pending on its trusted state again, or off
-- if that state is no longer known (it resumed from checkpoints whose
-- oldest is not the configured trusted state).
feedBackward :: Point Block -> DriverState -> Either EpochDataError DriverState
feedBackward p = \case
  DriverActive ts d -> case rollBackTo p d of
    Right (d', _) -> Right (DriverActive ts d')
    Left e@(RollbackBeyondWindow _ oldest)
      | pointSlot p < pointSlot oldest -> Right $ case ts of
          Just t | tsPoint t == oldest -> DriverPending t
          _ -> DriverOff
      | otherwise -> Left (DriverError e)
    Left e -> Left (DriverError e)
  other -> Right other

-- | Start the driver from a trusted state and record its first
-- checkpoint, which carries the nonce of the epoch the state is in (checked
-- against the table). The driver keeps that checkpoint exactly as stored,
-- so that a driver resumed from the store is the same as one that never
-- stopped.
startRecorded :: Monad m => NonceConfig -> NonceTable -> EpochDataStore m -> TrustedState -> m (Either EpochDataError NonceDriver)
startRecorded cfg table store ts = do
  let d = startDriver cfg ts
  case currentEpochNonce d of
    Left e -> pure (Left (DriverError e))
    Right en ->
      recordStart table store d >>= \case
        Left e -> pure (Left e)
        Right () -> pure (Right (resumeDriver cfg (pure (driverTip d) {cpNewEpochNonce = Just en})))

data DriverStartError
  = CheckpointsOutOfStep !(Point Block) !(Point Block)
  -- ^ The newest stored checkpoint and the stored tip differ.
  | TrustedStateAlreadyPassed !(Point Block) !(Point Block)
  -- ^ The trusted state's point is a stored block (or the start point)
  -- below the tip (second): the sync has passed it.
  | TrustedStateNotOnChain !(Point Block) !(Point Block)
  -- ^ The trusted state's point is not a stored block although the index
  -- covers its slot (the tip is second).
  | TrustedStateBeforeStart !(Point Block) !(Point Block)
  -- ^ The trusted state's point is before the index's start point.
  | StartFailed !EpochDataError
  deriving stock (Show)

-- | The driver's state when the indexer starts, recording the trusted
-- state's checkpoint if it starts at the stored tip.
startDriverState :: NonceConfig -> NonceTable -> Store -> Maybe TrustedState -> IO (Either DriverStartError DriverState)
startDriverState cfg table store trusted = do
  cps <- withEpochData store loadCheckpoints
  tip <- tipPoint store
  start <- getStartPoint store
  case (nonEmpty cps, trusted) of
    (Just stored, _)
      | Just (cpPoint (NonEmpty.last stored)) /= tip ->
          pure (Left (CheckpointsOutOfStep (cpPoint (NonEmpty.last stored)) (maybe (cpPoint (NonEmpty.last stored)) id tip)))
      | otherwise -> do
          let d = resumeDriver cfg stored
              ts = case trusted of
                Just t | tsPoint t == cpPoint (head (driverCheckpoints d)) -> Just t
                _ -> Nothing
          pure (Right (DriverActive ts d))
    (Nothing, Nothing) -> pure (Right DriverOff)
    (Nothing, Just ts) -> case tip of
      Nothing -> pure (Right (DriverPending ts))
      Just t
        | tsPoint ts == t ->
            withEpochData store (\eds -> startRecorded cfg table eds ts) >>= \case
              Left e -> pure (Left (StartFailed e))
              Right d -> pure (Right (DriverActive (Just ts) d))
        | pointSlot (tsPoint ts) > pointSlot t -> pure (Right (DriverPending ts))
        | maybe False (\s -> pointSlot (tsPoint ts) < pointSlot s) start ->
            pure (Left (TrustedStateBeforeStart (tsPoint ts) (maybe t id start)))
        | otherwise -> do
            passed <- (|| start == Just (tsPoint ts)) <$> hasBlock store (tsPoint ts)
            pure . Left $
              if passed
                then TrustedStateAlreadyPassed (tsPoint ts) t
                else TrustedStateNotOnChain (tsPoint ts) t
