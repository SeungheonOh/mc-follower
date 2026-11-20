-- | Headers announced by chain-sync whose bodies have not been delivered
-- yet, and how chain-sync events change them.
--
-- A rollback that lands inside the pending headers only shortens them: the
-- consumer never saw those blocks. A rollback to any other point discards
-- all pending headers and has to be passed downstream.
module McFollower.BlockSource.N2N.Pending
  ( Announced (..)
  , Pending
  , empty
  , null
  , toList
  , applyEvents
  , batch
  , dropOldest
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
