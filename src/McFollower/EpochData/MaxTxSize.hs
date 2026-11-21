-- | The protocol parameter @maxTxSize@ per epoch, as @GetMaxTxSize@ serves
-- it (db-sync @epoch_param.max_tx_size@).
--
-- With a local node the value comes from the node's current protocol
-- parameters ("McFollower.LocalStateQuery"). Without one (node-to-node
-- mode) it comes from a per-network table in configuration, guarded by a
-- tripwire: every block is scanned for proposals that would change
-- @maxTxSize@ ('scanBlock'). A sighting blocks serving the value for every
-- epoch from the earliest one the proposal could take effect in, until the
-- operator has reviewed it, brought the table up to date and acknowledged
-- the proposal in configuration ('lookupMaxTxSize'). Whether the proposal
-- was in fact enacted is not tracked; that needs the ledger.
--
-- Proposals that are found:
--
-- * Conway and later: a governance action @ParameterChange@ whose update
--   sets @maxTxSize@, in a phase-2-valid transaction (in Dijkstra, in a
--   sub-transaction too). Submitted in epoch @e@, it enters ratification at
--   the boundary into @e + 1@ and can be enacted at the boundary into
--   @e + 2@ at the earliest (Conway @EPOCH@ rule: enactment applies the
--   ratification state computed during the previous epoch, from the
--   proposals of the epoch before it).
-- * Shelley to Babbage: a protocol parameter update proposal (genesis
--   delegates) setting @maxTxSize@ for epoch @t@; if adopted it is in
--   force from @t + 1@.
--
-- Byron update proposals are not scanned.
module McFollower.EpochData.MaxTxSize
  ( -- * Table
    MaxTxSizeTable (..)
  , maxTxSizePreset
  , tableLookup
  , acknowledgedPreset

    -- * Tripwire
  , ProposalRef (..)
  , renderProposalRef
  , parseProposalRef
  , MaxTxSizeSighting (..)
  , scanBlock
  , updateSightings
  , proposalSightings

    -- * Answer
  , MaxTxSizeRefusal (..)
  , lookupMaxTxSize
  ) where

import Cardano.Crypto.Hash (hashFromTextAsHex, hashToTextAsHex)
import Cardano.Ledger.Alonzo.Tx (AlonzoEraTx (..), IsPhase2Valid (..))
import Cardano.Ledger.BaseTypes (StrictMaybe (..))
import Cardano.Ledger.Block qualified as Ledger
import Cardano.Ledger.Conway.TxBody (ConwayEraTxBody (..))
import Cardano.Ledger.Conway.Governance
  ( GovAction (..)
  , ProposalProcedure (..)
  )
import Cardano.Ledger.Core
  ( EraBlockBody (..)
  , EraPParams (..)
  , EraTx (..)
  , EraTxBody (..)
  , PParamsUpdate
  , TxLevel (..)
  , ppuMaxTxSizeL
  , txIdTxBody
  )
import Cardano.Ledger.Dijkstra.TxBody (DijkstraEraTxBody (..))
import Cardano.Ledger.Hashes (extractHash, unsafeMakeSafeHash)
import Cardano.Ledger.Keys (KeyHash (..), KeyRole (GenesisRole))
import Cardano.Ledger.Shelley.PParams (ProposedPPUpdates (..), Update (..))
import Cardano.Ledger.Shelley.TxBody (ShelleyEraTxBody (..))
import Cardano.Ledger.TxIn (TxId (..))
import Cardano.Slotting.Slot (EpochNo (..))
import Data.Foldable (toList)
import Data.List (sortOn)
import Data.Map.Strict qualified as Map
import Data.Maybe (listToMaybe)
import Data.Set (Set)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word16, Word32)
import Lens.Micro ((^.))
import McFollower.Block (Block)
import McFollower.Network (NetworkName (..))
import Ouroboros.Consensus.Block (Point, blockPoint)
import Ouroboros.Consensus.Cardano.Block
  ( pattern BlockAllegra
  , pattern BlockAlonzo
  , pattern BlockBabbage
  , pattern BlockByron
  , pattern BlockConway
  , pattern BlockDijkstra
  , pattern BlockMary
  , pattern BlockShelley
  )
import Ouroboros.Consensus.Shelley.Ledger (ShelleyBlock (..))
import Text.Read (readMaybe)

-- | @maxTxSize@ as a step function of the epoch: each entry is the value
-- from its epoch until the next entry's. Epochs before the first entry
-- are not covered.
newtype MaxTxSizeTable = MaxTxSizeTable [(EpochNo, Word32)]
  deriving stock (Eq, Show)

