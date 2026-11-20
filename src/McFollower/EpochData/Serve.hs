{-# LANGUAGE RecordWildCards #-}

-- | What @GetEpochNonce@, @GetStakeDistribution@ and @GetMaxTxSize@ answer,
-- from what the store holds. Pure decisions; the server turns them into
-- responses and status codes.
--
-- The rule throughout: an absent or empty answer is given only where
-- db-sync would give one too. Where the indexer does not know a value yet
-- (or cannot vouch for it) the answer is 'NotAvailable', which the server
-- sends as @UNAVAILABLE@ and the node's gRPC row source turns into an
-- error. This matters most for the nonce: the node's authority selection
-- replaces an absent nonce with the empty one
-- (@epoch_nonce_response.unwrap_or(EpochNonce(vec![]))@ in
-- @authority_selection_inputs.rs@), so an absent answer where db-sync has a
-- nonce would make the node select a different committee than its peers.
module McFollower.EpochData.Serve
  ( -- * Configuration
    EpochDataConfig (..)
  , EpochHealth (..)
  , healthy

    -- * Answers
  , EpochAnswer (..)
  , answerEpochNonce
  , answerStake
  , answerMaxTxSize
  ) where

import Cardano.Crypto.Hash (hashToBytes)
import Cardano.Ledger.BaseTypes (Nonce)
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash (..))
import Cardano.Slotting.Slot (EpochNo (..))
import Data.ByteString (ByteString)
import Data.Map.Strict qualified as Map
import Data.Set (Set)
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word32, Word64)
import McFollower.Block (renderPoint)
import McFollower.EpochData.MaxTxSize
  ( MaxTxSizeRefusal (..)
  , MaxTxSizeSighting (..)
  , MaxTxSizeTable
  , ProposalRef
  , lookupMaxTxSize
  , renderProposalRef
  )
import McFollower.EpochData.Stake (PoolStake)
import McFollower.EpochNonceTable
  ( EpochNonceLookup (..)
  , NonceConflict (..)
  , NonceTable (..)
  , lookupEpochNonce
  )
import McFollower.Nonce (nonceBytes)

-- | What the server needs besides the store to answer the epoch data
-- calls.
data EpochDataConfig = EpochDataConfig
  { edcNonceTable :: !NonceTable
  -- ^ The network's shipped epoch nonces.
  , edcMaxTxSize :: !MaxTxSizeTable
  , edcAcknowledged :: !(Set ProposalRef)
  -- ^ @maxTxSize@ proposals the operator has reviewed.
  , edcFirstShelleyEpoch :: !EpochNo
  -- ^ db-sync has no stake distribution for earlier (Byron) epochs.
  , edcHealth :: !(IO EpochHealth)
  -- ^ The producers' view, for @GetStatus@ and the nonce cross-check.
  }

-- | How the epoch data producers are doing (see
-- "McFollower.EpochData.Producer").
data EpochHealth = EpochHealth
  { ehDriver :: !Text
  -- ^ The nonce driver's state, for operators.
  , ehMissingStake :: ![EpochNo]
  -- ^ Epochs in the backfill window whose stake distribution the indexer
  -- expects to obtain and has not yet.
  , ehNonceDivergence :: !(Maybe Text)
  -- ^ Set when the driver's protocol state disagrees with a local node's
  -- at the same block. Nonces the driver produced are then not served.
  }
  deriving stock (Eq, Show)

-- | Nothing known to be wrong or missing.
healthy :: EpochHealth
healthy = EpochHealth "unknown" [] Nothing

data EpochAnswer a
  = Answer !a
  | NotAvailable !Text
  -- ^ The indexer does not know (yet): @UNAVAILABLE@.
  | Inconsistent !Text
  -- ^ The stored data contradicts itself: @INTERNAL@.
  deriving stock (Eq, Show)

