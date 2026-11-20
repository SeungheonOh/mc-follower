{-# LANGUAGE RecordWildCards #-}

-- | Slot to epoch and slot to time conversion through the consensus era
-- history ('Interpreter'), built from the genesis parameters of the public
-- networks.
--
-- The interpreter has two eras: Byron, which ends at the network's Shelley
-- hard-fork epoch, and Shelley, which stands for every Shelley-based era and
-- is unbounded. That is exact for mainnet, preprod and preview: none of their
-- hard forks after Shelley changed the epoch size or the slot length. Its
-- limit is that a future hard fork changing either would not be seen; an
-- interpreter obtained from a local node (@GetInterpreter@) has the same type
-- and can replace this one.
module McFollower.EraHistory
  ( -- * Genesis parameters
    GenesisParams (..)
  , genesisParams

    -- * Era history
  , EraHistory (..)
  , eraHistory
  , SlotInfo (..)
  , slotInfo
  ) where

import Cardano.Slotting.Slot (EpochNo (..), EpochSize (..), SlotNo)
import Cardano.Slotting.Time
  ( SlotLength
  , SystemStart (..)
  , fromRelativeTime
  , slotLengthFromSec
  )
import Data.Int (Int64)
import Data.SOP.NonEmpty qualified as SOP
import Data.Time (UTCTime (..), fromGregorian)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import Data.Word (Word64)
import McFollower.Network (NetworkConfig (..), NetworkName (..), networkConfig)
import Cardano.Chain.Slotting (EpochSlots (..))
import Ouroboros.Consensus.Block (GenesisWindow (..))
import Ouroboros.Consensus.Cardano.Block (CardanoEras, StandardCrypto)
import Ouroboros.Consensus.HardFork.History
  ( EraEnd (..)
  , EraParams (..)
  , EraSummary (..)
  , Interpreter
  , PastHorizonException
  , SafeZone (..)
  , Summary (..)
  , initBound
  , interpretQuery
  , mkInterpreter
  , mkUpperBound
  , slotToEpoch'
  , slotToWallclock
  , pattern NoPerasEnabled
  )

-- | The genesis values the era history depends on. Byron's epoch size is
-- 'ncByronEpochSlots' of the network configuration.
data GenesisParams = GenesisParams
  { gpSystemStart :: !UTCTime
  , gpSecurityParam :: !Word64
  -- ^ k, from the Shelley genesis (equal to the Byron one on these networks).
  , gpByronSlotLength :: !SlotLength
  , gpShelleyEpoch :: !EpochNo
  -- ^ First epoch of the Shelley era.
  , gpShelleyEpochSize :: !EpochSize
  , gpShelleySlotLength :: !SlotLength
  , gpActiveSlotsCoeffInverse :: !Word64
  -- ^ 1/f; only used for the Shelley genesis window.
  }
  deriving stock (Show)

-- | Values from each network's genesis files and node configuration
-- (byron-genesis.json @startTime@ and @slotDuration@, shelley-genesis.json
-- @securityParam@, @epochLength@, @slotLength@, @activeSlotsCoeff@,
-- config.json hard-fork epochs). Cross-checked against the Midnight node's
-- @res/<network>/pc-chain-config.json@, whose @first_epoch_number@,
-- @first_slot_number@, @first_epoch_timestamp_millis@ and
-- @epoch_duration_millis@ describe the first Shelley epoch.
genesisParams :: NetworkName -> GenesisParams
genesisParams = \case
  -- Shelley from epoch 208, slot 4492800, 2020-07-29T21:44:51Z.
  Mainnet ->
    GenesisParams
      { gpSystemStart = utc 2017 9 23 (21 * 3600 + 44 * 60 + 51)
      , gpSecurityParam = 2160
      , gpByronSlotLength = slotLengthFromSec 20
      , gpShelleyEpoch = EpochNo 208
      , gpShelleyEpochSize = EpochSize 432000
      , gpShelleySlotLength = slotLengthFromSec 1
      , gpActiveSlotsCoeffInverse = 20
      }
  -- Shelley from epoch 4, slot 86400, 2022-06-21T00:00:00Z.
  Preprod ->
    GenesisParams
      { gpSystemStart = utc 2022 6 1 0
      , gpSecurityParam = 2160
      , gpByronSlotLength = slotLengthFromSec 20
      , gpShelleyEpoch = EpochNo 4
      , gpShelleyEpochSize = EpochSize 432000
      , gpShelleySlotLength = slotLengthFromSec 1
      , gpActiveSlotsCoeffInverse = 20
      }
  -- No Byron epochs: the network forks to Shelley-based eras at epoch 0.
  Preview ->
    GenesisParams
      { gpSystemStart = utc 2022 10 25 0
      , gpSecurityParam = 432
      , gpByronSlotLength = slotLengthFromSec 20
      , gpShelleyEpoch = EpochNo 0
      , gpShelleyEpochSize = EpochSize 86400
      , gpShelleySlotLength = slotLengthFromSec 1
      , gpActiveSlotsCoeffInverse = 20
      }
 where
  utc y m d secs = UTCTime (fromGregorian y m d) (fromIntegral (secs :: Int))

data EraHistory = EraHistory
  { ehSystemStart :: !SystemStart
  , ehInterpreter :: !(Interpreter (CardanoEras StandardCrypto))
  }

-- | The era history of a public network.
eraHistory :: NetworkName -> EraHistory
eraHistory name =
  EraHistory
    { ehSystemStart = SystemStart gpSystemStart
    , ehInterpreter =
        mkInterpreter . Summary $
          SOP.NonEmptyCons byron (SOP.NonEmptyOne shelley)
    }
 where
  GenesisParams {..} = genesisParams name
  k = gpSecurityParam
  EpochSlots byronEpochSlots = ncByronEpochSlots (networkConfig name)

  byronParams =
    EraParams
      { eraEpochSize = EpochSize byronEpochSlots
      , eraSlotLength = gpByronSlotLength
      , eraSafeZone = StandardSafeZone (2 * k)
      , eraGenesisWin = GenesisWindow (2 * k)
      , eraPerasRoundLength = NoPerasEnabled
      }
  byronEnd = mkUpperBound byronParams initBound gpShelleyEpoch
  byron =
    EraSummary
      { eraStart = initBound
      , eraEnd = EraEnd byronEnd
      , eraParams = byronParams
      }

  shelley =
    EraSummary
      { eraStart = byronEnd
      , eraEnd = EraUnbounded
      , eraParams =
          EraParams
            { eraEpochSize = gpShelleyEpochSize
            , eraSlotLength = gpShelleySlotLength
            , eraSafeZone = UnsafeIndefiniteSafeZone
            , eraGenesisWin = GenesisWindow (3 * k * gpActiveSlotsCoeffInverse)
            , eraPerasRoundLength = NoPerasEnabled
            }
      }

-- | What the store records about a slot.
data SlotInfo = SlotInfo
  { siEpoch :: !EpochNo
  , siTime :: !Int64
  -- ^ Slot start time, whole seconds since the Unix epoch (fractions are
  -- truncated; none occur on the public networks).
  }
  deriving stock (Eq, Show)

slotInfo :: EraHistory -> SlotNo -> Either PastHorizonException SlotInfo
slotInfo EraHistory {ehSystemStart, ehInterpreter} slot =
  interpretQuery ehInterpreter $ do
    (epoch, _) <- slotToEpoch' slot
    (relTime, _) <- slotToWallclock slot
    pure
      SlotInfo
        { siEpoch = epoch
        , siTime = floor (utcTimeToPOSIXSeconds (fromRelativeTime ehSystemStart relTime))
        }
