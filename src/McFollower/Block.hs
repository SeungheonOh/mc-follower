-- | The Cardano block type mc-follower works with, plus the few per-era
-- projections and renderings that the rest of the code needs.
module McFollower.Block
  ( -- * Block type
    Block
  , Era (..)
  , blockEra
  , blockTxCount

    -- * Points and hashes
  , renderHash
  , renderChainHash
  , renderPoint
  , renderTip
  , parsePoint
  ) where

import Cardano.Chain.Block qualified as Byron
import Cardano.Chain.UTxO qualified as Byron
import Cardano.Ledger.Block qualified as Ledger
import Cardano.Ledger.Core (EraBlockBody (txSeqBlockBodyL))
import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (SlotNo (..))
import Data.ByteString.Base16 qualified as Base16
import Data.ByteString.Short qualified as SBS
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as Text
import Lens.Micro ((^.))
import Ouroboros.Consensus.Block (ChainHash (..), HeaderHash, Point (..))
import Ouroboros.Consensus.Byron.Ledger (ByronBlock (..))
import Ouroboros.Consensus.Cardano.Block
  ( CardanoBlock
  , StandardCrypto
  , pattern BlockAllegra
  , pattern BlockAlonzo
  , pattern BlockBabbage
  , pattern BlockByron
  , pattern BlockConway
  , pattern BlockDijkstra
  , pattern BlockMary
  , pattern BlockShelley
  )
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Ouroboros.Consensus.Shelley.Ledger (ShelleyBlock (..))
import Ouroboros.Network.Block (Tip (..))
import Text.Read (readMaybe)

-- Orphan instances for the Cardano eras, 'Show' and 'Eq' of points among them.
import Ouroboros.Consensus.Cardano.Node ()
import Ouroboros.Consensus.Shelley.Ledger.SupportsProtocol ()

-- | A block of any Cardano era.
type Block = CardanoBlock StandardCrypto

-- | The eras of 'Block', in chain order.
data Era
  = Byron
  | Shelley
  | Allegra
  | Mary
  | Alonzo
  | Babbage
  | Conway
  | Dijkstra
  deriving stock (Eq, Ord, Show, Enum, Bounded)

blockEra :: Block -> Era
blockEra = \case
  BlockByron _ -> Byron
  BlockShelley _ -> Shelley
  BlockAllegra _ -> Allegra
  BlockMary _ -> Mary
  BlockAlonzo _ -> Alonzo
  BlockBabbage _ -> Babbage
  BlockConway _ -> Conway
  BlockDijkstra _ -> Dijkstra

-- | Number of transactions in the block body, phase-2-invalid ones included.
-- Byron epoch boundary blocks have none.
blockTxCount :: Block -> Int
blockTxCount = \case
  BlockByron b -> byronTxCount b
  BlockShelley b -> shelleyTxCount b
  BlockAllegra b -> shelleyTxCount b
  BlockMary b -> shelleyTxCount b
  BlockAlonzo b -> shelleyTxCount b
  BlockBabbage b -> shelleyTxCount b
  BlockConway b -> shelleyTxCount b
  BlockDijkstra b -> shelleyTxCount b
 where
  byronTxCount ByronBlock {byronBlockRaw} = case byronBlockRaw of
    Byron.ABOBBlock b -> length (Byron.aUnTxPayload (Byron.blockTxPayload b))
    Byron.ABOBBoundary _ -> 0

  shelleyTxCount :: EraBlockBody era => ShelleyBlock proto era -> Int
  shelleyTxCount ShelleyBlock {shelleyBlockRaw} =
    length (Ledger.blockBody shelleyBlockRaw ^. txSeqBlockBodyL)

-- | Lower-case hex.
renderHash :: HeaderHash Block -> Text
renderHash = Text.decodeLatin1 . Base16.encode . SBS.fromShort . getOneEraHash

renderChainHash :: ChainHash Block -> Text
renderChainHash = \case
  GenesisHash -> "genesis"
  BlockHash h -> renderHash h

-- | @origin@ or @SLOT.HASH@, the format 'parsePoint' accepts.
renderPoint :: Point Block -> Text
renderPoint = \case
  GenesisPoint -> "origin"
  BlockPoint slot h -> Text.pack (show (unSlotNo slot)) <> "." <> renderHash h

-- | @origin@ or @SLOT/BLOCKNO/HASH@.
renderTip :: Tip Block -> Text
renderTip = \case
  TipGenesis -> "origin"
  Tip slot h bno ->
    Text.intercalate "/" [Text.pack (show (unSlotNo slot)), Text.pack (show (unBlockNo bno)), renderHash h]

-- | Parse @origin@ or @SLOT.HASH@ with a 32-byte hex header hash.
parsePoint :: Text -> Either String (Point Block)
parsePoint "origin" = Right GenesisPoint
parsePoint t = case Text.splitOn "." t of
  [slotText, hashText]
    | Just slot <- SlotNo <$> readMaybe (Text.unpack slotText)
    , Right bytes <- Base16.decode (Text.encodeUtf8 hashText)
    , SBS.length (SBS.toShort bytes) == 32 ->
        Right (BlockPoint slot (OneEraHash (SBS.toShort bytes)))
  _ -> Left ("expected 'origin' or SLOT.HASH with a 64-digit hex hash, got " <> show t)
