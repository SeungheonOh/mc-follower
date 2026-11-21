-- | The sync loop with the nonce driver and the tripwire on recorded
-- preview blocks, against an SQLite store: rollbacks across an epoch
-- boundary, restarts, a disagreeing nonce table, a driver that starts
-- after the indexer; and the serving decisions for the epoch data calls.
module Test.McFollower.EpochSync (tests) where

import Cardano.Crypto.Hash (hashFromBytes, hashToBytes)
import Cardano.Ledger.BaseTypes (Nonce (..), mkNonceFromNumber, (⭒))
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Keys (KeyHash (..))
import Cardano.Slotting.Slot (EpochNo (..), SlotNo (..), WithOrigin (..))
import Control.Exception (Exception, bracket, throwIO, try)
import Control.Tracer (nullTracer)
import Data.ByteString qualified as BS
import Data.IORef (IORef, newIORef, readIORef)
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.Set qualified as Set
import Data.Text (Text)
import Data.Text qualified as Text
import McFollower.Block (Block, parsePoint)
import McFollower.BlockSource (BlockEvent, BlockSource (..), ChainEvent (..))
import McFollower.EpochData.Driver
import Cardano.Ledger.Conway.Governance (Vote (..))
import McFollower.EpochData.MaxTxSize (CommitteeVote (..), MaxTxSizeSighting (..), MaxTxSizeTable (..), maxTxSizePreset, parseProposalRef)
import McFollower.EpochData.Serve
import McFollower.EpochData.Store (EpochDataError (..), EpochDataStore (..))
import McFollower.EpochNonceTable (NonceConflict (..), NonceTable (..), nonceTable)
import McFollower.EraHistory (presetHistory)
import McFollower.Network (NetworkName (..), chainParams)
import McFollower.Nonce (Checkpoint (..), EpochNonce (..), driverCheckpoints, nonceConfig)
import McFollower.Nonce.TrustedState (TrustedState (..))
import McFollower.Store
import McFollower.Store.Sql (SQLData)
import McFollower.Sync (SyncConfig (..), SyncEpochData (..), SyncStopped (..), runSync)
import McFollower.WatchSet (renderWatchConfig, watchFilter, watchPreset)
import Ouroboros.Consensus.Block (Point (..), blockPoint, blockPrevHash, blockSlot)
import Ouroboros.Consensus.Protocol.Praos (PraosState (..))
import Ouroboros.Network.Block (ChainHash (..), Tip (..))
import System.FilePath ((</>))
import System.IO.Temp (withSystemTempDirectory)
import Test.McFollower.Chain (dumpTables)
import Test.McFollower.Fixtures (boundaryBlocksFile, loadBlocks, proposalBlockFile)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, assertFailure, testCase, (@?=))

import Ouroboros.Consensus.Cardano.Node ()

tests :: TestTree
tests =
  testGroup
    "EpochSync"
    [ testGroup
        "sync loop with the nonce driver"
        [ testCase "rollback across an epoch boundary restores nonce, checkpoints and sightings exactly" rollbackAcrossBoundary
        , testCase "restart mid-epoch: the driver continues as an uninterrupted run" restartMidEpoch
        , testCase "a nonce that disagrees with the shipped table stops the sync; the block is not stored" tableConflict
        , testCase "a proposal changing maxTxSize is recorded with its block and goes with it" sightingsFollowBlocks
        ]
    , testGroup
        "driver starting later than the indexer"
        [ testCase "pending until the sync reaches the trusted point, then as if started there" startsLater
        , testCase "a trusted point the sync skipped over is an error" notOnChain
        , testCase "a trusted point at or before the index tip is refused at startup" refusedAtStartup
        , testCase "without a trusted state the driver stays off" withoutTrustedState
        ]
    , testGroup "serving decisions" servingTests
    ]

{-------------------------------------------------------------------------------
  Running the sync loop over recorded blocks
-------------------------------------------------------------------------------}

-- | The block before the recorded boundary blocks: preview 4874014, epoch
-- 1486. The last three recorded blocks are the first of epoch 1487.
parentPoint :: Point Block
parentPoint = either error id (parsePoint "128476714.539b4c8771ada4e6bdce51a84e87d196bba256c0b39d236d1a8f5acfc67b6f66")

