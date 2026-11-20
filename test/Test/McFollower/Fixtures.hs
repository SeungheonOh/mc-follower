-- | Recorded preview blocks and public data used by the tests.
module Test.McFollower.Fixtures
  ( loadBlocks
  , boundaryBlocksFile
  , proposalBlockFile
  , OgmiosCapture (..)
  , loadOgmiosCapture
  , ogmiosTrustedState
  , hexNonce
  ) where

import Cardano.Binary (DecoderError)
import Cardano.Crypto.Hash (hashFromTextAsHex)
import Cardano.Ledger.BaseTypes (Nonce (..))
import Cardano.Slotting.Slot (WithOrigin (..))
import Codec.CBOR.Read (deserialiseFromBytes)
import Data.Aeson (FromJSON (..), eitherDecodeFileStrict, withObject, (.:))
import Data.ByteString.Base16 qualified as Base16
import Data.ByteString.Char8 qualified as BS8
import Data.ByteString.Lazy qualified as BL
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import McFollower.Block (Block, parsePoint)
import McFollower.Network (NetworkName (..), codecConfig, networkConfig)
import McFollower.Nonce.TrustedState (TrustedState (..))
import Ouroboros.Consensus.Block (Point (..), pointSlot)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import Ouroboros.Consensus.Storage.Serialisation (decodeDisk)

import Ouroboros.Consensus.Cardano.Node ()

-- | Preview blocks 4874015 to 4874020: the last three of epoch 1486 and
-- the first three of 1487, as fetched from a preview relay.
boundaryBlocksFile :: FilePath
boundaryBlocksFile = "test/data/preview-blocks-4874015-4874020.hex"

-- | Preview block 4445282 (epoch 1350), whose second transction
-- (8b5f096a...) proposes a @ParameterChange@ setting @maxTxSize@ to 16400.
proposalBlockFile :: FilePath
proposalBlockFile = "test/data/preview-block-4445282.hex"

-- | One block per line, hex of the node's on-disk encoding.
loadBlocks :: FilePath -> IO [Block]
loadBlocks path = do
  ls <- filter (not . BS8.null) . BS8.lines <$> BS8.readFile path
  pure (map decodeLine ls)
 where
  cc = codecConfig (networkConfig Preview)
  decodeLine :: BS8.ByteString -> Block
  decodeLine l = case Base16.decode l of
    Left e -> error e
    Right bytes ->
      let lazy = BL.fromStrict bytes
       in case deserialiseFromBytes (decodeDisk cc) lazy of
            Left e -> error (show e)
            Right (_, mk :: BL.ByteString -> Either DecoderError Block) -> either (error . show) id (mk lazy)

-- | A protocol state read from an Ogmios instance (through Koios), with
-- the two fields Ogmios does not report taken from Koios.
data OgmiosCapture = OgmiosCapture
  { ocPoint :: !(Point Block)
  , ocEpochNonce :: !Nonce
  , ocCandidateNonce :: !Nonce
  , ocEvolvingNonce :: !Nonce
  , ocLastEpochLastAncestor :: !Nonce
  , ocParentHash :: !Nonce
  -- ^ The block's previous hash, as a nonce: what 'praosStateLabNonce'
  -- holds after the block.
  , ocPreviousEpochNonce :: !Nonce
  }
  deriving stock (Show)

instance FromJSON OgmiosCapture where
  parseJSON = withObject "OgmiosCapture" $ \o -> do
    point <- either fail pure . parsePoint =<< o .: "point"
    ogmios <- o .: "ogmios"
    let nonce t = either fail pure (hexNonce t)
    OgmiosCapture point
      <$> (nonce =<< ogmios .: "epochNonce")
      <*> (nonce =<< ogmios .: "candidateNonce")
      <*> (nonce =<< ogmios .: "evolvingNonce")
      <*> (nonce =<< ogmios .: "lastEpochLastAncestor")
      <*> (nonce =<< o .: "parent_hash")
      <*> (nonce =<< o .: "previous_epoch_nonce")

loadOgmiosCapture :: FilePath -> IO OgmiosCapture
loadOgmiosCapture path = either error id <$> eitherDecodeFileStrict path

-- | The 'PraosState' after the captured block: every nonce from public
-- data, the last slot from the point, and no operational certificate
-- counters (they play no part in nonces).
ogmiosTrustedState :: OgmiosCapture -> TrustedState
ogmiosTrustedState oc =
  TrustedState
    { tsPoint = ocPoint oc
    , tsState =
        PraosState
          { praosStateLastSlot = maybe Origin At (withOriginToMaybe (pointSlot (ocPoint oc)))
          , praosStateOCertCounters = Map.empty
          , praosStateEvolvingNonce = ocEvolvingNonce oc
          , praosStateCandidateNonce = ocCandidateNonce oc
          , praosStateEpochNonce = ocEpochNonce oc
          , praosStatePreviousEpochNonce = ocPreviousEpochNonce oc
          , praosStateLabNonce = ocParentHash oc
          , praosStateLastEpochBlockNonce = ocLastEpochLastAncestor oc
          }
    }
 where
  withOriginToMaybe = \case
    Origin -> Nothing
    At s -> Just s

hexNonce :: Text -> Either String Nonce
hexNonce t = maybe (Left ("not a 32-byte hex hash: " <> show t)) (Right . Nonce) (hashFromTextAsHex t)
