{- This file was auto-generated from mc_follower.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.McFollower_Fields where
import qualified Data.ProtoLens.Runtime.Prelude as Prelude
import qualified Data.ProtoLens.Runtime.Data.Int as Data.Int
import qualified Data.ProtoLens.Runtime.Data.Monoid as Data.Monoid
import qualified Data.ProtoLens.Runtime.Data.Word as Data.Word
import qualified Data.ProtoLens.Runtime.Data.ProtoLens as Data.ProtoLens
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes as Data.ProtoLens.Encoding.Bytes
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing as Data.ProtoLens.Encoding.Growing
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe as Data.ProtoLens.Encoding.Parser.Unsafe
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire as Data.ProtoLens.Encoding.Wire
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Field as Data.ProtoLens.Field
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum as Data.ProtoLens.Message.Enum
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types as Data.ProtoLens.Service.Types
import qualified Data.ProtoLens.Runtime.Lens.Family2 as Lens.Family2
import qualified Data.ProtoLens.Runtime.Lens.Family2.Unchecked as Lens.Family2.Unchecked
import qualified Data.ProtoLens.Runtime.Data.Text as Data.Text
import qualified Data.ProtoLens.Runtime.Data.Map as Data.Map
import qualified Data.ProtoLens.Runtime.Data.ByteString as Data.ByteString
import qualified Data.ProtoLens.Runtime.Data.ByteString.Char8 as Data.ByteString.Char8
import qualified Data.ProtoLens.Runtime.Data.Text.Encoding as Data.Text.Encoding
import qualified Data.ProtoLens.Runtime.Data.Vector as Data.Vector
import qualified Data.ProtoLens.Runtime.Data.Vector.Generic as Data.Vector.Generic
import qualified Data.ProtoLens.Runtime.Data.Vector.Unboxed as Data.Vector.Unboxed
import qualified Data.ProtoLens.Runtime.Text.Read as Text.Read
address ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "address" a) =>
  Lens.Family2.LensLike' f s a
address = Data.ProtoLens.Field.field @"address"
afterBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "afterBlockNo" a) =>
  Lens.Family2.LensLike' f s a
afterBlockNo = Data.ProtoLens.Field.field @"afterBlockNo"
afterPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "afterPosition" a) =>
  Lens.Family2.LensLike' f s a
afterPosition = Data.ProtoLens.Field.field @"afterPosition"
asset ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "asset" a) =>
  Lens.Family2.LensLike' f s a
asset = Data.ProtoLens.Field.field @"asset"
assetName ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "assetName" a) =>
  Lens.Family2.LensLike' f s a
assetName = Data.ProtoLens.Field.field @"assetName"
authToken ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "authToken" a) =>
  Lens.Family2.LensLike' f s a
authToken = Data.ProtoLens.Field.field @"authToken"
backfilling ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "backfilling" a) =>
  Lens.Family2.LensLike' f s a
backfilling = Data.ProtoLens.Field.field @"backfilling"
block ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "block" a) =>
  Lens.Family2.LensLike' f s a
block = Data.ProtoLens.Field.field @"block"
blockHash ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "blockHash" a) =>
  Lens.Family2.LensLike' f s a
blockHash = Data.ProtoLens.Field.field @"blockHash"
blockNo ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "blockNo" a) =>
  Lens.Family2.LensLike' f s a
blockNo = Data.ProtoLens.Field.field @"blockNo"
blockTimeUnixMillis ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "blockTimeUnixMillis" a) =>
  Lens.Family2.LensLike' f s a
blockTimeUnixMillis
  = Data.ProtoLens.Field.field @"blockTimeUnixMillis"
bridgeIn ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "bridgeIn" a) =>
  Lens.Family2.LensLike' f s a
bridgeIn = Data.ProtoLens.Field.field @"bridgeIn"
bridgeOut ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "bridgeOut" a) =>
  Lens.Family2.LensLike' f s a
