-- | Blocks as files, in the consensus on-disk encoding (the ImmutableDB
-- format: era tag and block CBOR). Used for test fixtures.
module McFollower.BlockFile
  ( encodeBlock
  , decodeBlock
  , writeBlockFile
  , readBlockFile
  ) where

import Cardano.Binary (DecoderError)
import Codec.CBOR.Read (deserialiseFromBytes)
import Codec.CBOR.Write (toLazyByteString)
import Data.ByteString.Lazy qualified as LBS
import McFollower.Block (Block)
import Ouroboros.Consensus.Block (CodecConfig)
import Ouroboros.Consensus.Storage.Serialisation (DecodeDisk (..), EncodeDisk (..))

encodeBlock :: CodecConfig Block -> Block -> LBS.ByteString
encodeBlock ccfg = toLazyByteString . encodeDisk ccfg

decodeBlock :: CodecConfig Block -> LBS.ByteString -> Either String Block
decodeBlock ccfg bytes = case deserialiseFromBytes (decodeDisk ccfg) bytes of
  Left e -> Left (show e)
  Right (rest, annotate)
    | LBS.null rest -> either (Left . show @DecoderError) Right (annotate bytes)
    | otherwise -> Left (show (LBS.length rest) <> " bytes after the block")

writeBlockFile :: CodecConfig Block -> FilePath -> Block -> IO ()
writeBlockFile ccfg path = LBS.writeFile path . encodeBlock ccfg

readBlockFile :: CodecConfig Block -> FilePath -> IO (Either String Block)
readBlockFile ccfg path = decodeBlock ccfg <$> LBS.readFile path