-- | @GetEpochNonce@: the shipped table up to its last epoch, the nonce
-- driver's stored nonces after it.
--
-- * A known nonce: its 32 bytes.
-- * The neutral nonce, and epochs before the table (Byron): absent, as
--   db-sync stores NULL or has no row.
-- * After the table and not produced by the driver (the epoch has not
--   started on the indexer's chain, the driver has not reached it, or there
--   is no driver): not available.
-- * A driver nonce while the driver is known to diverge from a local node:
--   not available.
answerEpochNonce :: NonceTable -> Maybe Text -> Maybe Nonce -> EpochNo -> EpochAnswer (Maybe ByteString)
answerEpochNonce table divergence fromDriver epoch = case lookupEpochNonce table fromDriver epoch of
  Left NonceConflict {ncTable, ncDriver} ->
    Inconsistent
      ( "the shipped nonce of epoch " <> epochText epoch <> " (" <> showText ncTable
          <> ") differs from the nonce driver's (" <> showText ncDriver <> ")"
      )
  Right BeforeTable -> Answer Nothing
  Right NotYetAvailable ->
    NotAvailable
      ( "the nonce of epoch " <> epochText epoch <> " is not known yet: the shipped table ends at epoch "
          <> epochText (ntLast table) <> " and the nonce driver has not produced it"
      )
  Right (NonceInForce n)
    | epoch > ntLast table
    , Just d <- divergence ->
        NotAvailable ("the nonce driver disagrees with the local node (" <> d <> "); its nonces are withheld")
    | otherwise -> Answer (nonceBytes n)

-- | @GetStakeDistribution@: a complete distribution's pools by pool hash;
-- empty for Byron epochs, which db-sync has no rows for; otherwise not
-- available (the indexer expects to obtain it from a node or Mithril, or
-- the epoch is outside what its sources cover).
answerStake :: EpochNo -> Maybe PoolStake -> EpochNo -> EpochAnswer [(ByteString, Word64)]
answerStake firstShelley stored epoch = case stored of
  Just pools -> Answer [(hashToBytes h, fromInteger c) | (KeyHash h, Coin c) <- Map.toAscList pools]
  Nothing
    | epoch < firstShelley -> Answer []
    | otherwise ->
        NotAvailable ("the stake distribution of epoch " <> epochText epoch <> " has not been obtained (yet)")

-- | @GetMaxTxSize@ for the epoch of the requested block: a local node's
-- value if one was stored; else the configured table, unless a proposal
-- that could change the epoch's value was sighted and not acknowledged
-- (not available, naming the proposals); absent for epochs the table does
-- not cover (Byron: db-sync has no @epoch_param@ row).
answerMaxTxSize
  :: MaxTxSizeTable
  -> Set ProposalRef
  -> [MaxTxSizeSighting]
  -> Maybe Word32
  -> EpochNo
  -> EpochAnswer (Maybe Word64)
answerMaxTxSize table acknowledged sightings fromNode epoch = case fromNode of
  Just size -> Answer (Just (fromIntegral size))
  Nothing -> case lookupMaxTxSize table acknowledged sightings epoch of
    Right size -> Answer (Just (fromIntegral size))
    Left (NotCovered _) -> Answer Nothing
    Left (UnconfirmedProposal _ blocking) ->
      NotAvailable
        ( "maxTxSize of epoch " <> epochText epoch <> " may have been changed by "
            <> Text.intercalate "; " (map describe blocking)
            <> ". Review the proposal, bring --max-tx-size up to date and acknowledge it with --acknowledge-proposal"
        )
 where
  describe MaxTxSizeSighting {..} =
    "proposal " <> renderProposalRef mssProposal <> " (maxTxSize " <> showText mssProposedValue
      <> ", from epoch " <> epochText mssEarliestEpoch <> " at the earliest, in block " <> renderPoint mssPoint <> ")"

showText :: Show a => a -> Text
showText = Text.pack . show

epochText :: EpochNo -> Text
epochText (EpochNo e) = showText e
