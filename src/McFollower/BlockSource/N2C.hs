-- | Node-to-client block source: local chain-sync over a cardano-node unix
-- socket, which delivers full blocks. Uses cardano-api's connection setup
-- and converts its types back to the consensus ones at the edge.
module McFollower.BlockSource.N2C
  ( LocalNodeConfig (..)
  , localNodeConnectInfo
  , n2cBlockSource
  ) where

import Cardano.Api
  ( BlockInMode
  , ChainPoint
  , ChainTip (..)
  , ConsensusModeParams (..)
  , File (..)
  , Hash (HeaderHash)
  , LocalChainSyncClient (..)
  , LocalNodeClientProtocols (..)
  , LocalNodeConnectInfo (..)
  , connectToLocalNode
  , fromConsensusPointHF
  , toConsensusBlock
  , toConsensusPointHF
  )
import Control.Exception (throwIO)
import Control.Tracer (Tracer, traceWith)
import Data.Text qualified as Text
import McFollower.Block (Block)
import McFollower.BlockSource
  ( BlockSource
  , BlockSourceError (..)
  , BlockSourceTrace (..)
  , Downstream (..)
  , reconnecting
  )
import McFollower.BlockSource.ChainSync (chainSyncClient)
import McFollower.EraHistory (byronEpochSlots)
import McFollower.Network (NetworkConfig (..), networkId)
import Ouroboros.Consensus.HardFork.Combinator (OneEraHash (..))
import Ouroboros.Network.Block (Point, Tip (..))
import Ouroboros.Network.Protocol.ChainSync.ClientPipelined
  ( ChainSyncClientPipelined
  , mapChainSyncClientPipelined
  )

data LocalNodeConfig = LocalNodeConfig
  { lncNetwork :: !NetworkConfig
  , lncSocketPath :: !FilePath
  }
  deriving stock (Show)

localNodeConnectInfo :: LocalNodeConfig -> LocalNodeConnectInfo
localNodeConnectInfo LocalNodeConfig {lncNetwork, lncSocketPath} =
  LocalNodeConnectInfo
    { localConsensusModeParams = CardanoModeParams (byronEpochSlots (ncChain lncNetwork))
    , localNodeNetworkId = networkId lncNetwork
    , localNodeSocketPath = File lncSocketPath
    }

-- | Follow the local node's chain, reconnecting if the node goes away.
n2cBlockSource :: Tracer IO BlockSourceTrace -> LocalNodeConfig -> BlockSource
n2cBlockSource tracer cfg = reconnecting tracer $ \_attempt points ds -> do
  traceWith tracer (TraceConnecting (Text.pack (lncSocketPath cfg)))
  connectToLocalNode
    (localNodeConnectInfo cfg)
    LocalNodeClientProtocols
      { localChainSyncClient =
          LocalChainSyncClientPipelined (inApiTypes (chainSyncClient tracer (dsAbort ds) points (dsDeliver ds)))
      , localTxSubmissionClient = Nothing
      , localStateQueryClient = Nothing
      , localTxMonitoringClient = Nothing
      }
  throwIO UpstreamClosed

inApiTypes
  :: ChainSyncClientPipelined Block (Point Block) (Tip Block) IO a
  -> ChainSyncClientPipelined BlockInMode ChainPoint ChainTip IO a
inApiTypes =
  mapChainSyncClientPipelined fromConsensusPointHF toConsensusPointHF toConsensusBlock fromChainTip

fromChainTip :: ChainTip -> Tip Block
fromChainTip = \case
  ChainTipAtGenesis -> TipGenesis
  ChainTip slot (HeaderHash h) bno -> Tip slot (OneEraHash h) bno
