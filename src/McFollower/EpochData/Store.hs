-- | The storage-facing side of the epoch data: what the nonce driver, the
-- stake sources and the @maxTxSize@ tripwire produce, as a record of
-- operations a store implements, plus an in-memory store for tests.
--
-- A store keeps, keyed by the block that produced them so that a rollback
-- can drop them:
--
-- * one 'Checkpoint' per block in the volatile window (the nonce driver's
--   state after the block, a few hundred bytes), to resume after a restart
--   ('resumeDriver') or roll back;
-- * the epoch nonce, from the checkpoint of the first block of each epoch;
-- * @maxTxSize@ sightings and constitutional committee votes.
--
-- Independently of blocks it keeps per-epoch stake distributions (only
-- complete ones are served), and in node-to-client mode per-epoch
-- @maxTxSize@ read from the node and whether the nonce driver disagrees
-- with the node.
--
-- 'applyChainEvent' is the glue between a block source and the store, and
-- 'epochNonce' what @GetEpochNonce@ serves (shipped table, then driver;
-- see "McFollower.EpochNonceTable").
module McFollower.EpochData.Store
  ( EpochDataStore (..)
  , EpochDataError (..)
  , applyChainEvent
  , recordStart
  , epochNonce
  , supplyNonces
  , suppliedTable

    -- * In memory
  , InMemoryEpochData (..)
  , newInMemoryStore
  ) where

import Cardano.Ledger.BaseTypes (Nonce)
import Cardano.Slotting.Slot (EpochNo)
import Data.Foldable (toList)
import Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Sequence (Seq, (|>))
import Data.Sequence qualified as Seq
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Word (Word32)
import McFollower.Block (Block)
import McFollower.BlockSource (ChainEvent (..))
import McFollower.EpochData.MaxTxSize (CommitteeVote (..), MaxTxSizeSighting (..))
import McFollower.EpochData.Stake (EpochStake (..), PoolStake)
import McFollower.EpochNonceTable
  ( EpochNonceLookup
  , NonceConflict
  , NonceTable
  , SupplyError (..)
  , checkAgainstTable
  , checkSupplied
  , extendTable
  , lookupEpochNonce
  )
import McFollower.Nonce
  ( Checkpoint (..)
  , EpochNonce (..)
  , NonceDriver
  , NonceError
  , applyHeader
  , currentEpochNonce
  , driverTip
  , rollBackTo
  )
import Ouroboros.Consensus.Block (Header, Point)

-- | Operations a store provides for the epoch data.
data EpochDataStore m = EpochDataStore
  { storeCheckpoint :: Checkpoint -> m ()
  -- ^ After each block, in chain order. A checkpoint with
  -- 'cpNewEpochNonce' also records that epoch's nonce.
  , storeSightings :: [MaxTxSizeSighting] -> m ()
  , storeCommitteeVotes :: [CommitteeVote] -> m ()
  -- ^ In transaction order; a later vote of the same voter on the same
  -- proposal in the same block replaces the earlier one.
  , storeStake :: EpochStake -> m ()
  -- ^ Replace the epoch's distribution, unless the stored one is complete
  -- and this one is not.
  , storeMaxTxSize :: EpochNo -> Word32 -> m ()
  , storeRollBack :: Point Block -> m ()
  -- ^ Forget checkpoints, epoch nonces and sightings of the blocks after
  -- the point.
  , loadCheckpoints :: m [Checkpoint]
  -- ^ The kept checkpoints, oldest first.
  , loadEpochNonce :: EpochNo -> m (Maybe Nonce)
  -- ^ The driver's nonce for the epoch, 'Nothing' if it has produced none
  -- ('NeutralNonce' is a value like any other). Serve through
  -- 'epochNonce', which consults the shipped table first.
  , loadStake :: EpochNo -> m (Maybe PoolStake)
  -- ^ Only a complete distribution.
  , loadSightings :: m [MaxTxSizeSighting]
  , loadCommitteeVotes :: m [CommitteeVote]
  -- ^ The votes on sighted proposals, in chain order.
  , loadMaxTxSize :: EpochNo -> m (Maybe Word32)
  , storeSuppliedNonces :: Map EpochNo Nonce -> m ()
  -- ^ Add epoch nonces given at run time; see 'supplyNonces'.
  , loadSuppliedNonces :: m (Map EpochNo Nonce)
  , loadSuppliedNonce :: EpochNo -> m (Maybe Nonce)
  , loadFirstDriverEpoch :: m (Maybe EpochNo)
  -- ^ The earliest epoch the driver has produced a nonce for.
  , storeNonceDivergence :: Maybe Text -> m ()
  -- ^ The outcome of the latest cross-check of the nonce driver against a
  -- local node: what disagreed, or 'Nothing' when they agreed. Kept until
  -- the next check, across restarts.
  , loadNonceDivergence :: m (Maybe Text)
  -- ^ While set, the driver's nonces are not served.
  }

