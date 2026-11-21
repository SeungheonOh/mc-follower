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
--
-- Epoch data ("McFollower.EpochData.Store") lives in the same database.
-- What a block produces (the nonce driver's checkpoint after it, the epoch
-- nonce it starts, @maxTxSize@ proposal sightings) is written in the
-- block's own transaction ('applyBlockWith') and undone by the rollback
-- that undoes the block. Checkpoints are kept for the volatile window only:
-- the last @k + 1@ blocks, enough to roll back @k@. Stake distributions
-- and @maxTxSize@ values read from a node or Mithril come from immutable
-- states and are keyed by epoch only ('withEpochData').
--
-- Several processes or threads may open the same database: SQLite
-- serialises writers (with a busy timeout) and WAL readers never wait.
module McFollower.Store
  ( -- * Opening
    Store
  , StoreIdentity (..)
  , StoreError (..)
  , openStore
  , openStoreReadOnly
  , checkIdentity
  , closeStore
  , withStore

    -- * Chain
  , getStartPoint
  , setStartPoint
  , applyBlock
  , applyBlockWith
  , rollBackTo
  , intersectionPoints
  , tipPoint
  , hasBlock

    -- * Epoch data
  , withEpochData
  , snapshotEpochData

    -- * Reading
  , Snapshot
  , withSnapshot
  , snapshotConn
  ) where

import Cardano.Crypto.Hash (hashFromBytes, hashToBytes)
import Cardano.Ledger.BaseTypes (Nonce (..))
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash (..))
import Cardano.Slotting.Slot (EpochNo (..))
import Control.Exception (Exception, bracket, onException, throwIO)
import Control.Monad (forM_, unless, when)
import Data.ByteString (ByteString)
import Data.ByteString.Short qualified as SBS
import Data.Int (Int64)
import Data.List (unfoldr)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Word (Word32, Word64)
import McFollower.Block (Block, parsePoint, renderPoint)
import McFollower.EpochData.MaxTxSize (MaxTxSizeSighting (..), parseProposalRef, renderProposalRef)
import McFollower.EpochData.Stake (EpochStake (..), StakeSource (..), SnapshotLabel (..))
import McFollower.EpochData.Store (EpochDataStore (..))
import McFollower.Extract (BlockRows (..), OutRef (..), OutputRow (..), TxRows (..))
import McFollower.Nonce (Checkpoint (..), EpochNonce (..), nonceBytes)
import McFollower.Nonce.TrustedState (decodePraosState, encodePraosState)
import McFollower.Store.Schema (schema, schemaVersion)
import McFollower.Store.Sql
import Ouroboros.Consensus.Block (Point (..), SlotNo (..))
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))

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
  | UnknownEpochDataPoint !(Point Block)
  -- ^ Epoch data for a point that is neither a stored block nor the start
  -- point.
  deriving stock (Show)

instance Exception StoreError

-- | Open or create the index at a path.
openStore :: FilePath -> StoreIdentity -> IO Store
openStore path StoreIdentity {..} = do
  conn <- openConn False path
  flip onException (closeConn conn) $ do
    execScript conn "PRAGMA busy_timeout = 60000; PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL;"
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
        checkMeta conn siNetworkMagic siWatchSet
    pure (Store conn siSecurityParam)
 where
  magic = Text.pack (show siNetworkMagic)

-- | Refuse a store that was created for another network or watch set (for
-- stores opened with 'openStoreReadOnly').
checkIdentity :: Store -> StoreIdentity -> IO ()
checkIdentity Store {storeConn} StoreIdentity {siNetworkMagic, siWatchSet} = checkMeta storeConn siNetworkMagic siWatchSet

checkMeta :: Conn -> Word32 -> Text -> IO ()
checkMeta conn networkMagic watchSet = do
  storedMagic <- getMeta conn "network_magic"
  unless (storedMagic == Just (Text.pack (show networkMagic))) $ throwIO (WrongNetwork (maybe "" id storedMagic))
  storedWatch <- getMeta conn "watch_set"
  unless (storedWatch == Just watchSet) $ throwIO (WrongWatchSet (maybe "" id storedWatch))