-- | A made-up trusted state at 'parentPoint' (as in "Test.McFollower.Nonce":
-- the driver does not validate headers, so any nonces will do).
trustedAtParent :: TrustedState
trustedAtParent =
  TrustedState
    parentPoint
    PraosState
      { praosStateLastSlot = At (SlotNo 128476714)
      , praosStateOCertCounters = Map.empty
      , praosStateEvolvingNonce = mkNonceFromNumber 1
      , praosStateCandidateNonce = mkNonceFromNumber 2
      , praosStateEpochNonce = mkNonceFromNumber 3
      , praosStatePreviousEpochNonce = mkNonceFromNumber 4
      , praosStateLabNonce = mkNonceFromNumber 5
      , praosStateLastEpochBlockNonce = mkNonceFromNumber 6
      }

-- | What the driver computes for epoch 1487 from 'trustedAtParent'.
nonce1487 :: Nonce
nonce1487 = mkNonceFromNumber 2 ⭒ mkNonceFromNumber 6

data Stop = Stop
  deriving stock (Show)

instance Exception Stop

identity :: StoreIdentity
identity =
  StoreIdentity
    { siNetworkMagic = 2
    , siWatchSet = renderWatchConfig (watchPreset Preview)
    , siSecurityParam = 432
    }

-- | A source that delivers the events, then stops the loop.
eventsSource :: [BlockEvent] -> BlockSource
eventsSource events = BlockSource $ \_ handler -> mapM_ handler events >> throwIO Stop

forward :: Block -> BlockEvent
forward b = RollForward b TipGenesis

backward :: Point Block -> BlockEvent
backward p = RollBackward p TipGenesis

-- | Run the sync loop over events (the first should be the rollback to the
-- intersection a real source starts with).
syncEvents :: NonceTable -> Store -> IORef DriverState -> [BlockEvent] -> IO (Either SyncStopped ())
syncEvents table store driverVar events = do
  wf <- either fail pure (watchFilter (watchPreset Preview))
  let cfg =
        SyncConfig
          { scWatchFilter = wf
          , scEraHistory = presetHistory (chainParams Preview)
          , scStopAfter = Nothing
          , scProgressEvery = 1000000
          , scOnUpstreamTip = \_ -> pure ()
          , scEpochData =
              SyncEpochData
                { sedNonceConfig = nonceConfig (chainParams Preview)
                , sedNonceTable = table
                , sedDriver = driverVar
                }
          }
  try (try (runSync nullTracer cfg (eventsSource events) store)) >>= \case
    Left (e :: SyncStopped) -> pure (Left e)
    Right (Left Stop) -> pure (Right ())
    Right (Right ()) -> pure (Right ())

synced :: Either SyncStopped () -> IO ()
synced = either (assertFailure . show) pure

withStoreAt :: Point Block -> (FilePath -> Store -> IO a) -> IO a
withStoreAt start use = withSystemTempDirectory "mc-follower-epoch" $ \dir -> do
  let path = dir </> "index.db"
  bracket (openStore path identity) closeStore $ \store -> do
    setStartPoint store start
    use path store

-- | Start the driver as the indexer does.
startWith :: Store -> Maybe TrustedState -> IO (IORef DriverState)
startWith store trusted =
  startDriverState (nonceConfig (chainParams Preview)) noTable store trusted >>= \case
    Left e -> assertFailure (show e)
    Right st -> newIORef st

-- | A table that covers none of the recorded epochs.
noTable :: NonceTable
noTable = NonceTable (EpochNo 0) (EpochNo 0) (Map.singleton (EpochNo 0) (mkNonceFromNumber 0))

epochTables :: Store -> IO [(Text, [[SQLData]])]
epochTables store = filter ((`elem` ["nonce_checkpoint", "epoch_nonce", "max_tx_size_sighting", "committee_vote"]) . fst) <$> dumpTables store

driverState :: IORef DriverState -> IO [Checkpoint]
driverState var =
  readIORef var >>= \case
    DriverActive _ d -> pure (driverCheckpoints d)
    other -> assertFailure ("driver not active: " <> Text.unpack (renderDriverState other))

