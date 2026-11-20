-- | Command-line entry point. For now only smoke tools for the block
-- source: follow the chain and print one line per event, and query a local
-- node's system start.
module Main (main) where

import Cardano.Slotting.Block (BlockNo (..))
import Cardano.Slotting.Slot (SlotNo (..))
import Cardano.Slotting.Time (SystemStart (..))
import Control.Exception (Exception, throwIO, try)
import Control.Monad (when)
import Control.Tracer (Tracer (..), emit)
import Data.IORef (atomicModifyIORef', newIORef)
import Data.List.NonEmpty (nonEmpty)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import Data.Void (absurd)
import McFollower.Block
  ( Block
  , blockEra
  , blockTxCount
  , parsePoint
  , renderChainHash
  , renderHash
  , renderPoint
  , renderTip
  )
import McFollower.BlockSource
  ( BlockEvent
  , BlockSource (..)
  , BlockSourceTrace (..)
  , ChainEvent (..)
  )
import McFollower.BlockSource.N2C (LocalNodeConfig (..), n2cBlockSource)
import McFollower.BlockSource.N2N (n2nBlockSource)
import McFollower.LocalStateQuery (QueryTarget (..), querySystemStart)
import McFollower.Network
  ( NetworkConfig (..)
  , NetworkName (..)
  , RelayAddress
  , networkConfig
  , parseNetworkName
  , parseRelayAddress
  )
import Options.Applicative
import Ouroboros.Consensus.Block (Point, blockHash, blockNo, blockPrevHash, blockSlot)
import System.Exit (exitFailure)
import System.IO (BufferMode (..), hPutStrLn, hSetBuffering, stderr, stdout)

data Command
  = Follow !FollowOptions
  | SystemStartQuery !QueryOptions

data Upstream
  = Relays ![RelayAddress]
  -- ^ Node-to-node; the network's bootstrap relays if empty.
  | LocalSocket !FilePath

data StartFrom = FromRecent | FromPoint !(Point Block)

data FollowOptions = FollowOptions
  { foNetwork :: !NetworkName
  , foUpstream :: !Upstream
  , foStart :: !StartFrom
  , foLimit :: !(Maybe Int)
  }

data QueryOptions = QueryOptions
  { qoNetwork :: !NetworkName
  , qoSocket :: !FilePath
  , qoTarget :: !QueryTarget
  }

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  cmd <- execParser (info (commandParser <**> helper) (fullDesc <> progDesc "Cardano indexer for Midnight"))
  case cmd of
    Follow opts -> follow opts
    SystemStartQuery opts -> systemStart opts

data LimitReached = LimitReached
  deriving stock (Show)

instance Exception LimitReached

follow :: FollowOptions -> IO ()
follow FollowOptions {foNetwork, foUpstream, foStart, foLimit} = do
  let cfg = networkConfig foNetwork
      source = case foUpstream of
        Relays relays -> n2nBlockSource traceToStderr cfg (fromMaybe (ncRelays cfg) (nonEmpty relays))
        LocalSocket path -> n2cBlockSource traceToStderr (LocalNodeConfig cfg path)
      start = case foStart of
        FromRecent -> [ncRecentPoint cfg]
        FromPoint p -> [p]
  forwards <- newIORef (0 :: Int)
  let handler ev = do
        Text.putStrLn (renderEvent ev)
        case ev of
          RollForward {} -> do
            n <- atomicModifyIORef' forwards (\n -> (n + 1, n + 1))
            when (Just n == foLimit) (throwIO LimitReached)
          RollBackward {} -> pure ()
  try (runBlockSource source start handler) >>= \case
    Left LimitReached -> pure ()
    Right v -> absurd v

systemStart :: QueryOptions -> IO ()
systemStart QueryOptions {qoNetwork, qoSocket, qoTarget} =
  querySystemStart (LocalNodeConfig (networkConfig qoNetwork) qoSocket) qoTarget >>= \case
    Left e -> hPutStrLn stderr (show e) >> exitFailure
    Right (SystemStart t) -> print t

renderEvent :: BlockEvent -> Text
renderEvent = \case
  RollForward blk tip ->
    Text.unwords
      [ "forward"
      , "era=" <> showText (blockEra blk)
      , "slot=" <> showText (unSlotNo (blockSlot blk))
      , "block=" <> showText (unBlockNo (blockNo blk))
      , "hash=" <> renderHash (blockHash blk)
      , "prev=" <> renderChainHash (blockPrevHash blk)
      , "txs=" <> showText (blockTxCount blk)
      , "tip=" <> renderTip tip
      ]
  RollBackward p tip ->
    Text.unwords ["backward", "point=" <> renderPoint p, "tip=" <> renderTip tip]

traceToStderr :: Tracer IO BlockSourceTrace
traceToStderr = Tracer (emit (hPutStrLn stderr . Text.unpack . renderTrace))

renderTrace :: BlockSourceTrace -> Text
renderTrace = \case
  TraceConnecting upstream -> "connecting to " <> upstream
  TraceIntersectFound p tip -> "intersected at " <> renderPoint p <> ", upstream tip " <> renderTip tip
  TraceNoBlocks from to ->
    "relay has no blocks for " <> renderPoint from <> " .. " <> renderPoint to <> ", waiting for rollback"
  TraceDisconnected e -> "disconnected: " <> showText e <> "; reconnecting"

showText :: Show a => a -> Text
showText = Text.pack . show

commandParser :: Parser Command
commandParser =
  hsubparser $
    command "follow" (info (Follow <$> followOptions) (progDesc "Follow the chain and print one line per event"))
      <> command
        "system-start"
        (info (SystemStartQuery <$> queryOptions) (progDesc "Query a local node's system start"))

followOptions :: Parser FollowOptions
followOptions =
  FollowOptions
    <$> networkOption
    <*> upstreamOption
    <*> startOption
    <*> optional
      (option auto (long "blocks" <> metavar "N" <> help "Stop after N blocks"))

queryOptions :: Parser QueryOptions
queryOptions =
  QueryOptions
    <$> networkOption
    <*> socketOption
    <*> option
      (eitherReader parseTarget)
      ( long "at"
          <> metavar "immutable|volatile|SLOT.HASH"
          <> value AtVolatileTip
          <> help "Ledger state to query (default: volatile)"
      )
 where
  parseTarget = \case
    "immutable" -> Right AtImmutableTip
    "volatile" -> Right AtVolatileTip
    s -> AtPoint <$> parsePoint (Text.pack s)

networkOption :: Parser NetworkName
networkOption =
  option
    (eitherReader (parseNetworkName . Text.pack))
    (long "network" <> metavar "mainnet|preprod|preview" <> help "Network to follow")

socketOption :: Parser FilePath
socketOption = strOption (long "socket" <> metavar "PATH" <> help "cardano-node socket")

upstreamOption :: Parser Upstream
upstreamOption =
  LocalSocket <$> socketOption
    <|> Relays
      <$> many
        ( option
            (eitherReader (parseRelayAddress . Text.pack))
            ( long "relay"
                <> metavar "HOST:PORT"
                <> help "Relay to follow over node-to-node; repeatable (default: the network's bootstrap relays)"
            )
        )

startOption :: Parser StartFrom
startOption =
  option
    (eitherReader parseStart)
    ( long "from"
        <> metavar "origin|recent|SLOT.HASH"
        <> value FromRecent
        <> help "Where to start (default: recent, a built-in recent block)"
    )
 where
  parseStart = \case
    "recent" -> Right FromRecent
    s -> FromPoint <$> parsePoint (Text.pack s)
