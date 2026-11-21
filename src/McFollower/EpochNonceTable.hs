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

    -- * Supplied nonces
  , extendTable
  , SupplyError (..)
  , checkSupplied
  , nonceGap

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

-- | The table extended by nonces supplied at run time
-- (@--epoch-nonces@, kept in the store) as far as they continue it without
-- a gap. 'checkSupplied' refuses supplied nonces that would leave one.
extendTable :: NonceTable -> Map EpochNo Nonce -> NonceTable
extendTable t supplied = t {ntLast = end, ntNonces = Map.union (ntNonces t) (Map.fromList added)}
 where
  added = contiguous (succ (ntLast t))
  contiguous e = case Map.lookup e supplied of
    Just n -> (e, n) : contiguous (succ e)
    Nothing -> []
  end = maybe (ntLast t) fst (lastMaybe added)
  lastMaybe xs = if null xs then Nothing else Just (last xs)

-- | Why supplied nonces are refused.
data SupplyError
  = SuppliedConflict !EpochNo !Text.Text !Nonce !Nonce
  -- ^ The epoch already has another nonce (from the named source: the
  -- shipped table, nonces supplied earlier, or the nonce driver), and the
  -- supplied one.
  | SuppliedBeforeTable !EpochNo !EpochNo
  -- ^ A supplied epoch before the shipped table's first (Byron).
  | SuppliedGap !EpochNo !EpochNo
  -- ^ Supplied epochs from the second on, but none for the first: they
  -- would not continue the table.
  deriving stock (Eq, Show)

-- | Check supplied nonces against the shipped table and the nonces supplied
-- before: each must agree with a value the epoch already has, and together
-- they must continue the table without a gap. Returns the ones to store:
-- those after the table not supplied before.
checkSupplied :: NonceTable -> Map EpochNo Nonce -> Map EpochNo Nonce -> Either SupplyError (Map EpochNo Nonce)
checkSupplied table stored file = do
  mapM_ check (Map.toAscList file)
  let new = Map.filterWithKey (\e _ -> e > ntLast table) (Map.difference file stored)
      extended = extendTable table (Map.union stored file)
  case Map.lookupMin (Map.filterWithKey (\e _ -> e > ntLast extended) (Map.union stored file)) of
    Just (e, _) -> Left (SuppliedGap (succ (ntLast extended)) e)
    Nothing -> Right new
 where
  check (e, n)
    | e < ntFirst table = Left (SuppliedBeforeTable e (ntFirst table))
    | Just t <- tableNonce table e, t /= n = Left (SuppliedConflict e "the shipped table" t n)
    | Just s <- Map.lookup e stored, s /= n = Left (SuppliedConflict e "nonces supplied earlier" s n)
    | otherwise = Right ()

-- | The epochs no nonce is known for between the end of the (extended)
-- table and the epoch the nonce driver starts in, if any: they can never be
-- served.
nonceGap :: NonceTable -> EpochNo -> Maybe (EpochNo, EpochNo)
nonceGap table driverStart
  | driverStart > succ (ntLast table) = Just (succ (ntLast table), pred driverStart)
  | otherwise = Nothing

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
