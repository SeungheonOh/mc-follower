{-# LANGUAGE GADTs #-}

-- | Local state queries against a cardano-node socket: acquire the ledger
-- state at a target, run queries, release. Each call opens its own
-- connection.
--
-- 'queryEpochData' takes everything the epoch data needs from one acquired
-- ledger state (by default the immutable tip, so nothing it returns can be
-- rolled back): the Praos protocol state (@DebugChainDepState@), the stake
-- snapshots (@GetStakeSnapshots@), the current protocol parameters (for
-- @maxTxSize@) and the era history (@GetInterpreter@).
--
-- 'queryProtocolState' and 'crossCheckWithNode' read just the protocol
-- state, to start the nonce driver from the node or to compare it with
-- the node.
--
-- Not yet run against a node: these functions compile against cardano-api
-- but have not been exercised.
module McFollower.LocalStateQuery
  ( QueryTarget (..)
  , LocalQueryError (..)
  , runLocalStateQuery
  , querySystemStart

    -- * Epoch data
  , NodeEpochData (..)
  , queryEpochData
  , nodeEpochStake
  , nodeTrustedState

    -- * Protocol state
  , queryProtocolState
  , crossCheckWithNode
  ) where

import Cardano.Api
  ( AcquiringFailure
  , AnyCardanoEra (..)
  , BabbageEraOnwards (..)
  , BlockInMode
  , CardanoEra (..)
  , ChainPoint
  , EraHistory (..)
  , EraMismatch
  , LocalStateQueryExpr
  , QueryInMode
  , ShelleyBasedEra (..)
  , UnsupportedNtcVersionError
  , executeLocalStateQueryExpr
  , fromConsensusPointHF
  , shelleyBasedEraConstraints
  , toConsensusPointHF
  )
import Cardano.Api qualified as Api
import Cardano.Ledger.Api.State.Query (StakeSnapshots)
import Cardano.Ledger.Core (ppMaxTxSizeL)
import Cardano.Protocol.Crypto (StandardCrypto)
import Cardano.Slotting.Slot (EpochNo)
import Cardano.Slotting.Time (SystemStart)
import Control.Monad.Except (ExceptT (..), runExceptT, withExceptT)
import Data.Bifunctor (first)
import Data.ByteString.Lazy qualified as BL
import Data.Word (Word32)
import Lens.Micro ((^.))
import McFollower.Block (Block)
import McFollower.BlockSource.N2C (LocalNodeConfig, localNodeConnectInfo)
import McFollower.EpochData.Stake (EpochStake, Finality (..), stakeFromSnapshots)
import McFollower.Nonce (CrossCheck, NonceDriver, crossCheck)
import McFollower.Nonce.TrustedState (TrustedState (..), decodePraosState)
import Ouroboros.Consensus.Cardano.Block (CardanoEras)
import Ouroboros.Consensus.HardFork.History qualified as History
import Ouroboros.Consensus.Protocol.Praos (PraosState)
import Ouroboros.Network.Block (Point)
import Ouroboros.Network.Protocol.LocalStateQuery.Type (Target (..))

import Ouroboros.Consensus.Cardano.Node ()

-- | Which ledger state to acquire.
data QueryTarget
  = AtImmutableTip
  | AtVolatileTip
  | AtPoint !(Point Block)
  deriving stock (Show)

data LocalQueryError
  = AcquireFailed !AcquiringFailure
  | QueryUnsupported !UnsupportedNtcVersionError
  | QueryEraMismatch !EraMismatch
  | NotAPraosEra !AnyCardanoEra
  -- ^ The ledger state is in an era before Babbage.
  | DecodeFailed !String
  deriving stock (Show)

-- | Run a cardano-api query expression on the ledger state at the target.
runLocalStateQuery
  :: LocalNodeConfig
  -> QueryTarget
  -> LocalStateQueryExpr BlockInMode ChainPoint QueryInMode () IO a
  -> IO (Either AcquiringFailure a)
runLocalStateQuery cfg target =
  executeLocalStateQueryExpr (localNodeConnectInfo cfg) $ case target of
    AtImmutableTip -> ImmutableTip
    AtVolatileTip -> VolatileTip
    AtPoint p -> SpecificPoint (fromConsensusPointHF p)

querySystemStart :: LocalNodeConfig -> QueryTarget -> IO (Either LocalQueryError SystemStart)
querySystemStart cfg target = do
  result <- runLocalStateQuery cfg target Api.querySystemStart
  pure $ case result of
    Left e -> Left (AcquireFailed e)
    Right (Left e) -> Left (QueryUnsupported e)
    Right (Right start) -> Right start

-- | What one acquired ledger state says about epochs.
data NodeEpochData = NodeEpochData
  { nedTarget :: !QueryTarget
  , nedPoint :: !(Point Block)
  -- ^ The block the ledger state is at.
  , nedEpoch :: !EpochNo
  -- ^ The ledger state's epoch.
  , nedProtocolState :: !PraosState
  -- ^ The Praos state after 'nedPoint', for the nonce driver's start
  -- ('nodeTrustedState') and cross-check.
  , nedStakeSnapshots :: !StakeSnapshots
  , nedMaxTxSize :: !Word32
  -- ^ @maxTxSize@ in force during 'nedEpoch'. Protocol parameters change
  -- only at epoch boundaries, so this is the epoch's value.
  , nedInterpreter :: !(History.Interpreter (CardanoEras StandardCrypto))
  }

-- | Acquire the ledger state at the target and read the epoch data from
-- it. Fails with 'NotAPraosEra' before Babbage.
queryEpochData :: LocalNodeConfig -> QueryTarget -> IO (Either LocalQueryError NodeEpochData)
queryEpochData cfg target = runExceptQuery cfg target $ inPraosEra $ \beo -> do
  let sbe = babbageToShelleyBased beo
  chainPoint <- ntc Api.queryChainPoint
  EraHistory interpreter <- ntc Api.queryEraHistory
  epoch <- inEra (Api.queryEpoch sbe)
  protocolState <- praosStateIn sbe
  serialisedSnapshots <- inEra (Api.queryStakeSnapshot beo Nothing)
  Api.StakeSnapshot snapshots <-
    liftEither (first (DecodeFailed . show) (Api.decodeStakeSnapshot sbe serialisedSnapshots))
  maxTxSize <- shelleyBasedEraConstraints sbe $ (^. ppMaxTxSizeL) <$> inEra (Api.queryProtocolParameters sbe)
  pure
    NodeEpochData
      { nedTarget = target
      , nedPoint = toConsensusPointHF chainPoint
      , nedEpoch = epoch
      , nedProtocolState = protocolState
      , nedStakeSnapshots = snapshots
      , nedMaxTxSize = maxTxSize
      , nedInterpreter = interpreter
      }

-- | Only the protocol state and the point it belongs to.
queryProtocolState :: LocalNodeConfig -> QueryTarget -> IO (Either LocalQueryError TrustedState)
queryProtocolState cfg target = runExceptQuery cfg target $ inPraosEra $ \beo -> do
  chainPoint <- ntc Api.queryChainPoint
  TrustedState (toConsensusPointHF chainPoint) <$> praosStateIn (babbageToShelleyBased beo)

-- | Compare the nonce driver with the node's protocol state at the target
-- (normally the immutable tip, which the driver still has a checkpoint
-- for while it is less than @k@ blocks behind the node).
crossCheckWithNode :: LocalNodeConfig -> QueryTarget -> NonceDriver -> IO (Either LocalQueryError CrossCheck)
crossCheckWithNode cfg target driver =
  fmap (\TrustedState {tsPoint, tsState} -> crossCheck tsPoint tsState driver)
    <$> queryProtocolState cfg target

runExceptQuery :: LocalNodeConfig -> QueryTarget -> ExceptT LocalQueryError Query a -> IO (Either LocalQueryError a)
runExceptQuery cfg target expr =
  either (Left . AcquireFailed) id <$> runLocalStateQuery cfg target (runExceptT expr)

-- | Run in the ledger state's era, which must be Babbage or later.
inPraosEra
  :: (forall era. BabbageEraOnwards era -> ExceptT LocalQueryError Query a)
  -> ExceptT LocalQueryError Query a
inPraosEra k = do
  AnyCardanoEra era <- ntc Api.queryCurrentEra
  maybe (liftEither (Left (NotAPraosEra (AnyCardanoEra era)))) k (babbageOnwards era)

-- | @DebugChainDepState@: in a Praos era the bytes are the 'PraosState'
-- encoding.
praosStateIn :: ShelleyBasedEra era -> ExceptT LocalQueryError Query PraosState
praosStateIn sbe = do
  Api.ProtocolState (Api.Serialised bytes) <- inEra (Api.queryProtocolState sbe)
  liftEither (first DecodeFailed (decodePraosState (BL.toStrict bytes)))

type Query = LocalStateQueryExpr BlockInMode ChainPoint QueryInMode () IO

ntc :: Query (Either UnsupportedNtcVersionError a) -> ExceptT LocalQueryError Query a
ntc q = withExceptT QueryUnsupported (ExceptT q)

inEra :: Query (Either UnsupportedNtcVersionError (Either EraMismatch a)) -> ExceptT LocalQueryError Query a
inEra q = ntc q >>= either (liftEither . Left . QueryEraMismatch) pure

liftEither :: Either LocalQueryError a -> ExceptT LocalQueryError Query a
liftEither = ExceptT . pure

babbageOnwards :: CardanoEra era -> Maybe (BabbageEraOnwards era)
babbageOnwards = \case
  ByronEra -> Nothing
  ShelleyEra -> Nothing
  AllegraEra -> Nothing
  MaryEra -> Nothing
  AlonzoEra -> Nothing
  BabbageEra -> Just BabbageEraOnwardsBabbage
  ConwayEra -> Just BabbageEraOnwardsConway
  DijkstraEra -> Just BabbageEraOnwardsDijkstra

babbageToShelleyBased :: BabbageEraOnwards era -> ShelleyBasedEra era
babbageToShelleyBased = \case
  BabbageEraOnwardsBabbage -> ShelleyBasedEraBabbage
  BabbageEraOnwardsConway -> ShelleyBasedEraConway
  BabbageEraOnwardsDijkstra -> ShelleyBasedEraDijkstra

-- | The stake distributions in the snapshots (epochs @e - 1@, @e@, @e + 1@),
-- with completeness according to the acquired target.
nodeEpochStake :: NodeEpochData -> [EpochStake]
nodeEpochStake ned = stakeFromSnapshots finality (nedEpoch ned) (nedStakeSnapshots ned)
 where
  finality = case nedTarget ned of
    AtImmutableTip -> Immutable
    AtVolatileTip -> Volatile
    -- A specific point may be anywhere; only the caller knows.
    AtPoint _ -> Volatile

-- | The node's protocol state as a starting point for the nonce driver.
nodeTrustedState :: NodeEpochData -> TrustedState
nodeTrustedState ned = TrustedState (nedPoint ned) (nedProtocolState ned)
