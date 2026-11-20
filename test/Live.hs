-- | Checks against the live preview network and public services. They
-- need network access and only run with @MC_FOLLOWER_LIVE=1@:
--
-- * the nonce driver, from a trusted state built from public data, over
--   node-to-node from a preview relay up to the current tip; every epoch
--   nonce it produces is compared with Koios @epoch_params.nonce@, and its
--   final state with the node state Ogmios reports (through Koios) at
--   that tip;
-- * a Mithril Cardano stake distribution, whose total is compared with
--   Koios @epoch_info.active_stake@ of the epoch it is mapped to.
--
-- Koios requests are spaced out; nothing here needs an API key.
module Main (main) where

import Cardano.Ledger.BaseTypes (Nonce (..))
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Slotting.Slot (EpochNo (..), WithOrigin (..))
import Control.Concurrent (threadDelay)
import Control.Exception (Exception, throwIO, try)
import Control.Monad (forM, unless, when)
import Control.Tracer (nullTracer)
import Data.Aeson (FromJSON (..), Value, withObject, (.:))
import Data.Aeson qualified as Aeson
import Data.Aeson.Types (parseEither)
import Data.ByteString.Base16 qualified as Base16
import Data.ByteString.Char8 qualified as BS8
import Data.IORef (modifyIORef', newIORef, readIORef, writeIORef)
import Data.List (intercalate)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Void (absurd)
import McFollower.Block (Block, parsePoint, renderPoint)
import McFollower.BlockSource (BlockSource (..), ChainEvent (..))
import McFollower.BlockSource.N2N (n2nBlockSource)
import McFollower.EpochData.Mithril
import McFollower.EpochData.Stake (EpochStake (..))
import McFollower.EraHistory (chainParams)
import McFollower.Network (NetworkConfig (..), NetworkName (..), networkConfig)
import McFollower.Nonce
import McFollower.Nonce.TrustedState (TrustedState (..))
import Network.HTTP.Client
  ( Manager
  , RequestBody (..)
  , Response (..)
  , httpLbs
  , method
  , parseRequest
  , requestBody
  , requestHeaders
  )
import Ouroboros.Consensus.Block (Point, blockPoint, blockSlot, getHeader, pointSlot)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import System.Environment (lookupEnv)
import Test.McFollower.Fixtures
  ( hexNonce
  , loadOgmiosCapture
  , ogmiosTrustedState
  )
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit (assertFailure, testCaseInfo, (@?=))

main :: IO ()
main = do
  live <- lookupEnv "MC_FOLLOWER_LIVE"
  if live == Just "1"
    then do
      manager <- newMithrilManager
      defaultMain (tests manager)
    else putStrLn "live checks skipped: set MC_FOLLOWER_LIVE=1 to run them"

tests :: Manager -> TestTree
tests manager =
  testGroup
    "live (preview)"
    [ testCaseInfo "nonce driver from the Ogmios-derived state at 128544245" $
        nonceCheck manager "test/data/preview-ogmios-128544245.json"
    , testCaseInfo "Mithril stake distribution total equals Koios active stake" $
        mithrilCheck manager
    ]

-- * Koios

koios :: Text
koios = "https://preview.koios.rest/api/v1"

koiosGet :: FromJSON a => Manager -> Text -> IO a
koiosGet manager path = do
  threadDelay 1_500_000
  request <- parseRequest (Text.unpack (koios <> path))
  response <- httpLbs request manager
  either fail pure (Aeson.eitherDecode (responseBody response))

ogmios :: Manager -> Text -> IO Value
ogmios manager rpc = do
  threadDelay 1_500_000
  request <- parseRequest (Text.unpack (koios <> "/ogmios"))
  response <-
    httpLbs
      request
        { method = "POST"
        , requestHeaders = [("content-type", "application/json")]
        , requestBody = RequestBodyLBS (Aeson.encode (Aeson.object ["jsonrpc" Aeson..= ("2.0" :: Text), "method" Aeson..= rpc]))
        }
      manager
  either fail pure (Aeson.eitherDecode (responseBody response) >>= parseEither (withObject "rpc" (.: "result")))

newtype EpochParams = EpochParams Text

instance FromJSON EpochParams where
  parseJSON = withObject "epoch_params" $ \o -> EpochParams <$> o .: "nonce"

koiosEpochNonce :: Manager -> EpochNo -> IO Nonce
koiosEpochNonce manager (EpochNo e) = do
  rows <- koiosGet manager ("/epoch_params?_epoch_no=" <> showText e <> "&select=nonce")
  case rows of
    [EpochParams t] -> either fail pure (hexNonce t)
    _ -> fail ("Koios has no epoch_params for epoch " <> show e)

-- | The node state Ogmios reports at its tip, with the tip: tip, nonces
-- and tip again, retried until both tips agree.
nodeStateAtTip :: Manager -> IO (Point Block, Value)
nodeStateAtTip manager = go (5 :: Int)
 where
  go 0 = fail "Ogmios tip kept moving"
  go n = do
    t1 <- ogmios manager "queryNetwork/tip"
    nonces <- ogmios manager "queryLedgerState/nonces"
    t2 <- ogmios manager "queryNetwork/tip"
    if t1 == t2
      then (,nonces) <$> either fail pure (parseEither tipPoint t1)
      else go (n - 1)
  tipPoint = withObject "tip" $ \o -> do
    slot <- o .: "slot"
    hash <- o .: "id"
    either fail pure (parsePoint (showText (slot :: Integer) <> "." <> hash))

-- * Nonce

data Stop = Reached | Overshot !(Point Block)
  deriving stock (Show)

instance Exception Stop

newtype DriverFailed = DriverFailed NonceError
  deriving stock (Show)

instance Exception DriverFailed

nonceCheck :: Manager -> FilePath -> IO String
nonceCheck manager capturePath = do
  capture <- loadOgmiosCapture capturePath
  let trusted = ogmiosTrustedState capture
      driver0 = startDriver (nonceConfig (chainParams Preview)) trusted
  -- The starting state's own epoch nonce must already agree with Koios.
  EpochNonce startEpoch startNonce <- either (assertFailure . show) pure (currentEpochNonce driver0)
  koiosStart <- koiosEpochNonce manager startEpoch
  startNonce @?= koiosStart

  (target, nodeNonces) <- nodeStateAtTip manager
  driverVar <- newIORef driver0
  producedVar <- newIORef []
  let cfg = networkConfig Preview
      source = n2nBlockSource nullTracer cfg (ncRelays cfg)
      targetSlot = pointSlot target
      handler = \case
        RollBackward p _ -> do
          d <- readIORef driverVar
          either (throwIO . DriverFailed) (writeIORef driverVar . fst) (rollBackTo p d)
        RollForward blk _ -> do
          when (At (blockSlot blk) > targetSlot) $ throwIO (Overshot target)
          d <- readIORef driverVar
          case applyHeader (getHeader blk) d of
            Left e -> throwIO (DriverFailed e)
            Right (d', cp) -> do
              writeIORef driverVar d'
              mapM_ (\en -> modifyIORef' producedVar (<> [en])) (cpNewEpochNonce cp)
              when (blockPoint blk == target) (throwIO Reached)
  try (runBlockSource source [tsPoint trusted] handler) >>= \case
    Left Reached -> pure ()
    Left e -> assertFailure (show e)
    Right v -> absurd v

  driver <- readIORef driverVar
  produced <- readIORef producedVar
  comparisons <- forM produced $ \(EpochNonce e n) -> do
    k <- koiosEpochNonce manager e
    pure (e, n, k)
  let mismatches = [c | c@(_, n, k) <- comparisons, n /= k]
  unless (null mismatches) $ assertFailure ("epoch nonces differ from Koios: " <> show mismatches)

  -- The node's state at the target, from Ogmios plus the two fields it
  -- does not report.
  nodeState <- nodeStateFromOgmios manager target nodeNonces (cpState (driverTip driver))
  let check = crossCheck target nodeState driver
  check @?= Agree target

  pure . intercalate "\n" $
    [ "start " <> Text.unpack (renderPoint (tsPoint trusted)) <> ", epoch " <> show (unEpochNo startEpoch) <> " nonce " <> showNonce startNonce <> " = Koios"
    ]
      <> [ "epoch " <> show (unEpochNo e) <> ": driver " <> showNonce n <> ", Koios " <> showNonce k
         | (e, n, k) <- comparisons
         ]
      <> [ "target " <> Text.unpack (renderPoint target) <> ": evolving, candidate, epoch, last-epoch-block and lab nonces equal the node's (Ogmios); "
            <> show (length (driverCheckpoints driver))
            <> " checkpoints kept"
         ]

-- | Ogmios reports four of the nonces. The lab nonce is the target
-- block's previous hash and the previous epoch nonce is Koios' nonce of
-- the epoch before; both are taken from public data as well.
nodeStateFromOgmios :: Manager -> Point Block -> Value -> PraosState -> IO PraosState
nodeStateFromOgmios manager target nonces ours = do
  let field name = either fail pure (parseEither (withObject "nonces" (.: name)) nonces >>= hexNonce)
  evolving <- field "evolvingNonce"
  candidate <- field "candidateNonce"
  epochNonce <- field "epochNonce"
  lastEpochBlock <- field "lastEpochLastAncestor"
  parent <- blockParent manager target
  -- The previous epoch nonce is not checked: take the driver's.
  pure
    ours
      { praosStateLastSlot = pointSlot target
      , praosStateEvolvingNonce = evolving
      , praosStateCandidateNonce = candidate
      , praosStateEpochNonce = epochNonce
      , praosStateLabNonce = parent
      , praosStateLastEpochBlockNonce = lastEpochBlock
      }

newtype BlockInfo = BlockInfo Text

instance FromJSON BlockInfo where
  parseJSON = withObject "block_info" $ \o -> BlockInfo <$> o .: "parent_hash"

blockParent :: Manager -> Point Block -> IO Nonce
blockParent manager target = do
  let hash = case Text.splitOn "." (renderPoint target) of
        [_, h] -> h
        _ -> error "point without hash"
  threadDelay 1_500_000
  request <- parseRequest (Text.unpack (koios <> "/block_info"))
  response <-
    httpLbs
      request
        { method = "POST"
        , requestHeaders = [("content-type", "application/json")]
        , requestBody = RequestBodyLBS (Aeson.encode (Aeson.object ["_block_hashes" Aeson..= [hash]]))
        }
      manager
  case Aeson.eitherDecode (responseBody response) of
    Right [BlockInfo parent] -> either fail pure (hexNonce parent)
    Right _ -> fail "Koios block_info: no such block"
    Left e -> fail e

-- * Mithril

newtype EpochInfo = EpochInfo Text

instance FromJSON EpochInfo where
  parseJSON = withObject "epoch_info" $ \o -> EpochInfo <$> o .: "active_stake"

mithrilCheck :: Manager -> IO String
mithrilCheck manager = do
  let aggregator = aggregatorFor Preview
  entries <- either (assertFailure . show) pure =<< listStakeDistributions manager aggregator
  -- The newest distribution is for the next epoch, which Koios does not
  -- have yet; take the newest one whose epoch Koios knows.
  (label, koiosTotal) <- firstKnown (map mleLabel entries)
  let epoch = stakeEpochOfLabel label
  es <- either (assertFailure . show) pure =<< fetchStakeForEpoch manager aggregator epoch
  esEpoch es @?= epoch
  let Coin total = sum (Map.elems (esPools es))
  total @?= koiosTotal
  pure $
    "Mithril label "
      <> show (unEpochNo label)
      <> " -> stake epoch "
      <> show (unEpochNo epoch)
      <> ": "
      <> show (Map.size (esPools es))
      <> " pools, total "
      <> show total
      <> " = Koios epoch_info.active_stake "
      <> show koiosTotal
 where
  firstKnown = \case
    [] -> assertFailure "Koios knows none of the listed epochs"
    l : ls -> do
      rows <- koiosGet manager ("/epoch_info?_epoch_no=" <> showText (unEpochNo (stakeEpochOfLabel l)))
      case rows of
        [EpochInfo t] -> pure (l, read (Text.unpack t) :: Integer)
        _ -> firstKnown ls

-- * Rendering

showNonce :: Nonce -> String
showNonce = \case
  NeutralNonce -> "neutral"
  n -> maybe "?" (BS8.unpack . Base16.encode) (nonceBytes n)

showText :: Show a => a -> Text
showText = Text.pack . show