storedNonce :: Store -> Word -> IO (Maybe Nonce)
storedNonce store e = withEpochData store (\eds -> loadEpochNonce eds (EpochNo (fromIntegral e)))

-- | A run from the parent with the trusted state there, over all blocks.
uninterrupted :: [Block] -> (Store -> IORef DriverState -> IO a) -> IO a
uninterrupted blocks k = withStoreAt parentPoint $ \_ store -> do
  dv <- startWith store (Just trustedAtParent)
  synced =<< syncEvents noTable store dv (backward parentPoint : map forward blocks)
  k store dv

rollbackAcrossBoundary :: IO ()
rollbackAcrossBoundary = do
  blocks <- loadBlocks boundaryBlocksFile
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store (Just trustedAtParent)
    synced =<< syncEvents noTable store dv (backward parentPoint : map forward (take 3 blocks))
    tablesBefore <- epochTables store
    driverBefore <- driverState dv
    synced =<< syncEvents noTable store dv (backward (blockPoint (blocks !! 2)) : map forward (drop 3 blocks))
    -- A sighting in the second block of 1487 (none of the recorded blocks
    -- carries one; "sightingsFollowBlocks" covers the scan).
    let proposal = either error id (parseProposalRef (Text.replicate 64 "c" <> "#1"))
    withEpochData store $ \eds -> storeSightings eds [MaxTxSizeSighting proposal (blockPoint (blocks !! 4)) 16400 (EpochNo 1489)]
    storedNonce store 1487 >>= (@?= Just nonce1487)
    tablesAfter <- epochTables store
    driverAfter <- driverState dv
    length driverAfter @?= 7
    -- Back across the boundary: to the last block of 1486.
    synced =<< syncEvents noTable store dv [backward (blockPoint (blocks !! 2))]
    epochTables store >>= (@?= tablesBefore)
    driverState dv >>= (@?= driverBefore)
    storedNonce store 1487 >>= (@?= Nothing)
    storedNonce store 1486 >>= (@?= Just (mkNonceFromNumber 3))
    withEpochData store loadSightings >>= (@?= [])
    -- And forward again: the same as before, minus the injected sighting.
    synced =<< syncEvents noTable store dv (backward (blockPoint (blocks !! 2)) : map forward (drop 3 blocks))
    driverState dv >>= (@?= driverAfter)
    epochTables store >>= (@?= [(t, if t == "max_tx_size_sighting" then [] else rows) | (t, rows) <- tablesAfter])

restartMidEpoch :: IO ()
restartMidEpoch = do
  blocks <- loadBlocks boundaryBlocksFile
  (tablesA, driverA) <- uninterrupted blocks $ \store dv -> (,) <$> epochTables store <*> driverState dv
  withStoreAt parentPoint $ \path store -> do
    dv <- startWith store (Just trustedAtParent)
    -- Stop after the second block of epoch 1487.
    synced =<< syncEvents noTable store dv (backward parentPoint : map forward (take 5 blocks))
    -- Restart: a new connection, the driver from the stored checkpoints.
    bracket (openStore path identity) closeStore $ \restarted -> do
      dv' <- startWith restarted (Just trustedAtParent)
      readIORef dv' >>= \case
        DriverActive (Just ts) _ -> tsPoint ts @?= parentPoint
        other -> assertFailure ("expected a resumed driver, got " <> Text.unpack (renderDriverState other))
      driverState dv' >>= (@?= take 6 driverA)
      synced =<< syncEvents noTable restarted dv' [backward (blockPoint (blocks !! 4)), forward (blocks !! 5)]
      driverState dv' >>= (@?= driverA)
      epochTables restarted >>= (@?= tablesA)

