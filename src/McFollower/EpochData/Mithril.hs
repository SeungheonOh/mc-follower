-- | Cardano stake distributions from a Mithril aggregator, for node-to-node
-- mode and for epochs outside a local node's three-epoch window.
--
-- Endpoints (aggregator OpenAPI, @openapi.yaml@ in the Mithril repository):
--
-- * @GET {aggregator}/artifact/cardano-stake-distributions@: the most
--   recent distributions (epoch label, hash, certificate hash).
-- * @GET {aggregator}/artifact/cardano-stake-distribution/epoch/{L}@: the
--   distribution labelled @L@, @{"epoch", "hash", "certificate_hash",
--   "stake_distribution": {"pool1...": lovelace}, "created_at"}@.
-- * @GET {aggregator}/certificate/{hash}@: the certificate.
--
-- Labels: Mithril labels a distribution with the epoch at the end of which
-- the node computed it, so label @L@ is the stake distribution for epoch
-- @L + 2@ (see "McFollower.EpochData.Stake"); 'labelForStakeEpoch' and
-- 'stakeEpochOfLabel' convert.
--
-- What is checked: the artifact is fetched over HTTPS (system trust
-- store), its pool ids must decode as bech32 @pool@ ids of 28 bytes, and
-- its certificate is fetched and must have the artifact's certificate hash
-- and certify a @CardanoStakeDistribution@ for the same label. Nothing is
-- verified cryptographically here: neither the certificate chain nor its
-- multi-signature, nor that the artifact's pools hash to the certificate's
-- Merkle root. In node-to-node mode the aggregator is trusted, as the
-- relay is.
module McFollower.EpochData.Mithril
  ( -- * Aggregators
    Aggregator (..)
  , aggregatorFor

    -- * Labels
  , labelForStakeEpoch
  , stakeEpochOfLabel

    -- * Fetching
  , MithrilStakeDistribution (..)
  , MithrilListEntry (..)
  , MithrilCertificate (..)
  , MithrilError (..)
  , newMithrilManager
  , listStakeDistributions
  , fetchStakeDistribution
  , fetchCertificate
  , fetchStakeForEpoch
  , toEpochStake
  ) where

import Cardano.Crypto.Hash (hashFromBytes)
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash (..), KeyRole (StakePool))
import Cardano.Slotting.Slot (EpochNo (..))
import Codec.Binary.Bech32 qualified as Bech32
import Control.Exception (try)
import Control.Monad (unless, when)
import Data.Aeson (FromJSON (..), withObject, (.:))
import Data.Aeson qualified as Aeson
import Data.Aeson.Key qualified as Key
import Data.Aeson.KeyMap qualified as KeyMap
import Data.Aeson.Types (Parser)
import Data.Bifunctor (first)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word64)
import McFollower.EpochData.Stake (EpochStake (..), StakeSource (..), positiveStake)
import McFollower.Network (NetworkName (..))
import Network.HTTP.Client
  ( HttpException
  , Manager
  , Response (..)
  , httpLbs
  , parseRequest
  )
import Network.HTTP.Client.TLS (newTlsManager)
import Network.HTTP.Types (statusCode)

-- | Base URL of an aggregator, without a trailing slash.
newtype Aggregator = Aggregator {aggregatorUrl :: Text}
  deriving stock (Eq, Show)

-- | The aggregator of each network's Mithril release network, from
-- @networks.json@ in the Mithril repository (read 2026-11-20):
-- @release-mainnet@, @release-preprod@ and @pre-release-preview@.
aggregatorFor :: NetworkName -> Aggregator
aggregatorFor = \case
  Mainnet -> Aggregator "https://aggregator.release-mainnet.api.mithril.network/aggregator"
  Preprod -> Aggregator "https://aggregator.release-preprod.api.mithril.network/aggregator"
  Preview -> Aggregator "https://aggregator.pre-release-preview.api.mithril.network/aggregator"

-- | The Mithril label of the distribution for a stake epoch: @N - 2@.
-- 'Nothing' for epochs 0 and 1, which no label covers.
labelForStakeEpoch :: EpochNo -> Maybe EpochNo
labelForStakeEpoch (EpochNo n)
  | n >= 2 = Just (EpochNo (n - 2))
  | otherwise = Nothing

-- | The stake epoch a Mithril label is the distribution for: @L + 2@.
stakeEpochOfLabel :: EpochNo -> EpochNo
stakeEpochOfLabel (EpochNo l) = EpochNo (l + 2)

data MithrilListEntry = MithrilListEntry
  { mleLabel :: !EpochNo
  , mleHash :: !Text
  , mleCertificateHash :: !Text
  }
  deriving stock (Eq, Show)

data MithrilStakeDistribution = MithrilStakeDistribution
  { msdLabel :: !EpochNo
  , msdHash :: !Text
  , msdCertificateHash :: !Text
  , msdPools :: !(Map (KeyHash StakePool) Coin)
  -- ^ As published, zero amounts included.
  }
  deriving stock (Eq, Show)

data MithrilCertificate = MithrilCertificate
  { mcHash :: !Text
  , mcPreviousHash :: !Text
  , mcEpoch :: !EpochNo
  , mcSignedStakeDistribution :: !(Maybe EpochNo)
  -- ^ The label, if the certificate's signed entity is a Cardano stake
  -- distribution.
  , mcMerkleRoot :: !(Maybe Text)
  -- ^ @cardano_stake_distribution_merkle_root@ of the protocol message.
  }
  deriving stock (Eq, Show)

data MithrilError
  = HttpError !Text !HttpException
  | HttpStatus !Text !Int
  -- ^ URL and status; 404 means the aggregator has no such artifact.
  | DecodeError !Text !String
  | CertificateMismatch !Text
  deriving stock (Show)

