{-# LANGUAGE GADTs #-}

-- | Development tool, not part of the indexer: reads the Praos protocol
-- state out of a cardano-node ledger snapshot (the @state@ file of a
-- @ledger/SLOT/@ snapshot directory, e.g. from a Mithril ancillary
-- archive) and prints it in the nonce driver's trusted-state JSON form.
--
-- The snapshot is @[1, [ledgerState, headerState]]@ (the version-1
-- snapshot encoding wrapping 'encodeDiskExtLedgerState'). The ledger state
-- is skipped token by token, without decoding it: its encoding changes
-- between node versions (a node 11.1.3 snapshot does not decode with this
-- package set's ledger decoder), while the header state's does not. The
-- header state is decoded with consensus's own 'decodeHeaderState' and the
-- block's 'decodeDisk' instances; the point is its tip and the state is
-- the current era's 'PraosState', with its operational certificate
-- counters dropped (they play no part in nonces; the nonce driver drops
-- them too).
--
-- > ledger-snapshot-praos-state preview ledger/128252153/state
module Main (main) where

import Cardano.Binary (enforceSize)
import Codec.CBOR.Decoding hiding (decodeFloat)
import Codec.CBOR.Decoding qualified as CBOR
import Codec.CBOR.Read (deserialiseFromBytes)
import Control.Monad (replicateM_, unless, void)
import Data.ByteString.Lazy qualified as BL
import Data.SOP.Strict (NS (..))
import Data.SOP.Telescope qualified as Telescope
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import McFollower.Block (Block)
import McFollower.Network (codecConfig, networkConfig, parseNetworkName)
import McFollower.Nonce.TrustedState (TrustedState (..), renderTrustedState)
import Ouroboros.Consensus.HardFork.Combinator (HardForkState (..))
import Ouroboros.Consensus.HardFork.Combinator.State.Types (Current (..))
import Ouroboros.Consensus.HeaderValidation (HeaderState (..), decodeHeaderState, headerStatePoint)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import Data.Map.Strict qualified as Map
import Ouroboros.Consensus.Storage.Serialisation (decodeDisk)
import Ouroboros.Consensus.Cardano.Block (CardanoEras)
import Cardano.Protocol.Crypto (StandardCrypto)
import Ouroboros.Consensus.TypeFamilyWrappers (WrapChainDepState (..))
import System.Environment (getArgs)
import System.Exit (die)

import Ouroboros.Consensus.Cardano.Node ()

main :: IO ()
main =
  getArgs >>= \case
    [networkText, path] -> do
      network <- either die pure (parseNetworkName (Text.pack networkText))
      let cc = codecConfig (networkConfig network)
      bytes <- BL.readFile path
      hs <-
        either (die . show) (pure . snd) $
          deserialiseFromBytes (snapshotHeaderState (decodeHeaderState (decodeDisk cc) (decodeDisk cc))) bytes
      st <- either die pure (praosState (headerStateChainDep hs))
      Text.putStrLn (renderTrustedState (TrustedState (headerStatePoint hs) st {praosStateOCertCounters = Map.empty}))
    _ -> die "usage: ledger-snapshot-praos-state NETWORK STATE-FILE"
 where
  snapshotHeaderState :: Decoder s (HeaderState Block) -> Decoder s (HeaderState Block)
  snapshotHeaderState decodeHs = do
    enforceSize "snapshot" 2
    version <- decodeWord
    unless (version == 1) $ fail ("unknown snapshot encoding version " <> show version)
    len <- decodeListLen
    unless (len == 2 || len == 3) $ fail ("unexpected ExtLedgerState length " <> show len)
    skipTerm
    decodeHs

  -- Eras by position: Byron, Shelley, Allegra, Mary, Alonzo, then the
  -- Praos eras Babbage, Conway, Dijkstra.
  praosState :: HardForkState WrapChainDepState (CardanoEras StandardCrypto) -> Either String PraosState
  praosState (HardForkState telescope) = case Telescope.tip telescope of
    S (S (S (S (S (Z c))))) -> Right (unwrapChainDepState (currentState c))
    S (S (S (S (S (S (Z c)))))) -> Right (unwrapChainDepState (currentState c))
    S (S (S (S (S (S (S (Z c))))))) -> Right (unwrapChainDepState (currentState c))
    _ -> Left "the snapshot is not in a Praos era (Babbage or later)"

-- | Skip one CBOR data item.
skipTerm :: Decoder s ()
skipTerm =
  peekTokenType >>= \case
    TypeUInt -> void decodeWord
    TypeUInt64 -> void decodeWord64
    TypeNInt -> void decodeNegWord
    TypeNInt64 -> void decodeNegWord64
    TypeInteger -> void decodeInteger
    TypeFloat16 -> void CBOR.decodeFloat
    TypeFloat32 -> void CBOR.decodeFloat
    TypeFloat64 -> void decodeDouble
    TypeBytes -> void decodeBytes
    TypeBytesIndef -> decodeBytesIndef >> untilBreak (void decodeBytes)
    TypeString -> void decodeString
    TypeStringIndef -> decodeStringIndef >> untilBreak (void decodeString)
    TypeListLen -> decodeListLen >>= \n -> replicateM_ n skipTerm
    TypeListLen64 -> decodeListLen >>= \n -> replicateM_ n skipTerm
    TypeListLenIndef -> decodeListLenIndef >> untilBreak skipTerm
    TypeMapLen -> decodeMapLen >>= \n -> replicateM_ (2 * n) skipTerm
    TypeMapLen64 -> decodeMapLen >>= \n -> replicateM_ (2 * n) skipTerm
    TypeMapLenIndef -> decodeMapLenIndef >> untilBreak (skipTerm >> skipTerm)
    TypeTag -> decodeTag >> skipTerm
    TypeTag64 -> decodeTag64 >> skipTerm
    TypeBool -> void decodeBool
    TypeNull -> decodeNull
    TypeSimple -> void decodeSimple
    TypeBreak -> fail "unexpected break"
    TypeInvalid -> fail "invalid CBOR token"
 where
  untilBreak item = do
    done <- decodeBreakOr
    unless done (item >> untilBreak item)