tableConflict :: IO ()
tableConflict = do
  blocks <- loadBlocks boundaryBlocksFile
  let table = NonceTable (EpochNo 1487) (EpochNo 1487) (Map.singleton (EpochNo 1487) (mkNonceFromNumber 42))
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store (Just trustedAtParent)
    syncEvents table store dv (backward parentPoint : map forward blocks) >>= \case
      Left (EpochDataFailed p (TableConflict c)) -> do
        p @?= blockPoint (blocks !! 3)
        c @?= NonceConflict (EpochNo 1487) (mkNonceFromNumber 42) nonce1487
      other -> assertFailure ("expected a table conflict, got " <> show other)
    tipPoint store >>= (@?= Just (blockPoint (blocks !! 2)))
    storedNonce store 1487 >>= (@?= Nothing)
    map cpPoint <$> driverState dv >>= (@?= parentPoint : map blockPoint (take 3 blocks))

sightingsFollowBlocks :: IO ()
sightingsFollowBlocks = do
  [block] <- loadBlocks proposalBlockFile
  let parent = case blockPrevHash block of
        BlockHash h -> BlockPoint (SlotNo (unSlot (blockSlot block) - 1)) h
        GenesisHash -> error "a block with a parent"
      unSlot (SlotNo s) = s
  withStoreAt parent $ \_ store -> do
    dv <- startWith store Nothing
    synced =<< syncEvents noTable store dv [backward parent, forward block]
    sightings <- withEpochData store loadSightings
    map (\s -> (mssPoint s, mssProposedValue s, mssEarliestEpoch s)) sightings @?= [(blockPoint block, 16400, EpochNo 1352)]
    -- Submission alone does not gate (the block has no committee vote).
    withEpochData store loadCommitteeVotes >>= (@?= [])
    let answer votes e = answerMaxTxSize (maxTxSizePreset Preview) Set.empty sightings votes Nothing (EpochNo e)
    answer [] 1400 @?= Answer (Just 16384)
    -- A committee Yes vote in epoch 1355 gates it from 1357.
    let yes = CommitteeVote (mssProposal (head sightings)) "key:01" VoteYes (blockPoint block) (EpochNo 1355)
    answer [yes] 1356 @?= Answer (Just 16384)
    case answer [yes] 1357 of
      NotAvailable _ -> pure ()
      other -> assertFailure (show other)
    answerMaxTxSize (maxTxSizePreset Preview) (Set.fromList (map mssProposal sightings)) sightings [yes] Nothing (EpochNo 1357)
      @?= Answer (Just 16384)
    synced =<< syncEvents noTable store dv [backward parent]
    withEpochData store loadSightings >>= (@?= [])

{-------------------------------------------------------------------------------
  Driver starting later than the indexer
-------------------------------------------------------------------------------}

-- | The state the uninterrupted run has after the second block, as the
-- trusted state of a driver that starts there.
trustedAtSecond :: [Block] -> [Checkpoint] -> TrustedState
trustedAtSecond blocks driverA = TrustedState (blockPoint (blocks !! 1)) (cpState (driverA !! 2))

startsLater :: IO ()
startsLater = do
  blocks <- loadBlocks boundaryBlocksFile
  (driverA, nonceA) <- uninterrupted blocks $ \store dv -> (,) <$> driverState dv <*> storedNonce store 1487
  let trusted = trustedAtSecond blocks driverA
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store (Just trusted)
    readIORef dv >>= \case
      DriverPending ts -> tsPoint ts @?= blockPoint (blocks !! 1)
      other -> assertFailure (Text.unpack (renderDriverState other))
    -- The first block is indexed without the driver.
    synced =<< syncEvents noTable store dv [backward parentPoint, forward (blocks !! 0)]
    withEpochData store loadCheckpoints >>= (@?= [])
    synced =<< syncEvents noTable store dv (backward (blockPoint (blocks !! 0)) : map forward (drop 1 blocks))
    cps <- driverState dv
    -- From the trusted point on, the same states as the run that started
    -- earlier; the starting checkpoint records the nonce of its epoch.
    map cpState cps @?= map cpState (drop 2 driverA)
    drop 1 cps @?= drop 3 driverA
    cpNewEpochNonce (head cps) @?= Just (EpochNonce (EpochNo 1486) (mkNonceFromNumber 3))
    storedNonce store 1487 >>= (@?= nonceA)
    tablesLater <- epochTables store
    -- A rollback to before the trusted point: pending again, nothing of
    -- the driver left in the store; forward again: the same as before.
    synced =<< syncEvents noTable store dv [backward (blockPoint (blocks !! 0))]
    readIORef dv >>= \case
      DriverPending ts -> tsPoint ts @?= blockPoint (blocks !! 1)
      other -> assertFailure (Text.unpack (renderDriverState other))
    withEpochData store loadCheckpoints >>= (@?= [])
    storedNonce store 1486 >>= (@?= Nothing)
    synced =<< syncEvents noTable store dv (backward (blockPoint (blocks !! 0)) : map forward (drop 1 blocks))
    epochTables store >>= (@?= tablesLater)

