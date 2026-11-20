module Main (main) where

import Test.McFollower.EpochData qualified as EpochData
import Test.McFollower.EpochNonceTable qualified as EpochNonceTable
import Test.McFollower.Extract qualified as Extract
import Test.McFollower.Network qualified as Network
import Test.McFollower.Nonce qualified as Nonce
import Test.McFollower.Pending qualified as Pending
import Test.McFollower.Query qualified as Query
import Test.McFollower.Recent qualified as Recent
import Test.McFollower.Server qualified as Server
import Test.McFollower.Store qualified as Store
import Test.Tasty (defaultMain, testGroup)

main :: IO ()
main =
  defaultMain
    ( testGroup
        "mc-follower"
        [ Recent.tests
        , Pending.tests
        , Network.tests
        , Extract.tests
        , Store.tests
        , Query.tests
        , Server.tests
        , Nonce.tests
        , EpochNonceTable.tests
        , EpochData.tests
        ]
    )
