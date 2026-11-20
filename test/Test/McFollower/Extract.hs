-- | The extractor on real blocks, stored as fixtures under @test/fixtures@
-- (fetched with @mc-follower fetch-blocks@). Expected values were checked
-- against Koios (db-sync backed) for preview and preprod.
module Test.McFollower.Extract (tests) where

import Cardano.Crypto.Hash.Blake2b (Blake2b_256)
import Cardano.Crypto.Hash.Class (hashFromBytes, hashToBytes, hashWith)
import Cardano.Ledger.Address (serialiseAddr)
import Cardano.Ledger.Binary (decodeFull', shelleyProtVer)
import Cardano.Ledger.Hashes (ScriptHash (..))
import Cardano.Ledger.Mary.Value (PolicyID (..))
import Cardano.Ledger.Metadata (Metadatum (..))
import Cardano.Slotting.Slot (EpochNo (..), SlotNo (..))
import Data.ByteString (ByteString)
import Data.ByteString.Base16 qualified as Base16
import Data.Maybe (fromJust)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Text.Encoding qualified as Text
import Data.Word (Word64)
import McFollower.Address (parseAddress, renderAddress)
import McFollower.BlockFile (readBlockFile)
import McFollower.EraHistory (SlotInfo (..), eraHistory, slotInfo)
import McFollower.Extract
import McFollower.Network (NetworkName (..), codecConfig, networkConfig)
import McFollower.WatchSet (WatchFilter (..), watchFilter, watchPreset)
import System.FilePath ((</>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (Assertion, assertBool, assertFailure, testCase, (@?=))

tests :: TestTree
tests =
  testGroup
    "Extract"
    [ testGroup
        "era history"
        [ testCase "preprod Byron and Shelley slots" $ do
            info Preprod 2 @?= SlotInfo (EpochNo 0) 1654041640
            info Preprod 84242 @?= SlotInfo (EpochNo 3) 1655726440
            info Preprod 86400 @?= SlotInfo (EpochNo 4) 1655769600
            info Preprod 86420 @?= SlotInfo (EpochNo 4) 1655769620
        , testCase "mainnet hard fork boundary" $ do
            info Mainnet 4492799 @?= SlotInfo (EpochNo 207) 1596059071
            info Mainnet 4492800 @?= SlotInfo (EpochNo 208) 1596059091
        , testCase "preview" $ do
            info Preview 0 @?= SlotInfo (EpochNo 0) 1666656000
            info Preview 102336276 @?= SlotInfo (EpochNo 1184) 1768992276
        ]
    , testGroup
        "addresses"
        [ testCase "every preset address is in db-sync's rendering" $
            mapM_ (\n -> either assertFailure (const (pure ())) (watchFilter (watchPreset n))) [minBound .. maxBound]
        , testCase "Byron address round trip" $
            renderAddress <$> parseAddress byronAddress @?= Right byronAddress
        , testCase "rejects text db-sync would not store" $
            assertBool "upper-case bech32" (either (const True) (const False) (parseAddress "ADDR_TEST1VRTFQFX9SKA769YSZFMYVW8JAZN224VJXKYPS42RTPUZ8HGKYMATX"))
        ]
    , testGroup
        "preprod"
        [ testCase "epoch boundary block" $ do
            rows <- extract Preprod noFilter "0.9ad7ff320c9cf74e0f5ee78d22a85ce42bb0a487d0506bf60cfb5a91ea4497d2"
            (brNumber rows, brSlot rows, brEpoch rows, brTime rows, brTxs rows, brPrevHash rows)
              @?= (Nothing, 0, 0, 1654041600, [], Nothing)
        , testCase "first Byron block" $ do
            rows <- extract Preprod noFilter "2.1d031daf47281f69cd95ab929c269fd26b1434a56a5bbbd65b7afe85ef96b233"
            (brNumber rows, brEpoch rows, brTime rows, brPrevHash rows)
              @?= (Just 1, 0, 1654041640, Just (hex "9ad7ff320c9cf74e0f5ee78d22a85ce42bb0a487d0506bf60cfb5a91ea4497d2"))
        , testCase "last Byron block and first Shelley block" $ do
            byron <- extract Preprod noFilter "84242.45899e8002b27df291e09188bfe3aeb5397ac03546a7d0ead93aa2500860f1af"
            shelley <- extract Preprod noFilter "86400.c971bfb21d2732457f9febf79d9b02b20b9a3bef12c561a78b818bcb8b35a574"
            (brNumber byron, brEpoch byron, brTime byron) @?= (Just 45, 3, 1655726440)
            (brNumber shelley, brEpoch shelley, brTime shelley, brPrevHash shelley)
              @?= (Just 46, 4, 1655769600, Just (brHash byron))
        ]
    , testGroup
        "preview"
        [ testCase "phase-2-invalid transaction with collateral return" $ do
            rows <- extract Preview (watching ["addr_test1vrtfqfx9ska769yszfmyvw8jazn224vjxkyps42rtpuz8hgkymatx"] [] []) invalidBlock
            brNumber rows @?= Just 384341
            map trHash (brTxs rows) @?= [hex "65c886d4b9bdce0622c65e68d5d48b38aa3d160de3f18561464f6556bf0a2230"]
            t <- one (brTxs rows)
            -- The collateral input is the spend; the collateral return is
            -- output 1 (one regular output); no witness datums, no metadata.
            trSpends t @?= [OutRef (hex "d3516f2b69077e423e57ef4f50492fcd6f4bb0e70321780a47919367c8f9ca4a") 2]
            map (\o -> (orIndex o, orAddress o, orDatumHash o, orAssets o)) (trOutputs t)
              @?= [(1, "addr_test1vrtfqfx9ska769yszfmyvw8jazn224vjxkyps42rtpuz8hgkymatx", Nothing, [])]
            (trDatums t, trMetadata t) @?= ([], [])
        , testCase "datum hash output whose datum is in the witness set" $ do
            rows <- extract Preview (watching ["addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8"] [] []) witnessBlock
            t <- one (brTxs rows)
            let datumHash = hex "923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec"
            trHash t @?= hex "f929fde71affea64678f7b16c097fa881aa3caa94781afca797618709f3b1f4e"
            map (\o -> (orIndex o, orDatumHash o)) (trOutputs t) @?= [(0, Just datumHash)]
            assertBool "datum bytes recorded" (datumHash `elem` map fst (trDatums t))
            trSpends t @?= [OutRef (hex "b52e0b67eb19bc4b6b9233bfa5c489d5bb0ea0b91d2d415e0413ded57e9b4382") 0]
        , testCase "Byron address, multi-asset output, metadata" $ do
            rows <- extract Preview (watching [byronAddress] [dripPolicy] [674]) byronAddressBlock
            (t0, t1) <- two (brTxs rows)
            trHash t0 @?= hex "49ae76cac48bf43a7907c435f310e0268add2146d32910d28ec0c6a85ecead1e"
            map orAddress (trOutputs t0) @?= [byronAddress]
            trHash t1 @?= hex "11be0d59e2112db9bd14d4b68b7b0d06c192dac12a7874ff8cc38a152f66175d"
            -- Watched by policy: only the assets of watched policies are kept.
            map (\o -> (orIndex o, orAssets o)) (trOutputs t1)
              @?= [ ( 0
                    ,
                      [ (dripPolicy, "BLUE", 636)
                      , (dripPolicy, "GREEN", 327)
                      , (dripPolicy, "PURPLE", 191)
                      , (dripPolicy, "RAINBOW", 725)
                      , (dripPolicy, "RED", 263)
                      , (dripPolicy, "YELLOW", 413)
                      ]
                    )
                  ]
            map fst (trMetadata t1) @?= [674]
            -- The label's metadatum, re-serialised by the ledger encoder.
            decodeFull' shelleyProtVer (snd (head (trMetadata t1)))
              @?= Right
                ( Map
                    [ ( S "msg"
                      , List [S "\128075", S "How much does a hipster weigh?", S "\129300", S "", S "An instagram.", S "\128540"]
                      )
                    ]
                )
        , testCase "Midnight governance, ICS, reserve and permissioned outputs (preset watch set)" $ do
            wf <- either fail pure (watchFilter (watchPreset Preview))
            rows <- extract Preview wf governanceBlock
            (brNumber rows, brEpoch rows, brTime rows, length (brTxs rows)) @?= (Just 3948762, 1179, 1768532786, 11)
            let watched =
                  [ (trHash t, orIndex o, orAddress o, orDatumHash o, orAssets o)
                  | t <- brTxs rows
                  , o <- trOutputs t
                  ]
            watched
              @?= [ out "c8bc37ba15c96e698b59b31fdb01f631dfef256dcb32df0aeccaf600028f7fde" "addr_test1wptcy7h9rmkhdnhn3jvm6tuhehcq2hhhzntvn00nq79ph8c44v43j" ("3854dae8d118fcf0d129d2cd7725d5534677c14259b172791e1335d62f743381", "57827ae51eed76cef38c99bd2f97cdf0055ef714d6c9bdf3078a1b9f")
                  , out "7fdd3056ababd8a752e685ef5e50dde30295e69df5ff171b75958c15e68b98b6" "addr_test1wzy47zdsq22pg9l48c5v0f835ljdjzkz47sa5za9cehcejcw28k2d" ("0717078621d0723358001558097edcc6d66de721098949eae87270bc3d6afe41", "895f09b002941417f53e28c7a4f1a7e4d90ac2afa1da0ba5c66f8ccb")
                  , out "a539270887861da9890042aa07248786dae7df904f1b4d30e6bb217d3b8cf149" "addr_test1wzdpdpyev08npr3ktyy9dskvh2v9wk3vphamd6kk60qmjtgftyu2n" ("8083c2a15e2830de23226540e3765aacb3a54a8e8eb7b92ed9ef128349997418", "9a16849963cf308e36590856c2ccba98575a2c0dfbb6ead6d3c1b92d")
                  , out "3724b9fd138acd7c2bf089a35e7955c0e28fc506be285ca1cc00fcd2faf2cce6" "addr_test1wzga9g4tw69twfvpjynyvdyzvpf5f0e88v6hnu9eh9qgdnqaw66xk" ("8083c2a15e2830de23226540e3765aacb3a54a8e8eb7b92ed9ef128349997418", "91d2a2ab768ab725819126463482605344bf273b3579f0b9b94086cc")
                  , out "6aecb0ed06cd76c7533d731766316492850f1ec3c17663a7cc6f8acc31109cee" "addr_test1wqjden7wy4m2uma8zjdufpv9qet2uma0naq43zgnzemn57qra54ul" ("4ff005d2a3e187838f132ac0f7acf0c36e53580ee70b9d7960a8913937829a2d", "24dccfce2576ae6fa7149bc485850656ae6faf9f4158891316773a78")
                  ]
        , testCase "every recorded datum hashes to its key" $
            mapM_
              ( \file -> do
                  rows <- extract Preview noFilter file
                  mapM_ checkDatum (concatMap trDatums (brTxs rows))
              )
              [invalidBlock, witnessBlock, byronAddressBlock, governanceBlock]
        ]
    ]
 where
  info network slot = either (error . show) id (slotInfo (eraHistory network) (SlotNo slot))
  -- Each of these transactions creates its watched output at index 2,
  -- holding one NFT of a watched policy or at a watched address.
  out txHash address (datum, policy) = (hex txHash, 2, address, Just (hex datum), [(hex policy, "", 1)])

invalidBlock, witnessBlock, byronAddressBlock, governanceBlock :: FilePath
invalidBlock = "8175489.ae021d065473d38dfdf58f903cfc6ca63a26f0364aa1dfcaa219fc580aa084ce"
witnessBlock = "6355642.c837f202b94371deac9223559154b5e52847f43471ed9472de0fb8f8304fabf6"
byronAddressBlock = "6613402.d271b249a010dae607c00505181001494da60e8b91c032804d6c9f56cf683112"
governanceBlock = "101876786.2dbb64f446b3cab3a5e80ea8e15004c345824df0e74163bc446c63fe764da2e0"

byronAddress :: Text
byronAddress = "FHnt4NL7yPY3jQSVFSzhkbzF9d8TKVXaAZme7hYM4psNcH9AkxCpjJoRK9c4UpQ"

dripPolicy :: ByteString
dripPolicy = hex "c462512684cf5a5ee0b176326c724d5879a37a4977d3bf1e4edc39f6"

extract :: NetworkName -> WatchFilter -> FilePath -> IO BlockRows
extract network wf file = do
  let path = "test" </> "fixtures" </> networkDir network </> file <> ".cbor"
  blk <- readBlockFile (codecConfig (networkConfig network)) path >>= either fail pure
  either (fail . show) pure (extractBlock wf (eraHistory network) blk)
 where
  networkDir = \case
    Mainnet -> "mainnet"
    Preprod -> "preprod"
    Preview -> "preview"

noFilter :: WatchFilter
noFilter = watching [] [] []

watching :: [Text] -> [ByteString] -> [Word64] -> WatchFilter
watching addresses policies labels =
  WatchFilter
    { wfAddresses = Set.fromList [serialiseAddr (either error id (parseAddress a)) | a <- addresses]
    , wfInputListAddresses = Set.empty
    , wfPolicies = Set.fromList [PolicyID (ScriptHash (fromJust (hashFromBytes p))) | p <- policies]
    , wfMetadataLabels = Set.fromList labels
    }

checkDatum :: (ByteString, ByteString) -> Assertion
checkDatum (key, bytes) = hashToBytes (hashWith @Blake2b_256 id bytes) @?= key

hex :: Text -> ByteString
hex = either error id . Base16.decode . Text.encodeUtf8

one :: [a] -> IO a
one = \case
  [x] -> pure x
  xs -> assertFailure ("expected one transaction, got " <> show (length xs))

two :: [a] -> IO (a, a)
two = \case
  [x, y] -> pure (x, y)
  xs -> assertFailure ("expected two transactions, got " <> show (length xs))
