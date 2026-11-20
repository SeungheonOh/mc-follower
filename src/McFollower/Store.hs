{-# LANGUAGE RecordWildCards #-}

-- | The index: an SQLite database in WAL mode ("McFollower.Store.Schema").
--
-- Writes happen on one connection, one transaction per applied block or
-- rollback, so a reader (see "McFollower.Query") always sees the index at a
-- block boundary. @synchronous = NORMAL@: a power loss can lose the last
-- committed blocks but never leaves a partial one; the follower then
-- re-intersects from what is stored.
--
-- Every block from the start point onward is kept, so the stored blocks are
-- also the chain points to re-intersect at after a restart. A rollback undoes
-- the blocks above its point: their blocks, transactions, outputs, input
-- lists, metadata and the datums they introduced are deleted, and outputs
-- they spent become unspent again. Rollbacks deeper than the security
-- parameter are refused.
module McFollower.Store
  ( -- * Opening
    Store
  , StoreIdentity (..)
  , StoreError (..)
  , openStore
  , openStoreReadOnly
  , closeStore
  , withStore

    -- * Chain
  , getStartPoint
  , setStartPoint
  , applyBlock
  , rollBackTo
  , intersectionPoints
  , tipPoint

    -- * Per-epoch data
  , putEpochNonce
  , putMaxTxSize
  , putPoolStake

    -- * Reading
  , Snapshot
  , withSnapshot
  , snapshotConn
  ) where

import Control.Exception (Exception, bracket, onException, throwIO)
import Control.Monad (forM_, unless, when)
import Data.ByteString (ByteString)
import Data.ByteString.Short qualified as SBS
import Data.Int (Int64)
import Data.List (unfoldr)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word32, Word64)
import McFollower.Block (Block, parsePoint, renderPoint)
import McFollower.Extract (BlockRows (..), OutRef (..), OutputRow (..), TxRows (..))
import McFollower.Store.Schema (schema, schemaVersion)
import McFollower.Store.Sql
import Ouroboros.Consensus.Block (Point (..), SlotNo (..))
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Cardano.Slotting.Slot (EpochNo (..))

data Store = Store
  { storeConn :: !Conn
  , storeSecurityParam :: !Word64
  }

-- | What a database is bound to when it is created; opening it with
-- anything else is refused.
data StoreIdentity = StoreIdentity
  { siNetworkMagic :: !Word32
  , siWatchSet :: !Text
  -- ^ 'McFollower.WatchSet.renderWatchConfig'.
  , siSecurityParam :: !Word64
  -- ^ Not stored; bounds rollbacks.
  }

data StoreError
  = IncompatibleSchema !Int
  -- ^ The database has this schema version (0: not an mc-follower database).
  | WrongNetwork !Text
  | WrongWatchSet !Text
  -- ^ The watch set the database was built with.
  | StartPointMismatch !(Point Block) !(Point Block)
  -- ^ Stored, requested.
  | NoStartPoint
  | NotConnected !(Maybe ByteString) !(Point Block)
  -- ^ A block whose parent (hash given) is not the stored tip (point given).
  | UnknownRollbackPoint !(Point Block)
  | RollbackTooDeep !(Point Block) !Int
  -- ^ Would undo this many blocks.
  deriving stock (Show)

instance Exception StoreError

-- | Open or create the index at a path.
openStore :: FilePath -> StoreIdentity -> IO Store
openStore path StoreIdentity {..} = do
  conn <- openConn False path
  flip onException (closeConn conn) $ do
    execScript conn "PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL;"
    version <- userVersion conn
    if version == 0
      then do
        objects <- query conn "SELECT count(*) FROM sqlite_schema" []
        unless (objects == [[SQLInteger 0]]) $ throwIO (IncompatibleSchema 0)
        withTransaction conn Immediate $ do
          execScript conn schema
          execScript conn ("PRAGMA user_version = " <> Text.pack (show schemaVersion))
          putMeta conn "network_magic" magic
          putMeta conn "watch_set" siWatchSet
      else do
        unless (version == schemaVersion) $ throwIO (IncompatibleSchema version)
        storedMagic <- getMeta conn "network_magic"
        unless (storedMagic == Just magic) $ throwIO (WrongNetwork (maybe "" id storedMagic))
        storedWatch <- getMeta conn "watch_set"
        unless (storedWatch == Just siWatchSet) $ throwIO (WrongWatchSet (maybe "" id storedWatch))
    pure (Store conn siSecurityParam)
 where
  magic = Text.pack (show siNetworkMagic)

