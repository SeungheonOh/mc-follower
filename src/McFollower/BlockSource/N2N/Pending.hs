-- | Headers announced by chain-sync whose bodies have not been delivered
-- yet, and how chain-sync events change them.
--
-- A rollback that lands inside the pending headers only shortens them: the
-- consumer never saw those blocks. A rollback to any other point discards
-- all pending headers and has to be passed downstream.
--
-- Chain-sync announces headers faster than their blocks are fetched and
-- applied. 'intake' bounds how many are pending: above a high-water mark
-- the block-fetch side stops taking header events off the chain-sync
-- queue, so the bounded queue fills and chain-sync blocks; below the
-- low-water mark it takes them again.
module McFollower.BlockSource.N2N.Pending
  ( Announced (..)
  , Pending
  , empty
  , null
  , size
  , toList
  , applyEvents
  , batch
  , dropOldest

    -- * Backpressure
  , Watermarks (..)
  , Intake (..)
  , intake
  ) where

import Data.Foldable qualified as Foldable
import Data.List (mapAccumL)
import Data.Maybe (catMaybes)
import Data.Sequence (Seq, (|>))
import Data.Sequence qualified as Seq
import McFollower.BlockSource (ChainEvent (..))
import Ouroboros.Network.Block (Point, StandardHash, Tip)
import Ouroboros.Network.Protocol.BlockFetch.Type (ChainRange (..))
import Prelude hiding (null)

-- | A header together with the upstream tip that came with it.
data Announced blk hdr = Announced
  { annPoint :: !(Point blk)
  , annHeader :: !hdr
  , annTip :: !(Tip blk)
  }

-- | Oldest first.
newtype Pending blk hdr = Pending (Seq (Announced blk hdr))

empty :: Pending blk hdr
empty = Pending Seq.empty

null :: Pending blk hdr -> Bool
null (Pending s) = Seq.null s

size :: Pending blk hdr -> Int
size (Pending s) = Seq.length s

toList :: Pending blk hdr -> [Announced blk hdr]
toList (Pending s) = Foldable.toList s

-- | Apply chain-sync events in order. Returns the rollbacks that reach past
-- the pending headers, in order, for the consumer.
applyEvents
  :: StandardHash blk
  => (hdr -> Point blk)
  -> [ChainEvent blk hdr]
  -> Pending blk hdr
  -> (Pending blk hdr, [(Point blk, Tip blk)])
applyEvents pointOf events pending =
  catMaybes <$> mapAccumL (flip (applyEvent pointOf)) pending events

applyEvent
  :: StandardHash blk
  => (hdr -> Point blk)
  -> ChainEvent blk hdr
  -> Pending blk hdr
  -> (Pending blk hdr, Maybe (Point blk, Tip blk))
applyEvent pointOf event (Pending s) = case event of
  RollForward hdr tip ->
    (Pending (s |> Announced (pointOf hdr) hdr tip), Nothing)
  RollBackward p tip -> case Seq.findIndexR ((== p) . annPoint) s of
    Just i -> (Pending (Seq.take (i + 1) s), Nothing)
    Nothing -> (empty, Just (p, tip))

-- | Up to @n@ of the oldest pending headers, as a block-fetch range.
batch :: Int -> Pending blk hdr -> Maybe (ChainRange (Point blk), [Announced blk hdr])
batch n (Pending s) = case Foldable.toList (Seq.take n s) of
  [] -> Nothing
  anns@(first : _) -> Just (ChainRange (annPoint first) (annPoint (last anns)), anns)

-- | The oldest pending header's block was delivered.
dropOldest :: Pending blk hdr -> Pending blk hdr
dropOldest (Pending s) = Pending (Seq.drop 1 s)

-- | Pending headers at which taking events stops ('wmHigh') and resumes
-- ('wmLow').
data Watermarks = Watermarks
  { wmHigh :: !Int
  , wmLow :: !Int
  }
  deriving stock (Eq, Show)

-- | What to do with the chain-sync queue before the next fetch.
data Intake
  = WaitAndTake
  -- ^ Wait for at least one event, then take every queued one.
  | TakeQueued
  -- ^ Take the queued events, without waiting.
  | Hold
  -- ^ Leave the queue alone: too many headers are pending.
  deriving stock (Eq, Show)

-- | Decide the intake from whether intake is currently paused, whether the
-- relay answered the last request with no blocks (then only chain-sync
-- can resolve the situation, with a rollback, so events must be taken
-- even while paused) and the pending headers. Returns the new paused flag.
--
-- Rollbacks are never lost or reordered by holding: they wait in the queue
-- behind the forward events before them. Blocks fetched meanwhile for
-- headers that a queued rollback will discard are delivered and then
-- rolled back downstream, as for any rollback past the pending headers.
intake :: Watermarks -> Bool -> Bool -> Pending blk hdr -> (Intake, Bool)
intake Watermarks {wmHigh, wmLow} paused stalled p
  | null p || stalled = (WaitAndTake, paused')
  | paused' = (Hold, True)
  | otherwise = (TakeQueued, False)
 where
  n = size p
  paused'
    | n >= wmHigh = True
    | n <= wmLow = False
    | otherwise = paused
