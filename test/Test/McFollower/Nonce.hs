-- | The nonce driver on recorded preview headers: epoch transition,
-- rollback, resumption, and the era history it relies on.
module Test.McFollower.Nonce (tests) where

import Cardano.Crypto.Hash (hashFromBytes)
import Cardano.Ledger.BaseTypes (mkNonceFromNumber, (⭒))
import Cardano.Ledger.Keys (KeyHash (..))
import Data.ByteString qualified as BS
import Data.Maybe (fromMaybe)
import Cardano.Slotting.EpochInfo (epochInfoEpoch, epochInfoFirst)
import Cardano.Slotting.Slot (EpochNo (..), SlotNo (..), WithOrigin (..))
import Control.Monad (foldM)
import Control.Monad.Except (Except, runExcept)
import Data.List.NonEmpty qualified as NonEmpty
import Data.Map.Strict qualified as Map
import McFollower.Block (Block, Era (..), parsePoint)
import McFollower.BlockSource (ChainEvent (..))
import McFollower.EpochData.Store
  ( EpochDataError (..)
  , EpochDataStore (..)
  , InMemoryEpochData (..)
  , applyChainEvent
  , newInMemoryStore
  , recordStart
  )
import McFollower.EpochNonceTable (NonceConflict (..), NonceTable (..))
import McFollower.EraHistory
  ( EraHistoryError (..)
  , PraosEra (..)
  , epochInfoAt
  , historyTransitions
  , observeEra
  , praosConsensusConfig
  , presetHistory
  )
import McFollower.Network (NetworkName (..), chainParams)
import McFollower.Nonce
import McFollower.Nonce.TrustedState
  ( TrustedState (..)
  , decodePraosState
  , encodePraosState
  , parseTrustedState
  , renderTrustedState
  )
import Data.Text.Encoding qualified as Text
import Ouroboros.Consensus.Block (Header, Point, blockPoint, getHeader)
import Ouroboros.Consensus.Protocol.Praos
  ( ConsensusConfig (..)
  , PraosParams (..)
  , PraosState (..)
  )
import Ouroboros.Network.Block (Tip (..))
import Test.McFollower.Fixtures (boundaryBlocksFile, hexNonce, loadBlocks)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertFailure, testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Nonce"
    [ testGroup "era history" eraHistoryTests
    , testGroup "driver" driverTests
    , testCase "PraosState and trusted state round-trip through their encodings" $ do
        decodePraosState (encodePraosState (tsState start)) @?= Right (tsState start)
        parseTrustedState (Text.encodeUtf8 (renderTrustedState start)) @?= Right start
    ]

-- | The value of an epoch-info query, if within the horizon.
known :: Except e a -> Maybe a
known = either (const Nothing) Just . runExcept

eraHistoryTests :: [TestTree]
eraHistoryTests =
  [ testCase "preview: slot to epoch and first slot" $ do
      let ei = epochInfoAt (presetHistory (chainParams Preview)) (SlotNo 128476806)
      known (epochInfoEpoch ei (SlotNo 128476806)) @?= Just (EpochNo 1487)
      known (epochInfoEpoch ei (SlotNo 128476799)) @?= Just (EpochNo 1486)
      known (epochInfoFirst ei (EpochNo 1488)) @?= Just (SlotNo 128563200)
  , testCase "mainnet: Byron epochs of 21600 slots, then 432000" $ do
      let ei = epochInfoAt (presetHistory (chainParams Mainnet)) (SlotNo 133660800)
      known (epochInfoEpoch ei (SlotNo 4492799)) @?= Just (EpochNo 207)
      known (epochInfoFirst ei (EpochNo 208)) @?= Just (SlotNo 4492800)
      known (epochInfoFirst ei (EpochNo 507)) @?= Just (SlotNo 133660800)
  , testCase "preprod: four Byron epochs" $ do
      let ei = epochInfoAt (presetHistory (chainParams Preprod)) (SlotNo 68774400)
      known (epochInfoFirst ei (EpochNo 4)) @?= Just (SlotNo 86400)
      known (epochInfoFirst ei (EpochNo 163)) @?= Just (SlotNo 68774400)
  , testCase "randomness stabilisation window: 3k/f in Babbage, 4k/f after" $ do
      let window net era =
            praosRandomnessStabilisationWindow . praosParams $
              praosConsensusConfig (chainParams net) era (epochInfoAt (presetHistory (chainParams net)) 0)
      map (window Preview) [PraosBabbage, PraosConway, PraosDijkstra] @?= [25920, 34560, 34560]
      map (window Mainnet) [PraosBabbage, PraosConway, PraosDijkstra] @?= [129600, 172800, 172800]
  , testCase "a header of the era after the last known one adds the transition" $ do
      let h = presetHistory (chainParams Preview)
      case observeEra Dijkstra (SlotNo 128563210) h of
        Left e -> assertFailure (show e)
        Right h' -> historyTransitions h' @?= map EpochNo [0, 0, 0, 0, 3, 646, 1488]
  , testCase "a header of an era the history places elsewhere is rejected" $
      case observeEra Babbage (SlotNo 128476806) (presetHistory (chainParams Preview)) of
        Left (EraMismatch Babbage Conway _) -> pure ()
        other -> assertFailure (show other)
  ]