bridgeOut = Data.ProtoLens.Field.field @"bridgeOut"
c2mMetadatumCbor ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "c2mMetadatumCbor" a) =>
  Lens.Family2.LensLike' f s a
c2mMetadatumCbor = Data.ProtoLens.Field.field @"c2mMetadatumCbor"
cbor ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "cbor" a) =>
  Lens.Family2.LensLike' f s a
cbor = Data.ProtoLens.Field.field @"cbor"
datum ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "datum" a) =>
  Lens.Family2.LensLike' f s a
datum = Data.ProtoLens.Field.field @"datum"
epochNo ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "epochNo" a) =>
  Lens.Family2.LensLike' f s a
epochNo = Data.ProtoLens.Field.field @"epochNo"
fromBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fromBlockNo" a) =>
  Lens.Family2.LensLike' f s a
fromBlockNo = Data.ProtoLens.Field.field @"fromBlockNo"
fromInclusive ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fromInclusive" a) =>
  Lens.Family2.LensLike' f s a
fromInclusive = Data.ProtoLens.Field.field @"fromInclusive"
fromPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fromPosition" a) =>
  Lens.Family2.LensLike' f s a
fromPosition = Data.ProtoLens.Field.field @"fromPosition"
hash ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "hash" a) =>
  Lens.Family2.LensLike' f s a
hash = Data.ProtoLens.Field.field @"hash"
hi ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "hi" a) =>
  Lens.Family2.LensLike' f s a
hi = Data.ProtoLens.Field.field @"hi"
holderAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "holderAddress" a) =>
  Lens.Family2.LensLike' f s a
holderAddress = Data.ProtoLens.Field.field @"holderAddress"
icsAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "icsAddress" a) =>
  Lens.Family2.LensLike' f s a
icsAddress = Data.ProtoLens.Field.field @"icsAddress"
immutableTip ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "immutableTip" a) =>
  Lens.Family2.LensLike' f s a
immutableTip = Data.ProtoLens.Field.field @"immutableTip"
index ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "index" a) =>
  Lens.Family2.LensLike' f s a
index = Data.ProtoLens.Field.field @"index"
limit ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "limit" a) =>
  Lens.Family2.LensLike' f s a
limit = Data.ProtoLens.Field.field @"limit"
lo ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "lo" a) =>
  Lens.Family2.LensLike' f s a
lo = Data.ProtoLens.Field.field @"lo"
mappingValidatorAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "mappingValidatorAddress" a) =>
  Lens.Family2.LensLike' f s a
mappingValidatorAddress
  = Data.ProtoLens.Field.field @"mappingValidatorAddress"
maxBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxBlockNo" a) =>
  Lens.Family2.LensLike' f s a
maxBlockNo = Data.ProtoLens.Field.field @"maxBlockNo"
maxSlot ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "maxSlot" a) =>
  Lens.Family2.LensLike' f s a
maxSlot = Data.ProtoLens.Field.field @"maxSlot"
maxTimeUnixMillis ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxTimeUnixMillis" a) =>
  Lens.Family2.LensLike' f s a
maxTimeUnixMillis = Data.ProtoLens.Field.field @"maxTimeUnixMillis"
maxTxSize ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxTxSize" a) =>
  Lens.Family2.LensLike' f s a
maxTxSize = Data.ProtoLens.Field.field @"maxTxSize"
maxTxs ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "maxTxs" a) =>
  Lens.Family2.LensLike' f s a
maxTxs = Data.ProtoLens.Field.field @"maxTxs"
maybe'afterBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'afterBlockNo" a) =>
  Lens.Family2.LensLike' f s a
maybe'afterBlockNo
  = Data.ProtoLens.Field.field @"maybe'afterBlockNo"
maybe'afterPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'afterPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'afterPosition
  = Data.ProtoLens.Field.field @"maybe'afterPosition"
