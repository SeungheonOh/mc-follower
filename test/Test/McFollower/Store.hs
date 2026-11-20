module Test.McFollower.Store (tests) where

import Cardano.Crypto.Hash (hashFromBytes)
import Cardano.Ledger.BaseTypes (Nonce (..), mkNonceFromNumber)
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash (..))
import Control.Exception (try)
import Control.Monad (forM_)
import Data.ByteString qualified as BS
import Data.ByteString.Short qualified as SBS
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.Text qualified as Text
import Data.Word (Word64)
import McFollower.EpochData.MaxTxSize (MaxTxSizeSighting (..), parseProposalRef)
import McFollower.EpochData.Stake (EpochStake (..), StakeSource (..))
import McFollower.EpochData.Store (EpochDataStore (..))
import McFollower.Nonce (Checkpoint (..), EpochNonce (..))
import McFollower.Extract (BlockRows (..), OutRef (..), OutputRow (..), TxRows (..))
import McFollower.Block (Block)
import McFollower.Store
import McFollower.Store.Sql (closeConn, execScript, openConn)
import System.FilePath ((</>))
import System.IO.Temp (withSystemTempDirectory)
import Cardano.Slotting.Slot (EpochNo (..))
import Ouroboros.Consensus.Block (Point (..), SlotNo (..))
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Test.McFollower.Chain
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, assertFailure, testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Store"
    [ testCase "apply then roll back restores the previous state" applyRollback
    , testCase "rolling back to the start point empties the chain" rollbackToStart
    , testCase "re-applying after a rollback gives the same state" reapply
    , testCase "refuses a block that does not extend the tip" notConnected
    , testCase "refuses unknown and too deep rollback points" badRollbacks
    , testCase "intersection points" intersections
    , testCase "reopening checks identity and schema" reopen
    , testCase "refuses foreign and other-version databases" foreignDatabases
    , testCase "epoch data: with blocks, pruned to the volatile window, rolled back" epochData
    ]

pointOf :: BlockRows -> Point Block
pointOf BlockRows {brSlot, brHash} = BlockPoint (SlotNo brSlot) (OneEraHash (SBS.toShort brHash))

-- Blocks 1 to 3, then 4 and 5 which spend outputs of 2 and 4, reveal a new
-- datum, repeat an old one and spend with a recorded input list.
base, extra :: [BlockRows]
base =
  chainFrom
    [ (1, [(tx 1 0) {trOutputs = [output 0 "a" [("p", "", 7)]], trDatums = [("d1", "x1")]}])
    , (2, [(tx 2 0) {trOutputs = [output 0 "a" [("p", "", 5)], output 1 "b" []]}, tx 2 1])
    , (3, [])
    ]
extra =
  chainFrom
    [ (4, [(tx 4 0) {trOutputs = [(output 0 "a" [("p", "n", 1)]) {orDatumHash = Just "d2"}], trDatums = [("d2", "x2"), ("d1", "x1")], trMetadata = [(6500973, "m")]}])
    ,
      ( 5
      ,
        [ (tx 5 0)
            { trSpends = [OutRef (txHash 2 0) 0, OutRef (txHash 4 0) 0, OutRef "unwatched" 3]
            , trOutputs = [output 0 "c" []]
            , trRecordInputs = True
            }
        ]
      )
    ]

applyRollback :: IO ()
applyRollback = withTestStore $ \_ store -> do
  mapM_ (applyBlock store) base
  before <- dumpTables store
  mapM_ (applyBlock store) extra
  during <- dumpTables store
  assertBool "blocks 4 and 5 changed the store" (during /= before)
  undone <- rollBackTo store (pointOf (last base))
  undone @?= 2
  after <- dumpTables store
  after @?= before

rollbackToStart :: IO ()
rollbackToStart = withTestStore $ \_ store -> do
  empty <- dumpTables store
  mapM_ (applyBlock store) (base <> extra)
  _ <- rollBackTo store startPoint
  dumpTables store >>= (@?= empty)

reapply :: IO ()
reapply = withTestStore $ \_ store -> do
  mapM_ (applyBlock store) (base <> extra)
  full <- dumpTables store
  _ <- rollBackTo store (pointOf (head base))
  mapM_ (applyBlock store) (tail base <> extra)
  dumpTables store >>= (@?= full)

