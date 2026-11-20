{-# LANGUAGE RecordWildCards #-}

-- | What the indexer stores beyond the block and transaction index: the
-- Midnight addresses, policies and metadata label of one network, with
-- presets for mainnet, preprod and preview.
--
-- The rule derived from a 'WatchConfig' ('WatchFilter') is:
--
-- * every output at a named address is stored, with all its assets;
-- * every output carrying a token of a named policy is stored, at any
--   address, with the assets of named policies only;
-- * the full input list is stored for every transaction that creates an
--   output at the committee-candidate address;
-- * the bridge metadata label is stored for every valid transaction that
--   carries it.
--
-- A query naming an address or policy outside this set cannot be answered
-- like db-sync would ('isWatchedAddress', 'isWatchedPolicy').
module McFollower.WatchSet
  ( -- * Configuration
    WatchConfig (..)
  , GovernanceBody (..)
  , BridgeWatch (..)
  , AssetId (..)
  , watchPreset
  , startPointPreset
  , renderWatchConfig

    -- * Derived filter
  , WatchFilter (..)
  , watchFilter
  , isWatchedAddress
  , isWatchedPolicy
  , recordsInputLists
  ) where

import Cardano.Crypto.Hash.Class (hashFromBytes)
import Cardano.Ledger.Address (serialiseAddr)
import Cardano.Ledger.Hashes (ScriptHash (..))
import Cardano.Ledger.Mary.Value (PolicyID (..))
import Data.ByteString (ByteString)
import Data.ByteString.Base16 qualified as Base16
import Data.Set (Set)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import Data.Word (Word64)
import McFollower.Address (parseAddress)
import McFollower.Block (Block, parsePoint)
import McFollower.Network (NetworkName (..))
import Ouroboros.Consensus.Block (Point)

-- | A native asset: 28-byte policy id and 0 to 32-byte name.
data AssetId = AssetId
  { assetPolicy :: !ByteString
  , assetName :: !ByteString
  }
  deriving stock (Eq, Ord, Show)

data GovernanceBody = GovernanceBody
  { gbAddress :: !Text
  , gbPolicy :: !ByteString
  }
  deriving stock (Eq, Show)

data BridgeWatch = BridgeWatch
  { bwIcsAddress :: !Text
  , bwReserveAddress :: !Text
  , bwToken :: !AssetId
  , bwMetadataLabel :: !Word64
  }
  deriving stock (Eq, Show)

-- | The Midnight main-chain scripts of one network. Addresses are in
-- db-sync's rendering ("McFollower.Address").
data WatchConfig = WatchConfig
  { wcCNight :: !AssetId
  , wcMappingValidatorAddress :: !Text
  , wcCouncil :: !GovernanceBody
  , wcTechnicalCommittee :: !GovernanceBody
  , wcPermissionedCandidatesPolicy :: !ByteString
  , wcCommitteeCandidateAddress :: !Text
  , wcBridge :: !BridgeWatch
  }
  deriving stock (Eq, Show)

-- | Values from @midnight-node/res/<network>/chain-spec.json@ (genesis
-- runtime config: @cNightObservation.config.addresses@,
-- @federatedAuthorityObservation@,
-- @sessionCommitteeManagement.mainChainScripts@, @bridge.mainChainScripts@),
-- which agree with the per-file copies named next to each value. The bridge
-- metadata label is partner-chains' @TOKEN_TRANSFER_METADATUM_KEY@
-- (@toolkit/smart-contracts/plutus-data/src/bridge.rs@).
watchPreset :: NetworkName -> WatchConfig
watchPreset = \case
  Mainnet ->
    WatchConfig
      { -- cnight-addresses.json
        wcCNight = asset "0691b2fecca1ac4f53cb6dfb00b7013e561d1f34403b957cbb5af1fa" "NIGHT"
      , wcMappingValidatorAddress = "addr1w9e7ft4rrdd4rkdseguxr9hudfxyytm5ckh2qy0yhz7lfeg9lvhq7"
      , -- federated-authority-addresses.json
        wcCouncil =
          GovernanceBody
            "addr1wxg3mm3436f57r4r9t6cqdvxe0hwjusayz4ed8ulmlenttqj62ul2"
            (hex "911dee358e934f0ea32af5803586cbeee9721d20ab969f9fdff335ac")
      , wcTechnicalCommittee =
          GovernanceBody
            "addr1w8umlgsw6cfkxpdk2jekzwa7rjdx7tc937mpahhyn00430s074k8y"
            (hex "f9bfa20ed6136305b654b3613bbe1c9a6f2f058fb61edee49bdf58be")
      , -- permissioned-candidates-addresses.json
        wcPermissionedCandidatesPolicy = hex "2c322542e32817f26a75bc49eaaf3ce831b62dafe4040e2f296e339a"
      , -- registered-candidates-addresses.json
        wcCommitteeCandidateAddress = "addr1w9cky55qfmt98yvf0yxa0rzvynm7ag5c8c2f3xwsaja8y5cwpj7fy"
      , wcBridge =
          BridgeWatch
            { -- ics-addresses.json
              bwIcsAddress = "addr1wyczfpxfnf5hvp36mrn655ye4k2cwluvlez6phx8jx46k6s2ttdaq"
            , -- reserve-addresses.json
              bwReserveAddress = "addr1w950c5zxn5fhwlauvpy3ssk287q0qlwz6e2zc4gaj62vaxsy3s9p0"
            , bwToken = asset "0691b2fecca1ac4f53cb6dfb00b7013e561d1f34403b957cbb5af1fa" "NIGHT"
            , bwMetadataLabel = bridgeLabel
            }
      }
  Preprod ->
    WatchConfig
      { -- cnight-addresses.json
        wcCNight = asset "d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1" ""
      , wcMappingValidatorAddress = "addr_test1wplxjzranravtp574s2wz00md7vz9rzpucu252je68u9a8qzjheng"
      , -- federated-authority-addresses.json
        wcCouncil =
          GovernanceBody
            "addr_test1wz76eeh439esrzt00h4m7kecd45e0ez43sfrw7lrajeze6qamp2sp"
            (hex "bdace6f5897301896f7debbf5b386d6997e4558c12377be3ecb22ce8")
      , wcTechnicalCommittee =
          GovernanceBody
            "addr_test1wp3fqhht7q4kqz5vtadn607p0kh0c7kask5javqyzk96uac8ua2lc"
            (hex "62905eebf02b600a8c5f5b3d3fc17daefc7add85a92eb004158bae77")
      , -- permissioned-candidates-addresses.json
        wcPermissionedCandidatesPolicy = hex "d962fc619efb2b904e5a8443838500ef2145452af117ab8f9cc3f97f"
      , -- registered-candidates-addresses.json
        wcCommitteeCandidateAddress = "addr_test1wr4zpkfvylru9y3zahezf6vvfz7hlhf2pa4h9vxq70xwqzszre3qk"
      , wcBridge =
          BridgeWatch
            { -- ics-addresses.json
              bwIcsAddress = "addr_test1wpr4mvu8h2fzs23c06waldlc6t7jjlumvcz9qqzl8mfh25qw9zcjz"
            , -- reserve-addresses.json
              bwReserveAddress = "addr_test1wraevj382xaeeww85mg5whg75j3evzpq5re33zpkgagzgfsgag5wv"
            , -- chain-spec.json bridge.mainChainScripts: name "NIGHT" (0x4e49474854).
              -- ics-addresses.json and reserve-addresses.json name the
              -- nameless cNIGHT asset instead; both are under the same
              -- policy, so both are indexed either way.
              bwToken = asset "d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1" "NIGHT"
            , bwMetadataLabel = bridgeLabel
            }
      }
  Preview ->
    WatchConfig
      { -- cnight-addresses.json
        wcCNight = asset "d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1" ""
      , wcMappingValidatorAddress = "addr_test1wplxjzranravtp574s2wz00md7vz9rzpucu252je68u9a8qzjheng"
      , -- federated-authority-addresses.json
        wcCouncil =
          GovernanceBody
            "addr_test1wzy47zdsq22pg9l48c5v0f835ljdjzkz47sa5za9cehcejcw28k2d"
            (hex "895f09b002941417f53e28c7a4f1a7e4d90ac2afa1da0ba5c66f8ccb")
      , wcTechnicalCommittee =
          GovernanceBody
            "addr_test1wptcy7h9rmkhdnhn3jvm6tuhehcq2hhhzntvn00nq79ph8c44v43j"
            (hex "57827ae51eed76cef38c99bd2f97cdf0055ef714d6c9bdf3078a1b9f")
      , -- permissioned-candidates-addresses.json
        wcPermissionedCandidatesPolicy = hex "24dccfce2576ae6fa7149bc485850656ae6faf9f4158891316773a78"
      , -- registered-candidates-addresses.json
        wcCommitteeCandidateAddress = "addr_test1wz5ax0hjvhx2uqef8sqrxnmfywd37hea4truhqxu4yxp9hsvggkfm"
      , wcBridge =
          BridgeWatch
            { -- ics-addresses.json
              bwIcsAddress = "addr_test1wzga9g4tw69twfvpjynyvdyzvpf5f0e88v6hnu9eh9qgdnqaw66xk"
            , -- reserve-config.json (preview has no reserve-addresses.json)
              bwReserveAddress = "addr_test1wzdpdpyev08npr3ktyy9dskvh2v9wk3vphamd6kk60qmjtgftyu2n"
            , bwToken = asset "d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1" ""
            , bwMetadataLabel = bridgeLabel
            }
      }
 where
  bridgeLabel = 6500973
  asset policy name = AssetId (hex policy) (Text.encodeUtf8 name)
  hex = either error id . Base16.decode . Text.encodeUtf8

-- | A point before the first appearance of every watched address and
-- policy, where a fresh index starts. 'Nothing' where no such point has been
-- established; the operator must then give one.
--
-- Preview: the block before the first cNIGHT mint (block 3870722, slot
-- 99496646, Koios @policy_asset_info@ creation time 1766152646). The other
-- watched policies were first minted, and the watched addresses first used,
-- later (block 3948762 and after, Koios @policy_asset_info@ and
-- @address_txs@); the committee-candidate address has no transactions.
-- Witness datums revealed before this point are not indexed.
startPointPreset :: NetworkName -> Maybe (Point Block)
startPointPreset = \case
  Mainnet -> Nothing
  Preprod -> Nothing
  Preview -> Just (point "99496584.cea2fb957a99a28f3b1a6b5052b6dfe897c1724503ee82b2890c084ab62ff009")
 where
  point = either error id . parsePoint

-- | A canonical rendering, stored with the index so that a database built for
-- one watch set is never served under another.
renderWatchConfig :: WatchConfig -> Text
renderWatchConfig WatchConfig {..} =
  Text.unlines
    [ "cnight " <> renderAsset wcCNight
    , "mapping-validator " <> wcMappingValidatorAddress
    , "council " <> gbAddress wcCouncil <> " " <> hexText (gbPolicy wcCouncil)
    , "technical-committee " <> gbAddress wcTechnicalCommittee <> " " <> hexText (gbPolicy wcTechnicalCommittee)
    , "permissioned-candidates " <> hexText wcPermissionedCandidatesPolicy
    , "committee-candidates " <> wcCommitteeCandidateAddress
    , "bridge-ics " <> bwIcsAddress wcBridge
    , "bridge-reserve " <> bwReserveAddress wcBridge
    , "bridge-token " <> renderAsset (bwToken wcBridge)
    , "bridge-metadata-label " <> Text.pack (show (bwMetadataLabel wcBridge))
    ]
 where
  renderAsset (AssetId policy name) = hexText policy <> "." <> hexText name
  hexText = Text.decodeLatin1 . Base16.encode

-- | The watch set in the form the extractor tests outputs against.
data WatchFilter = WatchFilter
  { wfAddresses :: !(Set ByteString)
  -- ^ 'serialiseAddr' of the named addresses.
  , wfInputListAddresses :: !(Set ByteString)
  , wfPolicies :: !(Set PolicyID)
  , wfMetadataLabels :: !(Set Word64)
  }
  deriving stock (Show)

watchFilter :: WatchConfig -> Either String WatchFilter
watchFilter WatchConfig {..} = do
  addresses <-
    traverse
      addressBytes
      [ wcMappingValidatorAddress
      , gbAddress wcCouncil
      , gbAddress wcTechnicalCommittee
      , wcCommitteeCandidateAddress
      , bwIcsAddress wcBridge
      , bwReserveAddress wcBridge
      ]
  inputListAddress <- addressBytes wcCommitteeCandidateAddress
  policies <-
    traverse
      policyId
      [ assetPolicy wcCNight
      , gbPolicy wcCouncil
      , gbPolicy wcTechnicalCommittee
      , wcPermissionedCandidatesPolicy
      , assetPolicy (bwToken wcBridge)
      ]
  pure
    WatchFilter
      { wfAddresses = Set.fromList addresses
      , wfInputListAddresses = Set.singleton inputListAddress
      , wfPolicies = Set.fromList policies
      , wfMetadataLabels = Set.singleton (bwMetadataLabel wcBridge)
      }
 where
  addressBytes text = case parseAddress text of
    Right addr -> Right (serialiseAddr addr)
    Left e -> Left ("address " <> Text.unpack text <> ": " <> e)
  policyId bytes = case hashFromBytes bytes of
    Just h -> Right (PolicyID (ScriptHash h))
    Nothing -> Left ("policy id " <> show (Base16.encode bytes) <> " is not 28 bytes")

-- | Every output at this address (db-sync text) is in the index.
isWatchedAddress :: WatchConfig -> Text -> Bool
isWatchedAddress WatchConfig {..} address =
  address
    `elem` [ wcMappingValidatorAddress
           , gbAddress wcCouncil
           , gbAddress wcTechnicalCommittee
           , wcCommitteeCandidateAddress
           , bwIcsAddress wcBridge
           , bwReserveAddress wcBridge
           ]

-- | Every output carrying a token of this policy is in the index.
isWatchedPolicy :: WatchConfig -> ByteString -> Bool
isWatchedPolicy WatchConfig {..} policy =
  policy
    `elem` [ assetPolicy wcCNight
           , gbPolicy wcCouncil
           , gbPolicy wcTechnicalCommittee
           , wcPermissionedCandidatesPolicy
           , assetPolicy (bwToken wcBridge)
           ]

-- | Outputs at this address come with their creating transaction's inputs.
recordsInputLists :: WatchConfig -> Text -> Bool
recordsInputLists WatchConfig {wcCommitteeCandidateAddress} = (== wcCommitteeCandidateAddress)