maybe'asset ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'asset" a) =>
  Lens.Family2.LensLike' f s a
maybe'asset = Data.ProtoLens.Field.field @"maybe'asset"
maybe'authToken ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'authToken" a) =>
  Lens.Family2.LensLike' f s a
maybe'authToken = Data.ProtoLens.Field.field @"maybe'authToken"
maybe'block ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'block" a) =>
  Lens.Family2.LensLike' f s a
maybe'block = Data.ProtoLens.Field.field @"maybe'block"
maybe'bridgeIn ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'bridgeIn" a) =>
  Lens.Family2.LensLike' f s a
maybe'bridgeIn = Data.ProtoLens.Field.field @"maybe'bridgeIn"
maybe'bridgeOut ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'bridgeOut" a) =>
  Lens.Family2.LensLike' f s a
maybe'bridgeOut = Data.ProtoLens.Field.field @"maybe'bridgeOut"
maybe'c2mMetadatumCbor ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'c2mMetadatumCbor" a) =>
  Lens.Family2.LensLike' f s a
maybe'c2mMetadatumCbor
  = Data.ProtoLens.Field.field @"maybe'c2mMetadatumCbor"
maybe'datum ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'datum" a) =>
  Lens.Family2.LensLike' f s a
maybe'datum = Data.ProtoLens.Field.field @"maybe'datum"
maybe'epochNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'epochNo" a) =>
  Lens.Family2.LensLike' f s a
maybe'epochNo = Data.ProtoLens.Field.field @"maybe'epochNo"
maybe'fromInclusive ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'fromInclusive" a) =>
  Lens.Family2.LensLike' f s a
maybe'fromInclusive
  = Data.ProtoLens.Field.field @"maybe'fromInclusive"
maybe'fromPosition ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'fromPosition" a) =>
  Lens.Family2.LensLike' f s a
maybe'fromPosition
  = Data.ProtoLens.Field.field @"maybe'fromPosition"
maybe'immutableTip ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'immutableTip" a) =>
  Lens.Family2.LensLike' f s a
maybe'immutableTip
  = Data.ProtoLens.Field.field @"maybe'immutableTip"
maybe'lower ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'lower" a) =>
  Lens.Family2.LensLike' f s a
maybe'lower = Data.ProtoLens.Field.field @"maybe'lower"
maybe'maxTxSize ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'maxTxSize" a) =>
  Lens.Family2.LensLike' f s a
maybe'maxTxSize = Data.ProtoLens.Field.field @"maybe'maxTxSize"
maybe'maxTxs ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'maxTxs" a) =>
  Lens.Family2.LensLike' f s a
maybe'maxTxs = Data.ProtoLens.Field.field @"maybe'maxTxs"
maybe'nonce ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'nonce" a) =>
  Lens.Family2.LensLike' f s a
maybe'nonce = Data.ProtoLens.Field.field @"maybe'nonce"
maybe'output ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'output" a) =>
  Lens.Family2.LensLike' f s a
maybe'output = Data.ProtoLens.Field.field @"maybe'output"
maybe'position ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'position" a) =>
  Lens.Family2.LensLike' f s a
maybe'position = Data.ProtoLens.Field.field @"maybe'position"
maybe'reserveIn ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'reserveIn" a) =>
  Lens.Family2.LensLike' f s a
maybe'reserveIn = Data.ProtoLens.Field.field @"maybe'reserveIn"
maybe'reserveOut ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'reserveOut" a) =>
  Lens.Family2.LensLike' f s a
maybe'reserveOut = Data.ProtoLens.Field.field @"maybe'reserveOut"
maybe'startBlock ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'startBlock" a) =>
  Lens.Family2.LensLike' f s a
maybe'startBlock = Data.ProtoLens.Field.field @"maybe'startBlock"
maybe'tip ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'tip" a) =>
  Lens.Family2.LensLike' f s a
