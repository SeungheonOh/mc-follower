{-# LANGUAGE RecordWildCards #-}

-- | The row queries the Midnight node makes, one function per RPC of
-- @proto/mc_follower.proto@, answered from a store 'Snapshot'. Each function
-- has the filters, ordering and limit semantics of the SQL it replaces (see
-- the proto comments); a gRPC server only converts requests and rows.
--
-- Positions are @(block_no, tx_index)@ and ordered lexicographically. A
-- 'Window' is half-open: @from <= position < to@.
--
-- Where the SQL has no @ORDER BY@ the order here is fixed and documented on
-- the function. Blocks and transactions before the index's start point are
-- absent.
--
-- Queries returning many rows come in two forms: @eachX@ passes the rows to
-- a 'Sink' one at a time while the statement steps, so that a server can
-- stream them without holding the result in memory; @getX@ collects them.
module McFollower.Query
  ( -- * Streaming
    Sink
  , collect

    -- * Row types
  , BlockInfo (..)
  , Position (..)
  , Window (..)
  , Page (..)
  , AssetId (..)
  , OutRef (..)

    -- * Status
  , IndexStatus (..)
  , getIndexStatus

    -- * Blocks
  , getLatestBlock
  , eachBlockByNumberRange
  , getBlocksByNumberRange
  , HighestBlockWindow (..)
  , getHighestBlockInWindow
  , getBlockByHash

    -- * Bridge
  , getTxPosition
  , BridgeLowerBound (..)
  , BridgeTxsRequest (..)
  , BridgeTxRow (..)
  , eachBridgeTx
  , getBridgeTxs

    -- * Authority selection
  , getLatestBlockForEpoch
  , getLatestStableEpoch
  , TokenOutput (..)
  , getLatestTokenOutputForEpoch
  , AddressOutput (..)
  , eachUnspentOutputAtAddress
  , getUnspentOutputsAtAddress

    -- * cNIGHT observation
  , RegistrationRow (..)
  , eachMappingRegistration
  , getMappingRegistrations
  , DeregistrationRow (..)
  , eachMappingDeregistration
  , getMappingDeregistrations
  , AssetCreateRow (..)
  , eachAssetCreate
  , getAssetCreates
  , AssetSpendRow (..)
  , eachAssetSpend
  , getAssetSpends
  , getBlockEpoch

    -- * Federated authority observation
  , GovernanceOutput (..)
  , getLatestGovernanceOutput
  ) where

import Control.Monad (when)
import Data.ByteString (ByteString)
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Int (Int64)
import Data.Maybe (listToMaybe)
import Data.Text (Text)
import Data.Word (Word16, Word32, Word64)
import McFollower.Extract (OutRef (..))
import McFollower.Store (Snapshot, snapshotConn)
import McFollower.Store.Sql
import McFollower.WatchSet (AssetId (..))

-- | Receives the rows of a query, one at a time, in the query's order.
type Sink a = a -> IO ()

-- | The rows an @eachX@ query passes to its sink.
collect :: (Sink a -> IO ()) -> IO [a]
collect each = do
  rows <- newIORef []
  each (\row -> modifyIORef' rows (row :))
  reverse <$> readIORef rows

-- | Decode the rows of a statement and pass them on as they come.
eachRow :: Snapshot -> Text -> [SQLData] -> ([SQLData] -> IO a) -> Sink a -> IO ()
eachRow snap sql params decode sink = foldQuery (snapshotConn snap) sql params () (\() row -> decode row >>= sink)

-- | A block of the indexed chain (never an epoch boundary block).
data BlockInfo = BlockInfo
  { biNumber :: !Word32
  , biHash :: !ByteString
  , biEpoch :: !Word32
  , biSlot :: !Word64
  , biTime :: !Int64
  -- ^ Slot start, Unix seconds.
  , biTxCount :: !Word64
  }
  deriving stock (Eq, Show)

data Position = Position
  { posBlock :: !Word32
  , posTx :: !Word32
  }
  deriving stock (Eq, Ord, Show)

-- | @[wFrom, wTo)@.
data Window = Window
  { wFrom :: !Position
  , wTo :: !Position
  }
  deriving stock (Eq, Show)

-- | @LIMIT pLimit OFFSET pOffset@, applied after filtering and ordering.
data Page = Page
  { pLimit :: !Word32
  , pOffset :: !Word32
  }
  deriving stock (Eq, Show)

blockColumns :: Text
blockColumns = "b.block_no, b.hash, b.epoch_no, b.slot_no, b.time, b.tx_count"

blockRow :: [SQLData] -> IO BlockInfo
blockRow = \case
  [SQLInteger n, SQLBlob h, SQLInteger e, SQLInteger s, SQLInteger t, SQLInteger c] ->
    pure (BlockInfo (fromIntegral n) h (fromIntegral e) (fromIntegral s) t (fromIntegral c))
  row -> rowError "block" row

blocks :: Snapshot -> Text -> [SQLData] -> IO [BlockInfo]
blocks snap sql params = query (snapshotConn snap) sql params >>= mapM blockRow

firstBlock :: Snapshot -> Text -> [SQLData] -> IO (Maybe BlockInfo)
firstBlock snap sql params = listToMaybe <$> blocks snap sql params

data IndexStatus = IndexStatus
  { isTip :: !(Maybe BlockInfo)
  , isImmutableTip :: !(Maybe BlockInfo)
  -- ^ The block @k@ below the tip.
  , isStartBlock :: !(Maybe BlockInfo)
  -- ^ The first numbered block of the index.
  }
  deriving stock (Eq, Show)

-- | The stored part of @GetStatus@, for security parameter @k@.
getIndexStatus :: Word32 -> Snapshot -> IO IndexStatus
getIndexStatus k snap = do
  tip <- getLatestBlock snap
  immutable <- case tip of
    Just BlockInfo {biNumber}
      | biNumber >= k ->
          firstBlock snap ("SELECT " <> blockColumns <> " FROM block b WHERE b.block_no = ?") [int (biNumber - k)]
    _ -> pure Nothing
  start <-
    firstBlock
      snap
      ("SELECT " <> blockColumns <> " FROM block b WHERE b.block_no IS NOT NULL ORDER BY b.block_no LIMIT 1")
      []
  pure (IndexStatus tip immutable start)

-- | @GetLatestBlock@: the highest-numbered block.
getLatestBlock :: Snapshot -> IO (Maybe BlockInfo)
getLatestBlock snap =
  firstBlock snap ("SELECT " <> blockColumns <> " FROM block b WHERE b.block_no IS NOT NULL ORDER BY b.block_no DESC LIMIT 1") []

-- | @GetBlocksByNumberRange@: @from <= block_no <= to@, ascending.
eachBlockByNumberRange :: Word32 -> Word32 -> Snapshot -> Sink BlockInfo -> IO ()
eachBlockByNumberRange from to snap =
  eachRow
    snap
    ("SELECT " <> blockColumns <> " FROM block b WHERE b.block_no >= ? AND b.block_no <= ? ORDER BY b.block_no")
    [int from, int to]
    blockRow

getBlocksByNumberRange :: Word32 -> Word32 -> Snapshot -> IO [BlockInfo]
getBlocksByNumberRange from to = collect . eachBlockByNumberRange from to

-- | All bounds inclusive; times in Unix milliseconds.
data HighestBlockWindow = HighestBlockWindow
  { hbMaxBlock :: !Word32
  , hbMinSlot :: !Word64
  , hbMaxSlot :: !Word64
  , hbMinTimeMillis :: !Int64
  , hbMaxTimeMillis :: !Int64
  }
  deriving stock (Eq, Show)

-- | @GetHighestBlockInWindow@: the highest block within all bounds. Block
-- time (whole seconds) is compared at millisecond precision.
getHighestBlockInWindow :: HighestBlockWindow -> Snapshot -> IO (Maybe BlockInfo)
getHighestBlockInWindow HighestBlockWindow {..} snap =
  firstBlock
    snap
    ( "SELECT " <> blockColumns <> " FROM block b \
      \WHERE b.block_no <= ? AND b.slot_no >= ? AND b.slot_no <= ? \
      \AND b.time * 1000 >= ? AND b.time * 1000 <= ? \
      \ORDER BY b.block_no DESC LIMIT 1"
    )
    [int hbMaxBlock, int hbMinSlot, int hbMaxSlot, SQLInteger hbMinTimeMillis, SQLInteger hbMaxTimeMillis]

-- | @GetBlockByHash@: absent for unknown hashes and epoch boundary blocks.
getBlockByHash :: ByteString -> Snapshot -> IO (Maybe BlockInfo)
getBlockByHash hash snap =
  firstBlock snap ("SELECT " <> blockColumns <> " FROM block b WHERE b.hash = ? AND b.block_no IS NOT NULL") [blob hash]

-- | @GetTxPosition@: any transaction, phase-2-invalid ones included.
getTxPosition :: ByteString -> Snapshot -> IO (Maybe Position)
getTxPosition hash snap =
  query (snapshotConn snap) "SELECT b.block_no, t.block_index FROM tx t JOIN block b ON b.id = t.block_id WHERE t.hash = ?" [blob hash]
    >>= \case
      [] -> pure Nothing
      [[SQLInteger n, SQLInteger i]] -> pure (Just (Position (fromIntegral n) (fromIntegral i)))
      rows -> rowError "tx position" (concat rows)

-- | Lower bound of 'getBridgeTxs' (the resolved bridge checkpoint).
data BridgeLowerBound
  = -- | @block_no > n@
    AfterBlock !Word32
  | -- | @position > p@
    AfterPosition !Position
  | -- | @position >= p@
    FromPosition !Position
  deriving stock (Eq, Show)

data BridgeTxsRequest = BridgeTxsRequest
  { btrIcsAddress :: !Text
  , btrReserveAddress :: !Text
  , btrToken :: !AssetId
  , btrLower :: !BridgeLowerBound
  , btrToBlock :: !Word32
  -- ^ Inclusive.
  , btrMaxTxs :: !(Maybe Word32)
  }
  deriving stock (Eq, Show)

-- | Sums are exact; the SQL computes them as unbounded @NUMERIC@.
data BridgeTxRow = BridgeTxRow
  { btPosition :: !Position
  , btTxHash :: !ByteString
  , btMetadatum :: !(Maybe ByteString)
  -- ^ CBOR of the metadatum under the bridge label.
  , btBridgeIn :: !Integer
  , btBridgeOut :: !Integer
  , btReserveIn :: !Integer
  , btReserveOut :: !Integer
  }
  deriving stock (Eq, Show)

-- | @GetBridgeTxs@: every transaction that created an output at the ICS
-- address carrying the token, within the bounds, that moved tokens into the
-- ICS address or out of the reserve address; ordered by position, at most
-- 'btrMaxTxs'. Metadata is that of the label in the watch set.
eachBridgeTx :: Word64 -> BridgeTxsRequest -> Snapshot -> Sink BridgeTxRow -> IO ()
eachBridgeTx label BridgeTxsRequest {..} snap sink = do
  -- Candidates are examined in order until the limit is reached.
  remaining <- newIORef btrMaxTxs
  let more = maybe True (> 0) <$> readIORef remaining
  start <- more
  when start $
    forRowsWhile
      c
      ( "SELECT DISTINCT o.block_id, o.block_no, o.block_index FROM tx_out o \
        \JOIN ma_tx_out m ON m.tx_out_id = o.id AND m.policy = ? AND m.name = ? \
        \WHERE o.address = ? AND o.block_no <= ? AND "
          <> lowerBound
          <> " ORDER BY o.block_no, o.block_index"
      )
      ([blob (assetPolicy btrToken), blob (assetName btrToken), SQLText btrIcsAddress, int btrToBlock] <> lowerParams)
      ( \candidate -> do
          examine candidate >>= mapM_ (\row -> sink row >> modifyIORef' remaining (fmap (subtract 1)))
          more
      )
 where
  c = snapshotConn snap
  (lowerBound, lowerParams) = case btrLower of
    AfterBlock n -> ("o.block_no > ?", [int n])
    AfterPosition (Position b t) -> ("(o.block_no, o.block_index) > (?, ?)", [int b, int t])
    FromPosition (Position b t) -> ("(o.block_no, o.block_index) >= (?, ?)", [int b, int t])

  -- The row of a candidate transaction, if it moved tokens into the ICS
  -- address or out of the reserve address.
  examine = \case
    [SQLInteger blockId, SQLInteger blockNo, SQLInteger txIndex] -> do
      bridgeOut <- created btrIcsAddress blockNo txIndex
      bridgeIn <- consumed btrIcsAddress blockId txIndex
      reserveOut <- created btrReserveAddress blockNo txIndex
      reserveIn <- consumed btrReserveAddress blockId txIndex
      if bridgeOut > bridgeIn || reserveIn > reserveOut
        then do
          hash <- txHashAt blockId txIndex
          metadatum <-
            query c "SELECT cbor FROM tx_metadata WHERE block_id = ? AND block_index = ? AND label = ?" [SQLInteger blockId, SQLInteger txIndex, word64Bits label]
              >>= \case
                [] -> pure Nothing
                [[SQLBlob m]] -> pure (Just m)
                rows -> rowError "metadata" (concat rows)
          pure (Just (BridgeTxRow (Position (fromIntegral blockNo) (fromIntegral txIndex)) hash metadatum bridgeIn bridgeOut reserveIn reserveOut))
        else pure Nothing
    row -> rowError "bridge candidate" row

  created address blockNo txIndex =
    sumQuantities
      "SELECT m.quantity FROM tx_out o CROSS JOIN ma_tx_out m ON m.tx_out_id = o.id \
      \WHERE o.address = ? AND o.block_no = ? AND o.block_index = ? AND m.policy = ? AND m.name = ?"
      [SQLText address, SQLInteger blockNo, SQLInteger txIndex, blob (assetPolicy btrToken), blob (assetName btrToken)]
  -- CROSS JOIN fixes the join order: from the spending transaction's
  -- outputs, never from all outputs carrying the token.
  consumed address blockId txIndex =
    sumQuantities
      "SELECT m.quantity FROM tx_out o CROSS JOIN ma_tx_out m ON m.tx_out_id = o.id \
      \WHERE o.spent_block_id = ? AND o.spent_block_index = ? AND o.address = ? AND m.policy = ? AND m.name = ?"
      [SQLInteger blockId, SQLInteger txIndex, SQLText address, blob (assetPolicy btrToken), blob (assetName btrToken)]
  sumQuantities sql params =
    foldQuery c sql params 0 $ \acc -> \case
      [SQLInteger q] -> pure (acc + toInteger (fromWord64Bits q))
      row -> rowError "quantity" row

  txHashAt blockId txIndex =
    query c "SELECT hash FROM tx WHERE block_id = ? AND block_index = ?" [SQLInteger blockId, SQLInteger txIndex] >>= \case
      [[SQLBlob h]] -> pure h
      rows -> rowError "tx hash" (concat rows)

getBridgeTxs :: Word64 -> BridgeTxsRequest -> Snapshot -> IO [BridgeTxRow]
getBridgeTxs label request = collect . eachBridgeTx label request

-- | @GetLatestBlockForEpoch@: the block with the highest slot among blocks
-- in epochs up to @epoch@.
getLatestBlockForEpoch :: Word32 -> Snapshot -> IO (Maybe BlockInfo)
getLatestBlockForEpoch epoch snap =
  -- Ordering by (epoch_no, slot_no) is ordering by slot_no, since epochs grow
  -- with slots; it lets the (epoch_no, slot_no) index serve the query.
  firstBlock
    snap
    ( "SELECT " <> blockColumns <> " FROM block b \
      \WHERE b.epoch_no <= ? AND b.block_no IS NOT NULL ORDER BY b.epoch_no DESC, b.slot_no DESC LIMIT 1"
    )
    [int epoch]

-- | @GetLatestStableEpoch@: the epoch of block @tip - k@, minus one (may be
-- -1); absent if that block is not indexed.
getLatestStableEpoch :: Word32 -> Snapshot -> IO (Maybe Int64)
getLatestStableEpoch k snap =
  query
    (snapshotConn snap)
    "SELECT s.epoch_no - 1 FROM block b JOIN block s ON s.block_no = b.block_no - ? \
    \WHERE b.block_no IS NOT NULL ORDER BY b.block_no DESC LIMIT 1"
    [int k]
    >>= \case
      [] -> pure Nothing
      [[SQLInteger e]] -> pure (Just e)
      rows -> rowError "stable epoch" (concat rows)

data TokenOutput = TokenOutput
  { toTxHash :: !ByteString
  , toIndex :: !Word16
  , toEpoch :: !Word32
  , toBlockNo :: !Word32
  , toSlot :: !Word64
  , toTxIndex :: !Word32
  , toDatum :: !(Maybe ByteString)
  }
  deriving stock (Eq, Show)

-- | @GetLatestTokenOutputForEpoch@: the latest output, spent or not, carrying
-- the asset, created in an epoch up to @epoch@; ties within a transaction
-- go to the highest output index.
getLatestTokenOutputForEpoch :: AssetId -> Word32 -> Snapshot -> IO (Maybe TokenOutput)
getLatestTokenOutputForEpoch AssetId {..} epoch snap =
  query
    (snapshotConn snap)
    -- The block_no bound restates the epoch bound on the asset index: epochs
    -- grow with block numbers.
    "SELECT o.tx_hash, o.idx, b.epoch_no, b.block_no, b.slot_no, o.block_index, d.bytes \
    \FROM ma_tx_out m JOIN tx_out o ON o.id = m.tx_out_id JOIN block b ON b.id = o.block_id \
    \LEFT JOIN datum d ON d.hash = o.datum_hash \
    \WHERE m.policy = ? AND m.name = ? AND b.epoch_no <= ?3 \
    \AND m.block_no <= (SELECT max(block_no) FROM block WHERE epoch_no <= ?3) \
    \ORDER BY m.block_no DESC, m.block_index DESC, m.idx DESC LIMIT 1"
    [blob assetPolicy, blob assetName, int epoch]
    >>= \case
      [] -> pure Nothing
      [[SQLBlob h, SQLInteger i, SQLInteger e, SQLInteger n, SQLInteger s, SQLInteger t, d]] ->
        Just . TokenOutput h (fromIntegral i) (fromIntegral e) (fromIntegral n) (fromIntegral s) (fromIntegral t) <$> datumColumn d
      rows -> rowError "token output" (concat rows)

data AddressOutput = AddressOutput
  { aoTxHash :: !ByteString
  , aoIndex :: !Word16
  , aoBlockNo :: !Word32
  , aoSlot :: !Word64
  , aoEpoch :: !Word32
  , aoTxIndex :: !Word32
  , aoAddress :: !Text
  , aoDatum :: !(Maybe ByteString)
  , aoInputs :: ![OutRef]
  -- ^ Inputs of the creating transaction, by (hash, index). Recorded only for
  -- addresses whose input lists the watch set keeps.
  }
  deriving stock (Eq, Show)

-- | @GetUnspentOutputsAtAddress@: outputs at the address created at or
-- before @block@ and not spent at or before it. The SQL has no ORDER BY;
-- rows come by (block_no, tx_index, output index).
eachUnspentOutputAtAddress :: Text -> Word32 -> Snapshot -> Sink AddressOutput -> IO ()
eachUnspentOutputAtAddress address block snap =
  eachRow
    snap
    "SELECT o.tx_hash, o.idx, o.block_no, b.slot_no, b.epoch_no, o.block_index, o.address, d.bytes, o.block_id \
      \FROM tx_out o JOIN block b ON b.id = o.block_id LEFT JOIN datum d ON d.hash = o.datum_hash \
      \WHERE o.address = ? AND o.block_no <= ?2 AND (o.spent_block_no IS NULL OR o.spent_block_no > ?2) \
    \ORDER BY o.block_no, o.block_index, o.idx"
    [SQLText address, int block]
    $ \case
    [SQLBlob h, SQLInteger i, SQLInteger n, SQLInteger s, SQLInteger e, SQLInteger t, SQLText a, d, SQLInteger blockId] -> do
      datum <- datumColumn d
      inputs <-
        query c "SELECT tx_hash, idx FROM tx_input WHERE block_id = ? AND block_index = ? ORDER BY tx_hash, idx" [SQLInteger blockId, SQLInteger t]
          >>= mapM (\case [SQLBlob ih, SQLInteger ii] -> pure (OutRef ih (fromIntegral ii)); row -> rowError "input" row)
      pure (AddressOutput h (fromIntegral i) (fromIntegral n) (fromIntegral s) (fromIntegral e) (fromIntegral t) a datum inputs)
    row -> rowError "address output" row
 where
  c = snapshotConn snap

getUnspentOutputsAtAddress :: Text -> Word32 -> Snapshot -> IO [AddressOutput]
getUnspentOutputsAtAddress address block = collect . eachUnspentOutputAtAddress address block

datumColumn :: SQLData -> IO (Maybe ByteString)
datumColumn = \case
  SQLNull -> pure Nothing
  SQLBlob b -> pure (Just b)
  other -> rowError "datum" [other]

-- | SQL and parameters restricting @(blockNo, txIndex)@ to a window.
windowCondition :: Text -> Text -> Window -> (Text, [SQLData])
windowCondition blockNo txIndex (Window (Position fb ft) (Position tb tt)) =
  ( blockNo <> " >= ? AND " <> blockNo <> " <= ? AND (" <> blockNo <> ", " <> txIndex <> ") >= (?, ?) AND ("
      <> blockNo <> ", " <> txIndex <> ") < (?, ?)"
  , [int fb, int tb, int fb, int ft, int tb, int tt]
  )

pageParams :: Page -> [SQLData]
pageParams (Page limit offset) = [int limit, int offset]

data RegistrationRow = RegistrationRow
  { rgDatum :: !ByteString
  , rgBlockNo :: !Word32
  , rgBlockHash :: !ByteString
  , rgBlockTimeMillis :: !Int64
  , rgTxIndex :: !Word32
  , rgTxHash :: !ByteString
  , rgIndex :: !Word16
  }
  deriving stock (Eq, Show)

-- | @GetMappingRegistrations@: outputs at the address holding exactly one
-- of the auth token, with a resolvable datum, created in the window;
-- ordered by (block_no, tx_index, output index).
eachMappingRegistration :: Text -> AssetId -> Window -> Page -> Snapshot -> Sink RegistrationRow -> IO ()
eachMappingRegistration address AssetId {..} window page snap =
  eachRow
    snap
    ( "SELECT d.bytes, o.block_no, b.hash, b.time, o.block_index, o.tx_hash, o.idx \
      \FROM tx_out o JOIN datum d ON d.hash = o.datum_hash \
      \JOIN ma_tx_out m ON m.tx_out_id = o.id JOIN block b ON b.id = o.block_id \
      \WHERE o.address = ? AND m.policy = ? AND m.name = ? AND m.quantity = 1 AND "
        <> cond
        <> " ORDER BY o.block_no, o.block_index, o.idx LIMIT ? OFFSET ?"
    )
    ([SQLText address, blob assetPolicy, blob assetName] <> params <> pageParams page)
    ( \case
        [SQLBlob d, SQLInteger n, SQLBlob bh, SQLInteger t, SQLInteger ti, SQLBlob th, SQLInteger i] ->
          pure (RegistrationRow d (fromIntegral n) bh (t * 1000) (fromIntegral ti) th (fromIntegral i))
        row -> rowError "registration" row
    )
 where
  (cond, params) = windowCondition "o.block_no" "o.block_index" window

getMappingRegistrations :: Text -> AssetId -> Window -> Page -> Snapshot -> IO [RegistrationRow]
getMappingRegistrations address asset window page = collect . eachMappingRegistration address asset window page

data DeregistrationRow = DeregistrationRow
  { drDatum :: !ByteString
  , drBlockNo :: !Word32
  , drBlockHash :: !ByteString
  , drBlockTimeMillis :: !Int64
  , drTxIndex :: !Word32
  , drTxHash :: !ByteString
  , drSpent :: !OutRef
  }
  deriving stock (Eq, Show)

-- | @GetMappingDeregistrations@: (spending transaction, spent output) for
-- outputs at the address with a resolvable datum, spent in the window;
-- ordered by (spending position, spent tx hash, spent index).
eachMappingDeregistration :: Text -> Window -> Page -> Snapshot -> Sink DeregistrationRow -> IO ()
eachMappingDeregistration address window page snap =
  eachRow
    snap
    ( "SELECT d.bytes, o.spent_block_no, b.hash, b.time, o.spent_block_index, t.hash, o.tx_hash, o.idx \
      \FROM tx_out o JOIN datum d ON d.hash = o.datum_hash \
      \JOIN block b ON b.id = o.spent_block_id \
      \JOIN tx t ON t.block_id = o.spent_block_id AND t.block_index = o.spent_block_index \
      \WHERE o.address = ? AND o.spent_block_id IS NOT NULL AND "
        <> cond
        <> " ORDER BY o.spent_block_no, o.spent_block_index, o.tx_hash, o.idx LIMIT ? OFFSET ?"
    )
    ([SQLText address] <> params <> pageParams page)
    ( \case
        [SQLBlob d, SQLInteger n, SQLBlob bh, SQLInteger t, SQLInteger ti, SQLBlob th, SQLBlob oh, SQLInteger oi] ->
          pure (DeregistrationRow d (fromIntegral n) bh (t * 1000) (fromIntegral ti) th (OutRef oh (fromIntegral oi)))
        row -> rowError "deregistration" row
    )
 where
  (cond, params) = windowCondition "o.spent_block_no" "o.spent_block_index" window

getMappingDeregistrations :: Text -> Window -> Page -> Snapshot -> IO [DeregistrationRow]
getMappingDeregistrations address window page = collect . eachMappingDeregistration address window page

data AssetCreateRow = AssetCreateRow
  { acBlockNo :: !Word32
  , acBlockHash :: !ByteString
  , acBlockTimeMillis :: !Int64
  , acTxIndex :: !Word32
  , acQuantity :: !Word64
  , acHolderAddress :: !Text
  , acTxHash :: !ByteString
  , acIndex :: !Word16
  }
  deriving stock (Eq, Show)

-- | @GetAssetCreates@: outputs carrying the asset, at any address, created
-- in the window; ordered by (block_no, tx_index, output index).
eachAssetCreate :: AssetId -> Window -> Page -> Snapshot -> Sink AssetCreateRow -> IO ()
eachAssetCreate AssetId {..} window page snap =
  eachRow
    snap
    ( "SELECT m.block_no, b.hash, b.time, m.block_index, m.quantity, o.address, o.tx_hash, m.idx \
      \FROM ma_tx_out m JOIN tx_out o ON o.id = m.tx_out_id JOIN block b ON b.id = o.block_id \
      \WHERE m.policy = ? AND m.name = ? AND "
        <> cond
        <> " ORDER BY m.block_no, m.block_index, m.idx LIMIT ? OFFSET ?"
    )
    ([blob assetPolicy, blob assetName] <> params <> pageParams page)
    ( \case
        [SQLInteger n, SQLBlob bh, SQLInteger t, SQLInteger ti, SQLInteger q, SQLText a, SQLBlob th, SQLInteger i] ->
          pure (AssetCreateRow (fromIntegral n) bh (t * 1000) (fromIntegral ti) (fromWord64Bits q) a th (fromIntegral i))
        row -> rowError "asset create" row
    )
 where
  (cond, params) = windowCondition "m.block_no" "m.block_index" window

getAssetCreates :: AssetId -> Window -> Page -> Snapshot -> IO [AssetCreateRow]
getAssetCreates asset window page = collect . eachAssetCreate asset window page

data AssetSpendRow = AssetSpendRow
  { asBlockNo :: !Word32
  , asBlockHash :: !ByteString
  , asBlockTimeMillis :: !Int64
  , asTxIndex :: !Word32
  , asQuantity :: !Word64
  , asHolderAddress :: !Text
  , asSpent :: !OutRef
  , asSpendingTxHash :: !ByteString
  }
  deriving stock (Eq, Show)

-- | @GetAssetSpends@: (spending transaction, spent output) for outputs
-- carrying the asset, spent in the window; ordered by (spending position,
-- spent tx hash, spent index).
eachAssetSpend :: AssetId -> Window -> Page -> Snapshot -> Sink AssetSpendRow -> IO ()
eachAssetSpend AssetId {..} window page snap =
  eachRow
    snap
    ( "SELECT m.spent_block_no, b.hash, b.time, m.spent_block_index, m.quantity, o.address, o.tx_hash, o.idx, t.hash \
      \FROM ma_tx_out m JOIN tx_out o ON o.id = m.tx_out_id \
      \JOIN block b ON b.id = o.spent_block_id \
      \JOIN tx t ON t.block_id = o.spent_block_id AND t.block_index = o.spent_block_index \
      \WHERE m.policy = ? AND m.name = ? AND m.spent_block_no IS NOT NULL AND "
        <> cond
        <> " ORDER BY m.spent_block_no, m.spent_block_index, o.tx_hash, o.idx LIMIT ? OFFSET ?"
    )
    ([blob assetPolicy, blob assetName] <> params <> pageParams page)
    ( \case
        [SQLInteger n, SQLBlob bh, SQLInteger t, SQLInteger ti, SQLInteger q, SQLText a, SQLBlob oh, SQLInteger oi, SQLBlob th] ->
          pure (AssetSpendRow (fromIntegral n) bh (t * 1000) (fromIntegral ti) (fromWord64Bits q) a (OutRef oh (fromIntegral oi)) th)
        row -> rowError "asset spend" row
    )
 where
  (cond, params) = windowCondition "m.spent_block_no" "m.spent_block_index" window

getAssetSpends :: AssetId -> Window -> Page -> Snapshot -> IO [AssetSpendRow]
getAssetSpends asset window page = collect . eachAssetSpend asset window page

-- | The epoch of block @block@, for @GetMaxTxSize@ (whose answer is the
-- epoch's, "McFollower.EpochData.Serve"); absent if the block is unknown.
getBlockEpoch :: Word32 -> Snapshot -> IO (Maybe Word32)
getBlockEpoch block snap =
  query (snapshotConn snap) "SELECT epoch_no FROM block WHERE block_no = ?" [int block] >>= \case
    [] -> pure Nothing
    [[SQLInteger e]] -> pure (Just (fromIntegral e))
    rows -> rowError "block epoch" (concat rows)

data GovernanceOutput = GovernanceOutput
  { goDatum :: !ByteString
  , goBlockNo :: !Word32
  , goBlockHash :: !ByteString
  , goTxIndex :: !Word32
  , goTxHash :: !ByteString
  , goIndex :: !Word16
  }
  deriving stock (Eq, Show)

-- | @GetLatestGovernanceOutput@: the latest output, spent or not, at the
-- address carrying any token of the policy, with a resolvable datum, created
-- at or before @block@; ties within a transaction go to the highest output
-- index.
getLatestGovernanceOutput :: Text -> ByteString -> Word32 -> Snapshot -> IO (Maybe GovernanceOutput)
getLatestGovernanceOutput address policy block snap =
  query
    (snapshotConn snap)
    "SELECT d.bytes, o.block_no, b.hash, o.block_index, o.tx_hash, o.idx \
    \FROM tx_out o JOIN datum d ON d.hash = o.datum_hash JOIN block b ON b.id = o.block_id \
    \WHERE o.address = ? AND o.block_no <= ? \
    \AND EXISTS (SELECT 1 FROM ma_tx_out m WHERE m.tx_out_id = o.id AND m.policy = ?) \
    \ORDER BY o.block_no DESC, o.block_index DESC, o.idx DESC LIMIT 1"
    [SQLText address, int block, blob policy]
    >>= \case
      [] -> pure Nothing
      [[SQLBlob d, SQLInteger n, SQLBlob bh, SQLInteger ti, SQLBlob th, SQLInteger i]] ->
        pure (Just (GovernanceOutput d (fromIntegral n) bh (fromIntegral ti) th (fromIntegral i)))
      rows -> rowError "governance output" (concat rows)
