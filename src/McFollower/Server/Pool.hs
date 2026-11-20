-- | A bounded pool of read-only store connections for the gRPC server.
--
-- A direct-sqlite connection must not be used by two threads at once, so
-- every request borrows a connection of its own for its whole duration (one
-- read transaction, "McFollower.Store.withSnapshot"). Connections are opened
-- on demand, up to a limit; requests beyond it wait for one to be returned.
-- A connection whose use ended in an exception is closed rather than reused.
--
-- Opening may fail (the database does not exist yet, or is not an
-- mc-follower database for this network); the exception is passed to the
-- borrower and the next borrower tries again.
module McFollower.Server.Pool
  ( Pool
  , newPool
  , withPooled
  , closePool
  ) where

import Control.Concurrent.QSem (QSem, newQSem, signalQSem, waitQSem)
import Control.Exception (bracket_, mask, onException)
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import McFollower.Store (Store, closeStore)

data Pool = Pool
  { poolOpen :: !(IO Store)
  , poolIdle :: !(IORef [Store])
  , poolSlots :: !QSem
  }

-- | A pool opening at most @n@ connections with the given action.
newPool :: Int -> IO Store -> IO Pool
newPool n open = Pool open <$> newIORef [] <*> newQSem (max 1 n)

-- | Run an action with a connection of its own.
withPooled :: Pool -> (Store -> IO a) -> IO a
withPooled Pool {poolOpen, poolIdle, poolSlots} use =
  bracket_ (waitQSem poolSlots) (signalQSem poolSlots) $
    mask $ \restore -> do
      store <-
        atomicModifyIORef' poolIdle (\case [] -> ([], Nothing); s : rest -> (rest, Just s))
          >>= maybe (restore poolOpen) pure
      result <- restore (use store) `onException` closeStore store
      atomicModifyIORef' poolIdle (\idle -> (store : idle, ()))
      pure result

-- | Close the idle connections; call it once no request is running.
closePool :: Pool -> IO ()
closePool Pool {poolIdle} = atomicModifyIORef' poolIdle ([],) >>= mapM_ closeStore
