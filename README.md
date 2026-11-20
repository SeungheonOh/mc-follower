# mc-follower

mc-follower is a Cardano indexer for Midnight. It follows Cardano, indexes
only the data a Midnight node reads, and serves it to the node over gRPC, in
place of cardano-db-sync and PostgreSQL. The design is in
[docs/SPEC.md](docs/SPEC.md).

It is written in Haskell on the Cardano node's own libraries
(ouroboros-network, cardano-diffusion, ouroboros-consensus, cardano-ledger,
cardano-api) and can follow the chain two ways:

- **node-to-node (N2N)** from one or more relays, with no local node: header
  chain-sync plus range block-fetch. The relay is trusted; headers are not
  validated.
- **node-to-client (N2C)** from a local cardano-node socket: chain-sync of
  full blocks, plus local state queries.

## Status

Implemented so far: the block source for both modes, the extractor, the
SQLite store with rollback, the sync loop (`mc-follower sync`) and the query
layer behind every row RPC of [proto/mc_follower.proto](proto/mc_follower.proto).
The nonce driver, epoch data (stake distribution, `max_tx_size`) and the gRPC
server are still to come; the store already has their tables and a write API.

| Module | Purpose |
|---|---|
| `McFollower.Block` | The `CardanoBlock StandardCrypto` type, per-era projections, point and hash rendering |
| `McFollower.BlockFile` | Blocks as files in the consensus on-disk encoding (test fixtures) |
| `McFollower.Network` | Network parameters and the mainnet, preprod and preview presets |
| `McFollower.EraHistory` | Genesis parameters and the era history: slot to epoch and slot start time |
| `McFollower.Address` | Address text exactly as db-sync stores it (bech32 / base58) |
| `McFollower.WatchSet` | What is indexed per network (Midnight addresses, policies, metadata label), presets and start points |
| `McFollower.Extract` | Pure function from a block to the rows to store, reproducing db-sync's representation |
| `McFollower.Store` | SQLite index: open/create, apply a block, roll back, intersection points, per-epoch data |
| `McFollower.Store.Schema` | The SQL schema and its version |
| `McFollower.Store.Sql` | Thin direct-sqlite layer (prepared-statement cache, transactions) |
| `McFollower.Query` | One function per row RPC of the proto, against a store snapshot |
| `McFollower.Sync` | The sync loop: block source to extractor to store, with progress reporting |
| `McFollower.BlockSource` | `ChainEvent`, the `BlockSource` interface, the reconnect loop |
| `McFollower.BlockSource.ChainSync` | Pipelined chain-sync client shared by both modes |
| `McFollower.BlockSource.N2N` | Node-to-node source: connection, block-fetch client, keep-alive |
| `McFollower.BlockSource.N2N.Pending` | Fetched-but-not-delivered headers and how rollbacks affect them |
| `McFollower.BlockSource.Recent` | Recently delivered points, used to re-intersect after a reconnect |
| `McFollower.BlockSource.N2C` | Node-to-client source over a local socket |
| `McFollower.LocalStateQuery` | Local state queries at the immutable tip, volatile tip or a point |

## Building

The package set is pinned to the one cardano-node 11.2.3 uses (same Hackage
and CHaP index states, constraints and flags; see `cabal.project`).

Requirements:

- GHC 9.6 and cabal 3.10 or later
- `libsodium`, `libsecp256k1` and `libblst`, all visible to `pkg-config`