-- | The block before the recorded ones: preview 4874014, epoch 1486.
startPoint :: Point Block
startPoint = either error id (parsePoint "128476714.539b4c8771ada4e6bdce51a84e87d196bba256c0b39d236d1a8f5acfc67b6f66")

-- | A made-up starting state at 'startPoint'. The driver does not validate
-- headers, so any nonces will do; distinct ones make the transitions
-- visible.
start :: TrustedState
start =
  TrustedState
    startPoint
    PraosState
      { praosStateLastSlot = At (SlotNo 128476714)
      , praosStateOCertCounters = Map.empty
      , praosStateEvolvingNonce = mkNonceFromNumber 1
      , praosStateCandidateNonce = mkNonceFromNumber 2
      , praosStateEpochNonce = mkNonceFromNumber 3
      , praosStatePreviousEpochNonce = mkNonceFromNumber 4
      , praosStateLabNonce = mkNonceFromNumber 5
      , praosStateLastEpochBlockNonce = mkNonceFromNumber 6
      }

previewDriver :: NonceDriver
previewDriver = startDriver (nonceConfig (chainParams Preview)) start

applyAll :: NonceDriver -> [Header Block] -> Either NonceError (NonceDriver, [Checkpoint])
applyAll d0 = foldM step (d0, [])
 where
  step (d, cps) h = fmap (\(d', cp) -> (d', cps <> [cp])) (applyHeader h d)

expectRight :: Show e => Either e a -> IO a
expectRight = either (assertFailure . show) pure

