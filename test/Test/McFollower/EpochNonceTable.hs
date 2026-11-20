-- | The shipped epoch nonce tables and how they combine with the driver.
module Test.McFollower.EpochNonceTable (tests) where

import Cardano.Ledger.BaseTypes (Nonce (..), mkNonceFromNumber)
import Cardano.Slotting.Slot (EpochNo (..))
import Data.ByteString.Char8 qualified as BS8
import Data.Map.Strict qualified as Map
import McFollower.EpochNonceTable
import McFollower.Network (NetworkName (..))
import McFollower.Nonce (EpochNonce (..))
import McFollower.Nonce.TrustedState (TrustedState (..), parseTrustedState)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import Test.McFollower.Fixtures (hexNonce)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertFailure, testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "EpochNonceTable"
    [ testCase "shipped tables cover every Shelley-or-later epoch up to their end" $ do
        coverage Mainnet @?= (EpochNo 208, EpochNo 667, 460)
        coverage Preprod @?= (EpochNo 4, EpochNo 325, 322)
        coverage Preview @?= (EpochNo 0, EpochNo 1486, 1487)
    , testCase "spot values" $ do
        tableNonce (nonceTable Preview) (EpochNo 1486) @?= Just (nonce "e598cab3b7e4866da524a6a3c2d657b5bc264dfc7f451f17f409c339afe02dab")
        tableNonce (nonceTable Mainnet) (EpochNo 208) @?= Just (nonce "1a3be38bcbb7911969283716ad7aa550250226b76a61fc51cc9a9a35d9276d81")
    , testCase "the node's ledger snapshot at preview 128252153 agrees with the table" $ do
        -- test/data/preview-trusted-128252153.json was read from a node
        -- ledger snapshot (Mithril ancillary archive, epoch 1484).
        bytes <- BS8.readFile "test/data/preview-trusted-128252153.json"
        TrustedState {tsState} <- either assertFailure pure (parseTrustedState bytes)
        tableNonce (nonceTable Preview) (EpochNo 1484) @?= Just (praosStateEpochNonce tsState)
        tableNonce (nonceTable Preview) (EpochNo 1483) @?= Just (praosStatePreviousEpochNonce tsState)
    , testCase "lookup: table up to its end, then the driver" $ do
        let t = NonceTable (EpochNo 5) (EpochNo 6) (Map.fromList [(EpochNo 5, n 5), (EpochNo 6, NeutralNonce)])
        lookupEpochNonce t Nothing (EpochNo 4) @?= Right BeforeTable
        lookupEpochNonce t Nothing (EpochNo 5) @?= Right (NonceInForce (n 5))
        lookupEpochNonce t (Just (n 5)) (EpochNo 5) @?= Right (NonceInForce (n 5))
        lookupEpochNonce t (Just (n 9)) (EpochNo 5) @?= Left (NonceConflict (EpochNo 5) (n 5) (n 9))
        lookupEpochNonce t Nothing (EpochNo 6) @?= Right (NonceInForce NeutralNonce)
        lookupEpochNonce t Nothing (EpochNo 7) @?= Right NotYetAvailable
        lookupEpochNonce t (Just (n 7)) (EpochNo 7) @?= Right (NonceInForce (n 7))
        lookupEpochNonce t (Just NeutralNonce) (EpochNo 7) @?= Right (NonceInForce NeutralNonce)
        checkAgainstTable t (EpochNonce (EpochNo 6) (n 1)) @?= Left (NonceConflict (EpochNo 6) NeutralNonce (n 1))
    , testCase "malformed tables are rejected" $ do
        let rejected = either (const True) (const False) . parseNonceTable . BS8.pack
        -- no header, a gap, a bad nonce
        map rejected ["0,\n", "epoch,nonce\n0,\n2,\n", "epoch,nonce\n0,zz\n"] @?= [True, True, True]
        parseNonceTable (BS8.pack "# c\nepoch,nonce\n3,\n4,\n")
          @?= Right (NonceTable (EpochNo 3) (EpochNo 4) (Map.fromList [(EpochNo 3, NeutralNonce), (EpochNo 4, NeutralNonce)]))
    ]
 where
  n = mkNonceFromNumber
  nonce = either error id . hexNonce
  coverage net =
    let t = nonceTable net
     in (ntFirst t, ntLast t, Map.size (ntNonces t))