notConnected :: IO ()
notConnected = withTestStore $ \_ store -> do
  mapM_ (applyBlock store) base
  before <- dumpTables store
  try (applyBlock store (blockRows 5 [])) >>= \case
    Left NotConnected {} -> pure ()
    other -> assertFailure ("expected NotConnected, got " <> show (fmap (const ()) other))
  dumpTables store >>= (@?= before)

badRollbacks :: IO ()
badRollbacks = withTestStore $ \_ store -> do
  let chain = chainFrom [(n, []) | n <- [1 .. 8]]
  mapM_ (applyBlock store) chain
  try (rollBackTo store (BlockPoint (SlotNo 999) (OneEraHash (SBS.toShort (hash32 0xee 1))))) >>= \case
    Left UnknownRollbackPoint {} -> pure ()
    other -> assertFailure ("expected UnknownRollbackPoint, got " <> show (fmap (const ()) other))
  -- k = 5: undoing blocks 3 to 8 is too deep, undoing 4 to 8 is not.
  try (rollBackTo store (pointOf (chain !! 1))) >>= \case
    Left RollbackTooDeep {} -> pure ()
    other -> assertFailure ("expected RollbackTooDeep, got " <> show (fmap (const ()) other))
  rollBackTo store (pointOf (chain !! 2)) >>= (@?= 5)

intersections :: IO ()
intersections = withTestStore $ \_ store -> do
  intersectionPoints store >>= (@?= [startPoint])
  let chain = chainFrom [(n, []) | n <- [1 .. 10]]
  mapM_ (applyBlock store) chain
  points <- intersectionPoints store
  points @?= map (pointOf . (chain !!) . subtract 1) [10, 9, 8, 6, 2, 1] <> [startPoint]

reopen :: IO ()
reopen = withTestStore $ \path store -> do
  mapM_ (applyBlock store) base
  try (openStore path testIdentity {siNetworkMagic = 7}) >>= \case
    Left WrongNetwork {} -> pure ()
    other -> assertFailure ("expected WrongNetwork, got " <> show (fmap (const ()) other))
  try (openStore path testIdentity {siWatchSet = "other"}) >>= \case
    Left WrongWatchSet {} -> pure ()
    other -> assertFailure ("expected WrongWatchSet, got " <> show (fmap (const ()) other))
  reopened <- openStore path testIdentity
  tipPoint reopened >>= (@?= Just (pointOf (last base)))
  try (setStartPoint reopened (pointOf (head base))) >>= \case
    Left StartPointMismatch {} -> pure ()
    other -> assertFailure ("expected StartPointMismatch, got " <> show (fmap (const ()) other))
  closeStore reopened