driverTests :: [TestTree]
driverTests =
  [ testCase "the first block of epoch 1487 produces its nonce" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (_, cps) <- expectRight (applyAll previewDriver hdrs)
      map cpNewEpochNonce cps
        @?= [ Nothing
            , Nothing
            , Nothing
            , -- The last blocks of 1486 are past the stabilisation window,
              -- so the candidate nonce is still the starting one (2), and
              -- the last-epoch-block nonce is the starting one (6).
              Just (EpochNonce (EpochNo 1487) (mkNonceFromNumber 2 ⭒ mkNonceFromNumber 6))
            , Nothing
            , Nothing
            ]
  , testCase "after the boundary: previous epoch nonce and last-epoch-block nonce" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (_, cps) <- expectRight (applyAll previewDriver hdrs)
      let st = cpState (cps !! 3)
      praosStatePreviousEpochNonce st @?= mkNonceFromNumber 3
      -- The previous hash of 4874017, the last block of 1486: the hash of
      -- 4874016. The node reports the same value for epoch 1487
      -- (Ogmios @lastEpochLastAncestor@, test/data/preview-ogmios-*.json).
      praosStateLastEpochBlockNonce st @?= expectNonce "89cf6db5ba7fa2e85a4bf7310491024d9c4f4019d44157099f35ab9d15198015"
      -- Early in the epoch the candidate nonce follows the evolving one.
      praosStateCandidateNonce st @?= praosStateEvolvingNonce st
      praosStateOCertCounters st @?= Map.empty
  , testCase "rolling back across the boundary restores the state and retracts the epoch nonce" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (d, cps) <- expectRight (applyAll previewDriver hdrs)
      (d', retracted) <- expectRight (rollBackTo (cpPoint (cps !! 2)) d)
      retracted @?= [EpochNo 1487]
      driverTip d' @?= cps !! 2
      (d'', cps') <- expectRight (applyAll d' (drop 3 hdrs))
      cps' @?= drop 3 cps
      driverTip d'' @?= driverTip d
  , testCase "rolling back to the starting point" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (d, _) <- expectRight (applyAll previewDriver hdrs)
      (d', retracted) <- expectRight (rollBackTo startPoint d)
      retracted @?= [EpochNo 1487]
      cpState (driverTip d') @?= tsState start
  , testCase "a rollback to an unknown point fails" $ do
      blocks <- loadBlocks boundaryBlocksFile
      (d, _) <- expectRight (applyAll previewDriver (map getHeader (take 2 blocks)))
      case rollBackTo (blockPoint (blocks !! 4)) d of
        Left (RollbackBeyondWindow _ oldest) -> oldest @?= startPoint
        Left e -> assertFailure (show e)
        Right _ -> assertFailure "rolled back to a point it never saw"
  , testCase "a header that does not extend the tip is rejected" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      case applyHeader (hdrs !! 2) previewDriver of
        Left (DoesNotExtend tip _) -> tip @?= startPoint
        other -> assertFailure (show (fmap snd other))
  , testCase "resuming from stored checkpoints continues identically" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (_, cps) <- expectRight (applyAll previewDriver hdrs)
      (_, firstThree) <- expectRight (applyAll previewDriver (take 3 hdrs))
      let resumed = resumeDriver (nonceConfig (chainParams Preview)) (NonEmpty.fromList firstThree)
      (_, rest) <- expectRight (applyAll resumed (drop 3 hdrs))
      rest @?= drop 3 cps
  , testCase "the in-memory store follows forward and backward events" $ do
      blocks <- loadBlocks boundaryBlocksFile
      (store, contents) <- newInMemoryStore 433
      _ <- expectRight =<< recordStart noTable store previewDriver
      let tip = TipGenesis
          forward d b = expectRight =<< applyChainEvent noTable store (RollForward (getHeader b, []) tip) d
      d <- foldM forward previewDriver blocks
      loadEpochNonce store (EpochNo 1486) >>= (@?= Just (mkNonceFromNumber 3))
      loadEpochNonce store (EpochNo 1487) >>= (@?= Just (mkNonceFromNumber 2 ⭒ mkNonceFromNumber 6))
      _ <- expectRight =<< applyChainEvent noTable store (RollBackward (blockPoint (blocks !! 1)) tip) d
      loadEpochNonce store (EpochNo 1487) >>= (@?= Nothing)
      Map.keys . imEpochNonces <$> contents >>= (@?= [EpochNo 1486])
      map cpPoint <$> loadCheckpoints store >>= (@?= [startPoint, blockPoint (blocks !! 0), blockPoint (blocks !! 1)])
  , testCase "cross-check against a node state" $ do
      hdrs <- map getHeader <$> loadBlocks boundaryBlocksFile
      (d, cps) <- expectRight (applyAll previewDriver hdrs)
      let cp = cps !! 4
          -- A node's state has operational certificate counters; they are
          -- not compared.
          issuer = KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 0)))
          node = (cpState cp) {praosStateOCertCounters = Map.singleton issuer 7}
      crossCheck (cpPoint cp) node d @?= Agree (cpPoint cp)
      crossCheck (cpPoint cp) node {praosStateCandidateNonce = mkNonceFromNumber 9} d
        @?= Diverge (cpPoint cp) [CandidateNonce (praosStateCandidateNonce (cpState cp)) (mkNonceFromNumber 9)]
      crossCheck (cpPoint (cps !! 2)) node (fst (either (error . show) id (rollBackTo startPoint d)))
        @?= NotInWindow (cpPoint (cps !! 2))
  , testCase "a driver nonce that differs from the table's is a hard error" $ do
      blocks <- loadBlocks boundaryBlocksFile
      (store, contents) <- newInMemoryStore 433
      let table = NonceTable (EpochNo 1487) (EpochNo 1487) (Map.singleton (EpochNo 1487) (mkNonceFromNumber 42))
          tip = TipGenesis
          forward d b = applyChainEvent table store (RollForward (getHeader b, []) tip) d
      d3 <- foldM (\d b -> expectRight =<< forward d b) previewDriver (take 3 blocks)
      forward d3 (blocks !! 3) >>= \case
        Left (TableConflict c) -> c @?= NonceConflict (EpochNo 1487) (mkNonceFromNumber 42) (mkNonceFromNumber 2 ⭒ mkNonceFromNumber 6)
        Left e -> assertFailure (show e)
        Right _ -> assertFailure "conflicting nonce accepted"
      -- Nothing was recorded for the rejected block.
      length . imCheckpoints <$> contents >>= (@?= 3)
  ]
 where
  expectNonce t = either error id (hexNonce t)
  -- A table that covers none of the recorded epochs.
  noTable = NonceTable (EpochNo 0) (EpochNo 0) (Map.singleton (EpochNo 0) (mkNonceFromNumber 0))
