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

Implemented so far: the block source for both modes and a smoke command that
prints the chain as it is followed. The extractor, SQLite store, nonce
driver, epoch data and gRPC server are still to come.

| Module | Purpose |
|---|---|
| `McFollower.Block` | The `CardanoBlock StandardCrypto` type, per-era projections, point and hash rendering |
| `McFollower.Network` | Network parameters and the mainnet, preprod and preview presets |
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
cabal update
cabal build all
cabal test
```

The first build compiles the whole Cardano dependency tree and takes a while.

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

## Epoch nonce and epoch data

| Module | Purpose |
|---|---|
| `McFollower.EraHistory` | Per-network chain constants and past hard forks, the `History.Summary`-based epoch info, the Praos configuration per era |
| `McFollower.Nonce` | The epoch nonce driver: `tickChainDepState` and `reupdateChainDepState` over headers, rollback window, cross-check against a node |
| `McFollower.Nonce.TrustedState` | The trusted starting `PraosState` and its point, in the node's own CBOR |
| `McFollower.EpochData.Stake` | Per-pool stake per epoch from mark/set/go snapshots, completeness |
| `McFollower.EpochData.Mithril` | Cardano stake distributions from a Mithril aggregator |
| `McFollower.EpochData.MaxTxSize` | `maxTxSize` table per network and the tripwire on proposals that change it |
| `McFollower.EpochData.Store` | The storage-facing interface for all of the above, and an in-memory store |

The nonce driver supports Praos eras only (Babbage onward) and starts from a
trusted protocol state, given as JSON:

```json
{ "point": "SLOT.HASH", "praos_state_cbor": "<hex of the node's PraosState encoding>" }
```

The CBOR is what a node returns for `DebugChainDepState` in a Praos era
(`cardano-cli query protocol-state --out-file`); in node-to-client mode
`McFollower.LocalStateQuery.queryEpochData` reads it directly.

Live checks against preview (a relay, Koios and the Mithril aggregator) are a
separate test suite that only runs on request:

```sh
cabal build mc-follower-live
MC_FOLLOWER_LIVE=1 $(cabal list-bin mc-follower-live)
```
