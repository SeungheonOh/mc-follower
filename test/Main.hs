module Main (main) where

import Test.McFollower.Network qualified as Network
import Test.McFollower.Pending qualified as Pending
import Test.McFollower.Recent qualified as Recent
import Test.Tasty (defaultMain, testGroup)

main :: IO ()
main = defaultMain (testGroup "mc-follower" [Recent.tests, Pending.tests, Network.tests])
