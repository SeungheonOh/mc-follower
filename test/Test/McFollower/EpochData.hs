-- | Stake labels, the Mithril artifact decoding and the @maxTxSize@
-- tripwire.
module Test.McFollower.EpochData (tests) where

import Cardano.Crypto.Hash (hashFromBytes, hashFromTextAsHex)
import Cardano.Crypto.Hash qualified as Hash
import Cardano.Ledger.Address (AccountAddress (..), AccountId (..))
import Cardano.Ledger.BaseTypes (Anchor (..), Network (Testnet), textToUrl)
import Cardano.Ledger.Credential (Credential (..))
import Cardano.Ledger.Hashes (unsafeMakeSafeHash)
import Cardano.Ledger.Api.State.Query (StakeSnapshot (..), StakeSnapshots (..))
import Cardano.Ledger.Babbage (BabbageEra)
import Cardano.Ledger.BaseTypes (StrictMaybe (..), unsafeNonZero)
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Conway (ConwayEra)
import Cardano.Ledger.Conway.Governance (GovAction (..), ProposalProcedure (..))
import Cardano.Ledger.Conway.TxBody (ConwayEraTxBody (..))
import Cardano.Ledger.Core
  ( EraTx (..)
  , EraTxBody (..)
  , emptyPParamsUpdate
  , ppuMaxTxSizeL
  , ppuMaxBBSizeL
  , txIdTxBody
  , TxLevel (..)
  )
import Cardano.Ledger.Keys (KeyHash (..), KeyRole (..))
import Cardano.Ledger.Shelley.PParams (ProposedPPUpdates (..), Update (..))
import Cardano.Ledger.Shelley.TxBody (ShelleyEraTxBody (..))
import Cardano.Slotting.Slot (EpochNo (..))
import Data.Aeson qualified as Aeson
import Data.ByteString qualified as BS
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.OSet.Strict qualified as OSet
import Data.Set qualified as Set
import Data.Text (Text)
import Lens.Micro ((&), (.~), (^.))
import McFollower.EpochData.MaxTxSize
import McFollower.EpochData.Mithril
  ( MithrilStakeDistribution (..)
  , labelForStakeEpoch
  , stakeEpochOfLabel
  , toEpochStake
  )
import McFollower.EpochData.Stake
import McFollower.Block (parsePoint)
import McFollower.Network (NetworkName (..))
import Ouroboros.Consensus.Block (blockPoint)
import Test.McFollower.Fixtures (loadBlocks, proposalBlockFile, boundaryBlocksFile)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertFailure, testCase, (@?=))

tests :: TestTree
tests = testGroup "EpochData" [stakeTests, mithrilTests, maxTxSizeTests]

pool :: Word -> KeyHash StakePool
pool n = KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 (fromIntegral n))))

stakeTests :: TestTree
stakeTests =
  testGroup
    "stake"
    [ testCase "go, set and mark are the distributions for e - 1, e and e + 1" $
        map (\es -> (esEpoch es, esPools es, esComplete es, esSource es)) (stakeFromSnapshots Immutable (EpochNo 100) snapshots)
          @?= [ (EpochNo 99, Map.fromList [(pool 2, Coin 7)], True, FromNodeSnapshot Go (EpochNo 100))
              , (EpochNo 100, Map.fromList [(pool 1, Coin 20), (pool 2, Coin 5)], True, FromNodeSnapshot Set (EpochNo 100))
              , (EpochNo 101, Map.fromList [(pool 1, Coin 10)], True, FromNodeSnapshot Mark (EpochNo 100))
              ]
    , testCase "mark from a volatile state is incomplete" $
        map esComplete (stakeFromSnapshots Volatile (EpochNo 100) snapshots) @?= [True, True, False]
    , testCase "epoch 0 has no previous epoch" $
        map esEpoch (stakeFromSnapshots Immutable (EpochNo 0) snapshots) @?= [EpochNo 0, EpochNo 1]
    ]
 where
  -- Pool 1 has no stake in go, pool 2 none in mark, pool 3 none at all
  -- (listed as the ledger does before protocol version 11).
  snapshots =
    StakeSnapshots
      { ssStakeSnapshots =
          Map.fromList
            [ (pool 1, StakeSnapshot (Coin 10) (Coin 20) (Coin 0))
            , (pool 2, StakeSnapshot (Coin 0) (Coin 5) (Coin 7))
            , (pool 3, StakeSnapshot (Coin 0) (Coin 0) (Coin 0))
            ]
      , ssMarkTotal = unsafeNonZero (Coin 10)
      , ssSetTotal = unsafeNonZero (Coin 25)
      , ssGoTotal = unsafeNonZero (Coin 7)
      }

