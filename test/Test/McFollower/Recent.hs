module Test.McFollower.Recent (tests) where

import McFollower.Block (Block)
import McFollower.BlockSource.Recent qualified as Recent
import Test.McFollower.Points (point)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Recent"
    [ testCase "no points, no candidates" $
        Recent.intersectionCandidates (Recent.empty 10 :: Recent.RecentPoints Block) @?= []
    , testCase "candidates are newest first and exponentially spaced" $
        Recent.intersectionCandidates (forwards 100 [1 .. 10])
          @?= map point [10, 9, 8, 6, 2, 1]
    , testCase "a single point is its own candidate" $
        Recent.intersectionCandidates (forwards 100 [1]) @?= [point 1]
    , testCase "keeps at most the capacity" $
        Recent.toOldestFirst (forwards 3 [1 .. 5]) @?= map point [3, 4, 5]
    , testCase "rolling back to a kept point drops what follows it" $
        Recent.toOldestFirst (Recent.rollBackward (point 3) (forwards 100 [1 .. 5]))
          @?= map point [1, 2, 3]
    , testCase "rolling back further than kept leaves only the rollback point" $
        Recent.toOldestFirst (Recent.rollBackward (point 0) (forwards 3 [1 .. 5]))
          @?= [point 0]
    ]
 where
  forwards capacity = foldl (flip (Recent.rollForward . point)) (Recent.empty capacity)