-- | Open an existing index for queries only.
openStoreReadOnly :: FilePath -> IO Store
openStoreReadOnly path = do
  conn <- openConn True path
  flip onException (closeConn conn) $ do
    version <- userVersion conn
    unless (version == schemaVersion) $ throwIO (IncompatibleSchema version)
    pure (Store conn 0)

closeStore :: Store -> IO ()
closeStore = closeConn . storeConn

withStore :: FilePath -> StoreIdentity -> (Store -> IO a) -> IO a
withStore path identity = bracket (openStore path identity) closeStore

userVersion :: Conn -> IO Int
userVersion conn =
  query conn "PRAGMA user_version" [] >>= \case
    [[SQLInteger v]] -> pure (fromIntegral v)
    row -> rowError "user_version" (concat row)

getMeta :: Conn -> Text -> IO (Maybe Text)
getMeta conn key =
  query conn "SELECT value FROM meta WHERE key = ?" [SQLText key] >>= \case
    [] -> pure Nothing
    [[SQLText v]] -> pure (Just v)
    row -> rowError "meta" (concat row)

putMeta :: Conn -> Text -> Text -> IO ()
putMeta conn key value = execute conn "INSERT INTO meta (key, value) VALUES (?, ?)" [SQLText key, SQLText value]

-- | The point a fresh index started from, once set.
getStartPoint :: Store -> IO (Maybe (Point Block))
getStartPoint Store {storeConn} =
  getMeta storeConn "start_point" >>= traverse (either (rowError "start_point" . pure . SQLText . Text.pack) pure . parsePoint)

-- | Record where the index starts. Allowed once; setting the same point
-- again is a no-op, a different one is refused.
setStartPoint :: Store -> Point Block -> IO ()
setStartPoint store@Store {storeConn} point =
  getStartPoint store >>= \case
    Just stored
      | stored == point -> pure ()
      | otherwise -> throwIO (StartPointMismatch stored point)
    Nothing -> withTransaction storeConn Immediate (putMeta storeConn "start_point" (renderPoint point))

