module Test.McFollower.Store (tests) where

import Control.Exception (try)
import Control.Monad (forM_)
import Data.ByteString.Short qualified as SBS
import Data.Map.Strict qualified as Map
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
    , testCase "epoch data is written and replaced" epochData
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

epochData :: IO ()
epochData = withTestStore $ \_ store -> do
  putEpochNonce store (EpochNo 3) "nonce3"
  putEpochNonce store (EpochNo 3) "nonce3b"
  putMaxTxSize store (EpochNo 3) 16384
  putPoolStake store (EpochNo 3) (Map.fromList [("pool-b", 2), ("pool-a", maxBound)])
  putPoolStake store (EpochNo 3) (Map.fromList [("pool-c", 1)])
  tables <- dumpTables store
  forM_ tables $ \(name, rows) -> case name of
    "epoch_nonce" -> length rows @?= 1
    "epoch_param" -> length rows @?= 1
    "pool_stake" -> length rows @?= 1
    _ -> pure ()

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