-- Made-up checkpoints on made-up blocks 1 to 8 (k = 5): written with the
-- blocks, pruned to the volatile window, undone by rollbacks.
epochData :: IO ()
epochData = withTestStore $ \_ store -> do
  let cp n new = Checkpoint (pointOfBlock n) (madeUpState n) new
      nonce n = mkNonceFromNumber (100 + n)
      newNonce n = case n of
        4 -> Just (EpochNonce (EpochNo 1) (nonce 4))
        7 -> Just (EpochNonce (EpochNo 2) NeutralNonce)
        _ -> Nothing
      proposal = either error id (parseProposalRef (Text.replicate 64 "a" <> "#0"))
      sighting = MaxTxSizeSighting proposal (pointOfBlock 6) 16400 (EpochNo 3)
      load f = withEpochData store f
  withEpochData store $ \eds -> storeCheckpoint eds (cp 0 (Just (EpochNonce (EpochNo 0) (nonce 0))))
  forM_ (chainFrom [(n, []) | n <- [1 .. 8]]) $ \rows -> do
    let n = fromMaybe (error "a numbered block") (brNumber rows)
    applyBlockWith store rows $ \eds -> do
      storeCheckpoint eds (cp n (newNonce n))
      storeSightings eds [sighting | n == 6]
  map cpPoint <$> load loadCheckpoints >>= (@?= map pointOfBlock [3 .. 8])
  load loadCheckpoints >>= (@?= [cp n (newNonce n) | n <- [3 .. 8]])
  mapM (\e -> load (\eds -> loadEpochNonce eds (EpochNo e))) [0, 1, 2, 3] >>= (@?= [Just (nonce 0), Just (nonce 4), Just NeutralNonce, Nothing])
  load loadSightings >>= (@?= [sighting])
  -- A checkpoint for a block that is not stored fails the whole block.
  try (applyBlockWith store (blockRows 9 []) (\eds -> storeCheckpoint eds (cp 10 Nothing))) >>= \case
    Left UnknownEpochDataPoint {} -> pure ()
    other -> assertFailure ("expected UnknownEpochDataPoint, got " <> show (fmap (const ()) other))
  tipPoint store >>= (@?= Just (pointOfBlock 8))
  _ <- rollBackTo store (pointOfBlock 3)
  load loadCheckpoints >>= (@?= [cp 3 Nothing])
  mapM (\e -> load (\eds -> loadEpochNonce eds (EpochNo e))) [0, 1, 2] >>= (@?= [Just (nonce 0), Nothing, Nothing])
  load loadSightings >>= (@?= [])
  -- Stake and maxTxSize are per epoch, not rolled back; a complete
  -- distribution is not replaced by an incomplete one.
  let pool b = KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 b)))
      stake complete pools = EpochStake (EpochNo 3) (Map.fromList pools) complete (FromMithril (EpochNo 1) "cert")
  withEpochData store $ \eds -> storeStake eds (stake False [(pool 1, Coin 5)])
  load (\eds -> loadStake eds (EpochNo 3)) >>= (@?= Nothing)
  withEpochData store $ \eds -> storeStake eds (stake True [(pool 2, Coin 7), (pool 1, Coin (toInteger (maxBound :: Word64)))])
  withEpochData store $ \eds -> storeStake eds (stake False [(pool 3, Coin 1)])
  load (\eds -> loadStake eds (EpochNo 3)) >>= (@?= Just (Map.fromList [(pool 1, Coin (toInteger (maxBound :: Word64))), (pool 2, Coin 7)]))
  withEpochData store $ \eds -> storeMaxTxSize eds (EpochNo 3) 16384 >> storeMaxTxSize eds (EpochNo 3) 16385
  load (\eds -> loadMaxTxSize eds (EpochNo 3)) >>= (@?= Just 16385)
  load (\eds -> loadMaxTxSize eds (EpochNo 4)) >>= (@?= Nothing)
  _ <- rollBackTo store startPoint
  load (\eds -> loadStake eds (EpochNo 3)) >>= (@?= Just (Map.fromList [(pool 1, Coin (toInteger (maxBound :: Word64))), (pool 2, Coin 7)]))
  -- The start point's checkpoint survives a rollback to the start point;
  -- it was pruned here, so none is left.
  load loadCheckpoints >>= (@?= [])
  load (\eds -> loadEpochNonce eds (EpochNo 0)) >>= (@?= Just (nonce 0))

foreignDatabases :: IO ()
foreignDatabases = withSystemTempDirectory "mc-follower-test" $ \dir -> do
  let alien = dir </> "foreign.db"
      newer = dir </> "newer.db"
  conn <- openConn False alien
  execScript conn "CREATE TABLE t (x INTEGER)"
  closeConn conn
  try (openStore alien testIdentity) >>= \case
    Left (IncompatibleSchema 0) -> pure ()
    other -> assertFailure ("expected IncompatibleSchema 0, got " <> show (fmap (const ()) other))
  openStore newer testIdentity >>= closeStore
  conn' <- openConn False newer
  execScript conn' "PRAGMA user_version = 99"
  closeConn conn'
  try (openStore newer testIdentity) >>= \case
    Left (IncompatibleSchema 99) -> pure ()
    other -> assertFailure ("expected IncompatibleSchema 99, got " <> show (fmap (const ()) other))
  try (openStoreReadOnly newer) >>= \case
    Left (IncompatibleSchema 99) -> pure ()
    other -> assertFailure ("expected IncompatibleSchema 99, got " <> show (fmap (const ()) other))