mithrilTests :: TestTree
mithrilTests =
  testGroup
    "Mithril"
    [ testCase "label L is the stake distribution for epoch L + 2" $ do
        stakeEpochOfLabel (EpochNo 1484) @?= EpochNo 1486
        labelForStakeEpoch (EpochNo 1486) @?= Just (EpochNo 1484)
        labelForStakeEpoch (EpochNo 1) @?= Nothing
    , testCase "an artifact decodes, pool ids as key hashes" $
        case Aeson.eitherDecode artifact of
          Left e -> assertFailure e
          Right sd -> do
            msdLabel sd @?= EpochNo 1484
            msdCertificateHash sd @?= "5d4caf019fa39710659a53d665b091259b2e150df444415b511c3754a10b70cb"
            msdPools sd
              @?= Map.fromList
                [ (keyHash "7bce4fc16f1108a84f2e6273209b78cfc2c323f20e8664deb787b18a", Coin 1200000000)
                , (keyHash "7d579e1d729463d8fc185c53eee0b7feb276977cc52a7b458ceb3ad6", Coin 0)
                ]
            let es = toEpochStake sd
            esEpoch es @?= EpochNo 1486
            Map.size (esPools es) @?= 1
            esComplete es @?= True
    , testCase "a pool id with the wrong prefix is rejected" $
        case Aeson.eitherDecode @MithrilStakeDistribution (artifactWith "stake1008ylst0zyy2snewvfejpxmcelpvxgljp6rxfh4hs7cc5cu8x59") of
          Left _ -> pure ()
          Right _ -> assertFailure "decoded a non-pool bech32 id"
    ]
 where
  keyHash :: Text -> KeyHash StakePool
  keyHash = KeyHash . fromMaybe (error "hex") . hashFromTextAsHex
  -- Shape and two entries of the preview artifact labelled 1484 (the
  -- second amount changed to 0).
  artifact =
    "{\"epoch\":1484,\"hash\":\"f749731804b1e31c16a9e2208da8dd19ed44d050c943927fc63b5c83fd6bba9d\",\
    \\"certificate_hash\":\"5d4caf019fa39710659a53d665b091259b2e150df444415b511c3754a10b70cb\",\
    \\"stake_distribution\":{\"pool1008ylst0zyy2snewvfejpxmcelpvxgljp6rxfh4hs7cc5cu8x59\":1200000000,\
    \\"pool104teu8tjj33a3lqct3f7ac9hl6e8d9muc548k3vvavadvk6s3pc\":0},\
    \\"created_at\":\"2026-11-18T00:05:27.190329384Z\"}"
  artifactWith poolId =
    "{\"epoch\":1484,\"hash\":\"00\",\"certificate_hash\":\"00\",\"stake_distribution\":{\""
      <> poolId
      <> "\":1},\"created_at\":\"2026-11-18T00:05:27Z\"}"

