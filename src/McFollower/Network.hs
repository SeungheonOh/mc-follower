-- | Per-network parameters needed to talk to a Cardano upstream, with
-- built-in presets for the public networks.
module McFollower.Network
  ( NetworkName (..)
  , NetworkConfig (..)
  , RelayAddress (..)
  , networkConfig
  , parseNetworkName
  , parseRelayAddress
  , renderRelayAddress
  , codecConfig
  , networkId
  ) where

import Cardano.Api qualified as Api
import Cardano.Chain.Slotting (EpochSlots (..))
import Data.List.NonEmpty (NonEmpty (..))
import Data.Text (Text)
import Data.Text qualified as Text
import McFollower.Block (Block, parsePoint)
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
  , ncByronEpochSlots :: !EpochSlots
  -- ^ Byron genesis @10 * k@. Only needed to decode Byron blocks.
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
      , ncByronEpochSlots = EpochSlots 21600
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
      , ncByronEpochSlots = EpochSlots 21600
      , ncRelays = RelayAddress "preprod-node.play.dev.cardano.org" 3001 :| []
      , ncRecentPoint =
          point "139500748.36ae5dc73c7c2f623fbce5300b5949204e89a347b48554f7b9a4c7015edb93c5"
      }
  Preview ->
    NetworkConfig
      { ncName = Preview
      , ncMagic = NetworkMagic 2
      , ncByronEpochSlots = EpochSlots 4320
      , ncRelays = RelayAddress "preview-node.play.dev.cardano.org" 3001 :| []
      , ncRecentPoint =
          point "128531690.290f168381e66d477e93d2ffc33e0706cdfdc6acfc1c7c723fb050fe39998128"
      }
 where
  point = either error id . parsePoint

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
    (ByronCodecConfig (ncByronEpochSlots cfg))
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
