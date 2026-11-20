-- | Per-network parameters needed to talk to a Cardano upstream, with
-- built-in presets for the public networks.
module McFollower.Network
  ( NetworkName (..)
  , NetworkConfig (..)
  , RelayAddress (..)
  , networkConfig
  , chainParams
  , parseNetworkName
  , parseRelayAddress
  , renderRelayAddress
  , codecConfig
  , networkId
  ) where

import Cardano.Api qualified as Api
import Cardano.Slotting.Slot (EpochNo (..), EpochSize (..))
import Cardano.Slotting.Time (SystemStart (..), slotLengthFromSec)
import Data.List.NonEmpty (NonEmpty (..))
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Time (UTCTime (..), fromGregorian)
import McFollower.Block (Block, parsePoint)
import McFollower.EraHistory (ChainParams (..), activeSlotCoeffOneTwentieth, byronEpochSlots)
import Network.Socket (HostName, PortNumber)
import Ouroboros.Consensus.Block (CodecConfig, Point)
import Ouroboros.Consensus.Byron.Ledger (CodecConfig (ByronCodecConfig))
import Ouroboros.Consensus.Cardano.Block (pattern CardanoCodecConfig)
import Ouroboros.Consensus.Shelley.Ledger (CodecConfig (ShelleyCodecConfig))
import Ouroboros.Network.Magic (NetworkMagic (..))
import Text.Read (readMaybe)

data NetworkName = Mainnet | Preprod | Preview
  deriving stock (Eq, Show, Enum, Bounded)

data RelayAddress = RelayAddress
  { relayHost :: !HostName
  , relayPort :: !PortNumber
  }
  deriving stock (Eq, Show)

data NetworkConfig = NetworkConfig
  { ncName :: !NetworkName
  , ncMagic :: !NetworkMagic
  , ncChain :: !ChainParams
  -- ^ Genesis and hard-fork constants ('chainParams').
  , ncRelays :: !(NonEmpty RelayAddress)
  -- ^ Bootstrap peers from the network's official topology file.
  , ncRecentPoint :: !(Point Block)
  -- ^ A fixed, reasonably recent block to start from without syncing
  -- from origin.
  }
  deriving stock (Show)

networkConfig :: NetworkName -> NetworkConfig
networkConfig = \case
  Mainnet ->
    NetworkConfig
      { ncName = Mainnet
      , ncMagic = NetworkMagic 764824073
      , ncChain = chainParams Mainnet
      , ncRelays =
          RelayAddress "backbone.cardano.iog.io" 3001
            :| [RelayAddress "backbone.mainnet.cardanofoundation.org" 3001]
      , ncRecentPoint =
          point "203629206.3cdeec244eb8f6b88574e2d3379a398e6eb7cc8df5113723e748d0214001e621"
      }
  Preprod ->
    NetworkConfig
      { ncName = Preprod
      , ncMagic = NetworkMagic 1
      , ncChain = chainParams Preprod
      , ncRelays = RelayAddress "preprod-node.play.dev.cardano.org" 3001 :| []
      , ncRecentPoint =
          point "139500748.36ae5dc73c7c2f623fbce5300b5949204e89a347b48554f7b9a4c7015edb93c5"
      }
  Preview ->
    NetworkConfig
      { ncName = Preview
      , ncMagic = NetworkMagic 2
      , ncChain = chainParams Preview
      , ncRelays = RelayAddress "preview-node.play.dev.cardano.org" 3001 :| []
      , ncRecentPoint =
          point "128531690.290f168381e66d477e93d2ffc33e0706cdfdc6acfc1c7c723fb050fe39998128"
      }
 where
  point = either error id . parsePoint

-- | The chain constants of each network, the only place they are written
-- down. Sources: the networks' Byron and Shelley genesis files
-- (@startTime@, @protocolConsts.k@, @blockVersionData.slotDuration@,
-- @securityParam@, @activeSlotsCoeff@, @epochLength@, @slotLength@,
-- @slotsPerKESPeriod@, @maxKESEvolutions@) published at
-- <https://book.play.dev.cardano.org/environments/>, read 2026-11-20, and
-- cross-checked against the Midnight node's
-- @res/<network>/pc-chain-config.json@ (first Shelley epoch, slot and
-- timestamp, epoch duration). Hard forks: the @era@ of each epoch in Koios
-- @epoch_params@, read 2026-11-20; preview's first four agree with the
-- @Test*HardForkAtEpoch: 0@ entries of its node configuration.
chainParams :: NetworkName -> ChainParams
chainParams = \case
  -- Shelley from epoch 208, slot 4492800, 2020-07-29T21:44:51Z.
  Mainnet ->
    ChainParams
      { cpSystemStart = utc 2017 9 23 (21 * 3600 + 44 * 60 + 51)
      , cpSecurityParam = 2160
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 432000
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [208, 236, 251, 290, 365, 507]
      }
  -- Shelley from epoch 4, slot 86400, 2022-06-21T00:00:00Z.
  Preprod ->
    ChainParams
      { cpSystemStart = utc 2022 6 1 0
      , cpSecurityParam = 2160
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 432000
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [4, 5, 6, 7, 12, 163]
      }
  -- No Byron epochs: the network forks to Shelley-based eras at epoch 0.
  Preview ->
    ChainParams
      { cpSystemStart = utc 2022 10 25 0
      , cpSecurityParam = 432
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 86400
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [0, 0, 0, 0, 3, 646]
      }
 where
  utc y m d secs = SystemStart (UTCTime (fromGregorian y m d) (fromIntegral (secs :: Int)))

parseNetworkName :: Text -> Either String NetworkName
parseNetworkName = \case
  "mainnet" -> Right Mainnet
  "preprod" -> Right Preprod
  "preview" -> Right Preview
  other -> Left ("unknown network " <> show other <> "; expected mainnet, preprod or preview")

-- | Parse @HOST:PORT@.
parseRelayAddress :: Text -> Either String RelayAddress
parseRelayAddress t = case Text.breakOnEnd ":" t of
  (hostColon, portText)
    | Just host <- Text.stripSuffix ":" hostColon
    , not (Text.null host)
    , Just port <- readMaybe @Integer (Text.unpack portText)
    , port > 0
    , port < 65536 ->
        Right (RelayAddress (Text.unpack host) (fromInteger port))
  _ -> Left ("expected HOST:PORT, got " <> show t)

renderRelayAddress :: RelayAddress -> Text
renderRelayAddress (RelayAddress host port) = Text.pack host <> ":" <> Text.pack (show port)

-- | Codec configuration for 'Block'. Only Byron needs a parameter.
codecConfig :: NetworkConfig -> CodecConfig Block
codecConfig cfg =
  CardanoCodecConfig
    (ByronCodecConfig (byronEpochSlots (ncChain cfg)))
    ShelleyCodecConfig
    ShelleyCodecConfig
    ShelleyCodecConfig
    ShelleyCodecConfig
    ShelleyCodecConfig
    ShelleyCodecConfig
    ShelleyCodecConfig

networkId :: NetworkConfig -> Api.NetworkId
networkId cfg = case ncName cfg of
  Mainnet -> Api.Mainnet
  Preprod -> Api.Testnet (ncMagic cfg)
  Preview -> Api.Testnet (ncMagic cfg)
