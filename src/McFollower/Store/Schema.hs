-- | The SQLite schema of the index and its version.
--
-- Conventions:
--
-- * @block.id@ is the block's position on the indexed chain, from 1, with no
--   gaps. Rows created by a block carry its @block_id@, so a rollback deletes
--   by @block_id > n@.
-- * A transaction is identified by @(block_id, block_index)@.
-- * Columns holding unsigned 64-bit values that may exceed 2^63-1
--   (asset quantities, metadata labels, stake) store the two's complement of
--   the value; SQL only ever compares them for equality.
-- * Positions used by queries (@block_no@, @block_index@, output @idx@ and
--   the spending position) are copied onto the output and asset rows so that
--   every query is an index range scan.
module McFollower.Store.Schema
  ( schemaVersion
  , schema
  ) where

import Data.Text (Text)

-- | Stored in @PRAGMA user_version@. A database with another version is
-- refused.
schemaVersion :: Int
schemaVersion = 1

schema :: Text
schema =
  "CREATE TABLE meta (\n\
  \  key TEXT PRIMARY KEY,\n\
  \  value TEXT NOT NULL\n\
  \) STRICT;\n\
  \\n\
  \CREATE TABLE block (\n\
  \  id INTEGER PRIMARY KEY,\n\
  \  hash BLOB NOT NULL UNIQUE,\n\
  \  block_no INTEGER,\n\
  \  slot_no INTEGER NOT NULL,\n\
  \  epoch_no INTEGER NOT NULL,\n\
  \  time INTEGER NOT NULL,\n\
  \  tx_count INTEGER NOT NULL\n\
  \) STRICT;\n\
  \CREATE UNIQUE INDEX block_block_no ON block (block_no) WHERE block_no IS NOT NULL;\n\
  \CREATE INDEX block_epoch_slot ON block (epoch_no, slot_no);\n\
  \\n\
  \CREATE TABLE tx (\n\
  \  block_id INTEGER NOT NULL,\n\
  \  block_index INTEGER NOT NULL,\n\
  \  hash BLOB NOT NULL,\n\
  \  PRIMARY KEY (block_id, block_index)\n\
  \) STRICT, WITHOUT ROWID;\n\
  \CREATE UNIQUE INDEX tx_hash ON tx (hash);\n\
  \\n\
  \CREATE TABLE tx_out (\n\
  \  id INTEGER PRIMARY KEY,\n\
  \  tx_hash BLOB NOT NULL,\n\
  \  idx INTEGER NOT NULL,\n\
  \  block_id INTEGER NOT NULL,\n\
  \  block_no INTEGER NOT NULL,\n\
  \  block_index INTEGER NOT NULL,\n\
  \  address TEXT NOT NULL,\n\
  \  datum_hash BLOB,\n\
  \  spent_block_id INTEGER,\n\
  \  spent_block_no INTEGER,\n\
  \  spent_block_index INTEGER\n\
  \) STRICT;\n\
  \CREATE UNIQUE INDEX tx_out_ref ON tx_out (tx_hash, idx);\n\
  \CREATE INDEX tx_out_block ON tx_out (block_id);\n\
  \CREATE INDEX tx_out_address ON tx_out (address, block_no, block_index, idx);\n\
  \CREATE INDEX tx_out_address_spent ON tx_out (address, spent_block_no, spent_block_index, tx_hash, idx)\n\
  \  WHERE spent_block_id IS NOT NULL;\n\
  \CREATE INDEX tx_out_spent_block ON tx_out (spent_block_id, spent_block_index)\n\
  \  WHERE spent_block_id IS NOT NULL;\n\
  \\n\
  \CREATE TABLE ma_tx_out (\n\
  \  tx_out_id INTEGER NOT NULL,\n\
  \  policy BLOB NOT NULL,\n\
  \  name BLOB NOT NULL,\n\
  \  quantity INTEGER NOT NULL,\n\
  \  block_no INTEGER NOT NULL,\n\
  \  block_index INTEGER NOT NULL,\n\
  \  idx INTEGER NOT NULL,\n\
  \  spent_block_no INTEGER,\n\
  \  spent_block_index INTEGER,\n\
  \  PRIMARY KEY (tx_out_id, policy, name)\n\
  \) STRICT, WITHOUT ROWID;\n\
  \CREATE INDEX ma_tx_out_asset ON ma_tx_out (policy, name, block_no, block_index, idx);\n\
  \CREATE INDEX ma_tx_out_asset_spent ON ma_tx_out (policy, name, spent_block_no, spent_block_index)\n\
  \  WHERE spent_block_no IS NOT NULL;\n\
  \\n\
  \CREATE TABLE tx_input (\n\
  \  block_id INTEGER NOT NULL,\n\
  \  block_index INTEGER NOT NULL,\n\
  \  ord INTEGER NOT NULL,\n\
  \  tx_hash BLOB NOT NULL,\n\
  \  idx INTEGER NOT NULL,\n\
  \  PRIMARY KEY (block_id, block_index, ord)\n\
  \) STRICT, WITHOUT ROWID;\n\
  \\n\
  \CREATE TABLE datum (\n\
  \  id INTEGER PRIMARY KEY,\n\
  \  hash BLOB NOT NULL UNIQUE,\n\
  \  bytes BLOB NOT NULL,\n\
  \  block_id INTEGER NOT NULL\n\
  \) STRICT;\n\
  \CREATE INDEX datum_block ON datum (block_id);\n\
  \\n\
  \CREATE TABLE tx_metadata (\n\
  \  block_id INTEGER NOT NULL,\n\
  \  block_index INTEGER NOT NULL,\n\
  \  label INTEGER NOT NULL,\n\
  \  cbor BLOB NOT NULL,\n\
  \  PRIMARY KEY (block_id, block_index, label)\n\
  \) STRICT, WITHOUT ROWID;\n\
  \\n\
  \CREATE TABLE epoch_nonce (\n\
  \  epoch_no INTEGER PRIMARY KEY,\n\
  \  nonce BLOB NOT NULL\n\
  \) STRICT;\n\
  \\n\
  \CREATE TABLE epoch_param (\n\
  \  epoch_no INTEGER PRIMARY KEY,\n\
  \  max_tx_size INTEGER NOT NULL\n\
  \) STRICT;\n\
  \\n\
  \CREATE TABLE pool_stake (\n\
  \  epoch_no INTEGER NOT NULL,\n\
  \  pool_hash BLOB NOT NULL,\n\
  \  stake INTEGER NOT NULL,\n\
  \  PRIMARY KEY (epoch_no, pool_hash)\n\
  \) STRICT, WITHOUT ROWID;\n"
