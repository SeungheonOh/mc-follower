#!/usr/bin/env bash
# Regenerate gen/Proto/McFollower*.hs from proto/mc_follower.proto.
#
# Needs protoc and proto-lens-protoc (the version the package set's
# proto-lens-runtime goes with, 0.9.0.1):
#
#   cabal install proto-lens-protoc-0.9.0.1 --installdir=DIR
#   PROTO_LENS_PROTOC=DIR/proto-lens-protoc scripts/gen-proto.sh
#
# The generated modules are committed, as cardano-rpc does, so that building
# mc-follower needs neither tool.
set -euo pipefail

cd "$(dirname "$0")/.."
plugin=${PROTO_LENS_PROTOC:-$(command -v proto-lens-protoc)}

rm -rf gen/Proto
mkdir -p gen
protoc \
  --plugin=protoc-gen-haskell="$plugin" \
  --haskell_out=gen \
  --proto_path=proto \
  proto/mc_follower.proto