-- | Why feeding the store failed.
data EpochDataError
  = DriverError !NonceError
  | TableConflict !NonceConflict
  -- ^ The driver produced a nonce for an epoch the shipped table covers,
  -- and the two differ. Either the starting state or the table is wrong;
  -- nothing is recorded for the block.
  | TrustedPointNotOnChain !(Point Block) !(Point Block)
  -- ^ The driver waits for the trusted state's point (first), and the sync
  -- reached a block at that slot or later (second) without passing it: the
  -- point is not on the followed chain.
  deriving stock (Show)

-- | Record the trusted starting state: its checkpoint, with the epoch
-- nonce of the epoch it is in (checked against the table).
recordStart :: Monad m => NonceTable -> EpochDataStore m -> NonceDriver -> m (Either EpochDataError ())
recordStart table store driver = case currentEpochNonce driver of
  Left e -> pure (Left (DriverError e))
  Right en -> case checkAgainstTable table en of
    Left c -> pure (Left (TableConflict c))
    Right () -> Right <$> storeCheckpoint store ((driverTip driver) {cpNewEpochNonce = Just en})

-- | Feed one chain event to the nonce driver and record what it produced.
-- The sightings of a forward block are passed in by the caller (they need
-- the block body and its epoch, see 'McFollower.EpochData.MaxTxSize.scanBlock').
-- An epoch nonce the table also has must equal the table's.
applyChainEvent
  :: Monad m
  => NonceTable
  -> EpochDataStore m
  -> ChainEvent Block (Header Block, [MaxTxSizeSighting])
  -> NonceDriver
  -> m (Either EpochDataError NonceDriver)
