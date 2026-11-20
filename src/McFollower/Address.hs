-- | Address text exactly as cardano-db-sync stores it in @tx_out.address@
-- (db-sync 13.8, @Cardano.DbSync.Util.Address.serialiseAddress@): bech32
-- with lenient encoding for Shelley addresses, prefixed @addr@ or
-- @addr_test@ according to the network recorded in the address itself, and
-- base58 (Bitcoin alphabet) for Byron addresses. Both encode the ledger's
-- re-serialisation of the decoded address ('serialiseAddr'), not the
-- original output bytes.
module McFollower.Address
  ( renderAddress
  , parseAddress
  ) where

import Cardano.Ledger.Address (Addr (..), decodeAddrEither, serialiseAddr)
import Cardano.Ledger.BaseTypes (Network (..))
import Codec.Binary.Bech32 qualified as Bech32
import Data.ByteString.Base58 (bitcoinAlphabet, decodeBase58, encodeBase58)
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text

renderAddress :: Addr -> Text
renderAddress addr = case addr of
  AddrBootstrap _ -> Text.decodeLatin1 (encodeBase58 bitcoinAlphabet (serialiseAddr addr))
  Addr network _ _ ->
    Bech32.encodeLenient (prefix network) (Bech32.dataPartFromBytes (serialiseAddr addr))
 where
  prefix = \case
    Mainnet -> hrp "addr"
    Testnet -> hrp "addr_test"
  hrp = either (error . show) id . Bech32.humanReadablePartFromText

-- | Decode address text (bech32 or base58) and accept it only if
-- 'renderAddress' gives back exactly the same text, so that matching on the
-- decoded address is the same as db-sync's text equality.
parseAddress :: Text -> Either String Addr
parseAddress text = do
  bytes <- case Bech32.decodeLenient text of
    Right (_, dataPart) -> maybe (Left "bech32 data part is not whole bytes") Right (Bech32.dataPartToBytes dataPart)
    Left bech32Error -> case decodeBase58 bitcoinAlphabet (Text.encodeUtf8 text) of
      Just bytes -> Right bytes
      Nothing -> Left ("neither bech32 (" <> show bech32Error <> ") nor base58")
  addr <- decodeAddrEither bytes
  if renderAddress addr == text
    then Right addr
    else Left ("not in db-sync's rendering; db-sync stores it as " <> Text.unpack (renderAddress addr))
