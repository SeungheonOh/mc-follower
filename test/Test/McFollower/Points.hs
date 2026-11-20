-- | Made-up points and tips for tests that only care about chain shape.
module Test.McFollower.Points
  ( point
  , tip
  ) where

import Data.ByteString.Short qualified as SBS
import McFollower.Block (Block)
import Ouroboros.Consensus.Block (BlockNo (..), Point, SlotNo (..), pattern BlockPoint)
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Ouroboros.Network.Block (Tip (..))

-- | The point of the @n@th block of a test chain, at slot @n@.
point :: Int -> Point Block
point n = BlockPoint (SlotNo (fromIntegral n)) (hash n)

-- | A tip at the @n@th block of a test chain.
tip :: Int -> Tip Block
tip n = Tip (SlotNo (fromIntegral n)) (hash n) (BlockNo (fromIntegral n))

hash :: Int -> OneEraHash xs
hash n = OneEraHash (SBS.pack (replicate 32 (fromIntegral n)))
