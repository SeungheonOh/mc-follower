module Test.McFollower.Query (tests) where

import Data.ByteString (ByteString)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Word (Word16, Word32, Word64)
import McFollower.Extract (BlockRows (..), OutputRow (..), TxRows (..))
import Cardano.Slotting.Slot (EpochNo (..))
import McFollower.Query
import Control.Exception (bracket)
import McFollower.Store (Snapshot, Store, applyBlock, closeStore, openStoreReadOnly, putEpochNonce, putMaxTxSize, putPoolStake, withSnapshot)
import Test.McFollower.Chain
import Test.Tasty (TestTree, testGroup, withResource)
import Test.Tasty.HUnit (testCase, (@?=))

-- Addresses: "map" (mapping validator), "gov", "ics", "res", "cand", "x".
-- Assets: cNIGHT ("N", ""), auth token ("A", ""), governance policy "G".
night, auth :: AssetId
night = AssetId "N" ""
auth = AssetId "A" ""

with :: [OutputRow] -> TxRows -> TxRows
with outs t = t {trOutputs = outs}

datumOut :: Word16 -> Text -> [(ByteString, ByteString, Word64)] -> ByteString -> OutputRow
datumOut ix address assets datum = (output ix address assets) {orDatumHash = Just datum}

spending :: [(Word64, Int, Word32)] -> TxRows -> TxRows
spending refs t = t {trSpends = [OutRef (txHash b i) (fromIntegral ix) | (b, i, ix) <- refs]}

chain :: [BlockRows]
chain =
  chainFrom
    [
      ( 1
      ,
        [ with
            [ output 0 "x" [("N", "", 100)]
            , datumOut 1 "map" [("A", "", 1)] "dm1"
            , datumOut 2 "map" [("A", "", 2)] "dm1"
            ]
            (tx 1 0) {trDatums = [("dm1", "DM1")]}
        , with
            [datumOut 0 "map" [("A", "", 1)] "dlate", datumOut 1 "map" [("A", "", 1), ("N", "", 5)] "dm1"]
            (tx 1 1) {trSpends = [OutRef "zz" 1, OutRef "aa" 2], trRecordInputs = True}
        ]
      )
    ,
      ( 2
      ,
        [ with [output 0 "x" [("N", "", 60)], output 1 "x" [("N", "", 40)]] (spending [(1, 0, 0), (1, 0, 1)] (tx 2 0))
        , (spending [(1, 1, 1)] (tx 2 1)) {trDatums = [("dlate", "DL")]}
        ]
      )
    ,
      ( 3
      ,
        [ with [datumOut 0 "gov" [("G", "a", 1)] "dg1", datumOut 1 "gov" [("G", "b", 1)] "dg1"] (tx 3 0) {trDatums = [("dg1", "DG1")]}
        , with [output 0 "gov" [("G", "a", 1)]] (tx 3 1)
        ]
      )
    , (4, [with [output 0 "res" [("N", "", 1000)]] (tx 4 0)])
    , (5, [with [output 0 "ics" [("N", "", 300)], output 1 "res" [("N", "", 700)]] (spending [(4, 0, 0)] (tx 5 0)) {trMetadata = [(6500973, "md5")]}])
    , (6, [with [output 0 "ics" [("N", "", 300)]] (spending [(5, 0, 0)] (tx 6 0)), with [output 0 "ics" [("N", "", 50)]] (tx 6 1)])
    , (7, [with [output 0 "ics" [("N", "", 1)]] (tx 7 0)])
    , (8, [])
    , (9, [])
    , (10, [with [output 0 "x" [("N", "", 7)]] (tx 10 0)])
    , (11, [])
    , (12, [spending [(2, 0, 1), (10, 0, 0), (2, 0, 0)] (tx 12 0)])
    ]
    <> [ebb]
 where
  -- An epoch boundary block after block 12: no number, no transactions.
  ebb = (blockRows 13 []) {brNumber = Nothing, brPrevHash = Just (hash32 0xb0 12)}