maybe'tip = Data.ProtoLens.Field.field @"maybe'tip"
maybe'toExclusive ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'toExclusive" a) =>
  Lens.Family2.LensLike' f s a
maybe'toExclusive = Data.ProtoLens.Field.field @"maybe'toExclusive"
maybe'token ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'token" a) =>
  Lens.Family2.LensLike' f s a
maybe'token = Data.ProtoLens.Field.field @"maybe'token"
maybe'upstreamTipBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'upstreamTipBlockNo" a) =>
  Lens.Family2.LensLike' f s a
maybe'upstreamTipBlockNo
  = Data.ProtoLens.Field.field @"maybe'upstreamTipBlockNo"
maybe'upstreamTipSlot ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'upstreamTipSlot" a) =>
  Lens.Family2.LensLike' f s a
maybe'upstreamTipSlot
  = Data.ProtoLens.Field.field @"maybe'upstreamTipSlot"
maybe'window ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'window" a) =>
  Lens.Family2.LensLike' f s a
maybe'window = Data.ProtoLens.Field.field @"maybe'window"
minSlot ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "minSlot" a) =>
  Lens.Family2.LensLike' f s a
minSlot = Data.ProtoLens.Field.field @"minSlot"
minTimeUnixMillis ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "minTimeUnixMillis" a) =>
  Lens.Family2.LensLike' f s a
minTimeUnixMillis = Data.ProtoLens.Field.field @"minTimeUnixMillis"
networkMagic ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "networkMagic" a) =>
  Lens.Family2.LensLike' f s a
networkMagic = Data.ProtoLens.Field.field @"networkMagic"
nonce ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "nonce" a) =>
  Lens.Family2.LensLike' f s a
nonce = Data.ProtoLens.Field.field @"nonce"
offset ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "offset" a) =>
  Lens.Family2.LensLike' f s a
offset = Data.ProtoLens.Field.field @"offset"
originTxHash ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "originTxHash" a) =>
  Lens.Family2.LensLike' f s a
originTxHash = Data.ProtoLens.Field.field @"originTxHash"
output ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "output" a) =>
  Lens.Family2.LensLike' f s a
output = Data.ProtoLens.Field.field @"output"
policyId ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "policyId" a) =>
  Lens.Family2.LensLike' f s a
policyId = Data.ProtoLens.Field.field @"policyId"
poolHash ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "poolHash" a) =>
  Lens.Family2.LensLike' f s a
poolHash = Data.ProtoLens.Field.field @"poolHash"
position ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "position" a) =>
  Lens.Family2.LensLike' f s a
position = Data.ProtoLens.Field.field @"position"
quantity ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "quantity" a) =>
  Lens.Family2.LensLike' f s a
quantity = Data.ProtoLens.Field.field @"quantity"
reserveAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "reserveAddress" a) =>
  Lens.Family2.LensLike' f s a
reserveAddress = Data.ProtoLens.Field.field @"reserveAddress"
reserveIn ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "reserveIn" a) =>
  Lens.Family2.LensLike' f s a
reserveIn = Data.ProtoLens.Field.field @"reserveIn"
reserveOut ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "reserveOut" a) =>
  Lens.Family2.LensLike' f s a
reserveOut = Data.ProtoLens.Field.field @"reserveOut"
securityParameter ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "securityParameter" a) =>
  Lens.Family2.LensLike' f s a
securityParameter = Data.ProtoLens.Field.field @"securityParameter"
slotNo ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "slotNo" a) =>
  Lens.Family2.LensLike' f s a
slotNo = Data.ProtoLens.Field.field @"slotNo"
spendingTxHash ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "spendingTxHash" a) =>
  Lens.Family2.LensLike' f s a
spendingTxHash = Data.ProtoLens.Field.field @"spendingTxHash"
stake ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "stake" a) =>
  Lens.Family2.LensLike' f s a
