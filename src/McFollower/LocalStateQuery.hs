-- | Local state queries against a cardano-node socket: acquire the ledger
-- state at a target, run queries, release. Each call opens its own
-- connection.
module McFollower.LocalStateQuery
  ( QueryTarget (..)
  , LocalQueryError (..)
  , runLocalStateQuery
  , querySystemStart
  ) where

import Cardano.Api
  ( AcquiringFailure
  , BlockInMode
  , ChainPoint
  , LocalStateQueryExpr
  , QueryInMode
  , UnsupportedNtcVersionError
  , executeLocalStateQueryExpr
  , fromConsensusPointHF
  )
import Cardano.Api qualified as Api
import Cardano.Slotting.Time (SystemStart)
import McFollower.Block (Block)
import McFollower.BlockSource.N2C (LocalNodeConfig, localNodeConnectInfo)
import Ouroboros.Network.Block (Point)
import Ouroboros.Network.Protocol.LocalStateQuery.Type (Target (..))

-- | Which ledger state to acquire.
data QueryTarget
  = AtImmutableTip
  | AtVolatileTip
  | AtPoint !(Point Block)
  deriving stock (Show)

data LocalQueryError
  = AcquireFailed !AcquiringFailure
  | QueryUnsupported !UnsupportedNtcVersionError
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