tests :: TestTree
tests =
  withResource setup (closeStore . snd) $ \getStore ->
    -- Tests run concurrently, each with its own read-only connection.
    let q :: (Snapshot -> IO a) -> IO a
        q f = getStore >>= \(path, _) -> bracket (openStoreReadOnly path) closeStore (`withSnapshot` f)
     in testGroup
          "Query"
          [ testGroup
              "blocks"
              [ testCase "latest block skips the boundary block" $
                  fmap biNumber <$> q getLatestBlock >>= (@?= Just 12)
              , testCase "number range is inclusive, empty when reversed" $ do
                  map biNumber <$> q (getBlocksByNumberRange 3 5) >>= (@?= [3, 4, 5])
                  q (getBlocksByNumberRange 5 3) >>= (@?= [])
              , testCase "block rows" $
                  q (getBlocksByNumberRange 5 5)
                    >>= (@?= [BlockInfo 5 (hash32 0xb0 5) 0 50 1050 1])
              , testCase "highest block in window" $ do
                  fmap biNumber <$> q (getHighestBlockInWindow (HighestBlockWindow 10 30 80 0 2000000)) >>= (@?= Just 8)
                  fmap biNumber <$> q (getHighestBlockInWindow (HighestBlockWindow 6 30 80 0 2000000)) >>= (@?= Just 6)
                  -- block 7 has time 1070 s: 1070000 ms
                  fmap biNumber <$> q (getHighestBlockInWindow (HighestBlockWindow 10 0 1000 0 1070000)) >>= (@?= Just 7)
                  fmap biNumber <$> q (getHighestBlockInWindow (HighestBlockWindow 10 0 1000 0 1069999)) >>= (@?= Just 6)
              , testCase "by hash: boundary blocks and unknown hashes are absent" $ do
                  fmap biNumber <$> q (getBlockByHash (hash32 0xb0 3)) >>= (@?= Just 3)
                  q (getBlockByHash (hash32 0xb0 13)) >>= (@?= Nothing)
                  q (getBlockByHash (hash32 0xb0 99)) >>= (@?= Nothing)
              , testCase "status" $ do
                  status <- q (getIndexStatus 5)
                  (biNumber <$> isTip status, biNumber <$> isImmutableTip status, biNumber <$> isStartBlock status)
                    @?= (Just 12, Just 7, Just 1)
              ]
          , testGroup
              "authority selection"
              [ testCase "latest block for epoch" $ do
                  fmap biNumber <$> q (getLatestBlockForEpoch 0) >>= (@?= Just 9)
                  fmap biNumber <$> q (getLatestBlockForEpoch 7) >>= (@?= Just 12)
              , testCase "latest stable epoch" $ do
                  q (getLatestStableEpoch 3) >>= (@?= Just (-1))
                  q (getLatestStableEpoch 2) >>= (@?= Just 0)
                  q (getLatestStableEpoch 20) >>= (@?= Nothing)
              , testCase "token output: latest, ties by output index, epoch bound" $ do
                  fmap toPos <$> q (getLatestTokenOutputForEpoch (AssetId "G" "a") 0) >>= (@?= Just (3, 1, 0, Nothing))
                  fmap toPos <$> q (getLatestTokenOutputForEpoch (AssetId "G" "b") 0) >>= (@?= Just (3, 0, 1, Just "DG1"))
                  fmap toPos <$> q (getLatestTokenOutputForEpoch night 0) >>= (@?= Just (7, 0, 0, Nothing))
                  fmap toPos <$> q (getLatestTokenOutputForEpoch night 1) >>= (@?= Just (10, 0, 0, Nothing))
                  q (getLatestTokenOutputForEpoch (AssetId "G" "zz") 1) >>= (@?= Nothing)
              , testCase "unspent outputs at an address, with creating inputs" $ do
                  rows1 <- q (getUnspentOutputsAtAddress "map" 1)
                  map aoPos rows1 @?= [(1, 0, 1), (1, 0, 2), (1, 1, 0), (1, 1, 1)]
                  map aoDatum rows1 @?= [Just "DM1", Just "DM1", Just "DL", Just "DM1"]
                  map aoInputs rows1 @?= [[], [], [OutRef "aa" 2, OutRef "zz" 1], [OutRef "aa" 2, OutRef "zz" 1]]
                  map aoPos <$> q (getUnspentOutputsAtAddress "map" 2) >>= (@?= [(1, 0, 2), (1, 1, 0)])
                  q (getUnspentOutputsAtAddress "map" 0) >>= (@?= [])
              , testCase "epoch nonce and stake distribution" $ do
                  q (getEpochNonce 1) >>= (@?= Just "nonce1")
                  q (getEpochNonce 2) >>= (@?= Nothing)
                  q (getStakeDistribution 1) >>= (@?= [("pa", 1), ("pb", maxBound)])
                  q (getStakeDistribution 2) >>= (@?= [])
              ]
          , testGroup
              "cNIGHT"
              [ testCase "registrations: quantity 1 and resolvable datum, ordered" $ do
                  rows <- q (getMappingRegistrations "map" auth (Window (Position 1 0) (Position 3 0)) (Page 10 0))
                  map rgPos rows @?= [(1, 0, 1), (1, 1, 0), (1, 1, 1)]
                  map rgDatum rows @?= ["DM1", "DL", "DM1"]
                  map rgBlockTimeMillis rows @?= [1010000, 1010000, 1010000]
              , testCase "registrations: limit and offset" $
                  map rgPos <$> q (getMappingRegistrations "map" auth (Window (Position 0 0) (Position 99 0)) (Page 2 1))
                    >>= (@?= [(1, 1, 0), (1, 1, 1)])
              , testCase "registrations: window is half-open on tx index" $ do
                  map rgPos <$> q (getMappingRegistrations "map" auth (Window (Position 1 1) (Position 2 0)) (Page 10 0))
                    >>= (@?= [(1, 1, 0), (1, 1, 1)])
                  map rgPos <$> q (getMappingRegistrations "map" auth (Window (Position 1 0) (Position 1 1)) (Page 10 0))
                    >>= (@?= [(1, 0, 1)])
                  q (getMappingRegistrations "map" auth (Window (Position 1 1) (Position 1 1)) (Page 10 0)) >>= (@?= [])
              , testCase "deregistrations" $ do
                  rows <- q (getMappingDeregistrations "map" (Window (Position 0 0) (Position 99 0)) (Page 10 0))
                  [(drBlockNo r, drTxIndex r, drTxHash r, drSpent r, drDatum r) | r <- rows]
                    @?= [(2, 0, txHash 2 0, OutRef (txHash 1 0) 1, "DM1"), (2, 1, txHash 2 1, OutRef (txHash 1 1) 1, "DM1")]
                  map drTxIndex <$> q (getMappingDeregistrations "map" (Window (Position 2 1) (Position 3 0)) (Page 10 0))
                    >>= (@?= [1])
              , testCase "asset creates" $ do
                  rows <- q (getAssetCreates night (Window (Position 0 0) (Position 99 0)) (Page 100 0))
                  [(acBlockNo r, acTxIndex r, acIndex r, acQuantity r) | r <- rows]
                    @?= [ (1, 0, 0, 100)
                        , (1, 1, 1, 5)
                        , (2, 0, 0, 60)
                        , (2, 0, 1, 40)
                        , (4, 0, 0, 1000)
                        , (5, 0, 0, 300)
                        , (5, 0, 1, 700)
                        , (6, 0, 0, 300)
                        , (6, 1, 0, 50)
                        , (7, 0, 0, 1)
                        , (10, 0, 0, 7)
                        ]
                  map acHolderAddress (take 2 rows) @?= ["x", "map"]
                  map (\r -> (acBlockNo r, acIndex r)) <$> q (getAssetCreates night (Window (Position 2 0) (Position 5 0)) (Page 2 1))
                    >>= (@?= [(2, 1), (4, 0)])
              , testCase "asset spends ordered by spending position, then spent output" $ do
                  rows <- q (getAssetSpends night (Window (Position 0 0) (Position 99 0)) (Page 100 0))
                  [(asBlockNo r, asTxIndex r, asSpent r, asQuantity r) | r <- rows]
                    @?= [ (2, 0, OutRef (txHash 1 0) 0, 100)
                        , (2, 1, OutRef (txHash 1 1) 1, 5)
                        , (5, 0, OutRef (txHash 4 0) 0, 1000)
                        , (6, 0, OutRef (txHash 5 0) 0, 300)
                        , (12, 0, OutRef (txHash 2 0) 0, 60)
                        , (12, 0, OutRef (txHash 2 0) 1, 40)
                        , (12, 0, OutRef (txHash 10 0) 0, 7)
                        ]
                  map asSpendingTxHash (take 1 rows) @?= [txHash 2 0]
                  map asSpent <$> q (getAssetSpends night (Window (Position 12 0) (Position 12 1)) (Page 2 1))
                    >>= (@?= [OutRef (txHash 2 0) 1, OutRef (txHash 10 0) 0])
              , testCase "max tx size by block's epoch" $ do
                  q (getMaxTxSize 3) >>= (@?= Just 16384)
                  q (getMaxTxSize 11) >>= (@?= Nothing)
                  q (getMaxTxSize 99) >>= (@?= Nothing)
              ]
          , testGroup
              "governance"
              [ testCase "latest output with datum, ties by output index" $ do
                  fmap goPos <$> q (getLatestGovernanceOutput "gov" "G" 3) >>= (@?= Just (3, 0, 1))
                  fmap goDatum <$> q (getLatestGovernanceOutput "gov" "G" 99) >>= (@?= Just "DG1")
                  q (getLatestGovernanceOutput "gov" "G" 2) >>= (@?= Nothing)
                  q (getLatestGovernanceOutput "gov" "other" 99) >>= (@?= Nothing)
              ]
          , testGroup
              "bridge"
              [ testCase "transactions, sums and metadata" $
                  q (getBridgeTxs 6500973 (bridge (AfterBlock 4) 7 Nothing))
                    >>= (@?= [ BridgeTxRow (Position 5 0) (txHash 5 0) (Just "md5") 0 300 1000 700
                             , BridgeTxRow (Position 6 1) (txHash 6 1) Nothing 0 50 0 0
                             , BridgeTxRow (Position 7 0) (txHash 7 0) Nothing 0 1 0 0
                             ]
                        )
              , testCase "bounds and limit" $ do
                  let positions r = map btPosition <$> q (getBridgeTxs 6500973 r)
                  positions (bridge (AfterBlock 4) 7 (Just 2)) >>= (@?= [Position 5 0, Position 6 1])
                  positions (bridge (AfterBlock 4) 7 (Just 0)) >>= (@?= [])
                  positions (bridge (AfterBlock 4) 6 Nothing) >>= (@?= [Position 5 0, Position 6 1])
                  positions (bridge (AfterPosition (Position 6 0)) 7 Nothing) >>= (@?= [Position 6 1, Position 7 0])
                  positions (bridge (AfterPosition (Position 6 1)) 7 Nothing) >>= (@?= [Position 7 0])
                  positions (bridge (FromPosition (Position 6 1)) 7 Nothing) >>= (@?= [Position 6 1, Position 7 0])
                  positions (bridge (AfterBlock 5) 7 Nothing) >>= (@?= [Position 6 1, Position 7 0])
              , testCase "transaction position" $ do
                  q (getTxPosition (txHash 6 1)) >>= (@?= Just (Position 6 1))
                  q (getTxPosition (txHash 9 0)) >>= (@?= Nothing)
              ]
          ]
 where
  bridge lower to limit = BridgeTxsRequest "ics" "res" night lower to limit
  toPos t = (toBlockNo t, toTxIndex t, toIndex t, toDatum t)
  aoPos r = (aoBlockNo r, aoTxIndex r, aoIndex r)
  rgPos r = (rgBlockNo r, rgTxIndex r, rgIndex r)
  goPos r = (goBlockNo r, goTxIndex r, goIndex r)

setup :: IO (FilePath, Store)
setup = do
  (path, store) <- newTestStore
  mapM_ (applyBlock store) chain
  putMaxTxSize store (EpochNo 0) 16384
  putEpochNonce store (EpochNo 1) "nonce1"
  putPoolStake store (EpochNo 1) (Map.fromList [("pb", maxBound), ("pa", 1)])
  pure (path, store)
