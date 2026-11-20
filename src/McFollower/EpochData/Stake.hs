-- | Per-pool stake per epoch, in the shape @GetStakeDistribution@ serves:
-- for epoch @N@, the stake of each pool equal to db-sync's
-- @SUM(epoch_stake.amount) GROUP BY pool WHERE epoch_no = N@, i.e. the
-- stake distribution the leader schedule of epoch @N@ is drawn from.
--
-- The ledger keeps three snapshots, rotated at every epoch boundary. In a
-- ledger state of epoch @e@:
--
-- * __mark__ (taken at the start of @e@) is the distribution for @e + 1@,
-- * __set__ (taken at the start of @e - 1@) is the distribution for @e@,
-- * __go__ (taken at the start of @e - 2@) is the distribution for @e - 1@.
--
-- So one @GetStakeSnapshots@ query in epoch @e@ yields three epochs
-- ('stakeFromSnapshots'). A Mithril Cardano stake distribution labelled
-- @L@ is the one computed at the end of epoch @L@, which is the mark
-- snapshot of epoch @L + 1@ and so the distribution for @L + 2@
-- ("McFollower.EpochData.Mithril").
--
-- Zero-stake pools are left out: a pool is in 'esPools' only with a
-- positive amount. From protocol version 11 the ledger's query itself omits
-- pools with no stake in all three snapshots (before that it lists every
-- pool with delegators, with 0 where it has no stake). Whether db-sync
-- writes zero-amount @epoch_stake@ rows, and so returns a pool with stake 0
-- from @GetStakeDistribution@, is not verified; it is not observable by the
-- node, which folds the rows into a map and treats a pool missing from a
-- non-empty map as stake 0. Only the empty distribution is special (no
-- stake data at all), which is why an incomplete distribution must never
-- be served.
module McFollower.EpochData.Stake
  ( PoolStake
  , EpochStake (..)
  , StakeSource (..)
  , SnapshotLabel (..)
  , Finality (..)
  , stakeFromSnapshots
  , positiveStake
  ) where

import Cardano.Ledger.Api.State.Query (StakeSnapshot (..), StakeSnapshots (..))
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash, KeyRole (StakePool))
import Cardano.Slotting.Slot (EpochNo (..))
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)

-- | Stake per pool, positive amounts only.
type PoolStake = Map (KeyHash StakePool) Coin

data EpochStake = EpochStake
  { esEpoch :: !EpochNo
  -- ^ The epoch the distribution is for (db-sync @epoch_stake.epoch_no@).
  , esPools :: !PoolStake
  , esComplete :: !Bool
  -- ^ Taken from a snapshot that can no longer change. Only complete
  -- distributions may be served.
  , esSource :: !StakeSource
  }
  deriving stock (Eq, Show)

data SnapshotLabel = Mark | Set | Go
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data StakeSource
  = FromNodeSnapshot !SnapshotLabel !EpochNo
  -- ^ A node's snapshot, queried in a ledger state of the given epoch.
  | FromMithril !EpochNo !Text
  -- ^ A Mithril Cardano stake distribution: its label and certificate hash.
  deriving stock (Eq, Show)

-- | Whether the ledger state a query ran against can still be rolled back.
data Finality
  = Immutable
  -- ^ Acquired at the immutable tip (the default) or another point at
  -- least @k@ blocks deep.
  | Volatile
  deriving stock (Eq, Show)

-- | The three distributions in a @GetStakeSnapshots@ result from a ledger
-- state of epoch @e@, oldest first: @e - 1@ (go), @e@ (set) and @e + 1@
-- (mark); @e - 1@ is left out for @e = 0@.
--
-- Go and set were fixed at boundaries at least one epoch back (more than
-- @k@ blocks), so they are complete either way. Mark was taken at the
-- boundary into @e@; it is complete only if that boundary cannot be rolled
-- back, which this function knows only for an 'Immutable' state.
stakeFromSnapshots :: Finality -> EpochNo -> StakeSnapshots -> [EpochStake]
stakeFromSnapshots finality e@(EpochNo n) StakeSnapshots {ssStakeSnapshots} =
  [ distribution (EpochNo (n - 1)) Go ssGoPool True | n > 0
  ]
    <> [ distribution e Set ssSetPool True
       , distribution (EpochNo (n + 1)) Mark ssMarkPool (finality == Immutable)
       ]
 where
  distribution epoch label get complete =
    EpochStake
      { esEpoch = epoch
      , esPools = positiveStake (Map.map get ssStakeSnapshots)
      , esComplete = complete
      , esSource = FromNodeSnapshot label e
      }

-- | Drop pools without stake.
positiveStake :: Map (KeyHash StakePool) Coin -> PoolStake
positiveStake = Map.filter (> Coin 0)
