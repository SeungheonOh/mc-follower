module Test.McFollower.Network (tests) where

import Data.Either (isLeft)
import McFollower.Block (parsePoint, renderPoint)
import McFollower.Network
  ( NetworkConfig (..)
  , NetworkName (..)
  , RelayAddress (..)
  , networkConfig
  , parseNetworkName
  , parseRelayAddress
  )
import Ouroboros.Network.Block (pattern GenesisPoint)
import Test.McFollower.Points (point)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Network"
    [ testCase "points render and parse back" $ do
        parsePoint (renderPoint (point 7)) @?= Right (point 7)
        parsePoint "origin" @?= Right GenesisPoint
    , testCase "malformed points are rejected" $ do
        assertBool "short hash" (isLeft (parsePoint "12.abcd"))
        assertBool "no slot" (isLeft (parsePoint (renderPoint (point 7) <> ".1")))
    , testCase "presets parse their recent points" $
        mapM_
          (\name -> assertBool (show name) (ncRecentPoint (networkConfig name) /= GenesisPoint))
          [minBound .. maxBound]
    , testCase "network names" $ do
        parseNetworkName "preview" @?= Right Preview
        assertBool "unknown" (isLeft (parseNetworkName "sanchonet"))
    , testCase "relay addresses" $ do
        parseRelayAddress "preview-node.play.dev.cardano.org:3001"
          @?= Right (RelayAddress "preview-node.play.dev.cardano.org" 3001)
        assertBool "no port" (isLeft (parseRelayAddress "relay.example"))
        assertBool "port out of range" (isLeft (parseRelayAddress "relay.example:70000"))
    ]