-- | Open an existing index for queries only.
openStoreReadOnly :: FilePath -> IO Store
openStoreReadOnly path = do
  conn <- openConn True path
  flip onException (closeConn conn) $ do
    execScript conn "PRAGMA busy_timeout = 60000;"
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
applyBlock store rows = applyBlockWith store rows (\_ -> pure ())

-- | Store a block on top of the stored tip and, in the same transaction
-- once the block's rows are in, run an action that records the epoch data
-- the block produced. If the action throws, nothing of the block is
-- stored.
applyBlockWith :: Store -> BlockRows -> (EpochDataStore IO -> IO a) -> IO a
applyBlockWith store@Store {storeConn = c} BlockRows {..} epochData = withTransaction c Immediate $ do
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
  epochData (epochDataStore store)

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
    <> epochRollbackStatements

-- | What a rollback to block id @?1@ undoes of the epoch data.
epochRollbackStatements :: [Text]
epochRollbackStatements =
  [ "DELETE FROM nonce_checkpoint WHERE block_id > ?1"
  , "DELETE FROM epoch_nonce WHERE block_id > ?1"
  , "DELETE FROM max_tx_size_sighting WHERE block_id > ?1"
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

-- | Whether a point is a stored block.
hasBlock :: Store -> Point Block -> IO Bool
hasBlock Store {storeConn = c} = \case
  BlockPoint (SlotNo slot) (OneEraHash h) ->
    not . null <$> query c "SELECT id FROM block WHERE hash = ? AND slot_no = ?" [blob (SBS.fromShort h), int slot]
  GenesisPoint -> pure False

blockPoint :: Int64 -> ByteString -> Point Block
blockPoint slot hash = BlockPoint (SlotNo (fromIntegral slot)) (OneEraHash (SBS.toShort hash))

pointHash :: Point Block -> Maybe ByteString
pointHash = \case
  GenesisPoint -> Nothing
  BlockPoint _ (OneEraHash h) -> Just (SBS.fromShort h)

-- | A consistent view of the index for the duration of one call.
newtype Snapshot = Snapshot Conn

-- | Run reads in one read transaction. The store's connection is not
-- thread-safe; concurrent readers each open their own store.
withSnapshot :: Store -> (Snapshot -> IO a) -> IO a
withSnapshot Store {storeConn} f = withTransaction storeConn Deferred (f (Snapshot storeConn))

snapshotConn :: Snapshot -> Conn
snapshotConn (Snapshot c) = c

{-------------------------------------------------------------------------------
  Epoch data
-------------------------------------------------------------------------------}

-- | Run an action with the epoch data operations in one write transaction
-- of its own: for data that no block produced (stake distributions,
-- @maxTxSize@ from a node), and for the nonce driver's starting
-- checkpoint when it starts at the stored tip.
withEpochData :: Store -> (EpochDataStore IO -> IO a) -> IO a
withEpochData store@Store {storeConn = c} f = withTransaction c Immediate (f (epochDataStore store))

-- | The epoch data of a snapshot, for reading (the write operations fail
-- on a read-only store).
snapshotEpochData :: Snapshot -> EpochDataStore IO
snapshotEpochData (Snapshot c) = epochDataStore (Store c 0)

-- | The epoch data operations on the store's connection, without a
-- transaction of their own: callers run them inside one
-- ('applyBlockWith', 'withEpochData', 'withSnapshot').
epochDataStore :: Store -> EpochDataStore IO
epochDataStore store@Store {storeConn = c, storeSecurityParam = k} =
  EpochDataStore
    { storeCheckpoint = \Checkpoint {cpPoint, cpState, cpNewEpochNonce} -> do
        (blockId, slot, hash) <- pointRow cpPoint
        execute
          c
          "INSERT INTO nonce_checkpoint (block_id, slot_no, hash, praos_state, new_epoch_no, new_epoch_nonce) \
          \VALUES (?, ?, ?, ?, ?, ?)"
          [ SQLInteger blockId
          , SQLInteger slot
          , blob hash
          , blob (encodePraosState cpState)
          , nullable (int . unEpochNo . enEpoch) cpNewEpochNonce
          , nullable blob (cpNewEpochNonce >>= nonceBytes . enNonce)
          ]
        forM_ cpNewEpochNonce $ \(EpochNonce (EpochNo e) n) ->
          execute c "INSERT INTO epoch_nonce (epoch_no, nonce, block_id) VALUES (?, ?, ?)" [int e, nullable blob (nonceBytes n), SQLInteger blockId]
        -- The volatile window: this block and the k before it.
        execute c "DELETE FROM nonce_checkpoint WHERE block_id < ?" [SQLInteger (blockId - fromIntegral k)]
    , storeSightings = mapM_ $ \MaxTxSizeSighting {..} -> do
        (blockId, _, _) <- pointRow mssPoint
        execute
          c
          "INSERT INTO max_tx_size_sighting (block_id, proposal, proposed_value, earliest_epoch) VALUES (?, ?, ?, ?)"
          [SQLInteger blockId, SQLText (renderProposalRef mssProposal), int mssProposedValue, int (unEpochNo mssEarliestEpoch)]
    , storeStake = \EpochStake {..} -> do
        let EpochNo e = esEpoch
        stored <-
          query c "SELECT complete FROM epoch_stake WHERE epoch_no = ?" [int e] >>= \case
            [] -> pure Nothing
            [[SQLInteger complete]] -> pure (Just (complete /= 0))
            row -> rowError "epoch_stake" (concat row)
        unless (stored == Just True && not esComplete) $ do
          execute c "DELETE FROM pool_stake WHERE epoch_no = ?" [int e]
          forM_ (Map.toList esPools) $ \(KeyHash pool, Coin lovelace) ->
            execute
              c
              "INSERT INTO pool_stake (epoch_no, pool_hash, stake) VALUES (?, ?, ?)"
              [int e, blob (hashToBytes pool), word64Bits (fromInteger lovelace)]
          execute
            c
            "INSERT OR REPLACE INTO epoch_stake (epoch_no, complete, source) VALUES (?, ?, ?)"
            [int e, int (fromEnum esComplete), SQLText (renderStakeSource esSource)]
    , storeMaxTxSize = \(EpochNo e) size ->
        execute c "INSERT OR REPLACE INTO epoch_param (epoch_no, max_tx_size) VALUES (?, ?)" [int e, int size]
    , storeRollBack = \p -> do
        (blockId, _, _) <- pointRow p
        forM_ epochRollbackStatements $ \sql -> execute c sql [SQLInteger blockId]
    , loadCheckpoints =
        query c "SELECT slot_no, hash, praos_state, new_epoch_no, new_epoch_nonce FROM nonce_checkpoint ORDER BY block_id" []
          >>= mapM checkpointRow
    , loadEpochNonce = \(EpochNo e) ->
        query c "SELECT nonce FROM epoch_nonce WHERE epoch_no = ?" [int e] >>= \case
          [] -> pure Nothing
          [[n]] -> Just <$> nonceColumn n
          rows -> rowError "epoch_nonce" (concat rows)
    , loadStake = \(EpochNo e) ->
        query c "SELECT complete FROM epoch_stake WHERE epoch_no = ?" [int e] >>= \case
          [[SQLInteger 1]] ->
            Just . Map.fromList
              <$> ( query c "SELECT pool_hash, stake FROM pool_stake WHERE epoch_no = ? ORDER BY pool_hash" [int e]
                      >>= mapM poolRow
                  )
          _ -> pure Nothing
    , loadSightings =
        query
          c
          "SELECT b.slot_no, b.hash, s.proposal, s.proposed_value, s.earliest_epoch \
          \FROM max_tx_size_sighting s JOIN block b ON b.id = s.block_id ORDER BY s.block_id, s.proposal"
          []
          >>= mapM sightingRow
    , storeNonceDivergence = \case
        Nothing -> execute c "DELETE FROM nonce_divergence" []
        Just detail -> execute c "INSERT OR REPLACE INTO nonce_divergence (id, detail) VALUES (1, ?)" [SQLText detail]
    , loadNonceDivergence =
        query c "SELECT detail FROM nonce_divergence" [] >>= \case
          [] -> pure Nothing
          [[SQLText d]] -> pure (Just d)
          rows -> rowError "nonce_divergence" (concat rows)
    , loadMaxTxSize = \(EpochNo e) ->
        query c "SELECT max_tx_size FROM epoch_param WHERE epoch_no = ?" [int e] >>= \case
          [] -> pure Nothing
          [[v]] | Just size <- word v -> pure (Just size)
          rows -> rowError "epoch_param" (concat rows)
    }
 where
  -- The block id of a stored block, or 0 for the start point.
  pointRow :: Point Block -> IO (Int64, Int64, ByteString)
  pointRow p = case p of
    BlockPoint (SlotNo slot) (OneEraHash h) ->
      query c "SELECT id FROM block WHERE hash = ? AND slot_no = ?" [blob (SBS.fromShort h), int slot] >>= \case
        [[SQLInteger i]] -> pure (i, fromIntegral slot, SBS.fromShort h)
        _ ->
          getStartPoint store >>= \case
            Just start | start == p -> pure (0, fromIntegral slot, SBS.fromShort h)
            _ -> throwIO (UnknownEpochDataPoint p)
    GenesisPoint -> throwIO (UnknownEpochDataPoint p)

  checkpointRow = \case
    [SQLInteger slot, SQLBlob hash, SQLBlob state, newEpoch, newNonce] -> do
      st <- either (\e -> rowError ("praos_state: " <> Text.pack e) []) pure (decodePraosState state)
      en <- case newEpoch of
        SQLNull -> pure Nothing
        SQLInteger e -> Just . EpochNonce (EpochNo (fromIntegral e)) <$> nonceColumn newNonce
        other -> rowError "new_epoch_no" [other]
      pure (Checkpoint (blockPoint slot hash) st en)
    row -> rowError "nonce_checkpoint" row

  poolRow = \case
    [SQLBlob pool, SQLInteger lovelace]
      | Just h <- hashFromBytes pool -> pure (KeyHash h, Coin (toInteger (fromWord64Bits lovelace)))
    row -> rowError "pool_stake" row

  sightingRow = \case
    [SQLInteger slot, SQLBlob hash, SQLText ref, SQLInteger value, SQLInteger epoch]
      | Right proposal <- parseProposalRef ref ->
          pure
            MaxTxSizeSighting
              { mssProposal = proposal
              , mssPoint = blockPoint slot hash
              , mssProposedValue = fromIntegral value
              , mssEarliestEpoch = EpochNo (fromIntegral epoch)
              }
    row -> rowError "max_tx_size_sighting" row

-- | A stored nonce: 32 bytes, or NULL for the neutral nonce.
nonceColumn :: SQLData -> IO Nonce
nonceColumn = \case
  SQLNull -> pure NeutralNonce
  SQLBlob b | Just h <- hashFromBytes b -> pure (Nonce h)
  other -> rowError "nonce" [other]

renderStakeSource :: StakeSource -> Text
renderStakeSource = \case
  FromNodeSnapshot label (EpochNo e) -> "node " <> labelText label <> " snapshot in epoch " <> Text.pack (show e)
  FromMithril (EpochNo l) cert -> "mithril label " <> Text.pack (show l) <> " certificate " <> cert
 where
  labelText = \case
    Mark -> "mark"
    Set -> "set"
    Go -> "go"
