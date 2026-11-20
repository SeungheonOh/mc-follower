-- | Node-to-node block source: an initiator-only connection to a relay that
-- follows its chain with header chain-sync and fetches bodies with plain
-- range block-fetch requests. The relay is trusted; headers are not
-- validated.
--
-- Chain-sync and block-fetch run on separate threads of the same connection.
-- Chain-sync feeds a bounded queue of header events; the block-fetch client
-- drains it, folds rollbacks into the headers it has not fetched yet
-- ("McFollower.BlockSource.N2N.Pending"), fetches the rest in ranges and
-- delivers blocks in chain order.
module McFollower.BlockSource.N2N
  ( n2nBlockSource
  ) where

import Cardano.Network.NodeToNode qualified as NtN
import Control.Concurrent (threadDelay)
import Control.Concurrent.Class.MonadSTM.Strict (newTVarIO)
import Control.Concurrent.STM
  ( TBQueue
  , atomically
  , flushTBQueue
  , newTBQueueIO
  , readTBQueue
  , writeTBQueue
  )
import Control.Exception (throwIO)
import Control.Monad (forever, unless)
import Control.Tracer (Tracer, nullTracer, traceWith)
import Data.ByteString.Lazy qualified as BL
import Data.Foldable (fold, traverse_)
import Data.IORef (modifyIORef', newIORef, readIORef, writeIORef)
import Data.List.NonEmpty (NonEmpty)
import Data.List.NonEmpty qualified as NonEmpty
import Data.Map.Strict qualified as Map
import Data.Proxy (Proxy (..))
import Data.Void (Void, absurd)
import McFollower.Block (Block)
import McFollower.BlockSource
  ( BlockSource
  , BlockSourceError (..)
  , BlockSourceTrace (..)
  , ChainEvent (..)
  , Downstream (..)
  , reconnecting
  )
import McFollower.BlockSource.ChainSync (chainSyncClient)
import McFollower.BlockSource.N2N.Pending (Announced (..))
import McFollower.BlockSource.N2N.Pending qualified as Pending
import McFollower.Network
  ( NetworkConfig (..)
  , RelayAddress (..)
  , codecConfig
  , renderRelayAddress
  )
import Network.Mux qualified as Mx
import Network.Socket qualified as Socket
import Ouroboros.Consensus.Block (Header, Point, blockPoint, headerPoint)
import Ouroboros.Consensus.Network.NodeToNode (Codecs (..), defaultCodecs)
import Ouroboros.Consensus.Node.NetworkProtocolVersion
  ( BlockNodeToNodeVersion
  , SupportedNetworkProtocolVersion (..)
  )
import Ouroboros.Network.Channel (Channel)
import Ouroboros.Network.Context (MinimalInitiatorContext (..))
import Ouroboros.Network.ControlMessage (continueForever)
import Ouroboros.Network.DeltaQ (defaultGSV)
import Ouroboros.Network.Driver (runPeer, runPeerWithLimits, runPipelinedPeer)
import Ouroboros.Network.IOManager (withIOManager)
import Ouroboros.Network.KeepAlive (KeepAliveInterval (..), keepAliveClient)
import Ouroboros.Network.Mux
  ( MiniProtocolCb (..)
  , OuroborosApplication (..)
  , OuroborosApplicationWithMinimalCtx
  , RunMiniProtocol (..)
  , RunMiniProtocolWithMinimalCtx
  )
import Ouroboros.Network.PeerSelection.PeerSharing (PeerSharing (..))
import Ouroboros.Network.PeerSelection.PeerSharing.Codec
  ( decodeRemoteAddress
  , encodeRemoteAddress
  )
import Ouroboros.Network.PerasSupport (PerasSupport (..))
import Ouroboros.Network.Protocol.BlockFetch.Client
  ( BlockFetchClient (..)
  , BlockFetchReceiver (..)
  , BlockFetchRequest (..)
  , BlockFetchResponse (..)
  , blockFetchClientPeer
  )
import Ouroboros.Network.Protocol.BlockFetch.Type (ChainRange (..))
import Ouroboros.Network.Protocol.ChainSync.ClientPipelined
  ( chainSyncClientPeerPipelined
  )
import Ouroboros.Network.Protocol.KeepAlive.Client (keepAliveClientPeer)
import Ouroboros.Network.Protocol.KeepAlive.Codec
  ( byteLimitsKeepAlive
  , timeLimitsKeepAlive
  )
import Ouroboros.Network.Snocket (socketSnocket)
import System.Random (newStdGen)

-- | Follow the chain of one of the given relays, moving on to the next one
-- after each disconnect.
n2nBlockSource
  :: Tracer IO BlockSourceTrace
  -> NetworkConfig
  -> NonEmpty RelayAddress
  -> BlockSource
n2nBlockSource tracer cfg relays = reconnecting tracer $ \attempt points ds ->
  connectOnce tracer cfg (relays NonEmpty.!! (attempt `mod` length relays)) points ds

type HeaderEvent = ChainEvent Block (Header Block)

connectOnce
  :: Tracer IO BlockSourceTrace
  -> NetworkConfig
  -> RelayAddress
  -> [Point Block]
  -> Downstream
  -> IO ()
connectOnce tracer cfg relay points ds = do
  traceWith tracer (TraceConnecting (renderRelayAddress relay))
  addr <- resolve relay
  headers <- newTBQueueIO headerQueueSize
  result <- withIOManager $ \iocp ->
    NtN.connectTo
      (socketSnocket iocp)
      NtN.nullNetworkConnectTracers
      (NtN.foldMapVersions (version headers) offeredVersions)
      Nothing
      (Socket.addrAddress addr)
  case result of
    Left e -> throwIO e
    Right (Left ()) -> throwIO UpstreamClosed
    Right (Right v) -> absurd v
 where
  version
    :: TBQueue HeaderEvent
    -> (NtN.NodeToNodeVersion, BlockNodeToNodeVersion Block)
    -> NtN.Versions
         NtN.NodeToNodeVersion
         NtN.NodeToNodeVersionData
         (OuroborosApplicationWithMinimalCtx Mx.InitiatorMode Socket.SockAddr BL.ByteString IO () Void)
  version headers (v, blockVersion) =
    NtN.simpleSingletonVersions v versionData $ \negotiated ->
      OuroborosApplication . fold $
        NtN.nodeToNodeProtocols
          mempty
          NtN.defaultMiniProtocolParameters
          (protocols headers codecs)
          v
          negotiated
   where
    codecs =
      defaultCodecs
        (codecConfig cfg)
        blockVersion
        encodeRemoteAddress
        (\ver -> decodeRemoteAddress ver)
        v

  versionData =
    NtN.NodeToNodeVersionData
      { NtN.networkMagic = ncMagic cfg
      , NtN.diffusionMode = NtN.InitiatorOnlyDiffusionMode
      , NtN.peerSharing = PeerSharingDisabled
      , NtN.query = False
      , NtN.perasSupport = PerasUnsupported
      }

  protocols headers codecs =
    NtN.NodeToNodeProtocols
      { NtN.chainSyncProtocol = InitiatorProtocolOnly . MiniProtocolCb $ \_ctx channel ->
          runPipelinedPeer nullTracer (cChainSyncCodec codecs) channel $
            chainSyncClientPeerPipelined $
              chainSyncClient tracer (dsAbort ds) points (atomically . writeTBQueue headers)
      , NtN.blockFetchProtocol = InitiatorProtocolOnly . MiniProtocolCb $ \_ctx channel -> do
          client <- blockFetchClient tracer headers ds
          runPeer nullTracer (cBlockFetchCodec codecs) channel (blockFetchClientPeer client)
      , NtN.keepAliveProtocol = InitiatorProtocolOnly . MiniProtocolCb $ \ctx channel ->
          keepAlive codecs (NtN.remoteAddress (micConnectionId ctx)) channel
      , NtN.txSubmissionProtocol = unused
      , NtN.peerSharingProtocol = unused
      , NtN.perasCertDiffusionProtocol = unused
      , NtN.perasVoteDiffusionProtocol = unused
      }

  -- A mini-protocol we never speak. It must not return: the connection
  -- ends as soon as any mini-protocol does.
  unused :: RunMiniProtocolWithMinimalCtx Mx.InitiatorMode Socket.SockAddr BL.ByteString IO () Void
  unused = InitiatorProtocolOnly . MiniProtocolCb $ \_ctx _channel ->
    forever (threadDelay maxBound)

  keepAlive codecs them (channel :: Channel IO BL.ByteString) = do
    rng <- newStdGen
    gsv <- newTVarIO (Map.singleton them defaultGSV)
    runPeerWithLimits
      nullTracer
      (cKeepAliveCodec codecs)
      (byteLimitsKeepAlive (fromIntegral . BL.length))
      timeLimitsKeepAlive
      channel
      $ keepAliveClientPeer
      $ keepAliveClient nullTracer rng (continueForever (Proxy @IO)) them gsv (KeepAliveInterval 10)

-- | Every node-to-node version this library supports, up to the newest one
-- in a released cardano-node. Experimental versions are left out.
offeredVersions :: [(NtN.NodeToNodeVersion, BlockNodeToNodeVersion Block)]
offeredVersions =
  [ vs
  | vs@(v, _) <- Map.toList (supportedNodeToNodeVersions (Proxy @Block))
  , maybe True (v <=) latestReleased
  ]
 where
  latestReleased = fst (latestReleasedNodeVersion (Proxy @Block))

resolve :: RelayAddress -> IO Socket.AddrInfo
resolve RelayAddress {relayHost, relayPort} = do
  let hints = Socket.defaultHints {Socket.addrSocketType = Socket.Stream}
  -- getAddrInfo throws rather than returning an empty list.
  NonEmpty.head <$> Socket.getAddrInfo (Just hints) (Just relayHost) (Just (show relayPort))

-- | The block-fetch side: drains header events, fetches bodies for the
-- headers still on the relay's chain and delivers them in order.
blockFetchClient
  :: Tracer IO BlockSourceTrace
  -> TBQueue HeaderEvent
  -> Downstream
  -> IO (BlockFetchClient Block (Point Block) IO ())
blockFetchClient tracer headers ds = do
  pendingVar <- newIORef Pending.empty
  -- Set after 'MsgNoBlocks': do not retry until chain-sync has news.
  stalledVar <- newIORef False
  let client = BlockFetchClient request

      request = do
        pending <- readIORef pendingVar
        stalled <- readIORef stalledVar
        events <-
          atomically $
            if Pending.null pending || stalled
              then (:) <$> readTBQueue headers <*> flushTBQueue headers
              else flushTBQueue headers
        writeIORef stalledVar False
        let (pending', rollbacks) = Pending.applyEvents headerPoint events pending
        writeIORef pendingVar pending'
        traverse_ (\(p, tip) -> dsDeliver ds (RollBackward p tip)) rollbacks
        case Pending.batch maxBatch pending' of
          Nothing -> request
          Just (range, expected) ->
            pure $ SendMsgRequestRange range (response range expected) client

      -- After 'MsgNoBlocks' the pending headers stay as they are: the
      -- relay switched forks, and chain-sync will roll them back.
      response (ChainRange from to) expected =
        BlockFetchResponse
          { handleStartBatch = pure (receive expected)
          , handleNoBlocks = do
              traceWith tracer (TraceNoBlocks from to)
              writeIORef stalledVar True
          }

      receive expected =
        BlockFetchReceiver
          { handleBlock = \blk -> case expected of
              ann : rest
                | blockPoint blk == annPoint ann -> do
                    modifyIORef' pendingVar Pending.dropOldest
                    dsDeliver ds (RollForward blk (annTip ann))
                    pure (receive rest)
                | otherwise -> throwIO (UnexpectedBlock (Just (annPoint ann)) (blockPoint blk))
              [] -> throwIO (UnexpectedBlock Nothing (blockPoint blk))
          , handleBatchDone =
              unless (null expected) $ throwIO (IncompleteBatch (map annPoint expected))
          }
  pure client

-- | Header events buffered between chain-sync and block-fetch.
headerQueueSize :: Num n => n
headerQueueSize = 1000

-- | Blocks per range request.
maxBatch :: Int
maxBatch = 50
