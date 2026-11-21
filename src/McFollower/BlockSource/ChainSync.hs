{-# LANGUAGE GADTs #-}

-- | A pipelined chain-sync client shared by both block sources: it
-- intersects, then passes every roll-forward and roll-backward on as a
-- 'ChainEvent'. Node-to-node runs it over headers, node-to-client over
-- full blocks.
module McFollower.BlockSource.ChainSync
  ( chainSyncClient
  ) where

import Control.Tracer (Tracer, traceWith)
import Data.Void (Void, absurd)
import McFollower.Block (Block)
import McFollower.BlockSource
  ( BlockSourceError (..)
  , BlockSourceTrace (..)
  , ChainEvent (..)
  )
import Network.TypedProtocol.Peer (Nat (..))
import Cardano.Slotting.Slot (WithOrigin (..))
import Ouroboros.Consensus.Block (HasHeader, Point, blockNo)
import Ouroboros.Network.Block (BlockNo, Tip, getTipBlockNo)
import Ouroboros.Network.Protocol.ChainSync.ClientPipelined
  ( ChainSyncClientPipelined (..)
  , ClientPipelinedStIdle (..)
  , ClientPipelinedStIntersect (..)
  , ClientStNext (..)
  )
import Ouroboros.Network.Protocol.ChainSync.PipelineDecision
  ( MkPipelineDecision
  , PipelineDecision (..)
  , pipelineDecisionLowHighMark
  , runPipelineDecision
  )

-- | Intersect at the first of the given points the upstream knows, then
-- follow its chain forever. If it knows none of them, hands
-- 'IntersectionNotFound' to the given action, which must not return (it
-- ends the connection, see 'McFollower.BlockSource.reconnecting').
chainSyncClient
  :: forall hdr a
   . HasHeader hdr
  => Tracer IO BlockSourceTrace
  -> (BlockSourceError -> IO Void)
  -> [Point Block]
  -> (ChainEvent Block hdr -> IO ())
  -> ChainSyncClientPipelined hdr (Point Block) (Tip Block) IO a
chainSyncClient tracer abort points emit =
  ChainSyncClientPipelined $
    pure $
      SendMsgFindIntersect
        points
        ClientPipelinedStIntersect
          { recvMsgIntersectFound = \p tip -> do
              traceWith tracer (TraceIntersectFound p tip)
              -- The intersection's block number is unknown; treating it as
              -- the upstream's makes the first request a plain one.
              pure (idle pipelining Zero (getTipBlockNo tip) (getTipBlockNo tip))
          , recvMsgIntersectNotFound = fmap absurd . abort . IntersectionNotFound points
          }
 where
  pipelining :: MkPipelineDecision
  pipelining = pipelineDecisionLowHighMark 1 50

  idle
    :: MkPipelineDecision
    -> Nat n
    -> WithOrigin BlockNo
    -> WithOrigin BlockNo
    -> ClientPipelinedStIdle n hdr (Point Block) (Tip Block) IO a
  idle decide n ours theirs = case (n, runPipelineDecision decide n ours theirs) of
    (Zero, (Request, decide')) ->
      SendMsgRequestNext (pure ()) (next decide' Zero)
    (_, (Pipeline, decide')) ->
      SendMsgRequestNextPipelined (pure ()) (idle decide' (Succ n) ours theirs)
    (Succ n', (CollectOrPipeline, decide')) ->
      CollectResponse
        (Just (pure (SendMsgRequestNextPipelined (pure ()) (idle decide' (Succ n) ours theirs))))
        (next decide' n')
    (Succ n', (Collect, decide')) ->
      CollectResponse Nothing (next decide' n')

  next
    :: MkPipelineDecision
    -> Nat n
    -> ClientStNext n hdr (Point Block) (Tip Block) IO a
  next decide n =
    ClientStNext
      { recvMsgRollForward = \hdr tip -> do
          emit (RollForward hdr tip)
          pure (idle decide n (At (blockNo hdr)) (getTipBlockNo tip))
      , recvMsgRollBackward = \p tip -> do
          emit (RollBackward p tip)
          -- As after intersecting: the block number at 'p' is unknown.
          pure (idle decide n (getTipBlockNo tip) (getTipBlockNo tip))
      }
