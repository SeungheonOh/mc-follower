-- | The epoch nonce driver: follows block headers with the consensus
-- library's own Praos state transitions and reports, for every epoch from
-- its starting point onward, the nonce in force during that epoch.
--
-- For each header the driver does what the node does when it adopts a
-- header, minus validation: 'tickChainDepState' to the header's slot (which,
-- at the first block of an epoch, moves the candidate and last-epoch-block
-- nonces into the epoch nonce), then 'reupdateChainDepState' with the
-- header's view (which folds the header's VRF output into the evolving
-- nonce, and into the candidate nonce until the randomness stabilisation
-- window). Both run in the header's era with that era's 'ConsensusConfig'
-- ("McFollower.EraHistory"). Neither needs the ledger: 'tickChainDepState'
-- only consults the epoch info, and 'reupdateChainDepState' does not read
-- the ledger view. The epoch nonce after the tick into epoch @e@ is the
-- nonce db-sync stores as @epoch_param.nonce@ for @e@.
--
-- Scope: Praos eras only (Babbage and later). The trusted starting state
-- must belong to a Babbage-or-later block; a header of a TPraos era (Shelley
-- to Alonzo) or Byron is rejected with 'UnsupportedEra'. Moving between
-- Praos eras needs no translation ('translateChainDepState' between two
-- Praos eras is the identity).
--
-- Operational certificate counters play no part in nonces. The driver
-- empties them after every header ('praosStateOCertCounters' is always
-- empty in its states), which keeps a state at a few hundred bytes; they
-- are ignored when comparing with a node's state.
--
-- Rollbacks: the driver keeps the state after each of the last @k + 1@
-- blocks, so a rollback within the security parameter restores the state
-- at the rollback point exactly.
module McFollower.Nonce
  ( -- * Configuration
    NonceConfig (..)
  , nonceConfig

    -- * Driver
  , NonceDriver
  , Checkpoint (..)
  , EpochNonce (..)
  , NonceError (..)
  , startDriver
  , resumeDriver
  , driverTip
  , driverCheckpoints
  , driverHistory
  , setDriverHistory
  , currentEpochNonce
  , applyHeader
  , rollBackTo

    -- * Cross-check against a node
  , CrossCheck (..)
  , NonceField (..)
  , crossCheck

    -- * Helpers
  , headerEra
  , nonceBytes
  ) where

import Cardano.Crypto.Hash (hashToBytes)
import Cardano.Ledger.BaseTypes (Nonce (..))
import Cardano.Protocol.Crypto (StandardCrypto)
import Cardano.Slotting.EpochInfo (epochInfoEpoch, epochInfoFirst)
import Cardano.Slotting.Slot (EpochNo (..), SlotNo, WithOrigin (Origin))
import Control.Monad (unless)
import Control.Monad.Except (Except, runExcept)
import Data.ByteString (ByteString)
import Data.Foldable (toList)
import Data.List.NonEmpty (NonEmpty)
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Sequence (Seq, (|>))
import Data.Sequence qualified as Seq
import McFollower.Block (Block, Era (..))
import McFollower.EraHistory
  ( ChainParams (..)
  , EraHistory
  , EraHistoryError (..)
  , PraosEra (..)
  , epochInfoAt
  , observeEra
  , praosConsensusConfig
  , presetHistory
  )
import McFollower.Nonce.TrustedState (TrustedState (..))
import Ouroboros.Consensus.Block
  ( Header
  , Point (..)
  , blockSlot
  , headerPoint
  , headerPrevHash
  , pointHash
  , pattern NotOrigin
  )
import Ouroboros.Consensus.Cardano.Block
  ( pattern HeaderAllegra
  , pattern HeaderAlonzo
  , pattern HeaderBabbage
  , pattern HeaderByron
  , pattern HeaderConway
  , pattern HeaderDijkstra
  , pattern HeaderMary
  , pattern HeaderShelley
  )