notOnChain :: IO ()
notOnChain = do
  blocks <- loadBlocks boundaryBlocksFile
  let SlotNo s1 = blockSlot (blocks !! 1)
      elsewhere = either error id (parsePoint (Text.pack (show (s1 + 1)) <> "." <> Text.replicate 64 "0"))
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store (Just trustedAtParent {tsPoint = elsewhere})
    syncEvents noTable store dv (backward parentPoint : map forward blocks) >>= \case
      Left (EpochDataFailed p (TrustedPointNotOnChain tp seen)) -> do
        (tp, seen, p) @?= (elsewhere, blockPoint (blocks !! 2), blockPoint (blocks !! 2))
      other -> assertFailure ("expected TrustedPointNotOnChain, got " <> show other)
    tipPoint store >>= (@?= Just (blockPoint (blocks !! 1)))

refusedAtStartup :: IO ()
refusedAtStartup = do
  blocks <- loadBlocks boundaryBlocksFile
  driverA <- uninterrupted blocks $ \_ dv -> driverState dv
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store Nothing
    synced =<< syncEvents noTable store dv (backward parentPoint : map forward blocks)
    let start ts = startDriverState (nonceConfig (chainParams Preview)) noTable store (Just ts)
        SlotNo s1 = blockSlot (blocks !! 1)
        at slot = either error id (parsePoint (Text.pack (show slot) <> "." <> Text.replicate 64 "0"))
    start (trustedAtSecond blocks driverA) >>= \case
      Left (TrustedStateAlreadyPassed p tip) -> (p, tip) @?= (blockPoint (blocks !! 1), blockPoint (blocks !! 5))
      other -> assertFailure (either show (Text.unpack . renderDriverState) other)
    start trustedAtParent >>= \case
      Left (TrustedStateAlreadyPassed p _) -> p @?= parentPoint
      other -> assertFailure (either show (Text.unpack . renderDriverState) other)
    start trustedAtParent {tsPoint = at (s1 + 1)} >>= \case
      Left (TrustedStateNotOnChain p _) -> p @?= at (s1 + 1)
      other -> assertFailure (either show (Text.unpack . renderDriverState) other)
    start trustedAtParent {tsPoint = at (100 :: Integer)} >>= \case
      Left (TrustedStateBeforeStart p start') -> (p, start') @?= (at (100 :: Integer), parentPoint)
      other -> assertFailure (either show (Text.unpack . renderDriverState) other)
    -- Nothing was recorded by the refused starts.
    withEpochData store loadCheckpoints >>= (@?= [])

withoutTrustedState :: IO ()
withoutTrustedState = do
  blocks <- loadBlocks boundaryBlocksFile
  withStoreAt parentPoint $ \_ store -> do
    dv <- startWith store Nothing
    synced =<< syncEvents noTable store dv (backward parentPoint : map forward blocks)
    readIORef dv >>= \case
      DriverOff -> pure ()
      other -> assertFailure (Text.unpack (renderDriverState other))
    withEpochData store loadCheckpoints >>= (@?= [])
    storedNonce store 1487 >>= (@?= Nothing)
    -- Served from the shipped table where it has the epoch, unavailable
    -- after it.
    let table = nonceTable Preview
        EpochNo lastShipped = ntLast table
    case answerEpochNonce table Nothing Nothing (EpochNo lastShipped) of
      Answer (Just _) -> pure ()
      other -> assertFailure (show other)
    case answerEpochNonce table Nothing Nothing (EpochNo (lastShipped + 1)) of
      NotAvailable _ -> pure ()
      other -> assertFailure (show other)

{-------------------------------------------------------------------------------
  Serving decisions
-------------------------------------------------------------------------------}

