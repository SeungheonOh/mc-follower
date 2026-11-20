-- | The trusted protocol state the nonce driver starts from: a Praos
-- 'PraosState' and the point of the block after which it holds.
--
-- The state is kept in the node's own encoding, the 'Serialise' instance of
-- 'PraosState' (versioned, @[0, [lastSlot, ocertCounters, evolving,
-- candidate, epoch, previousEpoch, lab, lastEpochBlock]]@). These are the
-- same bytes a node returns for the @DebugChainDepState@ query in a Praos
-- era (cardano-api @QueryProtocolState@, @cardano-cli query
-- protocol-state --out-file@), so a state taken from a node can be pasted
-- in unchanged.
--
-- Configuration form (JSON):
--
-- > { "point": "SLOT.HASH", "praos_state_cbor": "<hex>" }
module McFollower.Nonce.TrustedState
  ( TrustedState (..)
  , encodePraosState
  , decodePraosState
  , renderTrustedState
  , parseTrustedState
  ) where

import Codec.CBOR.Read (deserialiseFromBytes)
import Codec.CBOR.Write (toStrictByteString)
import Codec.Serialise (decode, encode)
import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, (.:), (.=))
import Data.Aeson qualified as Aeson
import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import Data.ByteString.Base16 qualified as Base16
import Data.ByteString.Lazy qualified as BL
import Data.Text (Text)
import Data.Text.Encoding qualified as Text
import McFollower.Block (Block, parsePoint, renderPoint)
import Ouroboros.Consensus.Block (Point)
import Ouroboros.Consensus.Protocol.Praos (PraosState)

data TrustedState = TrustedState
  { tsPoint :: !(Point Block)
  -- ^ The block the state was reached by applying; the driver continues
  -- with its successor.
  , tsState :: !PraosState
  }
  deriving stock (Eq, Show)

encodePraosState :: PraosState -> ByteString
encodePraosState = toStrictByteString . encode

decodePraosState :: ByteString -> Either String PraosState
decodePraosState bytes = case deserialiseFromBytes decode (BL.fromStrict bytes) of
  Left e -> Left (show e)
  Right (rest, st)
    | BL.null rest -> Right st
    | otherwise -> Left ("trailing bytes after PraosState: " <> show (BL.length rest))

instance ToJSON TrustedState where
  toJSON TrustedState {tsPoint, tsState} =
    object
      [ "point" .= renderPoint tsPoint
      , "praos_state_cbor" .= Text.decodeLatin1 (Base16.encode (encodePraosState tsState))
      ]

instance FromJSON TrustedState where
  parseJSON = withObject "TrustedState" $ \o -> do
    pointText <- o .: "point"
    hexText <- o .: "praos_state_cbor"
    either fail pure $ do
      p <- parsePoint pointText
      bytes <- first ("praos_state_cbor: " <>) (Base16.decode (Text.encodeUtf8 hexText))
      TrustedState p <$> first ("praos_state_cbor: " <>) (decodePraosState bytes)

renderTrustedState :: TrustedState -> Text
renderTrustedState = Text.decodeUtf8 . BL.toStrict . Aeson.encode

parseTrustedState :: ByteString -> Either String TrustedState
parseTrustedState = Aeson.eitherDecodeStrict
