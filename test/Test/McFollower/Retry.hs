-- | How the block source moves between upstreams after failures.
module Test.McFollower.Retry (tests) where

import McFollower.BlockSource (Outcome (..), Retry (..), nextAttempt, noRetries)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Retry"
    [ testCase "a relay without the intersection is not fatal while others remain" $ do
        let r2 = step 3 NoIntersection (step 3 NoIntersection noRetries)
        nextAttempt 3 NoIntersection r2 @?= Nothing
    , testCase "another failure in between restarts the count of relays without the intersection" $ do
        let r3 = step 2 NoIntersection (step 2 FailedEarly (step 2 NoIntersection noRetries))
        rNoIntersection r3 @?= 1
    , testCase "a single upstream without the intersection is fatal" $
        nextAttempt 1 NoIntersection noRetries @?= Nothing
    , testCase "failures back off once every relay has failed, up to five minutes" $ do
        let delays = map snd (take 12 (tail (iterateRetry 2)))
        take 4 delays @?= [5_000_000, 10_000_000, 10_000_000, 20_000_000]
        maximum delays @?= 300_000_000
    , testCase "a connection that delivered blocks resets the backoff" $ do
        nextAttempt 2 Progressed (step 2 FailedEarly (Retry 9 0)) @?= Just (noRetries, 5_000_000)
    ]
 where
  step n o r = maybe (error "unexpectedly fatal") fst (nextAttempt n o r)
  iterateRetry n = iterate (\(r, _) -> maybe (r, 0) id (nextAttempt n FailedEarly r)) (noRetries, 0)