-- | Store a block on top of the stored tip, in one transaction.
applyBlock :: Store -> BlockRows -> IO ()
applyBlock store@Store {storeConn = c} BlockRows {..} = withTransaction c Immediate $ do
  (parentId, parent) <-
    query c "SELECT id, slot_no, hash FROM block ORDER BY id DESC LIMIT 1" [] >>= \case
      [[SQLInteger i, SQLInteger s, SQLBlob h]] -> pure (i, blockPoint s h)
      [] -> (0,) <$> (getStartPoint store >>= maybe (throwIO NoStartPoint) pure)
      row -> rowError "tip" (concat row)
  unless (brPrevHash == pointHash parent) $ throwIO (NotConnected brPrevHash parent)
  let blockId = parentId + 1
  execute
    c
    "INSERT INTO block (id, hash, block_no, slot_no, epoch_no, time, tx_count) VALUES (?, ?, ?, ?, ?, ?, ?)"
    [ SQLInteger blockId
    , blob brHash
    , nullable int brNumber
    , int brSlot
    , int brEpoch
    , SQLInteger brTime
    , int (length brTxs)
    ]
  forM_ (zip [0 :: Int64 ..] brTxs) $ \(txIndex, TxRows {..}) -> do
    let position = [SQLInteger blockId, SQLInteger txIndex]
    blockNo <- maybe (rowError "transaction in a block without a number" [blob brHash]) (pure . int) brNumber
    execute c "INSERT INTO tx (block_id, block_index, hash) VALUES (?, ?, ?)" (position <> [blob trHash])
    forM_ trSpends $ \OutRef {..} -> do
      spent <-
        query
          c
          "UPDATE tx_out SET spent_block_id = ?, spent_block_no = ?, spent_block_index = ? \
          \WHERE tx_hash = ? AND idx = ? RETURNING id"
          [SQLInteger blockId, blockNo, SQLInteger txIndex, blob refTxHash, int refIndex]
      forM_ spent $ \outId ->
        execute
          c
          "UPDATE ma_tx_out SET spent_block_no = ?, spent_block_index = ? WHERE tx_out_id = ?"
          ([blockNo, SQLInteger txIndex] <> outId)
    forM_ trOutputs $ \OutputRow {..} -> do
      outId <-
        query
          c
          "INSERT INTO tx_out (tx_hash, idx, block_id, block_no, block_index, address, datum_hash) \
          \VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id"
          [blob trHash, int orIndex, SQLInteger blockId, blockNo, SQLInteger txIndex, SQLText orAddress, nullable blob orDatumHash]
      forM_ orAssets $ \(policy, name, quantity) ->
        execute
          c
          "INSERT INTO ma_tx_out (tx_out_id, policy, name, quantity, block_no, block_index, idx) \
          \VALUES (?, ?, ?, ?, ?, ?, ?)"
          (concat outId <> [blob policy, blob name, word64Bits quantity, blockNo, SQLInteger txIndex, int orIndex])
    when trRecordInputs $
      forM_ (zip [0 :: Int64 ..] trSpends) $ \(ord, OutRef {..}) ->
        execute
          c
          "INSERT INTO tx_input (block_id, block_index, ord, tx_hash, idx) VALUES (?, ?, ?, ?, ?)"
          (position <> [SQLInteger ord, blob refTxHash, int refIndex])
    forM_ trDatums $ \(hash, bytes) ->
      execute
        c
        "INSERT INTO datum (hash, bytes, block_id) VALUES (?, ?, ?) ON CONFLICT (hash) DO NOTHING"
        [blob hash, blob bytes, SQLInteger blockId]
    forM_ trMetadata $ \(label, cbor) ->
      execute
        c
        "INSERT INTO tx_metadata (block_id, block_index, label, cbor) VALUES (?, ?, ?, ?)"
        (position <> [word64Bits label, blob cbor])

-- | Undo every block above the point and return how many were undone. The
-- point must be a stored block or the start point.
rollBackTo :: Store -> Point Block -> IO Int
rollBackTo store@Store {storeConn = c, storeSecurityParam} point = withTransaction c Immediate $ do
  start <- getStartPoint store
  target <- case point of
    BlockPoint (SlotNo slot) (OneEraHash h) ->
      query c "SELECT id, slot_no FROM block WHERE hash = ?" [blob (SBS.fromShort h)] >>= \case
        [[SQLInteger i, SQLInteger s]] | fromIntegral s == slot -> pure (Just i)
        _ -> pure Nothing
    GenesisPoint -> pure Nothing
  targetId <- case target of
    Just i -> pure i
    Nothing
      | Just point == start -> pure 0
      | otherwise -> throwIO (UnknownRollbackPoint point)
  undone <-
    query c "SELECT count(*), count(block_no) FROM block WHERE id > ?" [SQLInteger targetId] >>= \case
      [[SQLInteger blocks, SQLInteger numbered]] -> pure (fromIntegral blocks, fromIntegral numbered :: Word64)
      row -> rowError "rollback depth" (concat row)
  when (snd undone > storeSecurityParam) $ throwIO (RollbackTooDeep point (fst undone))
  forM_ rollbackStatements $ \sql -> execute c sql [SQLInteger targetId]
  pure (fst undone)

rollbackStatements :: [Text]
rollbackStatements =
  [ "DELETE FROM datum WHERE block_id > ?1"
  , "UPDATE ma_tx_out SET spent_block_no = NULL, spent_block_index = NULL \
    \WHERE tx_out_id IN (SELECT id FROM tx_out WHERE spent_block_id > ?1)"
  , "UPDATE tx_out SET spent_block_id = NULL, spent_block_no = NULL, spent_block_index = NULL \
    \WHERE spent_block_id > ?1"
  , "DELETE FROM ma_tx_out WHERE tx_out_id IN (SELECT id FROM tx_out WHERE block_id > ?1)"
  , "DELETE FROM tx_out WHERE block_id > ?1"
  , "DELETE FROM tx_input WHERE block_id > ?1"
  , "DELETE FROM tx_metadata WHERE block_id > ?1"
  , "DELETE FROM tx WHERE block_id > ?1"
  , "DELETE FROM block WHERE id > ?1"
  ]

