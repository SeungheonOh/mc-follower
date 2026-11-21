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

    -- * Retry policy
  , Outcome (..)
  , Retry (..)
  , noRetries
  , nextAttempt
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
-- Never returns. Network failures are retried, on the next upstream if
-- there are several; an exception thrown by the handler, or an
-- intersection that no upstream can find, is rethrown.
newtype BlockSource = BlockSource
  { runBlockSource :: [Point Block] -> (BlockEvent -> IO ()) -> IO Void
  }

data BlockSourceTrace
  = TraceConnecting !Text
  | TraceIntersectFound !(Point Block) !(Tip Block)
  | TraceNoBlocks !(Point Block) !(Point Block)
  -- ^ The relay no longer has this range; waiting for chain-sync to roll back.
  | TraceDisconnected !SomeException !Int
  -- ^ The connection ended; the next one starts after this many
  -- microseconds.
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
  , dsDrop :: forall e a. Exception e => e -> IO a
  -- ^ End this connection for this reason; the source moves on to the
  -- next upstream.
  }

-- | How a connection ended, as far as choosing the next attempt goes.
data Outcome
  = Progressed
  -- ^ It delivered at least one block.
  | NoIntersection
  -- ^ The upstream knew none of the points.
  | FailedEarly
  -- ^ Any other failure before a block was delivered.
  deriving stock (Eq, Show)

-- | Consecutive connections that delivered no block, and how many of them
-- in a row found no intersection.
data Retry = Retry
  { rFailures :: !Int
  , rNoIntersection :: !Int
  }
  deriving stock (Eq, Show)

noRetries :: Retry
noRetries = Retry 0 0

-- | The next attempt after a connection to one of @n@ upstreams ended:
-- the delay before it in microseconds, or 'Nothing' when every upstream in
-- turn has found no intersection (no upstream can continue the
-- consumer's chain).
--
-- A failure moves on to the next upstream after 'reconnectDelay'; once
-- every upstream has failed in a row the delay doubles per further round,
-- up to 'maxReconnectDelay'. A connection that delivered a block resets
-- both counts.
nextAttempt :: Int -> Outcome -> Retry -> Maybe (Retry, Int)
nextAttempt n outcome Retry {rFailures, rNoIntersection} = case outcome of
  Progressed -> Just (noRetries, reconnectDelay)
  NoIntersection
    | rNoIntersection + 1 >= max 1 n -> Nothing
    | otherwise -> failed (rNoIntersection + 1)
  FailedEarly -> failed 0
 where
  failed noIntersection =
    let failures = rFailures + 1
        rounds = failures `div` max 1 n
     in Just
          ( Retry failures noIntersection
          , min maxReconnectDelay (reconnectDelay * 2 ^ min 10 rounds)
          )

-- | Build a source from a function that runs one connection until it fails.
-- The connection function receives the attempt number (to rotate between
-- the given number of upstreams) and the points to intersect at: those
-- recently delivered, newest first, followed by the caller's original
-- candidates.
--
-- A connection failure (cannot connect, protocol error, the upstream knows
-- none of the points) moves on to the next upstream ('nextAttempt'). The
-- source fails only when the handler fails, a connection calls 'dsAbort',
-- or every upstream in turn has found no intersection.
reconnecting
  :: Tracer IO BlockSourceTrace
  -> Int
  -> (Int -> [Point Block] -> Downstream -> IO ())
  -> BlockSource
reconnecting tracer upstreams connect = BlockSource $ \start handler -> do
  recentVar <- newIORef (Recent.empty recentCapacity)
  fatalVar <- newIORef Nothing
  droppedVar <- newIORef Nothing
  progressVar <- newIORef False
  let abort :: Exception e => e -> IO a
      abort e = do
        writeIORef fatalVar (Just (toException e))
        throwIO e

      drop' :: Exception e => e -> IO a
      drop' e = do
        writeIORef droppedVar (Just (toException e))
        throwIO e

      deliver ev = do
        handler ev `catch` \(e :: SomeException) ->
          if isAsync e then throwIO e else abort e
        modifyIORef' recentVar $ case ev of
          RollForward blk _ -> Recent.rollForward (blockPoint blk)
          RollBackward p _ -> Recent.rollBackward p
        case ev of
          RollForward {} -> writeIORef progressVar True
          RollBackward {} -> pure ()

      loop :: Int -> Retry -> IO Void
      loop attempt retry = do
        recent <- readIORef recentVar
        writeIORef droppedVar Nothing
        writeIORef progressVar False
        let candidates = nubOrd (Recent.intersectionCandidates recent <> start)
        result <- try (connect attempt candidates (Downstream deliver abort drop'))
        -- The connection's threads may wrap or swallow the original
        -- exception, so the reasons are recorded on the side.
        readIORef fatalVar >>= traverse_ throwIO
        dropped <- readIORef droppedVar
        progressed <- readIORef progressVar
        failure <- case (dropped, result) of
          (Just e, _) -> pure e
          (Nothing, Left e) -> do
            when (isAsync e) (throwIO e)
            pure e
          (Nothing, Right ()) -> pure (toException UpstreamClosed)
        let outcome
              | progressed = Progressed
              | Just IntersectionNotFound {} <- fromException failure = NoIntersection
              | otherwise = FailedEarly
        case nextAttempt upstreams outcome retry of
          Nothing -> throwIO failure
          Just (retry', delay) -> do
            traceWith tracer (TraceDisconnected failure delay)
            threadDelay delay
            loop (attempt + 1) retry'
  loop 0 noRetries
 where
  isAsync = isJust . fromException @SomeAsyncException

-- | Points kept for re-intersection: comfortably more than the security
-- parameter on every public network.
recentCapacity :: Int
recentCapacity = 4096

-- | Microseconds to wait before the next connection.
reconnectDelay :: Int
reconnectDelay = 5_000_000

-- | The longest wait between connections: five minutes.
maxReconnectDelay :: Int
maxReconnectDelay = 300_000_000
