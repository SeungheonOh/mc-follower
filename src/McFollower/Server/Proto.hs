{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | The gRPC service of @proto/mc_follower.proto@ for grapesy: the
-- proto-lens messages (generated into "Proto.McFollower" by
-- @scripts/gen-proto.sh@), one type per RPC, and the (empty) metadata of
-- every call.
module McFollower.Server.Proto
  ( -- * Service and messages
    module Proto.McFollower

    -- * RPCs
  , GetStatus
  , GetLatestBlock
  , GetBlocksByNumberRange
  , GetHighestBlockInWindow
  , GetBlockByHash
  , GetTxPosition
  , GetBridgeTxs
  , GetLatestBlockForEpoch
  , GetLatestStableEpoch
  , GetStakeDistribution
  , GetLatestTokenOutputForEpoch
  , GetEpochNonce
  , GetUnspentOutputsAtAddress
  , GetMappingRegistrations
  , GetMappingDeregistrations
  , GetAssetCreates
  , GetAssetSpends
  , GetMaxTxSize
  , GetLatestGovernanceOutput
  ) where

import Network.GRPC.Common (NoMetadata, RequestMetadata, ResponseInitialMetadata, ResponseTrailingMetadata)
import Network.GRPC.Common.Protobuf (Protobuf)
import Proto.McFollower

type GetStatus = Protobuf McFollower "getStatus"
type GetLatestBlock = Protobuf McFollower "getLatestBlock"
type GetBlocksByNumberRange = Protobuf McFollower "getBlocksByNumberRange"
type GetHighestBlockInWindow = Protobuf McFollower "getHighestBlockInWindow"
type GetBlockByHash = Protobuf McFollower "getBlockByHash"
type GetTxPosition = Protobuf McFollower "getTxPosition"
type GetBridgeTxs = Protobuf McFollower "getBridgeTxs"
type GetLatestBlockForEpoch = Protobuf McFollower "getLatestBlockForEpoch"
type GetLatestStableEpoch = Protobuf McFollower "getLatestStableEpoch"
type GetStakeDistribution = Protobuf McFollower "getStakeDistribution"
type GetLatestTokenOutputForEpoch = Protobuf McFollower "getLatestTokenOutputForEpoch"
type GetEpochNonce = Protobuf McFollower "getEpochNonce"
type GetUnspentOutputsAtAddress = Protobuf McFollower "getUnspentOutputsAtAddress"
type GetMappingRegistrations = Protobuf McFollower "getMappingRegistrations"
type GetMappingDeregistrations = Protobuf McFollower "getMappingDeregistrations"
type GetAssetCreates = Protobuf McFollower "getAssetCreates"
type GetAssetSpends = Protobuf McFollower "getAssetSpends"
type GetMaxTxSize = Protobuf McFollower "getMaxTxSize"
type GetLatestGovernanceOutput = Protobuf McFollower "getLatestGovernanceOutput"

type instance RequestMetadata (Protobuf McFollower meth) = NoMetadata
type instance ResponseInitialMetadata (Protobuf McFollower meth) = NoMetadata
type instance ResponseTrailingMetadata (Protobuf McFollower meth) = NoMetadata
