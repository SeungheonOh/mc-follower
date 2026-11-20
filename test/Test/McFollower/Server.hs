{-# LANGUAGE OverloadedLabels #-}

-- | The gRPC server on an ephemeral port against a store built from rows,
-- called with a grapesy client: every RPC, stream order, field presence and
-- each status code.
module Test.McFollower.Server (tests) where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (try)
import Control.Monad (replicateM)
import Control.Monad.Trans.Reader (ReaderT)
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Map.Strict qualified as Map
import Data.Maybe (isJust)
import Data.ProtoLens.Labels ()
import Data.Text (Text)
import Data.Word (Word16, Word32, Word64, Word8)
import Cardano.Slotting.Slot (EpochNo (..))
import McFollower.Extract (BlockRows (..), OutRef (..), OutputRow (..), TxRows (..))
import McFollower.Server (ServerConfig (..), SyncStatus (..), notFollowing, withServer)
import McFollower.Server.Proto qualified as P
import McFollower.Store (Store, applyBlock, closeStore, putEpochNonce, putMaxTxSize, putPoolStake)
import McFollower.Sync (UpstreamTip (..))
import McFollower.WatchSet (AssetId (..), BridgeWatch (..), GovernanceBody (..), WatchConfig (..))
import Network.GRPC.Client (Address (..), Server (..), rpc, withConnection)
import Network.GRPC.Client qualified as Client
import Network.GRPC.Client.StreamType.IO (nonStreaming, serverStreaming)
import Network.GRPC.Common (GrpcError (..), GrpcException (..), NextElem (..), def)
import Network.GRPC.Common.Protobuf (Proto (..), StreamingType (..), defMessage, getProto, (&), (.~), (^.))
import Network.GRPC.Spec (ClientHandler', Input, Output)
import System.FilePath ((</>))
import System.IO.Temp (withSystemTempDirectory)
import Test.McFollower.Chain
import Test.Tasty (TestTree, testGroup, withResource)
import Test.Tasty.HUnit (Assertion, assertFailure, testCase, (@?=))

-- Policies are 28 bytes on the wire: cNIGHT, the mapping auth token, the
-- council, and one nobody watches.
nightPolicy, authPolicy, govPolicy, otherPolicy :: ByteString
nightPolicy = policy 0x4e
authPolicy = policy 0x41
govPolicy = policy 0x47
otherPolicy = policy 0x58

policy :: Word8 -> ByteString
policy = BS.replicate 28

-- Addresses: "map" (mapping validator, also the committee-candidate address
-- here), "gov" (council), "tc" (technical committee), "ics", "res" (bridge)
-- and "x" (not watched).
watch :: WatchConfig
watch =
  WatchConfig
    { wcCNight = AssetId nightPolicy ""
    , wcMappingValidatorAddress = "map"
    , wcCouncil = GovernanceBody "gov" govPolicy
    , wcTechnicalCommittee = GovernanceBody "tc" (policy 0x54)
    , wcPermissionedCandidatesPolicy = policy 0x50
    , wcCommitteeCandidateAddress = "map"
    , wcBridge = BridgeWatch "ics" "res" (AssetId nightPolicy "") 6500973
    }

with :: [OutputRow] -> TxRows -> TxRows
with outs t = t {trOutputs = outs}

datumOut :: Word16 -> Text -> [(ByteString, ByteString, Word64)] -> ByteString -> OutputRow
datumOut ix address assets d = (output ix address assets) {orDatumHash = Just d}

spending :: [(Word64, Int, Word32)] -> TxRows -> TxRows
spending refs t = t {trSpends = [OutRef (txHash b i) (fromIntegral ix) | (b, i, ix) <- refs]}

-- The chain of the query tests ("Test.McFollower.Query") with full-length
-- policies; k = 5 (testIdentity).
chain :: [BlockRows]
chain =
  chainFrom
    [
      ( 1
      ,
        [ with
            [ output 0 "x" [(nightPolicy, "", 100)]
            , datumOut 1 "map" [(authPolicy, "", 1)] "dm1"
            , datumOut 2 "map" [(authPolicy, "", 2)] "dm1"
            ]
            (tx 1 0) {trDatums = [("dm1", "DM1")]}
        , with
            [datumOut 0 "map" [(authPolicy, "", 1)] "dlate", datumOut 1 "map" [(authPolicy, "", 1), (nightPolicy, "", 5)] "dm1"]
            (tx 1 1) {trSpends = [OutRef "zz" 1, OutRef "aa" 2], trRecordInputs = True}
        ]
      )
    ,
      ( 2
      ,
        [ with [output 0 "x" [(nightPolicy, "", 60)], output 1 "x" [(nightPolicy, "", 40)]] (spending [(1, 0, 0), (1, 0, 1)] (tx 2 0))
        , (spending [(1, 1, 1)] (tx 2 1)) {trDatums = [("dlate", "DL")]}
        ]
      )
    ,
      ( 3
      ,
        [ with [datumOut 0 "gov" [(govPolicy, "a", 1)] "dg1", datumOut 1 "gov" [(govPolicy, "b", 1)] "dg1"] (tx 3 0) {trDatums = [("dg1", "DG1")]}
        , with [output 0 "gov" [(govPolicy, "a", 1)]] (tx 3 1)
        ]
      )
    , (4, [with [output 0 "res" [(nightPolicy, "", 1000)]] (tx 4 0)])
    , (5, [with [output 0 "ics" [(nightPolicy, "", 300)], output 1 "res" [(nightPolicy, "", 700)]] (spending [(4, 0, 0)] (tx 5 0)) {trMetadata = [(6500973, "md5")]}])
    , (6, [with [output 0 "ics" [(nightPolicy, "", 300)]] (spending [(5, 0, 0)] (tx 6 0)), with [output 0 "ics" [(nightPolicy, "", 50)]] (tx 6 1)])
    , (7, [with [output 0 "ics" [(nightPolicy, "", 1)]] (tx 7 0)])
    , (8, [])
    , (9, [])
    , (10, [with [output 0 "x" [(nightPolicy, "", 7)]] (tx 10 0)])
    , (11, [])
    , (12, [spending [(2, 0, 1), (10, 0, 0), (2, 0, 0)] (tx 12 0)])
    ]

setup :: IO (FilePath, Store)
setup = do
  (path, store) <- newTestStore
  mapM_ (applyBlock store) chain
  putMaxTxSize store (EpochNo 0) 16384
  putEpochNonce store (EpochNo 1) (hash32 0xee 1)
  putPoolStake store (EpochNo 1) (Map.fromList [(policy 0x02, maxBound), (policy 0x01, 1)])
  pure (path, store)

config :: FilePath -> IO SyncStatus -> ServerConfig
config path status =
  ServerConfig
    { svHost = "127.0.0.1"
    , svPort = 0
    , svDatabase = path
    , svIdentity = testIdentity
    , svWatch = watch
    , svConnections = 4
    , svSyncStatus = status
    , svLog = \_ -> pure ()
    }

-- | A connection to a server over the database at the path.
withClient :: FilePath -> IO SyncStatus -> (Client.Connection -> IO a) -> IO a
withClient path status k =
  withServer (config path status) $ \port ->
    withConnection def (ServerInsecure (Address "127.0.0.1" port Nothing)) k

tests :: TestTree
tests =
  withResource setup (closeStore . snd) $ \getStore ->
    testGroup
      "Server"
      [ testCase "status" $ do
          (path, _) <- getStore
          status <- newIORef notFollowing
          let get = withClient path (readIORef status) $ \c -> getProto <$> nonStreaming c (rpc @P.GetStatus) (Proto defMessage)
          s <- get
          fmap (^. #blockNo) (s ^. #maybe'tip) @?= Just 12
          fmap (^. #blockNo) (s ^. #maybe'immutableTip) @?= Just 7
          fmap (^. #blockNo) (s ^. #maybe'startBlock) @?= Just 1
          (s ^. #securityParameter, s ^. #networkMagic, s ^. #backfilling) @?= (5, 42, [])
          (s ^. #syncing, s ^. #maybe'upstreamTipSlot, s ^. #maybe'upstreamTipBlockNo) @?= (False, Nothing, Nothing)
          writeIORef status (SyncStatus True Nothing)
          (^. #syncing) <$> get >>= (@?= True)
          writeIORef status (SyncStatus True (Just (UpstreamTip 200 20)))
          s' <- get
          (s' ^. #syncing, s' ^. #maybe'upstreamTipSlot, s' ^. #maybe'upstreamTipBlockNo) @?= (True, Just 200, Just 20)
          writeIORef status (SyncStatus True (Just (UpstreamTip 120 12)))
          (^. #syncing) <$> get >>= (@?= False)
      , testGroup
          "blocks"
          [ testCase "latest block, with every field" $
              call getStore (\c -> unary c (rpc @P.GetLatestBlock) defMessage)
                >>= (@?= (defMessage & #maybe'block .~ Just (blockMessage 12 1)))
          , testCase "number range: ascending, inclusive, empty when reversed" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetBlocksByNumberRange) (defMessage & #fromBlockNo .~ 3 & #toBlockNo .~ 5))
              map (^. #blockNo) rows @?= [3, 4, 5]
              rows !! 2 @?= blockMessage 5 1
              call getStore (\c -> streamed c (rpc @P.GetBlocksByNumberRange) (defMessage & #fromBlockNo .~ 5 & #toBlockNo .~ 3)) >>= (@?= [])
          , testCase "highest block in window" $ do
              let window maxTime =
                    defMessage & #maxBlockNo .~ 10 & #minSlot .~ 0 & #maxSlot .~ 1000 & #minTimeUnixMillis .~ 0 & #maxTimeUnixMillis .~ maxTime
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetHighestBlockInWindow) (window 1070000)) >>= (@?= Just 7)
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetHighestBlockInWindow) (window 1069999)) >>= (@?= Just 6)
          , testCase "by hash: present, absent" $ do
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetBlockByHash) (defMessage & #hash .~ hash32 0xb0 3)) >>= (@?= Just 3)
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetBlockByHash) (defMessage & #hash .~ hash32 0xb0 99)) >>= (@?= Nothing)
          , testCase "transaction position" $ do
              let pos h = fmap (\p -> (p ^. #blockNo, p ^. #txIndex)) . (^. #maybe'position) <$> call getStore (\c -> unary c (rpc @P.GetTxPosition) (defMessage & #txHash .~ h))
              pos (txHash 6 1) >>= (@?= Just (6, 1))
              pos (txHash 9 0) >>= (@?= Nothing)
          ]
      , testGroup
          "authority selection"
          [ testCase "latest block for epoch" $ do
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetLatestBlockForEpoch) (defMessage & #epochNo .~ 0)) >>= (@?= Just 9)
              blockNoOf <$> call getStore (\c -> unary c (rpc @P.GetLatestBlockForEpoch) (defMessage & #epochNo .~ 1)) >>= (@?= Just 12)
          , testCase "latest stable epoch: signed, absent below k" $ do
              let stable k = (^. #maybe'epochNo) <$> call getStore (\c -> unary c (rpc @P.GetLatestStableEpoch) (defMessage & #securityParameter .~ k))
              stable 3 >>= (@?= Just (-1))
              stable 2 >>= (@?= Just 0)
              stable 20 >>= (@?= Nothing)
          , testCase "stake distribution by pool hash" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetStakeDistribution) (defMessage & #epochNo .~ 1))
              map (\r -> (r ^. #poolHash, r ^. #stake)) rows @?= [(policy 0x01, 1), (policy 0x02, maxBound)]
              call getStore (\c -> streamed c (rpc @P.GetStakeDistribution) (defMessage & #epochNo .~ 2)) >>= (@?= [])
          , testCase "token output: datum set only when resolvable" $ do
              let token name epoch = (^. #maybe'output) <$> call getStore (\c -> unary c (rpc @P.GetLatestTokenOutputForEpoch) (defMessage & #asset .~ assetMessage govPolicy name & #epochNo .~ epoch))
              a <- token "a" 0
              fmap (\o -> (o ^. #txBlockNo, o ^. #txBlockIndex, o ^. #utxoIndex, o ^. #maybe'datum)) a @?= Just (3, 1, 0, Nothing)
              b <- token "b" 0
              b
                @?= Just
                  ( defMessage
                      & #originTxHash .~ txHash 3 0
                      & #utxoIndex .~ 1
                      & #txEpochNo .~ 0
                      & #txBlockNo .~ 3
                      & #txSlotNo .~ 30
                      & #txBlockIndex .~ 0
                      & #datum .~ (defMessage & #cbor .~ "DG1")
                  )
              token "zz" 1 >>= (@?= Nothing)
          , testCase "epoch nonce" $ do
              let nonce e = (^. #maybe'nonce) <$> call getStore (\c -> unary c (rpc @P.GetEpochNonce) (defMessage & #epochNo .~ e))
              nonce 1 >>= (@?= Just (hash32 0xee 1))
              nonce 0 >>= (@?= Nothing)
          , testCase "unspent outputs at an address, with inputs and optional datums" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetUnspentOutputsAtAddress) (defMessage & #address .~ "map" & #blockNo .~ 1))
              map (\r -> (r ^. #txBlockNo, r ^. #txIndexInBlock, r ^. #utxoIndex)) rows @?= [(1, 0, 1), (1, 0, 2), (1, 1, 0), (1, 1, 1)]
              map (fmap (^. #cbor) . (^. #maybe'datum)) rows @?= [Just "DM1", Just "DM1", Just "DL", Just "DM1"]
              map (map (\i -> (i ^. #txHash, i ^. #index)) . (^. #txInputs)) rows @?= [[], [], [("aa", 2), ("zz", 1)], [("aa", 2), ("zz", 1)]]
              map (^. #address) rows @?= replicate 4 "map"
              rows2 <- call getStore (\c -> streamed c (rpc @P.GetUnspentOutputsAtAddress) (defMessage & #address .~ "map" & #blockNo .~ 2))
              map (\r -> (r ^. #txIndexInBlock, r ^. #utxoIndex)) rows2 @?= [(0, 2), (1, 0)]
          ]
      , testGroup
          "cNIGHT"
          [ testCase "registrations: ordered, datum always set, limit and offset" $ do
              let regs from to lim off = call getStore (\c -> streamed c (rpc @P.GetMappingRegistrations) (defMessage & #mappingValidatorAddress .~ "map" & #authToken .~ assetMessage authPolicy "" & #window .~ windowMessage from to & #limit .~ lim & #offset .~ off))
              rows <- regs (1, 0) (3, 0) 10 0
              map (\r -> (r ^. #blockNo, r ^. #txIndex, r ^. #utxoIndex)) rows @?= [(1, 0, 1), (1, 1, 0), (1, 1, 1)]
              map (fmap (^. #cbor) . (^. #maybe'datum)) rows @?= [Just "DM1", Just "DL", Just "DM1"]
              map (^. #blockTimeUnixMillis) rows @?= [1010000, 1010000, 1010000]
              map (^. #blockHash) rows @?= replicate 3 (hash32 0xb0 1)
              map (^. #txHash) rows @?= [txHash 1 0, txHash 1 1, txHash 1 1]
              map (\r -> (r ^. #txIndex, r ^. #utxoIndex)) <$> regs (0, 0) (12, 0) 2 1 >>= (@?= [(1, 0), (1, 1)])
          , testCase "deregistrations" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetMappingDeregistrations) (defMessage & #mappingValidatorAddress .~ "map" & #window .~ windowMessage (0, 0) (12, 1) & #limit .~ 10))
              map (\r -> (r ^. #blockNo, r ^. #txIndex, r ^. #txHash, r ^. #utxoTxHash, r ^. #utxoIndex, fmap (^. #cbor) (r ^. #maybe'datum))) rows
                @?= [(2, 0, txHash 2 0, txHash 1 0, 1, Just "DM1"), (2, 1, txHash 2 1, txHash 1 1, 1, Just "DM1")]
          , testCase "asset creates" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetAssetCreates) (defMessage & #asset .~ assetMessage nightPolicy "" & #window .~ windowMessage (0, 0) (12, 1) & #limit .~ 100))
              map (\r -> (r ^. #blockNo, r ^. #txIndex, r ^. #utxoIndex, r ^. #quantity)) rows
                @?= [(1, 0, 0, 100), (1, 1, 1, 5), (2, 0, 0, 60), (2, 0, 1, 40), (4, 0, 0, 1000), (5, 0, 0, 300), (5, 0, 1, 700), (6, 0, 0, 300), (6, 1, 0, 50), (7, 0, 0, 1), (10, 0, 0, 7)]
              map (^. #holderAddress) (take 2 rows) @?= ["x", "map"]
          , testCase "asset spends" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetAssetSpends) (defMessage & #asset .~ assetMessage nightPolicy "" & #window .~ windowMessage (12, 0) (12, 1) & #limit .~ 2 & #offset .~ 1))
              map (\r -> (r ^. #blockNo, r ^. #utxoTxHash, r ^. #utxoIndex, r ^. #quantity, r ^. #spendingTxHash)) rows
                @?= [(12, txHash 2 0, 1, 40, txHash 12 0), (12, txHash 10 0, 0, 7, txHash 12 0)]
          , testCase "max tx size" $ do
              let size b = (^. #maybe'maxTxSize) <$> call getStore (\c -> unary c (rpc @P.GetMaxTxSize) (defMessage & #blockNo .~ b))
              size 3 >>= (@?= Just 16384)
              size 11 >>= (@?= Nothing)
          ]
      , testGroup
          "governance and bridge"
          [ testCase "governance output" $ do
              let gov b = (^. #maybe'output) <$> call getStore (\c -> unary c (rpc @P.GetLatestGovernanceOutput) (defMessage & #address .~ "gov" & #policyId .~ govPolicy & #blockNo .~ b))
              gov 3
                >>= ( @?=
                        Just
                          ( defMessage
                              & #datum .~ (defMessage & #cbor .~ "DG1")
                              & #blockNo .~ 3
                              & #blockHash .~ hash32 0xb0 3
                              & #txIndex .~ 0
                              & #txHash .~ txHash 3 0
                              & #utxoIndex .~ 1
                          )
                    )
              gov 2 >>= (@?= Nothing)
          , testCase "bridge transactions: sums always set, metadata when present" $ do
              rows <- call getStore (\c -> streamed c (rpc @P.GetBridgeTxs) (bridgeRequest & #afterBlockNo .~ 4 & #toBlockNo .~ 7))
              rows
                @?= [ bridgeRow 5 0 (Just "md5") 0 300 1000 700
                    , bridgeRow 6 1 Nothing 0 50 0 0
                    , bridgeRow 7 0 Nothing 0 1 0 0
                    ]
              -- zero sums are sent, not left unset
              concatMap (\r -> map isJust [r ^. #maybe'bridgeIn, r ^. #maybe'bridgeOut, r ^. #maybe'reserveIn, r ^. #maybe'reserveOut]) rows @?= replicate 12 True
          , testCase "bridge bounds and limit" $ do
              let positions req = map (\r -> (r ^. #blockNo, r ^. #txIndex)) <$> call getStore (\c -> streamed c (rpc @P.GetBridgeTxs) req)
              positions (bridgeRequest & #afterBlockNo .~ 4 & #toBlockNo .~ 7 & #maxTxs .~ 2) >>= (@?= [(5, 0), (6, 1)])
              positions (bridgeRequest & #afterBlockNo .~ 4 & #toBlockNo .~ 7 & #maxTxs .~ 0) >>= (@?= [])
              positions (bridgeRequest & #afterPosition .~ positionMessage (6, 1) & #toBlockNo .~ 7) >>= (@?= [(7, 0)])
              positions (bridgeRequest & #fromPosition .~ positionMessage (6, 1) & #toBlockNo .~ 7) >>= (@?= [(6, 1), (7, 0)])
          ]
      , testGroup
          "status codes"
          [ testCase "INVALID_ARGUMENT for malformed requests" $ do
              expectCode GrpcInvalidArgument $ call getStore (\c -> unary c (rpc @P.GetBlockByHash) (defMessage & #hash .~ "short"))
              expectCode GrpcInvalidArgument $ call getStore (\c -> unary c (rpc @P.GetTxPosition) defMessage)
              expectCode GrpcInvalidArgument $ call getStore (\c -> streamed c (rpc @P.GetBridgeTxs) (bridgeRequest & #toBlockNo .~ 7))
              expectCode GrpcInvalidArgument $ call getStore (\c -> streamed c (rpc @P.GetAssetCreates) (defMessage & #asset .~ assetMessage nightPolicy ""))
              expectCode GrpcInvalidArgument $ call getStore (\c -> streamed c (rpc @P.GetAssetCreates) (defMessage & #asset .~ assetMessage "short" "" & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcInvalidArgument $ call getStore (\c -> streamed c (rpc @P.GetAssetSpends) (defMessage & #asset .~ assetMessage nightPolicy (BS.replicate 33 0) & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcInvalidArgument $ call getStore (\c -> streamed c (rpc @P.GetMappingDeregistrations) (defMessage & #mappingValidatorAddress .~ "map" & #window .~ windowMessage (0, 0) (1, 0) & #limit .~ 2 ^ (31 :: Int)))
              expectCode GrpcInvalidArgument $ call getStore (\c -> unary c (rpc @P.GetLatestGovernanceOutput) (defMessage & #address .~ "gov" & #policyId .~ "G" & #blockNo .~ 3))
          , testCase "FAILED_PRECONDITION for what the watch set does not index" $ do
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetUnspentOutputsAtAddress) (defMessage & #address .~ "x" & #blockNo .~ 1))
              -- watched, but without the input lists of creating transactions
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetUnspentOutputsAtAddress) (defMessage & #address .~ "gov" & #blockNo .~ 1))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetMappingRegistrations) (defMessage & #mappingValidatorAddress .~ "x" & #authToken .~ assetMessage authPolicy "" & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetMappingDeregistrations) (defMessage & #mappingValidatorAddress .~ "x" & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetAssetCreates) (defMessage & #asset .~ assetMessage otherPolicy "" & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetAssetSpends) (defMessage & #asset .~ assetMessage otherPolicy "" & #window .~ windowMessage (0, 0) (1, 0)))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> unary c (rpc @P.GetLatestTokenOutputForEpoch) (defMessage & #asset .~ assetMessage otherPolicy "" & #epochNo .~ 0))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> unary c (rpc @P.GetLatestGovernanceOutput) (defMessage & #address .~ "x" & #policyId .~ govPolicy & #blockNo .~ 3))
              expectCode GrpcFailedPrecondition $ call getStore (\c -> streamed c (rpc @P.GetBridgeTxs) (bridgeRequest & #reserveAddress .~ "x" & #afterBlockNo .~ 4 & #toBlockNo .~ 7))
          , testCase "UNAVAILABLE beyond the tip" $ do
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetBlocksByNumberRange) (defMessage & #fromBlockNo .~ 10 & #toBlockNo .~ 13))
              expectCode GrpcUnavailable $ call getStore (\c -> unary c (rpc @P.GetHighestBlockInWindow) (defMessage & #maxBlockNo .~ 13 & #maxSlot .~ 1000 & #maxTimeUnixMillis .~ 2000000))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetBridgeTxs) (bridgeRequest & #afterBlockNo .~ 4 & #toBlockNo .~ 13))
              expectCode GrpcUnavailable $ call getStore (\c -> unary c (rpc @P.GetLatestBlockForEpoch) (defMessage & #epochNo .~ 2))
              expectCode GrpcUnavailable $ call getStore (\c -> unary c (rpc @P.GetLatestTokenOutputForEpoch) (defMessage & #asset .~ assetMessage nightPolicy "" & #epochNo .~ 2))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetUnspentOutputsAtAddress) (defMessage & #address .~ "map" & #blockNo .~ 13))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetMappingRegistrations) (defMessage & #mappingValidatorAddress .~ "map" & #authToken .~ assetMessage authPolicy "" & #window .~ windowMessage (0, 0) (13, 0)))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetMappingDeregistrations) (defMessage & #mappingValidatorAddress .~ "map" & #window .~ windowMessage (0, 0) (13, 0)))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetAssetCreates) (defMessage & #asset .~ assetMessage nightPolicy "" & #window .~ windowMessage (0, 0) (13, 0)))
              expectCode GrpcUnavailable $ call getStore (\c -> streamed c (rpc @P.GetAssetSpends) (defMessage & #asset .~ assetMessage nightPolicy "" & #window .~ windowMessage (0, 0) (13, 0)))
              expectCode GrpcUnavailable $ call getStore (\c -> unary c (rpc @P.GetMaxTxSize) (defMessage & #blockNo .~ 13))
              expectCode GrpcUnavailable $ call getStore (\c -> unary c (rpc @P.GetLatestGovernanceOutput) (defMessage & #address .~ "gov" & #policyId .~ govPolicy & #blockNo .~ 13))
          , testCase "UNAVAILABLE without a database or before the first block" $
              withSystemTempDirectory "mc-follower-server" $ \dir -> do
                let missing = dir </> "missing.db"
                withClient missing (pure notFollowing) $ \c -> do
                  expectCode GrpcUnavailable (unary c (rpc @P.GetLatestBlock) defMessage)
                  expectCode GrpcUnavailable (unary c (rpc @P.GetStatus) defMessage)
                withTestStore $ \path _ ->
                  withClient path (pure notFollowing) $ \c -> do
                    expectCode GrpcUnavailable (unary c (rpc @P.GetLatestBlock) defMessage)
                    expectCode GrpcUnavailable (unary c (rpc @P.GetEpochNonce) defMessage)
                    s <- unary c (rpc @P.GetStatus) defMessage
                    (s ^. #maybe'tip, s ^. #maybe'startBlock) @?= (Nothing, Nothing)
          , testCase "concurrent requests each see a whole answer" $ do
              done <- newEmptyMVar
              results <-
                call getStore $ \c -> do
                  mapM_ (\_ -> forkIO (try @GrpcException (streamed c (rpc @P.GetBlocksByNumberRange) (defMessage & #fromBlockNo .~ 1 & #toBlockNo .~ 12)) >>= putMVar done)) [1 .. 8 :: Int]
                  replicateM 8 (takeMVar done)
              map (fmap (map (^. #blockNo))) results @?= replicate 8 (Right [1 .. 12])
          ]
      ]
 where
  call :: IO (FilePath, Store) -> (Client.Connection -> IO a) -> IO a
  call getStore' k = do
    (path, _) <- getStore'
    withClient path (pure notFollowing) k

{-------------------------------------------------------------------------------
  Helpers
-------------------------------------------------------------------------------}

-- | A unary call.
unary ::
  (Input rpc ~ Proto req, Output rpc ~ Proto resp) =>
  Client.Connection ->
  ClientHandler' 'NonStreaming (ReaderT Client.Connection IO) rpc ->
  req ->
  IO resp
unary c h req = getProto <$> nonStreaming c h (Proto req)

-- | Every element of a server stream, in order.
streamed ::
  (Input rpc ~ Proto req, Output rpc ~ Proto resp) =>
  Client.Connection ->
  ClientHandler' 'ServerStreaming (ReaderT Client.Connection IO) rpc ->
  req ->
  IO [resp]
streamed c h req = serverStreaming c h (Proto req) drain
 where
  drain recv =
    recv >>= \case
      NoNextElem -> pure []
      NextElem x -> (getProto x :) <$> drain recv

expectCode :: GrpcError -> IO a -> Assertion
expectCode code action =
  try action >>= \case
    Left GrpcException {grpcError} -> grpcError @?= code
    Right _ -> assertFailure ("expected " <> show code)

blockNoOf :: P.OptionalBlock -> Maybe Word32
blockNoOf b = (^. #blockNo) <$> b ^. #maybe'block

-- | Block @n@ of the test chain ("Test.McFollower.Chain").
blockMessage :: Word32 -> Word64 -> P.Block
blockMessage n txs =
  defMessage
    & #blockNo .~ n
    & #hash .~ hash32 0xb0 (fromIntegral n)
    & #epochNo .~ n `div` 10
    & #slotNo .~ 10 * fromIntegral n
    & #timeUnixSeconds .~ 1000 + 10 * fromIntegral n
    & #txCount .~ txs

assetMessage :: ByteString -> ByteString -> P.AssetId
assetMessage p n = defMessage & #policyId .~ p & #assetName .~ n

positionMessage :: (Word32, Word32) -> P.Position
positionMessage (b, t) = defMessage & #blockNo .~ b & #txIndex .~ t

windowMessage :: (Word32, Word32) -> (Word32, Word32) -> P.PositionWindow
windowMessage from to = defMessage & #fromInclusive .~ positionMessage from & #toExclusive .~ positionMessage to

bridgeRequest :: P.GetBridgeTxsRequest
bridgeRequest = defMessage & #icsAddress .~ "ics" & #reserveAddress .~ "res" & #token .~ assetMessage nightPolicy ""

bridgeRow :: Word32 -> Word32 -> Maybe ByteString -> Word64 -> Word64 -> Word64 -> Word64 -> P.BridgeTxRow
bridgeRow b t metadatum bridgeIn bridgeOut reserveIn reserveOut =
  defMessage
    & #blockNo .~ b
    & #txIndex .~ t
    & #txHash .~ txHash (fromIntegral b) (fromIntegral t)
    & #maybe'c2mMetadatumCbor .~ metadatum
    & #bridgeIn .~ amount bridgeIn
    & #bridgeOut .~ amount bridgeOut
    & #reserveIn .~ amount reserveIn
    & #reserveOut .~ amount reserveOut
 where
  amount n = defMessage & #hi .~ 0 & #lo .~ n
