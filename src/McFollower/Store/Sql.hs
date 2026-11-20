-- | A thin layer over direct-sqlite: a connection with a cache of prepared
-- statements, parameterised execution, transactions and column decoding.
-- Shared by the store and the query layer; not meant for other users.
module McFollower.Store.Sql
  ( -- * Connections
    Conn
  , openConn
  , closeConn
  , execScript

    -- * Statements
  , query
  , foldQuery
  , forRowsWhile
  , execute

    -- * Transactions
  , withTransaction
  , TransactionMode (..)

    -- * Values
  , SQLData (..)
  , int
  , word
  , word64Bits
  , fromWord64Bits
  , blob
  , nullable
  , RowError (..)
  , rowError
  ) where

import Control.Exception (Exception, mask, onException, throwIO)
import Control.Monad (void, when)
import Data.ByteString (ByteString)
import Data.IORef (IORef, modifyIORef', newIORef, readIORef)
import Data.Int (Int64)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word64)
import Database.SQLite3 (Database, SQLData (..), SQLOpenFlag (..), SQLVFS (..), Statement, StepResult (..))
import Database.SQLite3 qualified as SQLite

data Conn = Conn
  { connDb :: !Database
  , connStatements :: !(IORef (Map Text Statement))
  }

-- | Open a database file; 'True' opens it read-only and never creates it.
openConn :: Bool -> FilePath -> IO Conn
openConn readOnly path = do
  db <- SQLite.open2 (Text.pack path) flags SQLVFSDefault
  Conn db <$> newIORef Map.empty
 where
  flags
    | readOnly = [SQLOpenReadOnly]
    | otherwise = [SQLOpenReadWrite, SQLOpenCreate]

closeConn :: Conn -> IO ()
closeConn Conn {connDb, connStatements} = do
  readIORef connStatements >>= mapM_ SQLite.finalize
  SQLite.close connDb

-- | Run one or more statements without parameters or results.
execScript :: Conn -> Text -> IO ()
execScript Conn {connDb} = SQLite.exec connDb

-- | Run a statement and fold over its rows, one at a time, from the left.
foldQuery :: Conn -> Text -> [SQLData] -> a -> (a -> [SQLData] -> IO a) -> IO a
foldQuery conn sql params z f = withPrepared conn sql $ \stmt -> do
  SQLite.bind stmt params
  let go acc =
        SQLite.step stmt >>= \case
          Done -> pure acc
          Row -> SQLite.columns stmt >>= f acc >>= go
  go z

-- | Run a statement and pass its rows, one at a time, to an action until it
-- returns 'False' or the rows run out.
forRowsWhile :: Conn -> Text -> [SQLData] -> ([SQLData] -> IO Bool) -> IO ()
forRowsWhile conn sql params f = withPrepared conn sql $ \stmt -> do
  SQLite.bind stmt params
  let go =
        SQLite.step stmt >>= \case
          Done -> pure ()
          Row -> SQLite.columns stmt >>= f >>= \more -> when more go
  go

query :: Conn -> Text -> [SQLData] -> IO [[SQLData]]
query conn sql params = reverse <$> foldQuery conn sql params [] (\rows row -> pure (row : rows))

execute :: Conn -> Text -> [SQLData] -> IO ()
execute conn sql params = void (foldQuery conn sql params () (\_ _ -> pure ()))

withPrepared :: Conn -> Text -> (Statement -> IO a) -> IO a
withPrepared Conn {connDb, connStatements} sql use = do
  stmt <-
    Map.lookup sql <$> readIORef connStatements >>= \case
      Just stmt -> pure stmt
      Nothing -> do
        stmt <- SQLite.prepare connDb sql
        modifyIORef' connStatements (Map.insert sql stmt)
        pure stmt
  mask $ \restore -> do
    result <- restore (use stmt) `onException` (SQLite.reset stmt >> SQLite.clearBindings stmt)
    SQLite.reset stmt
    SQLite.clearBindings stmt
    pure result

data TransactionMode
  = -- | Takes the write lock up front.
    Immediate
  | -- | A read transaction: one consistent snapshot until it ends.
    Deferred

-- | Run an action in a transaction, rolled back if the action throws.
withTransaction :: Conn -> TransactionMode -> IO a -> IO a
withTransaction conn mode action = mask $ \restore -> do
  execScript conn $ case mode of
    Immediate -> "BEGIN IMMEDIATE"
    Deferred -> "BEGIN DEFERRED"
  result <- restore action `onException` execScript conn "ROLLBACK"
  execScript conn "COMMIT"
  pure result

data RowError = RowError !Text ![SQLData]
  deriving stock (Show)

instance Exception RowError

-- | A row did not have the expected shape.
rowError :: Text -> [SQLData] -> IO a
rowError what row = throwIO (RowError what row)

int :: Integral a => a -> SQLData
int = SQLInteger . fromIntegral

-- | An unsigned value stored as its two's complement, for 'Word64' columns
-- that may exceed 'maxBound' of 'Int64'. Only equality is meaningful in SQL.
word64Bits :: Word64 -> SQLData
word64Bits = SQLInteger . fromIntegral

fromWord64Bits :: Int64 -> Word64
fromWord64Bits = fromIntegral

-- | A non-negative integer column.
word :: Num a => SQLData -> Maybe a
word = \case
  SQLInteger n | n >= 0 -> Just (fromIntegral n)
  _ -> Nothing

blob :: ByteString -> SQLData
blob = SQLBlob

nullable :: (a -> SQLData) -> Maybe a -> SQLData
nullable = maybe SQLNull
