-- | Era history for the parts of mc-follower that work from headers alone
-- (the nonce driver): slot to epoch arithmetic through a hard fork
-- 'History.Summary', the same structure the node derives from its ledger
-- state, and the per-network chain constants it is built from.
--
-- Two sources:
--
-- * 'presetHistory': the network's era parameters plus the epochs of its
--   past hard forks. Past era boundaries are immutable, so hard-coding them
--   is safe. The summary is rebuilt for every slot with 'History.summarize',
--   giving the last known era the node's own safe zone from that slot on. A
--   header of the era after the last known one adds that transition at the
--   epoch containing the header (see 'observeEra').
--
-- * 'nodeHistory': the 'History.Interpreter' a local node returns for
--   @GetInterpreter@. It ends at the node's safe zone; a slot past it is
--   reported as 'History.PastHorizonException' and the caller re-queries.
module McFollower.EraHistory
  ( -- * Chain constants
    ChainParams (..)
  , chainParams

    -- * Era history
  , EraHistory
  , presetHistory
  , nodeHistory
  , historyTransitions
  , epochInfoAt
  , observeEra
  , EraHistoryError (..)

    -- * Praos configuration
  , PraosEra (..)
  , praosEraOf
  , praosConsensusConfig
  ) where

import Cardano.Ledger.BaseTypes
  ( ActiveSlotCoeff
  , boundRational
  , mkActiveSlotCoeff
  , nonZeroOr
  )
import Cardano.Ledger.Core (eraProtVerHigh)
import Cardano.Ledger.Shelley.API (computeRandomnessStabilisationWindow, computeStabilityWindow)
import Cardano.Protocol.Crypto (StandardCrypto)
import Cardano.Slotting.EpochInfo (EpochInfo, epochInfoEpoch)
import Cardano.Slotting.Slot (EpochNo (..), EpochSize (..), SlotNo)
import Cardano.Slotting.Time (SlotLength, slotLengthFromSec)
import Control.Monad.Except (Except, runExcept)
import Data.Proxy (Proxy (..))
import Data.Ratio ((%))
import Data.SOP.Counting (Exactly (..), exactlyZipFoldable)
import Data.SOP (K (..))
import Data.SOP.Strict (NP (..), hpure)
import Data.Word (Word64)
import McFollower.Block (Era (..))
import McFollower.Network (NetworkName (..))
import Ouroboros.Consensus.Block (GenesisWindow (..), pattern NotOrigin)
import Ouroboros.Consensus.Cardano.Block (CardanoEras, CardanoShelleyEras)
import Ouroboros.Consensus.Config.SecurityParam (SecurityParam (..))
import Ouroboros.Consensus.HardFork.History qualified as History
import Ouroboros.Consensus.Protocol.Abstract (ConsensusConfig)
import Ouroboros.Consensus.Protocol.Praos
  ( ConsensusConfig (..)
  , Praos
  , PraosParams (..)
  )
import Ouroboros.Consensus.Protocol.Praos.Common (MaxMajorProtVer (..))
import Ouroboros.Consensus.Shelley.Eras
  ( BabbageEra
  , ConwayEra
  , DijkstraEra
  , ShelleyBasedEra (..)
  )

