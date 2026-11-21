-- | A small made-up chain of extracted blocks, and helpers to build stores
-- from rows in tests.
module Test.McFollower.Chain
  ( -- * Building rows
    hash32
  , txHash
  , blockRows
  , tx
  , output
  , chainFrom
  , startPoint
  , pointOfBlock
  , madeUpState

    -- * Stores
  , withTestStore
  , newTestStore
  , testIdentity
  , dumpTables
  ) where

import Control.Exception (bracket)
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Short qualified as SBS
import Data.List (sortOn)
import Data.Text (Text)
import Data.Word (Word16, Word64, Word8)
import Cardano.Ledger.BaseTypes (mkNonceFromNumber)
import Cardano.Slotting.Slot (WithOrigin (..))
import Data.Map.Strict qualified as Map
import McFollower.Block (Block)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import McFollower.Extract (BlockRows (..), OutputRow (..), TxRows (..))
import McFollower.Store
import McFollower.Store.Sql (SQLData, query)
import Ouroboros.Consensus.Block (Point (..), SlotNo (..))
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import System.FilePath ((</>))
import System.IO.Temp (createTempDirectory, getCanonicalTemporaryDirectory, withSystemTempDirectory)

-- | 32 bytes: a tag byte and a number.
hash32 :: Word8 -> Word64 -> ByteString
hash32 tag n = BS.pack (tag : replicate 23 0 <> [fromIntegral (n `div` (256 ^ i)) | i <- [7 :: Int, 6 .. 0]])

-- | Hash of transaction @t@ of block @b@.
txHash :: Word64 -> Int -> ByteString
txHash b t = hash32 0x70 (b * 1000 + fromIntegral t)

-- | Block @n@ (number n, slot 10n, epoch n `div` 10, time 1000 + 10n) after
-- block @n - 1@; block 0 is the start point.
blockRows :: Word64 -> [TxRows] -> BlockRows
blockRows n txs =
  BlockRows
    { brHash = hash32 0xb0 n
    , brPrevHash = Just (hash32 0xb0 (n - 1))
    , brNumber = Just n
    , brSlot = 10 * n
    , brEpoch = n `div` 10
    , brTime = 1000 + 10 * fromIntegral n
    , brTxs = txs
    }

startPoint :: Point Block
startPoint = pointOfBlock 0

-- | The point of block @n@ of 'blockRows'.
pointOfBlock :: Word64 -> Point Block
pointOfBlock n = BlockPoint (SlotNo (10 * n)) (OneEraHash (SBS.toShort (hash32 0xb0 n)))

-- | A made-up Praos state, for storing checkpoints of made-up blocks.
madeUpState :: Word64 -> PraosState
madeUpState n =
  PraosState
    { praosStateLastSlot = At (SlotNo (10 * n))
    , praosStateOCertCounters = Map.empty
    , praosStateEvolvingNonce = mkNonceFromNumber n
    , praosStateCandidateNonce = mkNonceFromNumber (n + 1)
    , praosStateEpochNonce = mkNonceFromNumber (n + 2)
    , praosStatePreviousEpochNonce = mkNonceFromNumber (n + 3)
    , praosStateLabNonce = mkNonceFromNumber (n + 4)
    , praosStateLastEpochBlockNonce = mkNonceFromNumber (n + 5)
    }

-- | Transaction @t@ of block @b@.
tx :: Word64 -> Int -> TxRows
tx b t = TxRows (txHash b t) [] [] False [] []

output :: Word16 -> Text -> [(ByteString, ByteString, Word64)] -> OutputRow
output ix address assets = OutputRow ix address Nothing assets

-- | Fill in the transaction hashes of a chain given as (block number, txs).
chainFrom :: [(Word64, [TxRows])] -> [BlockRows]
chainFrom = map (uncurry blockRows)

testIdentity :: StoreIdentity
testIdentity = StoreIdentity {siNetworkMagic = 42, siWatchSet = "test", siSecurityParam = 5}

withTestStore :: (FilePath -> Store -> IO a) -> IO a
withTestStore use = withSystemTempDirectory "mc-follower-test" $ \dir -> do
  let path = dir </> "index.db"
  bracket (openStore path testIdentity) closeStore $ \store -> do
    setStartPoint store startPoint
    use path store

-- | A store in a fresh temporary directory that is left for the system to
-- clean up, for test groups sharing one store.
newTestStore :: IO (FilePath, Store)
newTestStore = do
  tmp <- getCanonicalTemporaryDirectory
  dir <- createTempDirectory tmp "mc-follower-test"
  let path = dir </> "index.db"
  store <- openStore path testIdentity
  setStartPoint store startPoint
  pure (path, store)

-- | Every row of every table, sorted, for comparing whole stores.
dumpTables :: Store -> IO [(Text, [[SQLData]])]
dumpTables store = withSnapshot store $ \snap ->
  mapM
    (\table -> (table,) . sortOn show <$> query (snapshotConn snap) ("SELECT * FROM " <> table) [])
    [ "meta"
    , "block"
    , "tx"
    , "tx_out"
    , "ma_tx_out"
    , "tx_input"
    , "datum"
    , "tx_metadata"
    , "nonce_checkpoint"
    , "epoch_nonce"
    , "max_tx_size_sighting"
    , "committee_vote"
    , "nonce_divergence"
    , "epoch_param"
    , "epoch_stake"
    , "pool_stake"
    ]
