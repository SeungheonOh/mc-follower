-- | The most recently delivered points of a block source, kept so that a
-- reconnect can intersect close to where the consumer already is.
module McFollower.BlockSource.Recent
  ( RecentPoints
  , empty
  , rollForward
  , rollBackward
  , intersectionCandidates
  , toOldestFirst
  ) where

import Data.Foldable (toList)
import Data.Maybe (mapMaybe)
import Data.Sequence (Seq, (|>))
import Data.Sequence qualified as Seq
import Ouroboros.Network.Block (Point, StandardHash)

-- | At most a fixed number of points, oldest first.
data RecentPoints blk = RecentPoints !Int !(Seq (Point blk))

-- | No points, keeping at most the given number.
empty :: Int -> RecentPoints blk
empty capacity = RecentPoints (max 1 capacity) Seq.empty

-- | A block at this point was delivered.
rollForward :: Point blk -> RecentPoints blk -> RecentPoints blk
rollForward p (RecentPoints capacity ps) =
  RecentPoints capacity (Seq.drop (Seq.length ps + 1 - capacity) (ps |> p))

-- | The chain was rolled back to this point. If the point is older than
-- everything kept, it becomes the only point: it is on the consumer's chain,
-- and nothing newer is.
rollBackward :: StandardHash blk => Point blk -> RecentPoints blk -> RecentPoints blk
rollBackward p (RecentPoints capacity ps) = RecentPoints capacity $
  case Seq.findIndexR (== p) ps of
    Just i -> Seq.take (i + 1) ps
    Nothing -> Seq.singleton p

-- | Newest first: the newest point, then points 1, 2, 4, 8, ... back from
-- it, then the oldest one kept.
intersectionCandidates :: RecentPoints blk -> [Point blk]
intersectionCandidates (RecentPoints _ ps)
  | n == 0 = []
  | otherwise = mapMaybe back (takeWhile (< n - 1) offsets) <> [Seq.index ps 0]
 where
  n = Seq.length ps
  offsets = 0 : iterate (* 2) 1
  back offset = Seq.lookup (n - 1 - offset) ps

toOldestFirst :: RecentPoints blk -> [Point blk]
toOldestFirst (RecentPoints _ ps) = toList ps