import Ouroboros.Consensus.HardFork.History qualified as History
import Ouroboros.Consensus.Protocol.Abstract (ConsensusProtocol (..))
import Ouroboros.Consensus.Protocol.Praos (Praos, PraosState (..))
import Ouroboros.Consensus.Protocol.Praos.Views (HeaderView)
import Ouroboros.Consensus.Shelley.Ledger (Header (..))
import Ouroboros.Consensus.Shelley.Protocol.Abstract (protocolHeaderView)

-- Orphan instances for the Cardano eras, among them the ones that make
-- 'Header Block' a 'HasHeader'.
import Ouroboros.Consensus.Cardano.Node ()
import Ouroboros.Consensus.Shelley.Ledger.SupportsProtocol ()

data NonceConfig = NonceConfig
  { ncChainParams :: !ChainParams
  , ncHistory :: !EraHistory
  }
  deriving stock (Show)

-- | Configuration with the network's preset era history.
nonceConfig :: ChainParams -> NonceConfig
nonceConfig cp = NonceConfig cp (presetHistory cp)

-- | The state after a block, as the store keeps it for rollbacks and
-- restarts.
data Checkpoint = Checkpoint
  { cpPoint :: !(Point Block)
  , cpState :: !PraosState
  , cpNewEpochNonce :: !(Maybe EpochNonce)
  -- ^ Set when this block is the first of its epoch: the nonce in force
  -- during that epoch, which the block's tick produced.
  }
  deriving stock (Eq, Show)

-- | The nonce in force during an epoch. 'NeutralNonce' only occurs at
-- genesis with no extra entropy; db-sync then stores NULL.
data EpochNonce = EpochNonce
  { enEpoch :: !EpochNo
  , enNonce :: !Nonce
  }
  deriving stock (Eq, Show)

data NonceDriver = NonceDriver
  { ndChainParams :: !ChainParams
  , ndHistory :: !EraHistory
  , ndWindow :: !(Seq Checkpoint)
  -- ^ Oldest first, never empty, at most @k + 1@ entries. The last one is
  -- the current state.
  }

data NonceError
  = UnsupportedEra !Era !(Point Block)
  -- ^ A header of a non-Praos era.
  | DoesNotExtend !(Point Block) !(Point Block)
  -- ^ The header (second) does not extend the driver's tip (first).
  | HistoryError !EraHistoryError
  | RollbackBeyondWindow !(Point Block) !(Point Block)
  -- ^ The rollback point (first) is not among the kept states; the oldest
  -- kept one is the second.
  deriving stock (Show)

-- | Start from a trusted state. The starting state's own epoch nonce is
-- available from 'currentEpochNonce'.
startDriver :: NonceConfig -> TrustedState -> NonceDriver
startDriver cfg TrustedState {tsPoint, tsState} =
  resumeDriver cfg (pure (Checkpoint tsPoint (dropOCertCounters tsState) Nothing))

-- | Resume from stored checkpoints, oldest first (normally the last @k + 1@).
resumeDriver :: NonceConfig -> NonEmpty Checkpoint -> NonceDriver
resumeDriver NonceConfig {ncChainParams, ncHistory} cps =
  NonceDriver
    { ndChainParams = ncChainParams
    , ndHistory = ncHistory
    , ndWindow = trim ncChainParams (Seq.fromList (map dropCounters (toList cps)))
    }
 where
  dropCounters cp = cp {cpState = dropOCertCounters (cpState cp)}

driverTip :: NonceDriver -> Checkpoint
driverTip NonceDriver {ndWindow} = case Seq.viewr ndWindow of
  _ Seq.:> cp -> cp
  Seq.EmptyR -> error "NonceDriver: empty window"

-- | The kept checkpoints, oldest first.
driverCheckpoints :: NonceDriver -> [Checkpoint]
driverCheckpoints = toList . ndWindow