-- | Points to intersect at, newest first: the tip, then blocks 1, 2, 4, 8,
-- ... below it, the oldest stored block and the start point.
intersectionPoints :: Store -> IO [Point Block]
intersectionPoints store@Store {storeConn = c} = do
  tipId <-
    query c "SELECT max(id) FROM block" [] >>= \case
      [[SQLInteger i]] -> pure i
      [[SQLNull]] -> pure 0
      row -> rowError "tip id" (concat row)
  let ids = takeWhile (> 1) (map (tipId -) (0 : unfoldr (\o -> Just (o, o * 2)) 1)) <> [1 | tipId >= 1]
  points <- concat <$> mapM pointAt ids
  start <- getStartPoint store
  pure (points <> maybe [] pure start)
 where
  pointAt i =
    query c "SELECT slot_no, hash FROM block WHERE id = ?" [SQLInteger i] >>= \case
      [[SQLInteger s, SQLBlob h]] -> pure [blockPoint s h]
      row -> rowError "block point" (concat row)

-- | The newest stored block, or the start point if there is none.
tipPoint :: Store -> IO (Maybe (Point Block))
tipPoint store@Store {storeConn = c} =
  query c "SELECT slot_no, hash FROM block ORDER BY id DESC LIMIT 1" [] >>= \case
    [[SQLInteger s, SQLBlob h]] -> pure (Just (blockPoint s h))
    [] -> getStartPoint store
    row -> rowError "tip" (concat row)

blockPoint :: Int64 -> ByteString -> Point Block
blockPoint slot hash = BlockPoint (SlotNo (fromIntegral slot)) (OneEraHash (SBS.toShort hash))

pointHash :: Point Block -> Maybe ByteString
pointHash = \case
  GenesisPoint -> Nothing
  BlockPoint _ (OneEraHash h) -> Just (SBS.fromShort h)

-- | The nonce of an epoch (32 bytes). Replaces an existing one.
putEpochNonce :: Store -> EpochNo -> ByteString -> IO ()
putEpochNonce Store {storeConn = c} (EpochNo epoch) nonce =
  withTransaction c Immediate $
    execute c "INSERT OR REPLACE INTO epoch_nonce (epoch_no, nonce) VALUES (?, ?)" [int epoch, blob nonce]

-- | The @maxTxSize@ protocol parameter in force during an epoch.
putMaxTxSize :: Store -> EpochNo -> Word64 -> IO ()
putMaxTxSize Store {storeConn = c} (EpochNo epoch) size =
  withTransaction c Immediate $
    execute c "INSERT OR REPLACE INTO epoch_param (epoch_no, max_tx_size) VALUES (?, ?)" [int epoch, int size]

-- | The complete stake distribution of an epoch (pool hash to lovelace),
-- written in one transaction so that readers see all of it or none.
-- Replaces an existing one.
putPoolStake :: Store -> EpochNo -> Map ByteString Word64 -> IO ()
putPoolStake Store {storeConn = c} (EpochNo epoch) stake =
  withTransaction c Immediate $ do
    execute c "DELETE FROM pool_stake WHERE epoch_no = ?" [int epoch]
    forM_ (Map.toList stake) $ \(pool, lovelace) ->
      execute c "INSERT INTO pool_stake (epoch_no, pool_hash, stake) VALUES (?, ?, ?)" [int epoch, blob pool, word64Bits lovelace]

-- | A consistent view of the index for the duration of one call.
newtype Snapshot = Snapshot Conn

-- | Run reads in one read transaction. The store's connection is not
-- thread-safe; concurrent readers each open their own store.
withSnapshot :: Store -> (Snapshot -> IO a) -> IO a
withSnapshot Store {storeConn} f = withTransaction storeConn Deferred (f (Snapshot storeConn))

snapshotConn :: Snapshot -> Conn
snapshotConn (Snapshot c) = c
