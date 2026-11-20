-- | The era history: slot to epoch and slot to time arithmetic, for the
-- extractor (epoch and start time of every block) and for the nonce driver
-- (the 'EpochInfo' and Praos configuration its state transitions run
-- with).
--
-- Both work from the same 'History.Summary' structure the node derives
-- from its ledger state, built from the network's chain constants
-- ('ChainParams', whose values per network are
-- 'McFollower.Network.chainParams') and the epochs of its past hard
-- forks. Two sources:
--
-- * 'presetHistory': the network's era parameters plus the epochs of its
--   past hard forks. Past era boundaries are immutable, so hard-coding them
--   is safe. The summary is rebuilt for every slot with 'History.summarize',
--   giving the last known era the node's own safe zone from that slot on,
--   so any slot is within it. A header of the era after the last known one
--   adds that transition at the epoch containing the header (see
--   'observeEra').
--
-- * 'nodeHistory': the 'History.Interpreter' a local node returns for
--   @GetInterpreter@. It ends at the node's safe zone; a slot past it is
--   reported as 'History.PastHorizonException' and the caller re-queries.
module McFollower.EraHistory
  ( -- * Chain constants
    ChainParams (..)
  , byronEpochSlots
  , activeSlotCoeffOneTwentieth

    -- * Era history
  , EraHistory
  , presetHistory
  , nodeHistory
  , historyTransitions
  , epochInfoAt
  , observeEra
  , EraHistoryError (..)

    -- * Slot epoch and time
  , SlotInfo (..)
  , slotInfo

    -- * Praos configuration
  , PraosEra (..)
  , praosEraOf
  , praosConsensusConfig
  ) where

import Cardano.Chain.Slotting (EpochSlots (..))
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
import Cardano.Slotting.Time (SlotLength, SystemStart (..), fromRelativeTime)
import Control.Monad.Except (Except, runExcept)
import Data.Int (Int64)
import Data.Proxy (Proxy (..))
import Data.Ratio ((%))
import Data.SOP (K (..))
import Data.SOP.Counting (Exactly (..), exactlyZipFoldable)
import Data.SOP.Strict (NP (..), hpure)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import Data.Word (Word64)
import McFollower.Block (Era (..))
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
-- genesis files and node configuration. The values for the public
-- networks are 'McFollower.Network.chainParams'; nothing else in the code
-- base restates them.
data ChainParams = ChainParams
  { cpSystemStart :: !SystemStart
  -- ^ Byron @startTime@ (the Shelley @systemStart@ is the same instant).
  , cpSecurityParam :: !Word64
  -- ^ @k@ (Byron @protocolConsts.k@ and Shelley @securityParam@ agree).
  -- Byron epochs are @10 k@ slots ('byronEpochSlots').
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
  -- that order (a prefix is enough; later transitions are learned from
  -- headers). The first one is where Byron ends.
  }
  deriving stock (Show)

-- | Slots per Byron epoch, @10 k@ (also what Byron block decoding needs).
byronEpochSlots :: ChainParams -> EpochSlots
byronEpochSlots cp = EpochSlots (10 * cpSecurityParam cp)

-- | @f = 1/20@, as on all three public networks.
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

-- | Where slot, epoch and time arithmetic comes from.
data EraHistory
  = PresetHistory !ChainParams ![EpochNo]
  -- ^ Constants and the epochs of every transition known so far
  -- (the presets' plus any learned by 'observeEra').
  | NodeHistory !SystemStart !(History.Interpreter (CardanoEras StandardCrypto))

instance Show EraHistory where
  show = \case
    PresetHistory _ ts -> "PresetHistory " <> show ts
    NodeHistory _ _ -> "NodeHistory"

presetHistory :: ChainParams -> EraHistory
presetHistory cp = PresetHistory cp (cpHardForks cp)

-- | A node's era history (@GetInterpreter@) with its system start.
nodeHistory :: SystemStart -> History.Interpreter (CardanoEras StandardCrypto) -> EraHistory
nodeHistory = NodeHistory

-- | The transition epochs of a preset history, learned ones included.
-- 'Nothing' for a node's interpreter.
historyTransitions :: EraHistory -> Maybe [EpochNo]
historyTransitions = \case
  PresetHistory _ ts -> Just ts
  NodeHistory _ _ -> Nothing

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
  NodeHistory _ interpreter -> History.interpreterToEpochInfo interpreter

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
  EpochSlots byronSlots = byronEpochSlots cp
  byron =
    History.EraParams
      { History.eraEpochSize = EpochSize byronSlots
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
  NodeHistory _ _ -> Right history
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

-- | What the store records about a slot.
data SlotInfo = SlotInfo
  { siEpoch :: !EpochNo
  , siTime :: !Int64
  -- ^ Slot start time, whole seconds since the Unix epoch (fractions are
  -- truncated; none occur on the public networks).
  }
  deriving stock (Eq, Show)

-- | The epoch of a slot and its start time (the extractor's block epoch
-- and block time). With a preset history every slot is within the horizon
-- (see 'epochInfoAt'). Which Shelley-based era the known transitions place
-- a slot in does not matter: on the public networks they share epoch size
-- and slot length, so only the Byron to Shelley boundary affects the
-- result, and that one is fixed.
slotInfo :: EraHistory -> SlotNo -> Either History.PastHorizonException SlotInfo
slotInfo history slot =
  History.interpretQuery interpreter $ do
    (epoch, _) <- History.slotToEpoch' slot
    (relTime, _) <- History.slotToWallclock slot
    pure
      SlotInfo
        { siEpoch = epoch
        , siTime = floor (utcTimeToPOSIXSeconds (fromRelativeTime start relTime))
        }
 where
  (start, interpreter) = case history of
    PresetHistory cp ts -> (cpSystemStart cp, History.mkInterpreter (summary cp ts slot))
    NodeHistory s i -> (s, i)