maxTxSizeTests :: TestTree
maxTxSizeTests =
  testGroup
    "maxTxSize"
    [ testCase "a recorded Conway ParameterChange proposal is sighted" $ do
        [blk] <- loadBlocks proposalBlockFile
        scanBlock (EpochNo 1350) blk
          @?= [ MaxTxSizeSighting
                  { mssProposal = either error id (parseProposalRef "8b5f096ad63618f1b73112d8ac46fb59519897cbfa318fdb9ffed2dfcee782e4#0")
                  , mssPoint = blockPoint blk
                  , mssProposedValue = 16400
                  , mssEarliestEpoch = EpochNo 1352
                  }
              ]
    , testCase "blocks without such proposals give nothing" $ do
        blocks <- loadBlocks boundaryBlocksFile
        concatMap (scanBlock (EpochNo 1487)) blocks @?= []
    , testCase "a Conway ParameterChange not touching maxTxSize is ignored" $ do
        let update = emptyPParamsUpdate & ppuMaxBBSizeL .~ SJust 90000
            body = conwayBody (ParameterChange SNothing update SNothing)
        proposalSightings (EpochNo 10) somePoint body @?= []
    , testCase "a Conway ParameterChange setting maxTxSize: earliest epoch e + 2" $ do
        let update = emptyPParamsUpdate & ppuMaxTxSizeL .~ SJust 20000
            body = conwayBody (ParameterChange SNothing update SNothing)
        proposalSightings (EpochNo 10) somePoint body
          @?= [MaxTxSizeSighting (GovernanceAction (txIdTxBody body) 0) somePoint 20000 (EpochNo 12)]
    , testCase "a Babbage update proposal for epoch t: earliest epoch t + 1" $ do
        let genesisKey = KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 9)))
            update u = Update (ProposedPPUpdates (Map.singleton genesisKey u)) (EpochNo 400)
            tx u = mkBasicTx (mkBasicTxBody & updateTxBodyL .~ SJust (update u)) :: Tx TopTx BabbageEra
            setting = emptyPParamsUpdate & ppuMaxTxSizeL .~ SJust 32768
            other = emptyPParamsUpdate & ppuMaxBBSizeL .~ SJust 90000
        updateSightings somePoint (tx setting)
          @?= [ MaxTxSizeSighting
                  (UpdateProposal (txIdTxBody (tx setting ^. bodyTxL)) genesisKey)
                  somePoint
                  32768
                  (EpochNo 401)
              ]
        updateSightings somePoint (tx other) @?= []
    , testCase "the table is a step function from its first epoch" $ do
        let table = MaxTxSizeTable [(EpochNo 5, 100), (EpochNo 1, 50)]
        map (tableLookup table . EpochNo) [0, 1, 4, 5, 9] @?= [Nothing, Just 50, Just 50, Just 100, Just 100]
    , testCase "presets: 16384 from the first Shelley epoch" $ do
        tableLookup (maxTxSizePreset Mainnet) (EpochNo 207) @?= Nothing
        tableLookup (maxTxSizePreset Mainnet) (EpochNo 208) @?= Just 16384
        tableLookup (maxTxSizePreset Preprod) (EpochNo 4) @?= Just 16384
        tableLookup (maxTxSizePreset Preview) (EpochNo 0) @?= Just 16384
    , testCase "an unacknowledged sighting blocks its earliest epoch and later" $ do
        let s = MaxTxSizeSighting proposal somePoint 16400 (EpochNo 1352)
            table = maxTxSizePreset Preview
        lookupMaxTxSize table Set.empty [s] (EpochNo 1351) @?= Right 16384
        lookupMaxTxSize table Set.empty [s] (EpochNo 1352) @?= Left (UnconfirmedProposal (EpochNo 1352) [s])
        lookupMaxTxSize table Set.empty [s] (EpochNo 1400) @?= Left (UnconfirmedProposal (EpochNo 1400) [s])
        lookupMaxTxSize table (Set.singleton proposal) [s] (EpochNo 1400) @?= Right 16384
        lookupMaxTxSize (maxTxSizePreset Mainnet) Set.empty [] (EpochNo 100) @?= Left (NotCovered (EpochNo 100))
    , testCase "preview's known proposals are acknowledged by its preset" $ do
        let s = MaxTxSizeSighting proposal somePoint 16400 (EpochNo 1352)
        lookupMaxTxSize (maxTxSizePreset Preview) (acknowledgedPreset Preview) [s] (EpochNo 1400) @?= Right 16384
        Set.size (acknowledgedPreset Preview) @?= 4
        acknowledgedPreset Mainnet @?= Set.empty
    , testCase "proposal references round-trip through text" $ do
        parseProposalRef (renderProposalRef proposal) @?= Right proposal
        let update = UpdateProposal txId (KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 3))))
        parseProposalRef (renderProposalRef update) @?= Right update
    ]
 where
  somePoint = either error id (parsePoint "116681054.e18d47f3efe663b253d55263045f6bc12c9205d6a604483ae02581602f0a491a")
  proposal = either error id (parseProposalRef "8b5f096ad63618f1b73112d8ac46fb59519897cbfa318fdb9ffed2dfcee782e4#0")
  txId = case proposal of
    GovernanceAction t _ -> t
    UpdateProposal t _ -> t
  conwayBody action =
    mkBasicTxBody
      & proposalProceduresTxBodyL
        .~ OSet.singleton
          ProposalProcedure
            { pProcDeposit = Coin 1
            , pProcReturnAddr = AccountAddress Testnet (AccountId (KeyHashObj (KeyHash (hash28 4))))
            , pProcGovAction = action
            , pProcAnchor = Anchor (fromMaybe (error "url") (textToUrl 64 "https://example.org")) (unsafeMakeSafeHash (hash32 5))
            } ::
      TxBody TopTx ConwayEra
  hash28 :: Word -> Hash.Hash Hash.Blake2b_224 a
  hash28 n = fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 (fromIntegral n)))
  hash32 :: Word -> Hash.Hash Hash.Blake2b_256 a
  hash32 n = fromMaybe (error "32 bytes") (hashFromBytes (BS.replicate 32 (fromIntegral n)))
