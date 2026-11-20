-- | The interface between an upstream (a relay or a local node) and the
-- indexer: a stream of roll-forward and roll-backward events over 'Block'.
--
-- Concrete sources live in "McFollower.BlockSource.N2N" and
-- "McFollower.BlockSource.N2C". Both are built with 'reconnecting', which
-- owns the reconnect loop and the choice of intersection points.
module McFollower.BlockSource
  ( -- * Events
    ChainEvent (..)
  , BlockEvent

    -- * Sources
  , BlockSource (..)
  , BlockSourceTrace (..)
  , BlockSourceError (..)

    -- * Building sources
  , Downstream (..)
  , reconnecting
  ) where

import Control.Concurrent (threadDelay)
import Control.Exception
  ( Exception (..)
  , SomeAsyncException
  , SomeException
  , catch
  , throwIO
  , try
  )
import Control.Monad (when)
import Control.Tracer (Tracer, traceWith)
import Data.Containers.ListUtils (nubOrd)
import Data.Foldable (traverse_)
import Data.IORef (modifyIORef', newIORef, readIORef, writeIORef)
import Data.Maybe (isJust)
import Data.Text (Text)
import Data.Void (Void)
import McFollower.Block (Block)
import McFollower.BlockSource.Recent qualified as Recent
import Ouroboros.Consensus.Block (Point, blockPoint)
import Ouroboros.Network.Block (Tip)

-- | One step of the upstream's chain. @a@ is the payload of a forward step:
-- a full 'Block' for consumers, a header inside the node-to-node source.
--
-- A source always starts with a 'RollBackward' to the intersection it found,
-- and again after every reconnect.
data ChainEvent blk a
  = RollForward !a !(Tip blk)
  | RollBackward !(Point blk) !(Tip blk)
  deriving stock (Functor)

type BlockEvent = ChainEvent Block Block

-- | Run with candidate intersection points (most preferred first) and a
-- handler. The handler is called on the source's own thread, one event at a
-- time; the source waits for it to return, so a slow handler slows the
-- upstream down rather than buffering without bound.
--
-- Never returns. Network failures are retried; an exception thrown by the
-- handler, or an intersection that cannot be found, is rethrown.
newtype BlockSource = BlockSource
  { runBlockSource :: [Point Block] -> (BlockEvent -> IO ()) -> IO Void
  }

data BlockSourceTrace
  = TraceConnecting !Text
  | TraceIntersectFound !(Point Block) !(Tip Block)
  | TraceNoBlocks !(Point Block) !(Point Block)
  -- ^ The relay no longer has this range; waiting for chain-sync to roll back.
  | TraceDisconnected !SomeException
  deriving stock (Show)

data BlockSourceError
  = IntersectionNotFound ![Point Block] !(Tip Block)
  | UnexpectedBlock !(Maybe (Point Block)) !(Point Block)
  -- ^ Block-fetch delivered a block other than the next one requested
  -- (expected point, or 'Nothing' past the end of the range; received point).
  | IncompleteBatch ![Point Block]
  -- ^ Block-fetch batch ended without these blocks.
  | UpstreamClosed
  deriving stock (Show)

instance Exception BlockSourceError

-- | What a single connection needs from 'reconnecting'.
data Downstream = Downstream
  { dsDeliver :: BlockEvent -> IO ()
  -- ^ Pass an event on to the handler.
  , dsAbort :: forall e a. Exception e => e -> IO a
  -- ^ Fail the whole source, not just this connection.
  }

-- | Build a source from a function that runs one connection until it fails.
-- The connection function receives the attempt number (to rotate between
-- upstreams) and the points to intersect at: those recently delivered,
-- newest first, followed by the caller's original candidates.
reconnecting
  :: Tracer IO BlockSourceTrace
  -> (Int -> [Point Block] -> Downstream -> IO ())
  -> BlockSource
reconnecting tracer connect = BlockSource $ \start handler -> do
  recentVar <- newIORef (Recent.empty recentCapacity)
  fatalVar <- newIORef Nothing
  let abort :: Exception e => e -> IO a
      abort e = do
        writeIORef fatalVar (Just (toException e))
        throwIO e

      deliver ev = do
        handler ev `catch` \(e :: SomeException) ->
          if isAsync e then throwIO e else abort e
        modifyIORef' recentVar $ case ev of
          RollForward blk _ -> Recent.rollForward (blockPoint blk)
          RollBackward p _ -> Recent.rollBackward p

      loop :: Int -> IO Void
      loop attempt = do
        recent <- readIORef recentVar
        let candidates = nubOrd (Recent.intersectionCandidates recent <> start)
        result <- try (connect attempt candidates (Downstream deliver abort))
        -- The connection's threads may wrap or swallow the original
        -- exception, so fatal failures are recorded on the side.
        readIORef fatalVar >>= traverse_ throwIO
        failure <- case result of
          Left e -> do
            when (isAsync e) (throwIO e)
            pure e
          Right () -> pure (toException UpstreamClosed)
        traceWith tracer (TraceDisconnected failure)
        threadDelay reconnectDelay
        loop (attempt + 1)
  loop 0
 where
  isAsync = isJust . fromException @SomeAsyncException

-- | Points kept for re-intersection: comfortably more than the security
-- parameter on every public network.
recentCapacity :: Int
recentCapacity = 4096

-- | Microseconds to wait before reconnecting.
reconnectDelay :: Int
reconnectDelay = 5_000_000