instance FromJSON MithrilListEntry where
  parseJSON = withObject "CardanoStakeDistributionListItem" $ \o ->
    MithrilListEntry <$> (EpochNo <$> o .: "epoch") <*> o .: "hash" <*> o .: "certificate_hash"

instance FromJSON MithrilStakeDistribution where
  parseJSON = withObject "CardanoStakeDistribution" $ \o -> do
    pools <- o .: "stake_distribution"
    MithrilStakeDistribution
      <$> (EpochNo <$> o .: "epoch")
      <*> o .: "hash"
      <*> o .: "certificate_hash"
      <*> parsePools pools

parsePools :: Aeson.Object -> Parser (Map (KeyHash StakePool) Coin)
parsePools obj =
  Map.fromList <$> traverse entry (KeyMap.toList obj)
 where
  entry (k, v) = do
    amount <- parseJSON @Word64 v
    either fail (\kh -> pure (kh, Coin (fromIntegral amount))) (decodePoolId (Key.toText k))

-- | A bech32 pool id (@pool1...@) as the 28-byte key hash.
decodePoolId :: Text -> Either String (KeyHash StakePool)
decodePoolId t = do
  (hrp, dataPart) <- first show (Bech32.decodeLenient t)
  unless (Bech32.humanReadablePartToText hrp == "pool") $
    Left ("not a pool id: " <> Text.unpack t)
  bytes <- maybe (Left ("bad bech32 data in " <> Text.unpack t)) Right (Bech32.dataPartToBytes dataPart)
  maybe (Left ("pool id is not 28 bytes: " <> Text.unpack t)) (Right . KeyHash) (hashFromBytes bytes)

instance FromJSON MithrilCertificate where
  parseJSON = withObject "Certificate" $ \o -> do
    signed <- o .: "signed_entity_type"
    parts <- (.: "message_parts") =<< o .: "protocol_message"
    MithrilCertificate
      <$> o .: "hash"
      <*> o .: "previous_hash"
      <*> (EpochNo <$> o .: "epoch")
      <*> withObject "SignedEntityType" (\s -> fmap EpochNo <$> s Aeson..:? "CardanoStakeDistribution") signed
      <*> parts Aeson..:? "cardano_stake_distribution_merkle_root"

-- | A TLS-capable connection manager.
newMithrilManager :: IO Manager
newMithrilManager = newTlsManager

getJson :: FromJSON a => Manager -> Text -> IO (Either MithrilError a)
getJson manager url = do
  result <- try $ do
    request <- parseRequest (Text.unpack url)
    httpLbs request manager
  pure $ case result of
    Left e -> Left (HttpError url e)
    Right response
      | statusCode (responseStatus response) /= 200 ->
          Left (HttpStatus url (statusCode (responseStatus response)))
      | otherwise -> first (DecodeError url) (Aeson.eitherDecode (responseBody response))

listStakeDistributions :: Manager -> Aggregator -> IO (Either MithrilError [MithrilListEntry])
listStakeDistributions manager (Aggregator base) =
  getJson manager (base <> "/artifact/cardano-stake-distributions")

-- | The distribution with the given Mithril label.
fetchStakeDistribution :: Manager -> Aggregator -> EpochNo -> IO (Either MithrilError MithrilStakeDistribution)
fetchStakeDistribution manager (Aggregator base) (EpochNo label) =
  getJson manager (base <> "/artifact/cardano-stake-distribution/epoch/" <> Text.pack (show label))

fetchCertificate :: Manager -> Aggregator -> Text -> IO (Either MithrilError MithrilCertificate)
fetchCertificate manager (Aggregator base) hash =
  getJson manager (base <> "/certificate/" <> hash)

-- | The stake distribution for a stake epoch: fetches the artifact
-- labelled @N - 2@ and its certificate, and checks that the certificate is
-- the one the artifact names and certifies that label (see the module
-- header for what is not checked).
fetchStakeForEpoch :: Manager -> Aggregator -> EpochNo -> IO (Either MithrilError EpochStake)
fetchStakeForEpoch manager aggregator epoch = case labelForStakeEpoch epoch of
  Nothing -> pure (Left (CertificateMismatch ("no Mithril label covers epoch " <> showText epoch)))
  Just label ->
    fetchStakeDistribution manager aggregator label >>= \case
      Left e -> pure (Left e)
      Right sd ->
        fetchCertificate manager aggregator (msdCertificateHash sd) >>= \case
          Left e -> pure (Left e)
          Right cert -> pure $ do
            checkCertificate label sd cert
            pure (toEpochStake sd)
 where
  checkCertificate label sd cert = do
    when (msdLabel sd /= label) $
      Left (CertificateMismatch ("asked for label " <> showText label <> ", got " <> showText (msdLabel sd)))
    when (mcHash cert /= msdCertificateHash sd) $
      Left (CertificateMismatch ("certificate hash " <> mcHash cert <> " /= " <> msdCertificateHash sd))
    when (mcSignedStakeDistribution cert /= Just label) $
      Left
        ( CertificateMismatch
            ("certificate " <> mcHash cert <> " does not certify the stake distribution of " <> showText label)
        )

-- | The distribution as an 'EpochStake': for epoch @L + 2@, zero amounts
-- dropped, complete (Mithril certifies a distribution only after its epoch
-- has ended).
toEpochStake :: MithrilStakeDistribution -> EpochStake
toEpochStake sd =
  EpochStake
    { esEpoch = stakeEpochOfLabel (msdLabel sd)
    , esPools = positiveStake (msdPools sd)
    , esComplete = True
    , esSource = FromMithril (msdLabel sd) (msdCertificateHash sd)
    }

showText :: Show a => a -> Text
showText = Text.pack . show