applyChainEvent table store event driver = case event of
  RollForward (hdr, sightings) _ -> case applyHeader hdr driver of
    Left e -> pure (Left (DriverError e))
    Right (driver', cp) -> case traverse (checkAgainstTable table) (cpNewEpochNonce cp) of
      Left c -> pure (Left (TableConflict c))
      Right _ -> do
        storeCheckpoint store cp
        storeSightings store sightings
        pure (Right driver')
  RollBackward p _ -> case rollBackTo p driver of
    Left e -> pure (Left (DriverError e))
    Right (driver', _) -> do
      storeRollBack store p
      pure (Right driver')

-- | The nonce to serve for an epoch: the shipped table up to its end, the
-- driver's stored nonces after it ('lookupEpochNonce').
epochNonce :: Monad m => NonceTable -> EpochDataStore m -> EpochNo -> m (Either NonceConflict EpochNonceLookup)
epochNonce table store epoch = do
  fromDriver <- loadEpochNonce store epoch
  pure (lookupEpochNonce table fromDriver epoch)

-- | Merge epoch nonces given at run time (an @--epoch-nonces@ file) into
-- the store, on top of the shipped table. Every supplied nonce must agree
-- with any value its epoch already has: in the shipped table, among the
-- nonces supplied before, or produced by the nonce driver; and together
-- they must continue the table without a gap ('checkSupplied'). Nothing is
-- stored if one does not. Returns the table extended by every supplied
-- nonce.
supplyNonces :: Monad m => NonceTable -> EpochDataStore m -> Map EpochNo Nonce -> m (Either SupplyError NonceTable)
supplyNonces table store file = do
  stored <- loadSuppliedNonces store
  case checkSupplied table stored file of
    Left e -> pure (Left e)
    Right new -> do
      fromDriver <- traverse (\(e, n) -> fmap (\d -> (e, d, n)) <$> loadEpochNonce store e) (Map.toAscList file)
      case [SuppliedConflict e "the nonce driver" d n | Just (e, d, n) <- fromDriver, d /= n] of
        c : _ -> pure (Left c)
        [] -> do
          storeSuppliedNonces store new
          pure (Right (extendTable table (Map.union stored file)))

-- | The shipped table extended by the nonces supplied so far.
suppliedTable :: Monad m => NonceTable -> EpochDataStore m -> m NonceTable
suppliedTable table store = extendTable table <$> loadSuppliedNonces store

-- | Everything an in-memory store holds.
data InMemoryEpochData = InMemoryEpochData
  { imCheckpoints :: !(Seq Checkpoint)
  , imEpochNonces :: !(Map EpochNo (Nonce, Point Block))
  , imSightings :: ![MaxTxSizeSighting]
  , imVotes :: ![CommitteeVote]
  , imStake :: !(Map EpochNo EpochStake)
  , imMaxTxSize :: !(Map EpochNo Word32)
  , imNonceDivergence :: !(Maybe Text)
  , imSupplied :: !(Map EpochNo Nonce)
  }
  deriving stock (Show)

-- | A store in an 'IORef', keeping at most the given number of checkpoints
-- (use @k + 1@). Also returns a way to read the whole contents.
newInMemoryStore :: Int -> IO (EpochDataStore IO, IO InMemoryEpochData)
newInMemoryStore keep = do
  ref <- newIORef (InMemoryEpochData Seq.empty Map.empty [] [] Map.empty Map.empty Nothing Map.empty)
  pure (store ref, readIORef ref)
 where
  store :: IORef InMemoryEpochData -> EpochDataStore IO
  store ref =
    EpochDataStore
      { storeCheckpoint = \cp -> modify ref $ \s ->
          s
            { imCheckpoints = trimTo keep (imCheckpoints s |> cp)
            , imEpochNonces = case cpNewEpochNonce cp of
                Nothing -> imEpochNonces s
                Just (EpochNonce e n) -> Map.insert e (n, cpPoint cp) (imEpochNonces s)
            }
      , storeSightings = \ss -> modify ref $ \s -> s {imSightings = imSightings s <> ss}
      , storeCommitteeVotes = \vs -> modify ref $ \s -> s {imVotes = imVotes s <> vs}
      , storeStake = \es -> modify ref $ \s ->
          let keepOld = maybe False (\old -> esComplete old && not (esComplete es)) (Map.lookup (esEpoch es) (imStake s))
           in if keepOld then s else s {imStake = Map.insert (esEpoch es) es (imStake s)}
      , storeMaxTxSize = \e v -> modify ref $ \s -> s {imMaxTxSize = Map.insert e v (imMaxTxSize s)}
      , storeRollBack = \p -> modify ref (rollBack p)
      , loadCheckpoints = toList . imCheckpoints <$> readIORef ref
      , loadEpochNonce = \e -> fmap fst . Map.lookup e . imEpochNonces <$> readIORef ref
      , loadStake = \e -> do
          s <- readIORef ref
          pure $ case Map.lookup e (imStake s) of
            Just es | esComplete es -> Just (esPools es)
            _ -> Nothing
      , loadSightings = imSightings <$> readIORef ref
      , loadCommitteeVotes = do
          s <- readIORef ref
          let sighted = Set.fromList (map mssProposal (imSightings s))
          pure (filter ((`Set.member` sighted) . cvProposal) (imVotes s))
      , loadMaxTxSize = \e -> Map.lookup e . imMaxTxSize <$> readIORef ref
      , storeSuppliedNonces = \ns -> modify ref $ \s -> s {imSupplied = Map.union (imSupplied s) ns}
      , loadSuppliedNonces = imSupplied <$> readIORef ref
      , loadSuppliedNonce = \e -> Map.lookup e . imSupplied <$> readIORef ref
      , loadFirstDriverEpoch = fmap fst . Map.lookupMin . imEpochNonces <$> readIORef ref
      , storeNonceDivergence = \d -> modify ref $ \s -> s {imNonceDivergence = d}
      , loadNonceDivergence = imNonceDivergence <$> readIORef ref
      }

  modify ref f = atomicModifyIORef' ref (\s -> (f s, ()))

  -- Points after the rollback point are those of the checkpoints after it;
  -- whatever they produced goes with them. A point older than the kept
  -- checkpoints leaves only what is known not to be newer: nothing can be
  -- told apart, so everything keyed by a kept or unknown point stays.
  rollBack p s = case Seq.findIndexR ((== p) . cpPoint) (imCheckpoints s) of
    Nothing -> s
    Just i ->
      let (kept, dropped) = Seq.splitAt (i + 1) (imCheckpoints s)
          gone = Set.fromList (map cpPoint (toList dropped))
          survives q = not (q `Set.member` gone)
       in s
            { imCheckpoints = kept
            , imEpochNonces = Map.filter (survives . snd) (imEpochNonces s)
            , imSightings = filter (survives . mssPoint) (imSightings s)
            , imVotes = filter (survives . cvPoint) (imVotes s)
            }

  trimTo n xs = Seq.drop (Seq.length xs - n) xs