driverHistory :: NonceDriver -> EraHistory
driverHistory = ndHistory

-- | Replace the era history, e.g. with a fresher interpreter from the node.
setDriverHistory :: EraHistory -> NonceDriver -> NonceDriver
setDriverHistory h d = d {ndHistory = h}

-- | The epoch of the driver's tip and the nonce in force during it.
currentEpochNonce :: NonceDriver -> Either NonceError EpochNonce
currentEpochNonce d = case praosStateLastSlot st of
  Origin -> Right (EpochNonce (EpochNo 0) (praosStateEpochNonce st))
  NotOrigin slot -> do
    epoch <- horizon (epochInfoEpoch (epochInfoAt (ndHistory d) slot) slot)
    pure (EpochNonce epoch (praosStateEpochNonce st))
 where
  st = cpState (driverTip d)

-- | Apply the next header of the chain. The returned checkpoint is what
-- the store should keep for this block.
applyHeader :: Header Block -> NonceDriver -> Either NonceError (NonceDriver, Checkpoint)
applyHeader hdr d = do
  let tip = driverTip d
      point = headerPoint hdr
      slot = blockSlot hdr
      era = headerEra hdr
  unless (headerPrevHash hdr == pointHash (cpPoint tip)) $
    Left (DoesNotExtend (cpPoint tip) point)
  (praosEra, view) <- maybe (Left (UnsupportedEra era point)) Right (praosView hdr)
  history <- either (Left . HistoryError) Right (observeEra era slot (ndHistory d))
  let epochInfo = epochInfoAt history slot
      st = cpState tip
  -- Evaluate everything the transitions will ask of the epoch info, so a
  -- slot beyond the history's horizon is an error here rather than an
  -- exception thrown from inside them.
  epoch <- horizon (epochInfoEpoch epochInfo slot)
  _ <- horizon (epochInfoFirst epochInfo (succ epoch))
  previousEpoch <- case praosStateLastSlot st of
    Origin -> pure Nothing
    NotOrigin s -> Just <$> horizon (epochInfoEpoch epochInfo s)
  let cfg = praosConsensusConfig (ndChainParams d) praosEra epochInfo
      ticked = tickChainDepState cfg unusedLedgerView slot st
      st' = dropOCertCounters (reupdateChainDepState cfg view slot ticked)
      newEpoch
        | maybe True (< epoch) previousEpoch = Just (EpochNonce epoch (praosStateEpochNonce st'))
        | otherwise = Nothing
      cp = Checkpoint point st' newEpoch
  pure
    ( d {ndHistory = history, ndWindow = trim (ndChainParams d) (ndWindow d |> cp)}
    , cp
    )

-- | Roll back to a point among the kept checkpoints. Also returns the
-- epochs whose nonces were produced by the blocks rolled back, oldest
-- first; the store must forget them.
rollBackTo :: Point Block -> NonceDriver -> Either NonceError (NonceDriver, [EpochNo])
rollBackTo p d = case Seq.findIndexR ((== p) . cpPoint) (ndWindow d) of
  Nothing -> Left (RollbackBeyondWindow p (cpPoint (Seq.index (ndWindow d) 0)))
  Just i ->
    let (kept, dropped) = Seq.splitAt (i + 1) (ndWindow d)
     in Right (d {ndWindow = kept}, map enEpoch (mapMaybe cpNewEpochNonce (toList dropped)))

-- | Keep the last @k + 1@ checkpoints: enough to roll back @k@ blocks.
trim :: ChainParams -> Seq Checkpoint -> Seq Checkpoint
trim cp w = Seq.drop (Seq.length w - keep) w
 where
  keep = fromIntegral (cpSecurityParam cp) + 1

horizon :: Except History.PastHorizonException a -> Either NonceError a
horizon = either (Left . HistoryError . PastHorizon) Right . runExcept

dropOCertCounters :: PraosState -> PraosState
dropOCertCounters st = st {praosStateOCertCounters = Map.empty}

-- | 'tickChainDepState' for Praos stores the ledger view in the ticked
-- state and never inspects it; 'reupdateChainDepState' never reads it
-- either. Should a future version start reading it, this fails loudly
-- rather than computing with a made-up view.
unusedLedgerView :: LedgerView (Praos StandardCrypto)
unusedLedgerView =
  error "McFollower.Nonce: the Praos ledger view was read by a chain-dependent state transition"

praosView :: Header Block -> Maybe (PraosEra, HeaderView StandardCrypto)
praosView = \case
  HeaderBabbage h -> Just (PraosBabbage, protocolHeaderView (shelleyHeaderRaw h))
  HeaderConway h -> Just (PraosConway, protocolHeaderView (shelleyHeaderRaw h))
  HeaderDijkstra h -> Just (PraosDijkstra, protocolHeaderView (shelleyHeaderRaw h))
  HeaderByron _ -> Nothing
  HeaderShelley _ -> Nothing
  HeaderAllegra _ -> Nothing
  HeaderMary _ -> Nothing
  HeaderAlonzo _ -> Nothing

headerEra :: Header Block -> Era
headerEra = \case
  HeaderByron _ -> Byron
  HeaderShelley _ -> Shelley
  HeaderAllegra _ -> Allegra
  HeaderMary _ -> Mary
  HeaderAlonzo _ -> Alonzo
  HeaderBabbage _ -> Babbage
  HeaderConway _ -> Conway
  HeaderDijkstra _ -> Dijkstra

-- | The 32 bytes of a nonce; 'Nothing' for 'NeutralNonce'.
nonceBytes :: Nonce -> Maybe ByteString
nonceBytes = \case
  Nonce h -> Just (hashToBytes h)
  NeutralNonce -> Nothing

-- | Outcome of comparing the driver with a node's protocol state.
data CrossCheck
  = Agree !(Point Block)
  | Diverge !(Point Block) ![NonceField]
  -- ^ The fields that differ (driver's value, node's value).
  | NotInWindow !(Point Block)
  -- ^ The node's state is for a block the driver has no checkpoint for
  -- (not reached yet, rolled back, or older than the window).
  deriving stock (Eq, Show)

data NonceField
  = LastSlot !(WithOrigin SlotNo) !(WithOrigin SlotNo)
  | EvolvingNonce !Nonce !Nonce
  | CandidateNonce !Nonce !Nonce
  | EpochNonceField !Nonce !Nonce
  | PreviousEpochNonce !Nonce !Nonce
  | LabNonce !Nonce !Nonce
  | LastEpochBlockNonce !Nonce !Nonce
  deriving stock (Eq, Show)

-- | Compare the node's 'PraosState' at a point (from @DebugChainDepState@
-- acquired at that point, see "McFollower.LocalStateQuery") with the
-- driver's checkpoint for the same point. Operational certificate counters
-- are not compared.
crossCheck :: Point Block -> PraosState -> NonceDriver -> CrossCheck
crossCheck p node d = case filter ((== p) . cpPoint) (toList (ndWindow d)) of
  [] -> NotInWindow p
  cp : _ ->
    let ours = cpState cp
        diffs =
          concat
            [ field LastSlot praosStateLastSlot
            , field EvolvingNonce praosStateEvolvingNonce
            , field CandidateNonce praosStateCandidateNonce
            , field EpochNonceField praosStateEpochNonce
            , field PreviousEpochNonce praosStatePreviousEpochNonce
            , field LabNonce praosStateLabNonce
            , field LastEpochBlockNonce praosStateLastEpochBlockNonce
            ]
        field :: Eq a => (a -> a -> NonceField) -> (PraosState -> a) -> [NonceField]
        field mk get = [mk (get ours) (get node) | get ours /= get node]
     in if null diffs then Agree p else Diverge p diffs