On macOS, libsodium and secp256k1 come from Homebrew
(`brew install libsodium secp256k1 pkg-config`). blst is not packaged by
Homebrew; build it from [supranational/blst](https://github.com/supranational/blst)
and install a `libblst.pc` for it, then point `PKG_CONFIG_PATH` at that
directory. The project builds cardano-crypto-praos with
`-external-libsodium-vrf`, so stock libsodium is enough; IOG's libsodium fork
is not needed.

```sh
export PKG_CONFIG_PATH=$HOME/.local/blst/lib/pkgconfig   # where libblst.pc is
cabal update
cabal build all
cabal test
```

The first build compiles the whole Cardano dependency tree and takes a while.

## Syncing the index

`mc-follower sync` builds the index in an SQLite database and keeps it
following the chain, from a relay (node-to-node) or a local node socket:

```sh
mc-follower sync --network NAME (--relay HOST:PORT | --socket PATH) --db PATH [--from origin|SLOT.HASH] [--blocks N]
```

- `--db`: the database file; created if missing. A database is bound to the
  network and the watch set it was created with and refuses to open with
  others, or with another schema version.
- `--from`: where a new database starts; the first block indexed is the one
  after this point. The default is the network's preset start point
  (`McFollower.WatchSet.startPointPreset`), which precedes every watched
  address and policy. Preview has one; mainnet and preprod have none yet, so
  `--from` is required there. When resuming, the stored start point is used
  and a different `--from` is refused.
- `--blocks N`: stop after applying N blocks (for bounded runs).
- `--relay` may be repeated; without it and without `--socket`, the
  network's bootstrap relays are used.

Restarting resumes from the stored chain: the tip, then blocks 1, 2, 4, 8,
... below it, then the start point. Rollbacks reported by the upstream undo
the affected blocks in one transaction; rollbacks deeper than the security
parameter k are refused. Progress is written to stderr every 10 seconds:

```text
intersecting at 101876757.0dac7367…
connecting to preview-node.play.dev.cardano.org:3001
intersected at 101876757.0dac7367…, upstream tip 128546083/4876786/eb886ef2…
rolled back to 101876757.0dac7367… (0 blocks undone)
synced to slot 102107691 block 3956272 epoch 1181, upstream block 4876786; 7511 blocks, 2987 txs, 6 watched outputs in 10s
synced to slot 102341615 block 3963972 epoch 1184, upstream block 4876787; 7700 blocks, 5237 txs, 34 watched outputs in 10s
```

What is indexed (`McFollower.WatchSet`): every block (hash, number, slot,
epoch, time, transaction count) and transaction (hash, position); every
output at a watched address (mapping validator, council, technical
committee, committee candidates, bridge ICS and reserve) with all its assets;
every output carrying a token of a watched policy (cNIGHT, council, technical
committee, permissioned candidates, bridge token) at any address; spends of
those outputs; the input lists of transactions creating committee-candidate
outputs; every datum db-sync would put in its `datum` table (witness datums of
valid transactions and inline datums of all outputs); and tx metadata under
the bridge label 6500973.

## Fixture tool

`mc-follower fetch-blocks` follows the chain from a point and prints what
each block contains (tags such as `invalid`, `collateral-return`,
`inline-datum`, `witnessed-datum-hash`, `multi-asset`, `byron-address`,
`metadata`, `ebb`). With `--out DIR` it saves blocks as files, optionally only
those with a `--select`ed tag. The fixtures under `test/fixtures` were made
with it:

```sh
mc-follower fetch-blocks --network preview --from SLOT.HASH --blocks 20000 --out DIR --select invalid
```

## Smoke command

`mc-follower follow` connects, follows the chain and prints one line per
event: era, slot, block number, header hash, previous hash, transaction count
and the upstream tip.

Over node-to-node, from the network's bootstrap relays, starting at a
built-in recent block and stopping after 300 blocks:

```sh
cabal run mc-follower -- follow --network preview --blocks 300
```

Other starting points and upstreams:

```sh
# from origin, or from any SLOT.HASH
cabal run mc-follower -- follow --network preview --from origin --blocks 10
cabal run mc-follower -- follow --network preview \
  --from 128531690.290f168381e66d477e93d2ffc33e0706cdfdc6acfc1c7c723fb050fe39998128

# a specific relay (repeat --relay for several)
cabal run mc-follower -- follow --network preprod --relay preprod-node.play.dev.cardano.org:3001

# a local node
cabal run mc-follower -- follow --network preview --socket /path/to/node.socket
```

Output from a run against preview (one line per event; long lines shortened here):

```text
backward point=128531690.290f1683…98128 tip=128543485/4876668/b213fcb0…ea5b5
forward era=Conway slot=128531700 block=4876201 hash=36ed55b6…a1ebe prev=290f1683…98128 txs=1 tip=128543485/4876668/b213fcb0…ea5b5
forward era=Conway slot=128531743 block=4876202 hash=898d9acc…758bf prev=36ed55b6…a1ebe txs=2 tip=128543485/4876668/b213fcb0…ea5b5
```

Every run starts with a `backward` line for the intersection that was found.
Connection progress and disconnects are written to stderr.

`mc-follower system-start` runs a local state query against a node socket:

```sh
cabal run mc-follower -- system-start --network preview --socket /path/to/node.socket --at immutable
```