servingTests :: [TestTree]
servingTests =
  [ testCase "epoch nonce" $ do
      let n k = mkNonceFromNumber k
          table = NonceTable (EpochNo 5) (EpochNo 7) (Map.fromList [(EpochNo 5, n 5), (EpochNo 6, NeutralNonce), (EpochNo 7, n 7)])
          bytes (Nonce h) = Just (hashToBytes h)
          bytes NeutralNonce = Nothing
          ask = answerEpochNonce table
      -- Before the table: db-sync has no row.
      ask Nothing Nothing (EpochNo 4) @?= Answer Nothing
      -- The table, with or without (agreeing) driver values.
      ask Nothing Nothing (EpochNo 5) @?= Answer (bytes (n 5))
      ask Nothing (Just (n 7)) (EpochNo 7) @?= Answer (bytes (n 7))
      -- A final neutral nonce: NULL in db-sync.
      ask Nothing Nothing (EpochNo 6) @?= Answer Nothing
      ask Nothing (Just NeutralNonce) (EpochNo 8) @?= Answer Nothing
      -- After the table: the driver's, or not available.
      ask Nothing (Just (n 8)) (EpochNo 8) @?= Answer (bytes (n 8))
      notAvailable (ask Nothing Nothing (EpochNo 8))
      -- A disagreement is never served.
      case ask Nothing (Just (n 99)) (EpochNo 7) of
        Inconsistent _ -> pure ()
        other -> assertFailure (show other)
      -- A diverging driver: its nonces are withheld, the table's are not.
      notAvailable (ask (Just "diverged") (Just (n 8)) (EpochNo 8))
      ask (Just "diverged") Nothing (EpochNo 5) @?= Answer (bytes (n 5))
  , testCase "stake distribution" $ do
      let pool b = KeyHash (fromMaybe (error "28 bytes") (hashFromBytes (BS.replicate 28 b)))
          pools = Map.fromList [(pool 2, Coin 7), (pool 1, Coin 3)]
      answerStake (EpochNo 4) (Just pools) (EpochNo 9) @?= Answer [(BS.replicate 28 1, 3), (BS.replicate 28 2, 7)]
      -- Complete but empty: empty, like db-sync.
      answerStake (EpochNo 4) (Just Map.empty) (EpochNo 9) @?= Answer []
      -- Byron: db-sync has no rows.
      answerStake (EpochNo 4) Nothing (EpochNo 3) @?= Answer []
      -- Expected but not (completely) obtained.
      notAvailable (answerStake (EpochNo 4) Nothing (EpochNo 4))
  , testCase "max tx size" $ do
      let ref = either error id (parseProposalRef (Text.replicate 64 "d" <> "#2"))
          point = either error id (parsePoint ("100." <> Text.replicate 64 "e"))
          sighting = MaxTxSizeSighting ref point 20000 (EpochNo 12)
          yes = CommitteeVote ref "key:01" VoteYes point (EpochNo 10)
          table = MaxTxSizeTable [(EpochNo 4, 16384)]
          ask acks fromNode e = answerMaxTxSize table (Set.fromList acks) [sighting] [yes] fromNode (EpochNo e)
      -- Without a committee vote the proposal does not gate.
      answerMaxTxSize table Set.empty [sighting] [] Nothing (EpochNo 20) @?= Answer (Just 16384)
      ask [] Nothing 11 @?= Answer (Just 16384)
      case ask [] Nothing 12 of
        NotAvailable m -> assertBool (Text.unpack m) ((Text.replicate 64 "d" <> "#2") `Text.isInfixOf` m)
        other -> assertFailure (show other)
      ask [ref] Nothing 12 @?= Answer (Just 16384)
      -- A local node's value is the epoch's value.
      ask [] (Just 16500) 12 @?= Answer (Just 16500)
      -- Not covered by the table (Byron): no epoch_param row in db-sync.
      ask [] Nothing 3 @?= Answer Nothing
  ]
 where
  notAvailable :: Show a => EpochAnswer a -> IO ()
  notAvailable = \case
    NotAvailable _ -> pure ()
    other -> assertFailure ("expected NotAvailable, got " <> show other)