-- | Per-network chain constants, as in the network's Byron and Shelley
-- genesis files (sources: the genesis files published at
-- <https://book.play.dev.cardano.org/environments/>, read 2026-11-20).
data ChainParams = ChainParams
  { cpSecurityParam :: !Word64
  -- ^ @k@ (Byron @protocolConsts.k@ and Shelley @securityParam@ agree).
  , cpActiveSlotCoeff :: !ActiveSlotCoeff
  -- ^ @f@ (Shelley @activeSlotsCoeff@).
  , cpByronSlotLength :: !SlotLength
  -- ^ Byron @blockVersionData.slotDuration@.
  , cpShelleyEpochLength :: !EpochSize
  -- ^ Shelley @epochLength@.
  , cpShelleySlotLength :: !SlotLength
  -- ^ Shelley @slotLength@.
  , cpSlotsPerKESPeriod :: !Word64
  , cpMaxKESEvolutions :: !Word64
  , cpHardForks :: ![EpochNo]
  -- ^ First epoch of Shelley, Allegra, Mary, Alonzo, Babbage and Conway, in
  -- that order. Source: the @era@ of each epoch in Koios @epoch_params@,
  -- read 2026-11-20; preview's first four agree with the
  -- @Test*HardForkAtEpoch: 0@ entries of its node configuration.
  }
  deriving stock (Show)

chainParams :: NetworkName -> ChainParams
chainParams = \case
  Mainnet ->
    ChainParams
      { cpSecurityParam = 2160
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 432000
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [208, 236, 251, 290, 365, 507]
      }
  Preprod ->
    ChainParams
      { cpSecurityParam = 2160
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 432000
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [4, 5, 6, 7, 12, 163]
      }
  Preview ->
    ChainParams
      { cpSecurityParam = 432
      , cpActiveSlotCoeff = activeSlotCoeffOneTwentieth
      , cpByronSlotLength = slotLengthFromSec 20
      , cpShelleyEpochLength = EpochSize 86400
      , cpShelleySlotLength = slotLengthFromSec 1
      , cpSlotsPerKESPeriod = 129600
      , cpMaxKESEvolutions = 62
      , cpHardForks = map EpochNo [0, 0, 0, 0, 3, 646]
      }

-- | @f = 1/20@ on all three public networks.
activeSlotCoeffOneTwentieth :: ActiveSlotCoeff
activeSlotCoeffOneTwentieth =
  maybe (error "1/20 is a positive unit interval") mkActiveSlotCoeff (boundRational (1 % 20))

-- | The eras of 'Block' that run Praos, the only ones the nonce driver
-- supports.
data PraosEra = PraosBabbage | PraosConway | PraosDijkstra
  deriving stock (Eq, Ord, Show, Enum, Bounded)

praosEraOf :: Era -> Maybe PraosEra
praosEraOf = \case
  Byron -> Nothing
  Shelley -> Nothing
  Allegra -> Nothing
  Mary -> Nothing
  Alonzo -> Nothing
  Babbage -> Just PraosBabbage
  Conway -> Just PraosConway
  Dijkstra -> Just PraosDijkstra

-- | The Praos configuration the node uses for headers of the given era
-- ('Ouroboros.Consensus.Cardano.Node.protocolInfoCardano'): Babbage keeps
-- the TPraos-era randomness stabilisation window of @3k/f@ slots
-- ('computeStabilityWindow'), later eras use @4k/f@
-- ('computeRandomnessStabilisationWindow'). The two functions are the
-- ledger's, called with the genesis @k@ and @f@ exactly as the node does.
praosConsensusConfig
  :: ChainParams
  -> PraosEra
  -> EpochInfo (Except History.PastHorizonException)
  -> ConsensusConfig (Praos StandardCrypto)
praosConsensusConfig cp era epochInfo =
  PraosConfig
    { praosParams =
        PraosParams
          { praosSlotsPerKESPeriod = cpSlotsPerKESPeriod cp
          , praosLeaderF = cpActiveSlotCoeff cp
          , praosSecurityParam = securityParam cp
          , praosMaxKESEvo = cpMaxKESEvolutions cp
          , praosMaxMajorPV = MaxMajorProtVer (eraProtVerHigh @DijkstraEra)
          , praosRandomnessStabilisationWindow = case era of
              PraosBabbage -> computeStabilityWindow k f
              PraosConway -> computeRandomnessStabilisationWindow k f
              PraosDijkstra -> computeRandomnessStabilisationWindow k f
          }
    , praosEpochInfo = epochInfo
    }
 where
  k = cpSecurityParam cp
  f = cpActiveSlotCoeff cp

securityParam :: ChainParams -> SecurityParam
securityParam cp = SecurityParam (nonZeroOr (cpSecurityParam cp) (error "k is never zero"))

-- | Where slot and epoch arithmetic comes from.
data EraHistory
  = PresetHistory !ChainParams ![EpochNo]
  -- ^ Constants and the epochs of every transition known so far
  -- (the presets' plus any learned by 'observeEra').
  | NodeHistory !(History.Interpreter (CardanoEras StandardCrypto))

instance Show EraHistory where
  show = \case
    PresetHistory _ ts -> "PresetHistory " <> show ts
    NodeHistory _ -> "NodeHistory"

presetHistory :: ChainParams -> EraHistory
presetHistory cp = PresetHistory cp (cpHardForks cp)

nodeHistory :: History.Interpreter (CardanoEras StandardCrypto) -> EraHistory
nodeHistory = NodeHistory

-- | The transition epochs of a preset history, learned ones included.
-- 'Nothing' for a node's interpreter.
historyTransitions :: EraHistory -> Maybe [EpochNo]
historyTransitions = \case
  PresetHistory _ ts -> Just ts
  NodeHistory _ -> Nothing

-- | An 'EpochInfo' valid at least up to and including the given slot and
-- the first slot of the epoch after it.
--
-- For a preset history this is the 'History.Summary' the node would have
-- with its ledger tip at that slot and no transition announced beyond the
-- known ones: the last known era extends a safe zone ahead of the slot, and
-- the summary's upper bound admits the first slot of the following epoch.
epochInfoAt :: EraHistory -> SlotNo -> EpochInfo (Except History.PastHorizonException)
epochInfoAt history slot = case history of
  PresetHistory cp ts -> History.summaryToEpochInfo (summary cp ts slot)
  NodeHistory interpreter -> History.interpreterToEpochInfo interpreter

summary :: ChainParams -> [EpochNo] -> SlotNo -> History.Summary (CardanoEras StandardCrypto)
summary cp ts slot = History.summarize (NotOrigin slot) (shape cp) (transitions ts)

-- | Era parameters exactly as 'Ouroboros.Consensus.Byron.Ledger.byronEraParams'
-- and 'Ouroboros.Consensus.Shelley.Ledger.shelleyEraParams' build them from
-- the genesis files.
shape :: ChainParams -> History.Shape (CardanoEras StandardCrypto)
shape cp =
  History.Shape . Exactly $
    K byron
      :* K (shelley (Proxy @ShelleyEraTag))
      :* K (shelley (Proxy @ShelleyEraTag))
      :* K (shelley (Proxy @ShelleyEraTag))
      :* K (shelley (Proxy @ShelleyEraTag))
      :* K (shelley (Proxy @BabbageEra))
      :* K (shelley (Proxy @ConwayEra))
      :* K (shelley (Proxy @DijkstraEra))
      :* Nil
 where
  k = cpSecurityParam cp
  byron =
    History.EraParams
      { History.eraEpochSize = EpochSize (10 * k)
      , History.eraSlotLength = cpByronSlotLength cp
      , History.eraSafeZone = History.StandardSafeZone (2 * k)
      , History.eraGenesisWin = GenesisWindow (2 * k)
      , History.eraPerasRoundLength = History.NoPerasEnabled
      }
  stabilityWindow = computeStabilityWindow k (cpActiveSlotCoeff cp)
  shelley :: ShelleyBasedEra era => Proxy era -> History.EraParams
  shelley proxy =
    History.EraParams
      { History.eraEpochSize = cpShelleyEpochLength cp
      , History.eraSlotLength = cpShelleySlotLength cp
      , History.eraSafeZone = History.StandardSafeZone stabilityWindow
      , History.eraGenesisWin = GenesisWindow stabilityWindow
      , History.eraPerasRoundLength = getShelleyEraPerasRoundLength proxy
      }

-- | The TPraos eras only matter here for their 'History.EraParams', which
-- do not depend on the era; Babbage stands in for them.
type ShelleyEraTag = BabbageEra

transitions :: [EpochNo] -> History.Transitions (CardanoEras StandardCrypto)
transitions ts =
  History.Transitions . fmap snd $
    exactlyZipFoldable (Exactly (hpure (K ())) :: Exactly (CardanoShelleyEras StandardCrypto) ()) ts

data EraHistoryError
  = EraSkipped !Era !SlotNo ![EpochNo]
  -- ^ A header of this era at this slot, while the history only knows the
  -- eras up to an earlier one and not the one in between.
  | EraMismatch !Era !Era !SlotNo
  -- ^ A header of the first era at a slot the history places in the second.
  | PastHorizon !History.PastHorizonException
  deriving stock (Show)

-- | Check a header's era against the history, learning a transition if
-- the header is the first one seen of the era after the last known one.
--
-- Learning places the transition at the epoch containing the header. That
-- is exact for the first block of the new era (eras start at epoch
-- boundaries and every epoch has blocks), and harmless otherwise: all
-- Shelley-based eras of the public networks share epoch size and slot
-- length, so slot and epoch arithmetic does not depend on where a
-- transition between two of them is placed.
observeEra :: Era -> SlotNo -> EraHistory -> Either EraHistoryError EraHistory
observeEra era slot history = case history of
  NodeHistory _ -> Right history
  PresetHistory cp ts -> do
    epoch <- either (Left . PastHorizon) Right . runExcept $
      epochInfoEpoch (epochInfoAt history slot) slot
    -- Era i (Byron = 0) starts at the (i-1)-th transition.
    let expected = length (takeWhile (<= epoch) ts)
        known = length ts
    case compare (fromEnum era) known of
      _ | fromEnum era == expected -> Right history
      GT
        | fromEnum era == known + 1 -> Right (PresetHistory cp (ts <> [epoch]))
        | otherwise -> Left (EraSkipped era slot ts)
      _ -> Left (EraMismatch era (toEnum expected) slot)