stake = Data.ProtoLens.Field.field @"stake"
startBlock ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "startBlock" a) =>
  Lens.Family2.LensLike' f s a
startBlock = Data.ProtoLens.Field.field @"startBlock"
syncing ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "syncing" a) =>
  Lens.Family2.LensLike' f s a
syncing = Data.ProtoLens.Field.field @"syncing"
timeUnixSeconds ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "timeUnixSeconds" a) =>
  Lens.Family2.LensLike' f s a
timeUnixSeconds = Data.ProtoLens.Field.field @"timeUnixSeconds"
tip ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "tip" a) =>
  Lens.Family2.LensLike' f s a
tip = Data.ProtoLens.Field.field @"tip"
toBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "toBlockNo" a) =>
  Lens.Family2.LensLike' f s a
toBlockNo = Data.ProtoLens.Field.field @"toBlockNo"
toExclusive ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "toExclusive" a) =>
  Lens.Family2.LensLike' f s a
toExclusive = Data.ProtoLens.Field.field @"toExclusive"
token ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "token" a) =>
  Lens.Family2.LensLike' f s a
token = Data.ProtoLens.Field.field @"token"
txBlockIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txBlockIndex" a) =>
  Lens.Family2.LensLike' f s a
txBlockIndex = Data.ProtoLens.Field.field @"txBlockIndex"
txBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txBlockNo" a) =>
  Lens.Family2.LensLike' f s a
txBlockNo = Data.ProtoLens.Field.field @"txBlockNo"
txCount ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "txCount" a) =>
  Lens.Family2.LensLike' f s a
txCount = Data.ProtoLens.Field.field @"txCount"
txEpochNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txEpochNo" a) =>
  Lens.Family2.LensLike' f s a
txEpochNo = Data.ProtoLens.Field.field @"txEpochNo"
txHash ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "txHash" a) =>
  Lens.Family2.LensLike' f s a
txHash = Data.ProtoLens.Field.field @"txHash"
txIndex ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "txIndex" a) =>
  Lens.Family2.LensLike' f s a
txIndex = Data.ProtoLens.Field.field @"txIndex"
txIndexInBlock ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txIndexInBlock" a) =>
  Lens.Family2.LensLike' f s a
txIndexInBlock = Data.ProtoLens.Field.field @"txIndexInBlock"
txInputs ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txInputs" a) =>
  Lens.Family2.LensLike' f s a
txInputs = Data.ProtoLens.Field.field @"txInputs"
txSlotNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "txSlotNo" a) =>
  Lens.Family2.LensLike' f s a
txSlotNo = Data.ProtoLens.Field.field @"txSlotNo"
upstreamTipBlockNo ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "upstreamTipBlockNo" a) =>
  Lens.Family2.LensLike' f s a
upstreamTipBlockNo
  = Data.ProtoLens.Field.field @"upstreamTipBlockNo"
upstreamTipSlot ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "upstreamTipSlot" a) =>
  Lens.Family2.LensLike' f s a
upstreamTipSlot = Data.ProtoLens.Field.field @"upstreamTipSlot"
utxoIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "utxoIndex" a) =>
  Lens.Family2.LensLike' f s a
utxoIndex = Data.ProtoLens.Field.field @"utxoIndex"
utxoTxHash ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "utxoTxHash" a) =>
  Lens.Family2.LensLike' f s a
utxoTxHash = Data.ProtoLens.Field.field @"utxoTxHash"
vec'backfilling ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'backfilling" a) =>
  Lens.Family2.LensLike' f s a
vec'backfilling = Data.ProtoLens.Field.field @"vec'backfilling"
vec'txInputs ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'txInputs" a) =>
  Lens.Family2.LensLike' f s a
vec'txInputs = Data.ProtoLens.Field.field @"vec'txInputs"
window ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "window" a) =>
  Lens.Family2.LensLike' f s a
window = Data.ProtoLens.Field.field @"window"