-- | Known history per network. On all three networks @maxTxSize@ has been
-- 16384 bytes from the first Shelley epoch to the time of writing:
--
-- * Shelley genesis @protocolParams.maxTxSize = 16384@ for mainnet,
--   preprod and preview (genesis files at
--   <https://book.play.dev.cardano.org/environments/>, read 2026-11-20).
-- * Koios @epoch_params@ (db-sync @epoch_param.max_tx_size@) is 16384 for
--   every epoch: mainnet 208-668, preprod 4-326, preview 0-1487 (read
--   2026-11-20).
-- * Koios @param_updates@ lists no enacted change; on preview, four
--   Conway proposals to change it were never enacted (16386 in epoch 750,
--   32768 in 1046, 16385 in 1047, 16400 in 1350).
--
-- Byron epochs (mainnet before 208, preprod before 4) have no
-- @epoch_param@ row in db-sync and are not covered.
maxTxSizePreset :: NetworkName -> MaxTxSizeTable
maxTxSizePreset = \case
  Mainnet -> MaxTxSizeTable [(EpochNo 208, 16384)]
  Preprod -> MaxTxSizeTable [(EpochNo 4, 16384)]
  Preview -> MaxTxSizeTable [(EpochNo 0, 16384)]

tableLookup :: MaxTxSizeTable -> EpochNo -> Maybe Word32
tableLookup (MaxTxSizeTable entries) epoch =
  fmap snd . listToMaybe . reverse $ takeWhile ((<= epoch) . fst) (sortOn fst entries)

-- | Proposals per network that were reviewed when the indexer was
-- released and need no @--acknowledge-proposal@. Every Conway proposal to
-- change @maxTxSize@ on preview, from Koios @proposal_list@ (read
-- 2026-11-20); none was ratified or enacted and @maxTxSize@ stayed 16384
-- throughout (see 'maxTxSizePreset'):
--
-- * @3f8139c5...82f8#0@: 16386, submitted in epoch 750, expired.
-- * @608037b7...e09b#0@: 32768, submitted in epoch 1046, expired.
-- * @8db9c91a...7a16#0@: 16385, submitted in epoch 1047, expired.
-- * @8b5f096a...82e4#0@: 16400, submitted in epoch 1350, dropped in 1367.
--   It is after preview's preset start point, so without this entry a new
--   preview database would refuse @GetMaxTxSize@ from epoch 1352 on.
--
-- Mainnet and preprod have had no such proposal.
acknowledgedPreset :: NetworkName -> Set ProposalRef
acknowledgedPreset = \case
  Mainnet -> Set.empty
  Preprod -> Set.empty
  Preview ->
    Set.fromList . map (either error id . parseProposalRef) $
      [ "3f8139c5a67d3ef290ebbf9cad60009713fbb994bd41d4c885fbeefa706382f8#0"
      , "608037b7bcb79de6d57a3570857832811f79e3a7f8f90cf3c92aec999c99e09b#0"
      , "8db9c91ab04f4f198d98e9bda5dbf08870154514f2a213d0858f2ba51a1d7a16#0"
      , "8b5f096ad63618f1b73112d8ac46fb59519897cbfa318fdb9ffed2dfcee782e4#0"
      ]

-- | Identifies a proposal so the operator can acknowledge it.
data ProposalRef
  = GovernanceAction !TxId !Word16
  -- ^ A Conway governance action: transaction id and index.
  | UpdateProposal !TxId !(KeyHash GenesisRole)
  -- ^ A pre-Conway update proposal: transaction id and proposing genesis
  -- key.
  deriving stock (Eq, Ord, Show)

-- | @TXID#INDEX@ or @TXID\@GENESISKEYHASH@, hex.
renderProposalRef :: ProposalRef -> Text
renderProposalRef = \case
  GovernanceAction txId ix -> renderTxId txId <> "#" <> Text.pack (show ix)
  UpdateProposal txId (KeyHash kh) -> renderTxId txId <> "@" <> hashToTextAsHex kh
 where
  renderTxId (TxId h) = hashToTextAsHex (extractHash h)

parseProposalRef :: Text -> Either String ProposalRef
parseProposalRef t = case (Text.splitOn "#" t, Text.splitOn "@" t) of
  ([txId, ix], _)
    | Just tid <- parseTxId txId
    , Just i <- readMaybe (Text.unpack ix) ->
        Right (GovernanceAction tid i)
  (_, [txId, kh])
    | Just tid <- parseTxId txId
    , Just h <- hashFromTextAsHex kh ->
        Right (UpdateProposal tid (KeyHash h))
  _ -> Left ("expected TXID#INDEX or TXID@GENESISKEYHASH, got " <> show t)
 where
  parseTxId = fmap (TxId . unsafeMakeSafeHash) . hashFromTextAsHex

data MaxTxSizeSighting = MaxTxSizeSighting
  { mssProposal :: !ProposalRef
  , mssPoint :: !(Point Block)
  -- ^ The block carrying it; on a rollback past it the sighting goes.
  , mssProposedValue :: !Word32
  , mssEarliestEpoch :: !EpochNo
  -- ^ The first epoch whose @maxTxSize@ the proposal could change.
  }
  deriving stock (Eq, Show)

-- | Proposals in a block that would change @maxTxSize@. The epoch is the
-- block's own.
scanBlock :: EpochNo -> Block -> [MaxTxSizeSighting]
scanBlock epoch blk = case blk of
  BlockByron _ -> []
  BlockShelley b -> concatMap (updateSightings point) (allTxs b)
  BlockAllegra b -> concatMap (updateSightings point) (allTxs b)
  BlockMary b -> concatMap (updateSightings point) (allTxs b)
  BlockAlonzo b -> concatMap (updateSightings point) (validTxs b)
  BlockBabbage b -> concatMap (updateSightings point) (validTxs b)
  BlockConway b -> concatMap (proposalSightings epoch point . (^. bodyTxL)) (validTxs b)
  BlockDijkstra b -> concatMap withSubTransactions (validTxs b)
 where
  point = blockPoint blk

  withSubTransactions tx =
    let body = tx ^. bodyTxL
     in proposalSightings epoch point body
          <> concatMap (proposalSightings epoch point . (^. bodyTxL)) (toList (body ^. subTransactionsTxBodyL))

  allTxs :: EraBlockBody era => ShelleyBlock proto era -> [Tx TopTx era]
  allTxs ShelleyBlock {shelleyBlockRaw} = toList (Ledger.blockBody shelleyBlockRaw ^. txSeqBlockBodyL)

  validTxs :: (EraBlockBody era, AlonzoEraTx era) => ShelleyBlock proto era -> [Tx TopTx era]
  validTxs = filter (\tx -> tx ^. isPhase2ValidTxL == Phase2Valid) . allTxs

-- | The @maxTxSize@ changes in a pre-Conway transaction's update proposal,
-- one per proposing genesis key. The transaction must be one whose update
-- takes effect (in Alonzo and Babbage, a phase-2-valid one).
updateSightings :: (EraTx era, ShelleyEraTxBody era) => Point Block -> Tx TopTx era -> [MaxTxSizeSighting]
updateSightings point tx = case body ^. updateTxBodyL of
  SNothing -> []
  SJust (Update (ProposedPPUpdates byKey) (EpochNo target)) ->
    [ MaxTxSizeSighting
        { mssProposal = UpdateProposal (txIdTxBody body) genesisKey
        , mssPoint = point
        , mssProposedValue = value
        , mssEarliestEpoch = EpochNo (target + 1)
        }
    | (genesisKey, update) <- Map.toList byKey
    , SJust value <- [maxTxSizeOf update]
    ]
 where
  body = tx ^. bodyTxL

-- | The @ParameterChange@ governance actions setting @maxTxSize@ among a
-- (phase-2-valid) transaction body's proposals, submitted in the given
-- epoch.
proposalSightings
  :: (EraTx era, ConwayEraTxBody era) => EpochNo -> Point Block -> TxBody l era -> [MaxTxSizeSighting]
proposalSightings (EpochNo e) point body =
  [ MaxTxSizeSighting
      { mssProposal = GovernanceAction (txIdTxBody body) ix
      , mssPoint = point
      , mssProposedValue = value
      , mssEarliestEpoch = EpochNo (e + 2)
      }
  | (ix, ProposalProcedure {pProcGovAction = ParameterChange _ update _}) <-
      zip [0 ..] (toList (body ^. proposalProceduresTxBodyL))
  , SJust value <- [maxTxSizeOf update]
  ]

maxTxSizeOf :: EraPParams era => PParamsUpdate era -> StrictMaybe Word32
maxTxSizeOf update = update ^. ppuMaxTxSizeL

data MaxTxSizeRefusal
  = NotCovered !EpochNo
  -- ^ The table has no value for the epoch.
  | UnconfirmedProposal !EpochNo ![MaxTxSizeSighting]
  -- ^ Proposals that could have changed the epoch's value and that the
  -- operator has not acknowledged.
  deriving stock (Eq, Show)

-- | The value for an epoch, unless an unacknowledged sighting could have
-- changed it or the table does not cover it.
lookupMaxTxSize
  :: MaxTxSizeTable
  -> Set ProposalRef
  -- ^ Acknowledged proposals (configuration).
  -> [MaxTxSizeSighting]
  -- ^ Every sighting on the current chain.
  -> EpochNo
  -> Either MaxTxSizeRefusal Word32
lookupMaxTxSize table acknowledged sightings epoch
  | not (null blocking) = Left (UnconfirmedProposal epoch blocking)
  | otherwise = maybe (Left (NotCovered epoch)) Right (tableLookup table epoch)
 where
  blocking =
    [ s
    | s <- sightings
    , mssEarliestEpoch s <= epoch
    , not (mssProposal s `Set.member` acknowledged)
    ]
