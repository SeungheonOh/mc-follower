{-# LANGUAGE TemplateHaskell #-}

-- | Historical epoch nonces, shipped with the indexer, and the rule that
-- combines them with the nonce driver's.
--
-- The nonce of an epoch that has already started is a fixed public value,
-- so the nonces of past epochs are not recomputed: they ship per network
-- in @data/epoch-nonces/NETWORK.csv@ (db-sync @epoch_param.nonce@ read
-- from Koios; source and retrieval date in the file's header,
-- regenerated with @scripts/fetch-epoch-nonces.py@). The nonce driver
-- ("McFollower.Nonce") computes the epochs after the table, starting from
-- a current protocol state.
--
-- 'lookupEpochNonce' combines the two: the table for epochs it covers, the
-- driver for later ones. Where both have a value for an epoch they must
-- agree; a disagreement is a 'NonceConflict', never resolved silently in
-- either's favour. 'checkAgainstTable' applies the same rule to each nonce
-- as the driver produces it.
module McFollower.EpochNonceTable
  ( -- * Tables
    NonceTable (..)
  , nonceTable
  , parseNonceTable
  , tableNonce

    -- * Combining with the driver
  , EpochNonceLookup (..)
  , NonceConflict (..)
  , lookupEpochNonce
  , checkAgainstTable
  ) where

import Cardano.Crypto.Hash (hashFromTextAsHex)
import Cardano.Ledger.BaseTypes (Nonce (..))
import Cardano.Slotting.Slot (EpochNo (..))
import Control.Monad (unless, when)
import Data.ByteString (ByteString)
import Data.FileEmbed (embedFile, makeRelativeToProject)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import McFollower.Network (NetworkName (..))
import McFollower.Nonce (EpochNonce (..))
import Text.Read (readMaybe)

-- | The nonces of a contiguous range of epochs.
data NonceTable = NonceTable
  { ntFirst :: !EpochNo
  , ntLast :: !EpochNo
  , ntNonces :: !(Map EpochNo Nonce)
  -- ^ Every epoch from 'ntFirst' to 'ntLast'; 'NeutralNonce' where the
  -- file has an empty nonce.
  }
  deriving stock (Eq, Show)

-- | The shipped table of a network. The files are checked by the test
-- suite; a malformed one fails here on first use.
nonceTable :: NetworkName -> NonceTable
nonceTable network = either (error . (("data/epoch-nonces/" <> show network <> ".csv: ") <>)) id $
  parseNonceTable $ case network of
    Mainnet -> mainnetFile
    Preprod -> preprodFile
    Preview -> previewFile

mainnetFile, preprodFile, previewFile :: ByteString
mainnetFile = $(makeRelativeToProject "data/epoch-nonces/mainnet.csv" >>= embedFile)
preprodFile = $(makeRelativeToProject "data/epoch-nonces/preprod.csv" >>= embedFile)
previewFile = $(makeRelativeToProject "data/epoch-nonces/preview.csv" >>= embedFile)

-- | @#@ comment lines, an @epoch,nonce@ header, then one @EPOCH,HEX@ line
-- per epoch in order without gaps; an empty @HEX@ is the neutral nonce.
parseNonceTable :: ByteString -> Either String NonceTable
parseNonceTable bytes = do
  let rows = filter (\l -> not (Text.null l) && not ("#" `Text.isPrefixOf` l)) (Text.lines (Text.decodeUtf8 bytes))
  body <- case rows of
    "epoch,nonce" : rest -> Right rest
    _ -> Left "missing epoch,nonce header"
  entries <- traverse row body
  case entries of
    [] -> Left "no epochs"
    (first, _) : _ -> do
      let lastEpoch = fst (last entries)
      unless (map fst entries == [first .. lastEpoch]) $ Left "epochs are not contiguous and in order"
      Right (NonceTable first lastEpoch (Map.fromList entries))
 where
  row l = case Text.splitOn "," l of
    [e, n]
      | Just epoch <- readMaybe (Text.unpack e) -> do
          nonce <-
            if Text.null n
              then Right NeutralNonce
              else maybe (Left ("bad nonce in " <> show l)) (Right . Nonce) (hashFromTextAsHex n)
          Right (EpochNo epoch, nonce)
    _ -> Left ("bad line " <> show l)

-- | The table's nonce for an epoch it covers.
tableNonce :: NonceTable -> EpochNo -> Maybe Nonce
tableNonce t e = Map.lookup e (ntNonces t)

-- | What to serve for an epoch.
data EpochNonceLookup
  = NonceInForce !Nonce
  -- ^ Known. 'NeutralNonce' is a known value that db-sync stores as NULL,
  -- so it is served as absent, like db-sync does.
  | NotYetAvailable
  -- ^ After the table and not (yet) produced by the driver: the epoch has
  -- not started on the indexer's chain, or the driver has not reached it.
  -- Served as absent; unlike 'NeutralNonce' it may change later.
  | BeforeTable
  -- ^ Before the table's first epoch (Byron): db-sync has no row.
  deriving stock (Eq, Show)

-- | The table and the driver disagree on an epoch.
data NonceConflict = NonceConflict
  { ncEpoch :: !EpochNo
  , ncTable :: !Nonce
  , ncDriver :: !Nonce
  }
  deriving stock (Eq, Show)

-- | The table for epochs up to its end, the driver's value (as stored,
-- see "McFollower.EpochData.Store") after it.
lookupEpochNonce :: NonceTable -> Maybe Nonce -> EpochNo -> Either NonceConflict EpochNonceLookup
lookupEpochNonce table fromDriver epoch
  | epoch < ntFirst table = Right BeforeTable
  | Just t <- tableNonce table epoch = do
      mapM_ (checkAgainstTable table . EpochNonce epoch) fromDriver
      Right (NonceInForce t)
  | otherwise = Right (maybe NotYetAvailable NonceInForce fromDriver)

-- | A nonce the driver produced must equal the table's, if the table has
-- the epoch.
checkAgainstTable :: NonceTable -> EpochNonce -> Either NonceConflict ()
checkAgainstTable table (EpochNonce epoch nonce) = case tableNonce table epoch of
  Just t -> when (t /= nonce) $ Left (NonceConflict epoch t nonce)
  Nothing -> Right ()
