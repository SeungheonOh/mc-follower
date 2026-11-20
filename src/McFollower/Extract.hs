{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -Werror=incomplete-patterns #-}

-- | The extractor: a pure function from a block to the rows the store keeps,
-- reproducing cardano-db-sync 13.8's representation (docs/SPEC.md section 4).
--
-- Per transaction (db-sync @Cardano.DbSync.Era.Shelley.Generic.Tx.*@ and
-- @Era.Universal.Insert.Tx@):
--
-- * Inputs that consume outputs: the regular inputs of a valid transaction,
--   the collateral inputs of a phase-2-invalid one. Reference inputs and the
--   collateral inputs of valid transactions never consume.
-- * Outputs: the regular outputs of a valid transaction. A phase-2-invalid
--   Babbage-or-later transaction has exactly one, its collateral return, at
--   index @length outputs@; a phase-2-invalid Alonzo transaction has none.
--   Only outputs matching the watch set are kept.
-- * Datums: the witness-set datums of valid transactions and the inline
--   datum of every output db-sync writes (outputs as above, plus the
--   collateral return of valid transactions), whether or not the output is
--   watched, keyed by hash with their original bytes. db-sync puts all of
--   these into its global @datum@ table, which is what resolves a datum hash.
-- * Metadata: for valid transactions only, the watched labels.
--
-- Matching an era is exhaustive: a new era is a compile error here.
module McFollower.Extract
  ( -- * Rows
    BlockRows (..)
  , TxRows (..)
  , OutputRow (..)
  , OutRef (..)

    -- * Extraction
  , extractBlock

    -- * Describing blocks
  , TxFeatures (..)
  , blockFeatures
  ) where

import Cardano.Chain.Block qualified as Byron
import Cardano.Chain.UTxO qualified as Byron
import Cardano.Crypto.Hash.Class (hashToBytes)
import Cardano.Crypto.Hashing qualified as Byron
import Cardano.Ledger.Address (Addr (..), BootstrapAddress (..), serialiseAddr)
import Cardano.Ledger.Alonzo.Tx (AlonzoEraTx (..), IsPhase2Valid (..))
import Cardano.Ledger.Alonzo.TxBody (AlonzoEraTxBody (..))
import Cardano.Ledger.Alonzo.TxOut (AlonzoEraTxOut (..))
import Cardano.Ledger.Alonzo.TxWits (AlonzoEraTxWits (..), unTxDats)
import Cardano.Ledger.Babbage.TxBody (BabbageEraTxBody (..))
import Cardano.Ledger.Babbage.TxOut (BabbageEraTxOut (..))
import Cardano.Ledger.BaseTypes (TxIx (..))
import Cardano.Ledger.Binary (serialize', shelleyProtVer)
import Cardano.Ledger.Block qualified as Ledger
import Cardano.Ledger.Core
  ( EraBlockBody (..)
  , EraTx (..)
  , EraTxAuxData (..)
  , EraTxBody (..)
  , EraTxOut (..)
  , Tx
  , TxLevel (..)
  , TxOut
  , Value
  , originalBytes
  , txIdTx
  )
import Cardano.Ledger.Hashes (DataHash, extractHash)
import Cardano.Ledger.Mary.Value (AssetName (..), MaryValue (..), MultiAsset (..), PolicyID (..))
import Cardano.Ledger.Hashes (ScriptHash (..))
import Cardano.Ledger.Metadata (Metadatum)
import Cardano.Ledger.Plutus.Data (Datum (..), hashBinaryData)
import Cardano.Ledger.TxIn (TxId (..), TxIn (..))
import Data.ByteString (ByteString)
import Data.ByteString.Short qualified as SBS
import Data.Foldable (toList)
import Data.Int (Int64)
import Data.List.NonEmpty qualified as NonEmpty
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe.Strict (StrictMaybe (..), strictMaybeToMaybe)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Word (Word16, Word64)
import Lens.Micro ((^.))
import McFollower.Address (renderAddress)
import McFollower.Block (Block)
import McFollower.EraHistory (EraHistory, SlotInfo (..), slotInfo)
import McFollower.WatchSet (WatchFilter (..))
import Ouroboros.Consensus.Block (blockHash, blockNo, blockPrevHash, blockSlot)
import Ouroboros.Consensus.Block qualified as Consensus
import Ouroboros.Consensus.Byron.Ledger (ByronBlock (..))
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
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Ouroboros.Consensus.HardFork.History (PastHorizonException)
import Ouroboros.Consensus.Shelley.Ledger (ShelleyBlock (..))
import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (EpochNo (..), SlotNo (..))

-- | Everything the store keeps about one block.
data BlockRows = BlockRows
  { brHash :: !ByteString
  , brPrevHash :: !(Maybe ByteString)
  -- ^ 'Nothing' for the first block of the chain.
  , brNumber :: !(Maybe Word64)
  -- ^ 'Nothing' for Byron epoch boundary blocks, as in db-sync.
  , brSlot :: !Word64
  , brEpoch :: !Word64
  , brTime :: !Int64
  -- ^ Slot start, whole seconds since the Unix epoch.
  , brTxs :: ![TxRows]
  -- ^ Every transaction, phase-2-invalid ones included, in block order. The
  -- position in this list is the transaction's index in the block.
  }
  deriving stock (Eq, Show)

data TxRows = TxRows
  { trHash :: !ByteString
  , trSpends :: ![OutRef]
  -- ^ Outputs this transaction consumes, in ledger order (sorted).
  , trOutputs :: ![OutputRow]
  -- ^ Watched outputs only.
  , trRecordInputs :: !Bool
  -- ^ The transaction creates an output at an address whose creating
  -- transactions' input lists are kept; 'trSpends' is that list.
  , trDatums :: ![(ByteString, ByteString)]
  -- ^ (datum hash, original datum bytes).
  , trMetadata :: ![(Word64, ByteString)]
  -- ^ (label, CBOR of that label's metadatum).
  }
  deriving stock (Eq, Show)

data OutputRow = OutputRow
  { orIndex :: !Word16
  , orAddress :: !Text
  , orDatumHash :: !(Maybe ByteString)
  -- ^ Hash of the inline datum or the datum hash, as db-sync's
  -- @tx_out.data_hash@.
  , orAssets :: ![(ByteString, ByteString, Word64)]
  -- ^ (policy, asset name, quantity).
  }
  deriving stock (Eq, Show)

data OutRef = OutRef
  { refTxHash :: !ByteString
  , refIndex :: !Word16
  }
  deriving stock (Eq, Ord, Show)

-- | Fails only if the era history cannot place the block's slot.
extractBlock :: WatchFilter -> EraHistory -> Block -> Either PastHorizonException BlockRows
extractBlock wf eras blk = do
  SlotInfo {siEpoch, siTime} <- slotInfo eras slot
  pure
    BlockRows
      { brHash = SBS.fromShort (getOneEraHash (blockHash blk))
      , brPrevHash = case blockPrevHash blk of
          Consensus.GenesisHash -> Nothing
          Consensus.BlockHash h -> Just (SBS.fromShort (getOneEraHash h))
      , brNumber = if isBoundary then Nothing else Just (unBlockNo (blockNo blk))
      , brSlot = unSlotNo slot
      , brEpoch = unEpochNo siEpoch
      , brTime = siTime
      , brTxs = map (txRows wf) txs
      }
 where
  slot = blockSlot blk
  (isBoundary, txs) = blockTxs blk

-- | What a transaction contains, regardless of the watch set; used to pick
-- test fixtures.
data TxFeatures = TxFeatures
  { tfValid :: !Bool
  , tfCollateralReturn :: !Bool
  -- ^ Phase-2-invalid with a collateral return output.
  , tfInlineDatums :: !Int
  -- ^ Stored outputs with an inline datum.
  , tfDatumHashes :: !Int
  -- ^ Stored outputs with only a datum hash.
  , tfWitnessDatums :: !Int
  , tfWitnessedDatumHashes :: !Int
  -- ^ Stored outputs with only a datum hash whose datum is in this
  -- transaction's witness set.
  , tfMultiAssetOutputs :: !Int
  , tfByronAddresses :: !Int
  , tfMetadataLabels :: ![Word64]
  }
  deriving stock (Eq, Show)

-- | Whether the block is an epoch boundary block, and what each of its
-- transactions contains.
blockFeatures :: Block -> (Bool, [TxFeatures])
blockFeatures blk = (isBoundary, map features txs)
 where
  (isBoundary, txs) = blockTxs blk
  features TxView {..} =
    TxFeatures
      { tfValid = tvValid
      , tfCollateralReturn = not tvValid && not (null tvOutputs)
      , tfInlineDatums = count (\o -> case ovDatum o of Inline {} -> True; _ -> False)
      , tfDatumHashes = count (\o -> case ovDatum o of HashOnly {} -> True; _ -> False)
      , tfWitnessDatums = length tvWitnessDatums
      , tfWitnessedDatumHashes =
          count (\o -> case ovDatum o of HashOnly h -> h `elem` map fst tvWitnessDatums; _ -> False)
      , tfMultiAssetOutputs = count (not . null . ovAssets)
      , tfByronAddresses = count (\o -> case ovAddress o of AddrBootstrap {} -> True; _ -> False)
      , tfMetadataLabels = Map.keys tvMetadata
      }
   where
    count p = length (filter (p . snd) tvOutputs)

-- | One transaction, in the shape db-sync stores it, before filtering.
data TxView = TxView
  { tvHash :: !ByteString
  , tvValid :: !Bool
  , tvSpends :: ![OutRef]
  , tvOutputs :: ![(Word16, OutView)]
  , tvCollateralReturn :: !(Maybe OutView)
  -- ^ Of a valid transaction: not an output, but its inline datum is kept.
  , tvWitnessDatums :: ![(ByteString, ByteString)]
  , tvMetadata :: !(Map Word64 Metadatum)
  }

data OutView = OutView
  { ovAddress :: !Addr
  , ovAssets :: ![(PolicyID, AssetName, Integer)]
  , ovDatum :: !OutDatum
  }

data OutDatum
  = NoOutDatum
  | HashOnly !ByteString
  | Inline !ByteString !ByteString

txRows :: WatchFilter -> TxView -> TxRows
txRows WatchFilter {..} TxView {..} =
  TxRows
    { trHash = tvHash
    , trSpends = tvSpends
    , trOutputs = [mk ix | (ix, out) <- tvOutputs, Just mk <- [watched out]]
    , trRecordInputs = any ((`Set.member` wfInputListAddresses) . serialiseAddr . ovAddress . snd) tvOutputs
    , trDatums =
        tvWitnessDatums
          <> [d | out <- map snd tvOutputs <> toList tvCollateralReturn, Inline h b <- [ovDatum out], let d = (h, b)]
    , trMetadata =
        [ (label, serialize' shelleyProtVer md)
        | (label, md) <- Map.toList tvMetadata
        , label `Set.member` wfMetadataLabels
        ]
    }
 where
  watched OutView {..}
    | serialiseAddr ovAddress `Set.member` wfAddresses = Just (mkRow ovAssets)
    | watchedAssets@(_ : _) <- filter (\(p, _, _) -> p `Set.member` wfPolicies) ovAssets = Just (mkRow watchedAssets)
    | otherwise = Nothing
   where
    mkRow assets ix =
      OutputRow
        { orIndex = ix
        , orAddress = renderAddress ovAddress
        , orDatumHash = case ovDatum of
            NoOutDatum -> Nothing
            HashOnly h -> Just h
            Inline h _ -> Just h
        , orAssets = [(policyBytes p, SBS.fromShort n, fromInteger q) | (p, AssetName n, q) <- assets]
        }

-- | Whether the block is an epoch boundary block, and its transactions.
blockTxs :: Block -> (Bool, [TxView])
blockTxs = \case
  BlockByron ByronBlock {byronBlockRaw} -> case byronBlockRaw of
    Byron.ABOBBoundary _ -> (True, [])
    Byron.ABOBBlock b -> (False, map byronTx (Byron.aUnTxPayload (Byron.blockTxPayload b)))
  BlockShelley b -> (False, map (shelleyTx coinOnly) (ledgerTxs b))
  BlockAllegra b -> (False, map (shelleyTx coinOnly) (ledgerTxs b))
  BlockMary b -> (False, map (shelleyTx maryAssets) (ledgerTxs b))
  BlockAlonzo b -> (False, map alonzoTx (ledgerTxs b))
  BlockBabbage b -> (False, map babbageTx (ledgerTxs b))
  BlockConway b -> (False, map babbageTx (ledgerTxs b))
  BlockDijkstra b -> (False, map babbageTx (ledgerTxs b))
 where
  ledgerTxs :: EraBlockBody era => ShelleyBlock proto era -> [Tx TopTx era]
  ledgerTxs ShelleyBlock {shelleyBlockRaw} = toList (Ledger.blockBody shelleyBlockRaw ^. txSeqBlockBodyL)

byronTx :: Byron.ATxAux ByteString -> TxView
byronTx txAux =
  TxView
    { tvHash = Byron.hashToBytes (Byron.serializeCborHash tx)
    , tvValid = True
    , tvSpends = [OutRef (Byron.hashToBytes txId) ix | Byron.TxInUtxo txId ix <- NonEmpty.toList (Byron.txInputs tx)]
    , tvOutputs =
        zip [0 ..] [OutView (AddrBootstrap (BootstrapAddress (Byron.txOutAddress out))) [] NoOutDatum | out <- NonEmpty.toList (Byron.txOutputs tx)]
    , tvCollateralReturn = Nothing
    , tvWitnessDatums = []
    , tvMetadata = Map.empty
    }
 where
  tx = Byron.taTx txAux

-- | Shelley, Allegra and Mary: every transaction is valid, no datums.
shelleyTx :: EraTx era => (Value era -> [(PolicyID, AssetName, Integer)]) -> Tx TopTx era -> TxView
shelleyTx assets tx =
  TxView
    { tvHash = txHash tx
    , tvValid = True
    , tvSpends = map outRef (toList (body ^. inputsTxBodyL))
    , tvOutputs = zip [0 ..] [OutView (out ^. addrTxOutL) (assets (out ^. valueTxOutL)) NoOutDatum | out <- toList (body ^. outputsTxBodyL)]
    , tvCollateralReturn = Nothing
    , tvWitnessDatums = []
    , tvMetadata = metadata tx
    }
 where
  body = tx ^. bodyTxL

alonzoTx
  :: (AlonzoEraTx era, Value era ~ MaryValue)
  => Tx TopTx era -> TxView
alonzoTx tx = case tx ^. isPhase2ValidTxL of
  Phase2Valid ->
    TxView
      { tvHash = txHash tx
      , tvValid = True
      , tvSpends = map outRef (toList (body ^. inputsTxBodyL))
      , tvOutputs = zip [0 ..] (map alonzoOut (toList (body ^. outputsTxBodyL)))
      , tvCollateralReturn = Nothing
      , tvWitnessDatums = witnessDatums tx
      , tvMetadata = metadata tx
      }
  Phase2Invalid ->
    TxView
      { tvHash = txHash tx
      , tvValid = False
      , tvSpends = map outRef (toList (body ^. collateralInputsTxBodyL))
      , tvOutputs = []
      , tvCollateralReturn = Nothing
      , tvWitnessDatums = []
      , tvMetadata = Map.empty
      }
 where
  body = tx ^. bodyTxL
  alonzoOut out =
    OutView
      { ovAddress = out ^. addrTxOutL
      , ovAssets = maryAssets (out ^. valueTxOutL)
      , ovDatum = maybe NoOutDatum (HashOnly . dataHashBytes) (strictMaybeToMaybe (out ^. dataHashTxOutL))
      }

-- | Babbage, Conway and Dijkstra (top-level transactions only, as db-sync).
babbageTx
  :: (AlonzoEraTx era, BabbageEraTxBody era, Value era ~ MaryValue)
  => Tx TopTx era -> TxView
babbageTx tx = case tx ^. isPhase2ValidTxL of
  Phase2Valid ->
    TxView
      { tvHash = txHash tx
      , tvValid = True
      , tvSpends = map outRef (toList (body ^. inputsTxBodyL))
      , tvOutputs = zip [0 ..] (map babbageOut outputs)
      , tvCollateralReturn = babbageOut <$> collateralReturn
      , tvWitnessDatums = witnessDatums tx
      , tvMetadata = metadata tx
      }
  Phase2Invalid ->
    TxView
      { tvHash = txHash tx
      , tvValid = False
      , tvSpends = map outRef (toList (body ^. collateralInputsTxBodyL))
      , tvOutputs = [(collateralReturnIndex, babbageOut out) | Just out <- [collateralReturn]]
      , tvCollateralReturn = Nothing
      , tvWitnessDatums = []
      , tvMetadata = Map.empty
      }
 where
  body = tx ^. bodyTxL
  outputs = toList (body ^. outputsTxBodyL)
  collateralReturn = strictMaybeToMaybe (body ^. collateralReturnTxBodyL)
  -- db-sync falls back to the largest index if the count does not fit.
  collateralReturnIndex = fromIntegral (min (length outputs) (fromIntegral (maxBound :: Word16)))

babbageOut :: (BabbageEraTxOut era, Value era ~ MaryValue) => TxOut era -> OutView
babbageOut out =
  OutView
    { ovAddress = out ^. addrTxOutL
    , ovAssets = maryAssets (out ^. valueTxOutL)
    , ovDatum = case out ^. datumTxOutL of
        NoDatum -> NoOutDatum
        DatumHash h -> HashOnly (dataHashBytes h)
        Datum bd -> Inline (dataHashBytes (hashBinaryData bd)) (originalBytes bd)
    }

coinOnly :: a -> [(PolicyID, AssetName, Integer)]
coinOnly _ = []

maryAssets :: MaryValue -> [(PolicyID, AssetName, Integer)]
maryAssets (MaryValue _ (MultiAsset assets)) =
  [(policy, name, quantity) | (policy, names) <- Map.toList assets, (name, quantity) <- Map.toList names]

txHash :: EraTx era => Tx l era -> ByteString
txHash tx = let TxId h = txIdTx tx in hashToBytes (extractHash h)

outRef :: TxIn -> OutRef
outRef (TxIn (TxId h) (TxIx ix)) = OutRef (hashToBytes (extractHash h)) ix

witnessDatums :: AlonzoEraTx era => Tx TopTx era -> [(ByteString, ByteString)]
witnessDatums tx =
  [(dataHashBytes h, originalBytes d) | (h, d) <- Map.toList (unTxDats (tx ^. witsTxL . datsTxWitsL))]

metadata :: EraTx era => Tx l era -> Map Word64 Metadatum
metadata tx = case tx ^. auxDataTxL of
  SNothing -> Map.empty
  SJust aux -> aux ^. metadataTxAuxDataL

dataHashBytes :: DataHash -> ByteString
dataHashBytes = hashToBytes . extractHash

policyBytes :: PolicyID -> ByteString
policyBytes (PolicyID (ScriptHash h)) = hashToBytes h
