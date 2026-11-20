module Test.McFollower.Pending (tests) where

import McFollower.Block (Block)
import McFollower.BlockSource (ChainEvent (..))
import McFollower.BlockSource.N2N.Pending (Announced (..), Pending)
import McFollower.BlockSource.N2N.Pending qualified as Pending
import Ouroboros.Network.Block (Point)
import Ouroboros.Network.Protocol.BlockFetch.Type (ChainRange (..))
import Test.McFollower.Points (point, tip)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

-- | The header is represented by its own point.
type Event = ChainEvent Block (Point Block)

forward :: Int -> Event
forward n = RollForward (point n) (tip n)

backward :: Int -> Event
backward n = RollBackward (point n) (tip n)

apply :: [Event] -> Pending Block (Point Block) -> (Pending Block (Point Block), [Point Block])
apply events pending = fmap fst <$> Pending.applyEvents id events pending

pendingPoints :: Pending Block (Point Block) -> [Point Block]
pendingPoints = map annPoint . Pending.toList

tests :: TestTree
tests =
  testGroup
    "Pending"
    [ testCase "forwards queue up in order" $ do
        let (pending, rollbacks) = apply (map forward [1 .. 3]) Pending.empty
        pendingPoints pending @?= map point [1 .. 3]
        rollbacks @?= []
    , testCase "batches are ranges over the oldest headers" $ do
        let (pending, _) = apply (map forward [1 .. 5]) Pending.empty
        fmap (\(ChainRange from to, anns) -> (from, to, map annPoint anns)) (Pending.batch 2 pending)
          @?= Just (point 1, point 2, map point [1, 2])
    , testCase "no batch when nothing is pending" $
        fmap fst (Pending.batch 2 (Pending.empty :: Pending Block ())) @?= Nothing
    , testCase "a rollback into pending headers stays local" $ do
        let (pending, rollbacks) = apply (map forward [1 .. 5] <> [backward 3]) Pending.empty
        pendingPoints pending @?= map point [1 .. 3]
        rollbacks @?= []
    , testCase "a rollback past pending headers clears them and goes downstream" $ do
        let (pending, rollbacks) = apply (map forward [5 .. 7] <> [backward 4]) Pending.empty
        pendingPoints pending @?= []
        rollbacks @?= [point 4]
    , testCase "rollbacks and forwards interleave in order" $ do
        let (pending, rollbacks) =
              apply [backward 1, forward 2, backward 1, forward 9] Pending.empty
        pendingPoints pending @?= [point 9]
        rollbacks @?= [point 1, point 1]
    , testCase "delivered headers leave from the front" $ do
        let (pending, _) = apply (map forward [1 .. 3]) Pending.empty
        pendingPoints (Pending.dropOldest pending) @?= map point [2, 3]
    ]
