{- This file was auto-generated from mc_follower.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.McFollower (
        McFollower(..), AddressOutputRow(), AssetCreateRow(), AssetId(),
        AssetSpendRow(), Block(), BridgeTxRow(), Datum(),
        DeregistrationRow(), GetAssetCreatesRequest(),
        GetAssetSpendsRequest(), GetBlockByHashRequest(),
        GetBlocksByNumberRangeRequest(), GetBridgeTxsRequest(),
        GetBridgeTxsRequest'Lower(..), _GetBridgeTxsRequest'AfterBlockNo,
        _GetBridgeTxsRequest'AfterPosition,
        _GetBridgeTxsRequest'FromPosition, GetEpochNonceRequest(),
        GetEpochNonceResponse(), GetHighestBlockInWindowRequest(),
        GetLatestBlockForEpochRequest(), GetLatestBlockRequest(),
        GetLatestGovernanceOutputRequest(),
        GetLatestGovernanceOutputResponse(), GetLatestStableEpochRequest(),
        GetLatestStableEpochResponse(),
        GetLatestTokenOutputForEpochRequest(),
        GetLatestTokenOutputForEpochResponse(),
        GetMappingDeregistrationsRequest(),
        GetMappingRegistrationsRequest(), GetMaxTxSizeRequest(),
        GetMaxTxSizeResponse(), GetStakeDistributionRequest(),
        GetStatusRequest(), GetStatusResponse(), GetTxPositionRequest(),
        GetTxPositionResponse(), GetUnspentOutputsAtAddressRequest(),
        GovernanceOutput(), OptionalBlock(), OutputRef(), Position(),
        PositionWindow(), RegistrationRow(), StakePoolEntry(),
        TokenTxOutput(), Uint128()
    ) where
import qualified Data.ProtoLens.Runtime.Control.DeepSeq as Control.DeepSeq
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Prism as Data.ProtoLens.Prism
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
{- | Fields :
     
         * 'Proto.McFollower_Fields.utxoTxHash' @:: Lens' AddressOutputRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' AddressOutputRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txBlockNo' @:: Lens' AddressOutputRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txSlotNo' @:: Lens' AddressOutputRow Data.Word.Word64@
         * 'Proto.McFollower_Fields.txEpochNo' @:: Lens' AddressOutputRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txIndexInBlock' @:: Lens' AddressOutputRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.address' @:: Lens' AddressOutputRow Data.Text.Text@
         * 'Proto.McFollower_Fields.datum' @:: Lens' AddressOutputRow Datum@
         * 'Proto.McFollower_Fields.maybe'datum' @:: Lens' AddressOutputRow (Prelude.Maybe Datum)@
         * 'Proto.McFollower_Fields.txInputs' @:: Lens' AddressOutputRow [OutputRef]@
         * 'Proto.McFollower_Fields.vec'txInputs' @:: Lens' AddressOutputRow (Data.Vector.Vector OutputRef)@ -}
data AddressOutputRow
  = AddressOutputRow'_constructor {_AddressOutputRow'utxoTxHash :: !Data.ByteString.ByteString,
                                   _AddressOutputRow'utxoIndex :: !Data.Word.Word32,
                                   _AddressOutputRow'txBlockNo :: !Data.Word.Word32,
                                   _AddressOutputRow'txSlotNo :: !Data.Word.Word64,
                                   _AddressOutputRow'txEpochNo :: !Data.Word.Word32,
                                   _AddressOutputRow'txIndexInBlock :: !Data.Word.Word32,
                                   _AddressOutputRow'address :: !Data.Text.Text,
                                   _AddressOutputRow'datum :: !(Prelude.Maybe Datum),
                                   _AddressOutputRow'txInputs :: !(Data.Vector.Vector OutputRef),
                                   _AddressOutputRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AddressOutputRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AddressOutputRow "utxoTxHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'utxoTxHash
           (\ x__ y__ -> x__ {_AddressOutputRow'utxoTxHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'utxoIndex
           (\ x__ y__ -> x__ {_AddressOutputRow'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "txBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txBlockNo
           (\ x__ y__ -> x__ {_AddressOutputRow'txBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "txSlotNo" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txSlotNo
           (\ x__ y__ -> x__ {_AddressOutputRow'txSlotNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "txEpochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txEpochNo
           (\ x__ y__ -> x__ {_AddressOutputRow'txEpochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "txIndexInBlock" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txIndexInBlock
           (\ x__ y__ -> x__ {_AddressOutputRow'txIndexInBlock = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "address" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'address
           (\ x__ y__ -> x__ {_AddressOutputRow'address = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "datum" Datum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'datum
           (\ x__ y__ -> x__ {_AddressOutputRow'datum = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField AddressOutputRow "maybe'datum" (Prelude.Maybe Datum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'datum
           (\ x__ y__ -> x__ {_AddressOutputRow'datum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AddressOutputRow "txInputs" [OutputRef] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txInputs
           (\ x__ y__ -> x__ {_AddressOutputRow'txInputs = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField AddressOutputRow "vec'txInputs" (Data.Vector.Vector OutputRef) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AddressOutputRow'txInputs
           (\ x__ y__ -> x__ {_AddressOutputRow'txInputs = y__}))
        Prelude.id
instance Data.ProtoLens.Message AddressOutputRow where
  messageName _ = Data.Text.pack "mcfollower.v1.AddressOutputRow"
  packedMessageDescriptor _
    = "\n\
      \\DLEAddressOutputRow\DC2 \n\
      \\futxo_tx_hash\CAN\SOH \SOH(\fR\n\
      \utxoTxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\STX \SOH(\rR\tutxoIndex\DC2\RS\n\
      \\vtx_block_no\CAN\ETX \SOH(\rR\ttxBlockNo\DC2\FS\n\
      \\n\
      \tx_slot_no\CAN\EOT \SOH(\EOTR\btxSlotNo\DC2\RS\n\
      \\vtx_epoch_no\CAN\ENQ \SOH(\rR\ttxEpochNo\DC2)\n\
      \\DC1tx_index_in_block\CAN\ACK \SOH(\rR\SOtxIndexInBlock\DC2\CAN\n\
      \\aaddress\CAN\a \SOH(\tR\aaddress\DC2/\n\
      \\ENQdatum\CAN\b \SOH(\v2\DC4.mcfollower.v1.DatumH\NULR\ENQdatum\136\SOH\SOH\DC25\n\
      \\ttx_inputs\CAN\t \ETX(\v2\CAN.mcfollower.v1.OutputRefR\btxInputsB\b\n\
      \\ACK_datum"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        utxoTxHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoTxHash")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        txBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txBlockNo")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        txSlotNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_slot_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txSlotNo")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        txEpochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txEpochNo")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        txIndexInBlock__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index_in_block"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txIndexInBlock")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        address__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"address")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        datum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "datum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Datum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'datum")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
        txInputs__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_inputs"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor OutputRef)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"txInputs")) ::
              Data.ProtoLens.FieldDescriptor AddressOutputRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, utxoTxHash__field_descriptor),
           (Data.ProtoLens.Tag 2, utxoIndex__field_descriptor),
           (Data.ProtoLens.Tag 3, txBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 4, txSlotNo__field_descriptor),
           (Data.ProtoLens.Tag 5, txEpochNo__field_descriptor),
           (Data.ProtoLens.Tag 6, txIndexInBlock__field_descriptor),
           (Data.ProtoLens.Tag 7, address__field_descriptor),
           (Data.ProtoLens.Tag 8, datum__field_descriptor),
           (Data.ProtoLens.Tag 9, txInputs__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AddressOutputRow'_unknownFields
        (\ x__ y__ -> x__ {_AddressOutputRow'_unknownFields = y__})
  defMessage
    = AddressOutputRow'_constructor
        {_AddressOutputRow'utxoTxHash = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'utxoIndex = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'txBlockNo = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'txSlotNo = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'txEpochNo = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'txIndexInBlock = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'address = Data.ProtoLens.fieldDefault,
         _AddressOutputRow'datum = Prelude.Nothing,
         _AddressOutputRow'txInputs = Data.Vector.Generic.empty,
         _AddressOutputRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AddressOutputRow
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld OutputRef
             -> Data.ProtoLens.Encoding.Bytes.Parser AddressOutputRow
        loop x mutable'txInputs
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'txInputs <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                              mutable'txInputs)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'txInputs") frozen'txInputs x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "utxo_tx_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoTxHash") y x)
                                  mutable'txInputs
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                                  mutable'txInputs
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txBlockNo") y x)
                                  mutable'txInputs
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "tx_slot_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txSlotNo") y x)
                                  mutable'txInputs
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_epoch_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txEpochNo") y x)
                                  mutable'txInputs
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index_in_block"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"txIndexInBlock") y x)
                                  mutable'txInputs
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "address"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"address") y x)
                                  mutable'txInputs
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "datum"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"datum") y x)
                                  mutable'txInputs
                        74
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "tx_inputs"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'txInputs y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'txInputs
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'txInputs <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                    Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'txInputs)
          "AddressOutputRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"utxoTxHash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"utxoIndex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txBlockNo") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txSlotNo") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txEpochNo") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               _v
                                 = Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"txIndexInBlock") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                        _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v = Lens.Family2.view (Data.ProtoLens.Field.field @"address") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((Prelude..)
                                           (\ bs
                                              -> (Data.Monoid.<>)
                                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                      (Prelude.fromIntegral
                                                         (Data.ByteString.length bs)))
                                                   (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           Data.Text.Encoding.encodeUtf8 _v))
                               ((Data.Monoid.<>)
                                  (case
                                       Lens.Family2.view
                                         (Data.ProtoLens.Field.field @"maybe'datum") _x
                                   of
                                     Prelude.Nothing -> Data.Monoid.mempty
                                     (Prelude.Just _v)
                                       -> (Data.Monoid.<>)
                                            (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                            ((Prelude..)
                                               (\ bs
                                                  -> (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                          (Prelude.fromIntegral
                                                             (Data.ByteString.length bs)))
                                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                               Data.ProtoLens.encodeMessage _v))
                                  ((Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                        (\ _v
                                           -> (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                                ((Prelude..)
                                                   (\ bs
                                                      -> (Data.Monoid.<>)
                                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                              (Prelude.fromIntegral
                                                                 (Data.ByteString.length bs)))
                                                           (Data.ProtoLens.Encoding.Bytes.putBytes
                                                              bs))
                                                   Data.ProtoLens.encodeMessage _v))
                                        (Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"vec'txInputs") _x))
                                     (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                        (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))))
instance Control.DeepSeq.NFData AddressOutputRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AddressOutputRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AddressOutputRow'utxoTxHash x__)
                (Control.DeepSeq.deepseq
                   (_AddressOutputRow'utxoIndex x__)
                   (Control.DeepSeq.deepseq
                      (_AddressOutputRow'txBlockNo x__)
                      (Control.DeepSeq.deepseq
                         (_AddressOutputRow'txSlotNo x__)
                         (Control.DeepSeq.deepseq
                            (_AddressOutputRow'txEpochNo x__)
                            (Control.DeepSeq.deepseq
                               (_AddressOutputRow'txIndexInBlock x__)
                               (Control.DeepSeq.deepseq
                                  (_AddressOutputRow'address x__)
                                  (Control.DeepSeq.deepseq
                                     (_AddressOutputRow'datum x__)
                                     (Control.DeepSeq.deepseq
                                        (_AddressOutputRow'txInputs x__) ())))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' AssetCreateRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.blockHash' @:: Lens' AssetCreateRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.blockTimeUnixMillis' @:: Lens' AssetCreateRow Data.Int.Int64@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' AssetCreateRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.quantity' @:: Lens' AssetCreateRow Data.Word.Word64@
         * 'Proto.McFollower_Fields.holderAddress' @:: Lens' AssetCreateRow Data.Text.Text@
         * 'Proto.McFollower_Fields.txHash' @:: Lens' AssetCreateRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' AssetCreateRow Data.Word.Word32@ -}
data AssetCreateRow
  = AssetCreateRow'_constructor {_AssetCreateRow'blockNo :: !Data.Word.Word32,
                                 _AssetCreateRow'blockHash :: !Data.ByteString.ByteString,
                                 _AssetCreateRow'blockTimeUnixMillis :: !Data.Int.Int64,
                                 _AssetCreateRow'txIndex :: !Data.Word.Word32,
                                 _AssetCreateRow'quantity :: !Data.Word.Word64,
                                 _AssetCreateRow'holderAddress :: !Data.Text.Text,
                                 _AssetCreateRow'txHash :: !Data.ByteString.ByteString,
                                 _AssetCreateRow'utxoIndex :: !Data.Word.Word32,
                                 _AssetCreateRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AssetCreateRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AssetCreateRow "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'blockNo
           (\ x__ y__ -> x__ {_AssetCreateRow'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "blockHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'blockHash
           (\ x__ y__ -> x__ {_AssetCreateRow'blockHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "blockTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'blockTimeUnixMillis
           (\ x__ y__ -> x__ {_AssetCreateRow'blockTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'txIndex
           (\ x__ y__ -> x__ {_AssetCreateRow'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "quantity" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'quantity
           (\ x__ y__ -> x__ {_AssetCreateRow'quantity = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "holderAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'holderAddress
           (\ x__ y__ -> x__ {_AssetCreateRow'holderAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'txHash
           (\ x__ y__ -> x__ {_AssetCreateRow'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetCreateRow "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetCreateRow'utxoIndex
           (\ x__ y__ -> x__ {_AssetCreateRow'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Message AssetCreateRow where
  messageName _ = Data.Text.pack "mcfollower.v1.AssetCreateRow"
  packedMessageDescriptor _
    = "\n\
      \\SOAssetCreateRow\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\GS\n\
      \\n\
      \block_hash\CAN\STX \SOH(\fR\tblockHash\DC23\n\
      \\SYNblock_time_unix_millis\CAN\ETX \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
      \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\SUB\n\
      \\bquantity\CAN\ENQ \SOH(\EOTR\bquantity\DC2%\n\
      \\SOholder_address\CAN\ACK \SOH(\tR\rholderAddress\DC2\ETB\n\
      \\atx_hash\CAN\a \SOH(\fR\ACKtxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\b \SOH(\rR\tutxoIndex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        blockHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockHash")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        blockTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        quantity__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "quantity"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"quantity")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        holderAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "holder_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"holderAddress")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor AssetCreateRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, blockHash__field_descriptor),
           (Data.ProtoLens.Tag 3, blockTimeUnixMillis__field_descriptor),
           (Data.ProtoLens.Tag 4, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 5, quantity__field_descriptor),
           (Data.ProtoLens.Tag 6, holderAddress__field_descriptor),
           (Data.ProtoLens.Tag 7, txHash__field_descriptor),
           (Data.ProtoLens.Tag 8, utxoIndex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AssetCreateRow'_unknownFields
        (\ x__ y__ -> x__ {_AssetCreateRow'_unknownFields = y__})
  defMessage
    = AssetCreateRow'_constructor
        {_AssetCreateRow'blockNo = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'blockHash = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'blockTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'txIndex = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'quantity = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'holderAddress = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'txHash = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'utxoIndex = Data.ProtoLens.fieldDefault,
         _AssetCreateRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AssetCreateRow
          -> Data.ProtoLens.Encoding.Bytes.Parser AssetCreateRow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "block_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"blockHash") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"blockTimeUnixMillis") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "quantity"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"quantity") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "holder_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"holderAddress") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AssetCreateRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockHash") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"blockTimeUnixMillis") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"quantity") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                         ((Data.Monoid.<>)
                            (let
                               _v
                                 = Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"holderAddress") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                     ((Prelude..)
                                        (\ bs
                                           -> (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                   (Prelude.fromIntegral
                                                      (Data.ByteString.length bs)))
                                                (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                        Data.Text.Encoding.encodeUtf8 _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"utxoIndex") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral _v))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData AssetCreateRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AssetCreateRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AssetCreateRow'blockNo x__)
                (Control.DeepSeq.deepseq
                   (_AssetCreateRow'blockHash x__)
                   (Control.DeepSeq.deepseq
                      (_AssetCreateRow'blockTimeUnixMillis x__)
                      (Control.DeepSeq.deepseq
                         (_AssetCreateRow'txIndex x__)
                         (Control.DeepSeq.deepseq
                            (_AssetCreateRow'quantity x__)
                            (Control.DeepSeq.deepseq
                               (_AssetCreateRow'holderAddress x__)
                               (Control.DeepSeq.deepseq
                                  (_AssetCreateRow'txHash x__)
                                  (Control.DeepSeq.deepseq
                                     (_AssetCreateRow'utxoIndex x__) ()))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.policyId' @:: Lens' AssetId Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.assetName' @:: Lens' AssetId Data.ByteString.ByteString@ -}
data AssetId
  = AssetId'_constructor {_AssetId'policyId :: !Data.ByteString.ByteString,
                          _AssetId'assetName :: !Data.ByteString.ByteString,
                          _AssetId'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AssetId where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AssetId "policyId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetId'policyId (\ x__ y__ -> x__ {_AssetId'policyId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetId "assetName" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetId'assetName (\ x__ y__ -> x__ {_AssetId'assetName = y__}))
        Prelude.id
instance Data.ProtoLens.Message AssetId where
  messageName _ = Data.Text.pack "mcfollower.v1.AssetId"
  packedMessageDescriptor _
    = "\n\
      \\aAssetId\DC2\ESC\n\
      \\tpolicy_id\CAN\SOH \SOH(\fR\bpolicyId\DC2\GS\n\
      \\n\
      \asset_name\CAN\STX \SOH(\fR\tassetName"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        policyId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "policy_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"policyId")) ::
              Data.ProtoLens.FieldDescriptor AssetId
        assetName__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "asset_name"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"assetName")) ::
              Data.ProtoLens.FieldDescriptor AssetId
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, policyId__field_descriptor),
           (Data.ProtoLens.Tag 2, assetName__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AssetId'_unknownFields
        (\ x__ y__ -> x__ {_AssetId'_unknownFields = y__})
  defMessage
    = AssetId'_constructor
        {_AssetId'policyId = Data.ProtoLens.fieldDefault,
         _AssetId'assetName = Data.ProtoLens.fieldDefault,
         _AssetId'_unknownFields = []}
  parseMessage
    = let
        loop :: AssetId -> Data.ProtoLens.Encoding.Bytes.Parser AssetId
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "policy_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"policyId") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "asset_name"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"assetName") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AssetId"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"policyId") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"assetName") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData AssetId where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AssetId'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AssetId'policyId x__)
                (Control.DeepSeq.deepseq (_AssetId'assetName x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' AssetSpendRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.blockHash' @:: Lens' AssetSpendRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.blockTimeUnixMillis' @:: Lens' AssetSpendRow Data.Int.Int64@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' AssetSpendRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.quantity' @:: Lens' AssetSpendRow Data.Word.Word64@
         * 'Proto.McFollower_Fields.holderAddress' @:: Lens' AssetSpendRow Data.Text.Text@
         * 'Proto.McFollower_Fields.utxoTxHash' @:: Lens' AssetSpendRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' AssetSpendRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.spendingTxHash' @:: Lens' AssetSpendRow Data.ByteString.ByteString@ -}
data AssetSpendRow
  = AssetSpendRow'_constructor {_AssetSpendRow'blockNo :: !Data.Word.Word32,
                                _AssetSpendRow'blockHash :: !Data.ByteString.ByteString,
                                _AssetSpendRow'blockTimeUnixMillis :: !Data.Int.Int64,
                                _AssetSpendRow'txIndex :: !Data.Word.Word32,
                                _AssetSpendRow'quantity :: !Data.Word.Word64,
                                _AssetSpendRow'holderAddress :: !Data.Text.Text,
                                _AssetSpendRow'utxoTxHash :: !Data.ByteString.ByteString,
                                _AssetSpendRow'utxoIndex :: !Data.Word.Word32,
                                _AssetSpendRow'spendingTxHash :: !Data.ByteString.ByteString,
                                _AssetSpendRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AssetSpendRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AssetSpendRow "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'blockNo
           (\ x__ y__ -> x__ {_AssetSpendRow'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "blockHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'blockHash
           (\ x__ y__ -> x__ {_AssetSpendRow'blockHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "blockTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'blockTimeUnixMillis
           (\ x__ y__ -> x__ {_AssetSpendRow'blockTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'txIndex
           (\ x__ y__ -> x__ {_AssetSpendRow'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "quantity" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'quantity
           (\ x__ y__ -> x__ {_AssetSpendRow'quantity = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "holderAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'holderAddress
           (\ x__ y__ -> x__ {_AssetSpendRow'holderAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "utxoTxHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'utxoTxHash
           (\ x__ y__ -> x__ {_AssetSpendRow'utxoTxHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'utxoIndex
           (\ x__ y__ -> x__ {_AssetSpendRow'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AssetSpendRow "spendingTxHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AssetSpendRow'spendingTxHash
           (\ x__ y__ -> x__ {_AssetSpendRow'spendingTxHash = y__}))
        Prelude.id
instance Data.ProtoLens.Message AssetSpendRow where
  messageName _ = Data.Text.pack "mcfollower.v1.AssetSpendRow"
  packedMessageDescriptor _
    = "\n\
      \\rAssetSpendRow\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\GS\n\
      \\n\
      \block_hash\CAN\STX \SOH(\fR\tblockHash\DC23\n\
      \\SYNblock_time_unix_millis\CAN\ETX \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
      \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\SUB\n\
      \\bquantity\CAN\ENQ \SOH(\EOTR\bquantity\DC2%\n\
      \\SOholder_address\CAN\ACK \SOH(\tR\rholderAddress\DC2 \n\
      \\futxo_tx_hash\CAN\a \SOH(\fR\n\
      \utxoTxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\b \SOH(\rR\tutxoIndex\DC2(\n\
      \\DLEspending_tx_hash\CAN\t \SOH(\fR\SOspendingTxHash"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        blockHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockHash")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        blockTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        quantity__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "quantity"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"quantity")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        holderAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "holder_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"holderAddress")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        utxoTxHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoTxHash")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
        spendingTxHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "spending_tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"spendingTxHash")) ::
              Data.ProtoLens.FieldDescriptor AssetSpendRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, blockHash__field_descriptor),
           (Data.ProtoLens.Tag 3, blockTimeUnixMillis__field_descriptor),
           (Data.ProtoLens.Tag 4, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 5, quantity__field_descriptor),
           (Data.ProtoLens.Tag 6, holderAddress__field_descriptor),
           (Data.ProtoLens.Tag 7, utxoTxHash__field_descriptor),
           (Data.ProtoLens.Tag 8, utxoIndex__field_descriptor),
           (Data.ProtoLens.Tag 9, spendingTxHash__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AssetSpendRow'_unknownFields
        (\ x__ y__ -> x__ {_AssetSpendRow'_unknownFields = y__})
  defMessage
    = AssetSpendRow'_constructor
        {_AssetSpendRow'blockNo = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'blockHash = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'blockTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'txIndex = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'quantity = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'holderAddress = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'utxoTxHash = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'utxoIndex = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'spendingTxHash = Data.ProtoLens.fieldDefault,
         _AssetSpendRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AssetSpendRow -> Data.ProtoLens.Encoding.Bytes.Parser AssetSpendRow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "block_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"blockHash") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"blockTimeUnixMillis") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "quantity"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"quantity") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "holder_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"holderAddress") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "utxo_tx_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoTxHash") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "spending_tx_hash"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"spendingTxHash") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "AssetSpendRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockHash") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"blockTimeUnixMillis") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"quantity") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                         ((Data.Monoid.<>)
                            (let
                               _v
                                 = Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"holderAddress") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                     ((Prelude..)
                                        (\ bs
                                           -> (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                   (Prelude.fromIntegral
                                                      (Data.ByteString.length bs)))
                                                (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                        Data.Text.Encoding.encodeUtf8 _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"utxoTxHash") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"utxoIndex") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral _v))
                                  ((Data.Monoid.<>)
                                     (let
                                        _v
                                          = Lens.Family2.view
                                              (Data.ProtoLens.Field.field @"spendingTxHash") _x
                                      in
                                        if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                            Data.Monoid.mempty
                                        else
                                            (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                              ((\ bs
                                                  -> (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                          (Prelude.fromIntegral
                                                             (Data.ByteString.length bs)))
                                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                                 _v))
                                     (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                        (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))))
instance Control.DeepSeq.NFData AssetSpendRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AssetSpendRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AssetSpendRow'blockNo x__)
                (Control.DeepSeq.deepseq
                   (_AssetSpendRow'blockHash x__)
                   (Control.DeepSeq.deepseq
                      (_AssetSpendRow'blockTimeUnixMillis x__)
                      (Control.DeepSeq.deepseq
                         (_AssetSpendRow'txIndex x__)
                         (Control.DeepSeq.deepseq
                            (_AssetSpendRow'quantity x__)
                            (Control.DeepSeq.deepseq
                               (_AssetSpendRow'holderAddress x__)
                               (Control.DeepSeq.deepseq
                                  (_AssetSpendRow'utxoTxHash x__)
                                  (Control.DeepSeq.deepseq
                                     (_AssetSpendRow'utxoIndex x__)
                                     (Control.DeepSeq.deepseq
                                        (_AssetSpendRow'spendingTxHash x__) ())))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' Block Data.Word.Word32@
         * 'Proto.McFollower_Fields.hash' @:: Lens' Block Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' Block Data.Word.Word32@
         * 'Proto.McFollower_Fields.slotNo' @:: Lens' Block Data.Word.Word64@
         * 'Proto.McFollower_Fields.timeUnixSeconds' @:: Lens' Block Data.Int.Int64@
         * 'Proto.McFollower_Fields.txCount' @:: Lens' Block Data.Word.Word64@ -}
data Block
  = Block'_constructor {_Block'blockNo :: !Data.Word.Word32,
                        _Block'hash :: !Data.ByteString.ByteString,
                        _Block'epochNo :: !Data.Word.Word32,
                        _Block'slotNo :: !Data.Word.Word64,
                        _Block'timeUnixSeconds :: !Data.Int.Int64,
                        _Block'txCount :: !Data.Word.Word64,
                        _Block'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Block where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Block "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'blockNo (\ x__ y__ -> x__ {_Block'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Block "hash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'hash (\ x__ y__ -> x__ {_Block'hash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Block "epochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'epochNo (\ x__ y__ -> x__ {_Block'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Block "slotNo" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'slotNo (\ x__ y__ -> x__ {_Block'slotNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Block "timeUnixSeconds" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'timeUnixSeconds
           (\ x__ y__ -> x__ {_Block'timeUnixSeconds = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Block "txCount" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Block'txCount (\ x__ y__ -> x__ {_Block'txCount = y__}))
        Prelude.id
instance Data.ProtoLens.Message Block where
  messageName _ = Data.Text.pack "mcfollower.v1.Block"
  packedMessageDescriptor _
    = "\n\
      \\ENQBlock\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\DC2\n\
      \\EOThash\CAN\STX \SOH(\fR\EOThash\DC2\EM\n\
      \\bepoch_no\CAN\ETX \SOH(\rR\aepochNo\DC2\ETB\n\
      \\aslot_no\CAN\EOT \SOH(\EOTR\ACKslotNo\DC2*\n\
      \\DC1time_unix_seconds\CAN\ENQ \SOH(\ETXR\SItimeUnixSeconds\DC2\EM\n\
      \\btx_count\CAN\ACK \SOH(\EOTR\atxCount"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor Block
        hash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"hash")) ::
              Data.ProtoLens.FieldDescriptor Block
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"epochNo")) ::
              Data.ProtoLens.FieldDescriptor Block
        slotNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "slot_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"slotNo")) ::
              Data.ProtoLens.FieldDescriptor Block
        timeUnixSeconds__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_seconds"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixSeconds")) ::
              Data.ProtoLens.FieldDescriptor Block
        txCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txCount")) ::
              Data.ProtoLens.FieldDescriptor Block
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, hash__field_descriptor),
           (Data.ProtoLens.Tag 3, epochNo__field_descriptor),
           (Data.ProtoLens.Tag 4, slotNo__field_descriptor),
           (Data.ProtoLens.Tag 5, timeUnixSeconds__field_descriptor),
           (Data.ProtoLens.Tag 6, txCount__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Block'_unknownFields
        (\ x__ y__ -> x__ {_Block'_unknownFields = y__})
  defMessage
    = Block'_constructor
        {_Block'blockNo = Data.ProtoLens.fieldDefault,
         _Block'hash = Data.ProtoLens.fieldDefault,
         _Block'epochNo = Data.ProtoLens.fieldDefault,
         _Block'slotNo = Data.ProtoLens.fieldDefault,
         _Block'timeUnixSeconds = Data.ProtoLens.fieldDefault,
         _Block'txCount = Data.ProtoLens.fieldDefault,
         _Block'_unknownFields = []}
  parseMessage
    = let
        loop :: Block -> Data.ProtoLens.Encoding.Bytes.Parser Block
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"hash") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "slot_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"slotNo") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "time_unix_seconds"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixSeconds") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "tx_count"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txCount") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Block"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"hash") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"epochNo") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"slotNo") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                      ((Data.Monoid.<>)
                         (let
                            _v
                              = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"timeUnixSeconds") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txCount") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData Block where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Block'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Block'blockNo x__)
                (Control.DeepSeq.deepseq
                   (_Block'hash x__)
                   (Control.DeepSeq.deepseq
                      (_Block'epochNo x__)
                      (Control.DeepSeq.deepseq
                         (_Block'slotNo x__)
                         (Control.DeepSeq.deepseq
                            (_Block'timeUnixSeconds x__)
                            (Control.DeepSeq.deepseq (_Block'txCount x__) ()))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' BridgeTxRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' BridgeTxRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txHash' @:: Lens' BridgeTxRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.c2mMetadatumCbor' @:: Lens' BridgeTxRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.maybe'c2mMetadatumCbor' @:: Lens' BridgeTxRow (Prelude.Maybe Data.ByteString.ByteString)@
         * 'Proto.McFollower_Fields.bridgeIn' @:: Lens' BridgeTxRow Uint128@
         * 'Proto.McFollower_Fields.maybe'bridgeIn' @:: Lens' BridgeTxRow (Prelude.Maybe Uint128)@
         * 'Proto.McFollower_Fields.bridgeOut' @:: Lens' BridgeTxRow Uint128@
         * 'Proto.McFollower_Fields.maybe'bridgeOut' @:: Lens' BridgeTxRow (Prelude.Maybe Uint128)@
         * 'Proto.McFollower_Fields.reserveIn' @:: Lens' BridgeTxRow Uint128@
         * 'Proto.McFollower_Fields.maybe'reserveIn' @:: Lens' BridgeTxRow (Prelude.Maybe Uint128)@
         * 'Proto.McFollower_Fields.reserveOut' @:: Lens' BridgeTxRow Uint128@
         * 'Proto.McFollower_Fields.maybe'reserveOut' @:: Lens' BridgeTxRow (Prelude.Maybe Uint128)@ -}
data BridgeTxRow
  = BridgeTxRow'_constructor {_BridgeTxRow'blockNo :: !Data.Word.Word32,
                              _BridgeTxRow'txIndex :: !Data.Word.Word32,
                              _BridgeTxRow'txHash :: !Data.ByteString.ByteString,
                              _BridgeTxRow'c2mMetadatumCbor :: !(Prelude.Maybe Data.ByteString.ByteString),
                              _BridgeTxRow'bridgeIn :: !(Prelude.Maybe Uint128),
                              _BridgeTxRow'bridgeOut :: !(Prelude.Maybe Uint128),
                              _BridgeTxRow'reserveIn :: !(Prelude.Maybe Uint128),
                              _BridgeTxRow'reserveOut :: !(Prelude.Maybe Uint128),
                              _BridgeTxRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show BridgeTxRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField BridgeTxRow "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'blockNo
           (\ x__ y__ -> x__ {_BridgeTxRow'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'txIndex
           (\ x__ y__ -> x__ {_BridgeTxRow'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'txHash (\ x__ y__ -> x__ {_BridgeTxRow'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "c2mMetadatumCbor" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'c2mMetadatumCbor
           (\ x__ y__ -> x__ {_BridgeTxRow'c2mMetadatumCbor = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField BridgeTxRow "maybe'c2mMetadatumCbor" (Prelude.Maybe Data.ByteString.ByteString) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'c2mMetadatumCbor
           (\ x__ y__ -> x__ {_BridgeTxRow'c2mMetadatumCbor = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "bridgeIn" Uint128 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'bridgeIn
           (\ x__ y__ -> x__ {_BridgeTxRow'bridgeIn = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BridgeTxRow "maybe'bridgeIn" (Prelude.Maybe Uint128) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'bridgeIn
           (\ x__ y__ -> x__ {_BridgeTxRow'bridgeIn = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "bridgeOut" Uint128 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'bridgeOut
           (\ x__ y__ -> x__ {_BridgeTxRow'bridgeOut = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BridgeTxRow "maybe'bridgeOut" (Prelude.Maybe Uint128) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'bridgeOut
           (\ x__ y__ -> x__ {_BridgeTxRow'bridgeOut = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "reserveIn" Uint128 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'reserveIn
           (\ x__ y__ -> x__ {_BridgeTxRow'reserveIn = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BridgeTxRow "maybe'reserveIn" (Prelude.Maybe Uint128) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'reserveIn
           (\ x__ y__ -> x__ {_BridgeTxRow'reserveIn = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField BridgeTxRow "reserveOut" Uint128 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'reserveOut
           (\ x__ y__ -> x__ {_BridgeTxRow'reserveOut = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField BridgeTxRow "maybe'reserveOut" (Prelude.Maybe Uint128) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _BridgeTxRow'reserveOut
           (\ x__ y__ -> x__ {_BridgeTxRow'reserveOut = y__}))
        Prelude.id
instance Data.ProtoLens.Message BridgeTxRow where
  messageName _ = Data.Text.pack "mcfollower.v1.BridgeTxRow"
  packedMessageDescriptor _
    = "\n\
      \\vBridgeTxRow\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\EM\n\
      \\btx_index\CAN\STX \SOH(\rR\atxIndex\DC2\ETB\n\
      \\atx_hash\CAN\ETX \SOH(\fR\ACKtxHash\DC21\n\
      \\DC2c2m_metadatum_cbor\CAN\EOT \SOH(\fH\NULR\DLEc2mMetadatumCbor\136\SOH\SOH\DC23\n\
      \\tbridge_in\CAN\ENQ \SOH(\v2\SYN.mcfollower.v1.Uint128R\bbridgeIn\DC25\n\
      \\n\
      \bridge_out\CAN\ACK \SOH(\v2\SYN.mcfollower.v1.Uint128R\tbridgeOut\DC25\n\
      \\n\
      \reserve_in\CAN\a \SOH(\v2\SYN.mcfollower.v1.Uint128R\treserveIn\DC27\n\
      \\vreserve_out\CAN\b \SOH(\v2\SYN.mcfollower.v1.Uint128R\n\
      \reserveOutB\NAK\n\
      \\DC3_c2m_metadatum_cbor"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        c2mMetadatumCbor__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "c2m_metadatum_cbor"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'c2mMetadatumCbor")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        bridgeIn__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "bridge_in"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Uint128)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'bridgeIn")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        bridgeOut__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "bridge_out"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Uint128)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'bridgeOut")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        reserveIn__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "reserve_in"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Uint128)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'reserveIn")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
        reserveOut__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "reserve_out"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Uint128)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'reserveOut")) ::
              Data.ProtoLens.FieldDescriptor BridgeTxRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 3, txHash__field_descriptor),
           (Data.ProtoLens.Tag 4, c2mMetadatumCbor__field_descriptor),
           (Data.ProtoLens.Tag 5, bridgeIn__field_descriptor),
           (Data.ProtoLens.Tag 6, bridgeOut__field_descriptor),
           (Data.ProtoLens.Tag 7, reserveIn__field_descriptor),
           (Data.ProtoLens.Tag 8, reserveOut__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _BridgeTxRow'_unknownFields
        (\ x__ y__ -> x__ {_BridgeTxRow'_unknownFields = y__})
  defMessage
    = BridgeTxRow'_constructor
        {_BridgeTxRow'blockNo = Data.ProtoLens.fieldDefault,
         _BridgeTxRow'txIndex = Data.ProtoLens.fieldDefault,
         _BridgeTxRow'txHash = Data.ProtoLens.fieldDefault,
         _BridgeTxRow'c2mMetadatumCbor = Prelude.Nothing,
         _BridgeTxRow'bridgeIn = Prelude.Nothing,
         _BridgeTxRow'bridgeOut = Prelude.Nothing,
         _BridgeTxRow'reserveIn = Prelude.Nothing,
         _BridgeTxRow'reserveOut = Prelude.Nothing,
         _BridgeTxRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          BridgeTxRow -> Data.ProtoLens.Encoding.Bytes.Parser BridgeTxRow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "c2m_metadatum_cbor"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"c2mMetadatumCbor") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "bridge_in"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"bridgeIn") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "bridge_out"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"bridgeOut") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "reserve_in"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"reserveIn") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "reserve_out"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"reserveOut") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "BridgeTxRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               _v))
                   ((Data.Monoid.<>)
                      (case
                           Lens.Family2.view
                             (Data.ProtoLens.Field.field @"maybe'c2mMetadatumCbor") _x
                       of
                         Prelude.Nothing -> Data.Monoid.mempty
                         (Prelude.Just _v)
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                                ((\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   _v))
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'bridgeIn") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v)
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                   ((Prelude..)
                                      (\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                      Data.ProtoLens.encodeMessage _v))
                         ((Data.Monoid.<>)
                            (case
                                 Lens.Family2.view
                                   (Data.ProtoLens.Field.field @"maybe'bridgeOut") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just _v)
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage _v))
                            ((Data.Monoid.<>)
                               (case
                                    Lens.Family2.view
                                      (Data.ProtoLens.Field.field @"maybe'reserveIn") _x
                                of
                                  Prelude.Nothing -> Data.Monoid.mempty
                                  (Prelude.Just _v)
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                         ((Prelude..)
                                            (\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                            Data.ProtoLens.encodeMessage _v))
                               ((Data.Monoid.<>)
                                  (case
                                       Lens.Family2.view
                                         (Data.ProtoLens.Field.field @"maybe'reserveOut") _x
                                   of
                                     Prelude.Nothing -> Data.Monoid.mempty
                                     (Prelude.Just _v)
                                       -> (Data.Monoid.<>)
                                            (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                            ((Prelude..)
                                               (\ bs
                                                  -> (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                          (Prelude.fromIntegral
                                                             (Data.ByteString.length bs)))
                                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                               Data.ProtoLens.encodeMessage _v))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData BridgeTxRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_BridgeTxRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_BridgeTxRow'blockNo x__)
                (Control.DeepSeq.deepseq
                   (_BridgeTxRow'txIndex x__)
                   (Control.DeepSeq.deepseq
                      (_BridgeTxRow'txHash x__)
                      (Control.DeepSeq.deepseq
                         (_BridgeTxRow'c2mMetadatumCbor x__)
                         (Control.DeepSeq.deepseq
                            (_BridgeTxRow'bridgeIn x__)
                            (Control.DeepSeq.deepseq
                               (_BridgeTxRow'bridgeOut x__)
                               (Control.DeepSeq.deepseq
                                  (_BridgeTxRow'reserveIn x__)
                                  (Control.DeepSeq.deepseq (_BridgeTxRow'reserveOut x__) ()))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.cbor' @:: Lens' Datum Data.ByteString.ByteString@ -}
data Datum
  = Datum'_constructor {_Datum'cbor :: !Data.ByteString.ByteString,
                        _Datum'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Datum where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Datum "cbor" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Datum'cbor (\ x__ y__ -> x__ {_Datum'cbor = y__}))
        Prelude.id
instance Data.ProtoLens.Message Datum where
  messageName _ = Data.Text.pack "mcfollower.v1.Datum"
  packedMessageDescriptor _
    = "\n\
      \\ENQDatum\DC2\DC2\n\
      \\EOTcbor\CAN\SOH \SOH(\fR\EOTcbor"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        cbor__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "cbor"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"cbor")) ::
              Data.ProtoLens.FieldDescriptor Datum
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, cbor__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Datum'_unknownFields
        (\ x__ y__ -> x__ {_Datum'_unknownFields = y__})
  defMessage
    = Datum'_constructor
        {_Datum'cbor = Data.ProtoLens.fieldDefault,
         _Datum'_unknownFields = []}
  parseMessage
    = let
        loop :: Datum -> Data.ProtoLens.Encoding.Bytes.Parser Datum
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "cbor"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"cbor") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Datum"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"cbor") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData Datum where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Datum'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Datum'cbor x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.datum' @:: Lens' DeregistrationRow Datum@
         * 'Proto.McFollower_Fields.maybe'datum' @:: Lens' DeregistrationRow (Prelude.Maybe Datum)@
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' DeregistrationRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.blockHash' @:: Lens' DeregistrationRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.blockTimeUnixMillis' @:: Lens' DeregistrationRow Data.Int.Int64@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' DeregistrationRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txHash' @:: Lens' DeregistrationRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoTxHash' @:: Lens' DeregistrationRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' DeregistrationRow Data.Word.Word32@ -}
data DeregistrationRow
  = DeregistrationRow'_constructor {_DeregistrationRow'datum :: !(Prelude.Maybe Datum),
                                    _DeregistrationRow'blockNo :: !Data.Word.Word32,
                                    _DeregistrationRow'blockHash :: !Data.ByteString.ByteString,
                                    _DeregistrationRow'blockTimeUnixMillis :: !Data.Int.Int64,
                                    _DeregistrationRow'txIndex :: !Data.Word.Word32,
                                    _DeregistrationRow'txHash :: !Data.ByteString.ByteString,
                                    _DeregistrationRow'utxoTxHash :: !Data.ByteString.ByteString,
                                    _DeregistrationRow'utxoIndex :: !Data.Word.Word32,
                                    _DeregistrationRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show DeregistrationRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField DeregistrationRow "datum" Datum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'datum
           (\ x__ y__ -> x__ {_DeregistrationRow'datum = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField DeregistrationRow "maybe'datum" (Prelude.Maybe Datum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'datum
           (\ x__ y__ -> x__ {_DeregistrationRow'datum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'blockNo
           (\ x__ y__ -> x__ {_DeregistrationRow'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "blockHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'blockHash
           (\ x__ y__ -> x__ {_DeregistrationRow'blockHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "blockTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'blockTimeUnixMillis
           (\ x__ y__ -> x__ {_DeregistrationRow'blockTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'txIndex
           (\ x__ y__ -> x__ {_DeregistrationRow'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'txHash
           (\ x__ y__ -> x__ {_DeregistrationRow'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "utxoTxHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'utxoTxHash
           (\ x__ y__ -> x__ {_DeregistrationRow'utxoTxHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField DeregistrationRow "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _DeregistrationRow'utxoIndex
           (\ x__ y__ -> x__ {_DeregistrationRow'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Message DeregistrationRow where
  messageName _ = Data.Text.pack "mcfollower.v1.DeregistrationRow"
  packedMessageDescriptor _
    = "\n\
      \\DC1DeregistrationRow\DC2*\n\
      \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
      \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
      \\n\
      \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC23\n\
      \\SYNblock_time_unix_millis\CAN\EOT \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
      \\btx_index\CAN\ENQ \SOH(\rR\atxIndex\DC2\ETB\n\
      \\atx_hash\CAN\ACK \SOH(\fR\ACKtxHash\DC2 \n\
      \\futxo_tx_hash\CAN\a \SOH(\fR\n\
      \utxoTxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\b \SOH(\rR\tutxoIndex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        datum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "datum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Datum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'datum")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        blockHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockHash")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        blockTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        utxoTxHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoTxHash")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor DeregistrationRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, datum__field_descriptor),
           (Data.ProtoLens.Tag 2, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 3, blockHash__field_descriptor),
           (Data.ProtoLens.Tag 4, blockTimeUnixMillis__field_descriptor),
           (Data.ProtoLens.Tag 5, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 6, txHash__field_descriptor),
           (Data.ProtoLens.Tag 7, utxoTxHash__field_descriptor),
           (Data.ProtoLens.Tag 8, utxoIndex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _DeregistrationRow'_unknownFields
        (\ x__ y__ -> x__ {_DeregistrationRow'_unknownFields = y__})
  defMessage
    = DeregistrationRow'_constructor
        {_DeregistrationRow'datum = Prelude.Nothing,
         _DeregistrationRow'blockNo = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'blockHash = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'blockTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'txIndex = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'txHash = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'utxoTxHash = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'utxoIndex = Data.ProtoLens.fieldDefault,
         _DeregistrationRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          DeregistrationRow
          -> Data.ProtoLens.Encoding.Bytes.Parser DeregistrationRow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "datum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"datum") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "block_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"blockHash") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"blockTimeUnixMillis") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "utxo_tx_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoTxHash") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "DeregistrationRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'datum") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockHash") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"blockTimeUnixMillis") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                     ((\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                        _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"utxoTxHash") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"utxoIndex") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral _v))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData DeregistrationRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_DeregistrationRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_DeregistrationRow'datum x__)
                (Control.DeepSeq.deepseq
                   (_DeregistrationRow'blockNo x__)
                   (Control.DeepSeq.deepseq
                      (_DeregistrationRow'blockHash x__)
                      (Control.DeepSeq.deepseq
                         (_DeregistrationRow'blockTimeUnixMillis x__)
                         (Control.DeepSeq.deepseq
                            (_DeregistrationRow'txIndex x__)
                            (Control.DeepSeq.deepseq
                               (_DeregistrationRow'txHash x__)
                               (Control.DeepSeq.deepseq
                                  (_DeregistrationRow'utxoTxHash x__)
                                  (Control.DeepSeq.deepseq
                                     (_DeregistrationRow'utxoIndex x__) ()))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.asset' @:: Lens' GetAssetCreatesRequest AssetId@
         * 'Proto.McFollower_Fields.maybe'asset' @:: Lens' GetAssetCreatesRequest (Prelude.Maybe AssetId)@
         * 'Proto.McFollower_Fields.window' @:: Lens' GetAssetCreatesRequest PositionWindow@
         * 'Proto.McFollower_Fields.maybe'window' @:: Lens' GetAssetCreatesRequest (Prelude.Maybe PositionWindow)@
         * 'Proto.McFollower_Fields.limit' @:: Lens' GetAssetCreatesRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.offset' @:: Lens' GetAssetCreatesRequest Data.Word.Word32@ -}
data GetAssetCreatesRequest
  = GetAssetCreatesRequest'_constructor {_GetAssetCreatesRequest'asset :: !(Prelude.Maybe AssetId),
                                         _GetAssetCreatesRequest'window :: !(Prelude.Maybe PositionWindow),
                                         _GetAssetCreatesRequest'limit :: !Data.Word.Word32,
                                         _GetAssetCreatesRequest'offset :: !Data.Word.Word32,
                                         _GetAssetCreatesRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetAssetCreatesRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "asset" AssetId where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'asset
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'asset = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "maybe'asset" (Prelude.Maybe AssetId) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'asset
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'asset = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "window" PositionWindow where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'window
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'window = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "maybe'window" (Prelude.Maybe PositionWindow) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'window
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'window = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "limit" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'limit
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'limit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetCreatesRequest "offset" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetCreatesRequest'offset
           (\ x__ y__ -> x__ {_GetAssetCreatesRequest'offset = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetAssetCreatesRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetAssetCreatesRequest"
  packedMessageDescriptor _
    = "\n\
      \\SYNGetAssetCreatesRequest\DC2,\n\
      \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC25\n\
      \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
      \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
      \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        asset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "asset"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AssetId)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asset")) ::
              Data.ProtoLens.FieldDescriptor GetAssetCreatesRequest
        window__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "window"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor PositionWindow)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'window")) ::
              Data.ProtoLens.FieldDescriptor GetAssetCreatesRequest
        limit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "limit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"limit")) ::
              Data.ProtoLens.FieldDescriptor GetAssetCreatesRequest
        offset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"offset")) ::
              Data.ProtoLens.FieldDescriptor GetAssetCreatesRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, asset__field_descriptor),
           (Data.ProtoLens.Tag 2, window__field_descriptor),
           (Data.ProtoLens.Tag 3, limit__field_descriptor),
           (Data.ProtoLens.Tag 4, offset__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetAssetCreatesRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetAssetCreatesRequest'_unknownFields = y__})
  defMessage
    = GetAssetCreatesRequest'_constructor
        {_GetAssetCreatesRequest'asset = Prelude.Nothing,
         _GetAssetCreatesRequest'window = Prelude.Nothing,
         _GetAssetCreatesRequest'limit = Data.ProtoLens.fieldDefault,
         _GetAssetCreatesRequest'offset = Data.ProtoLens.fieldDefault,
         _GetAssetCreatesRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetAssetCreatesRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetAssetCreatesRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "asset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"asset") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "window"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"window") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "limit"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"limit") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "offset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"offset") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetAssetCreatesRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'asset") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'window") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"limit") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"offset") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData GetAssetCreatesRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetAssetCreatesRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetAssetCreatesRequest'asset x__)
                (Control.DeepSeq.deepseq
                   (_GetAssetCreatesRequest'window x__)
                   (Control.DeepSeq.deepseq
                      (_GetAssetCreatesRequest'limit x__)
                      (Control.DeepSeq.deepseq
                         (_GetAssetCreatesRequest'offset x__) ()))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.asset' @:: Lens' GetAssetSpendsRequest AssetId@
         * 'Proto.McFollower_Fields.maybe'asset' @:: Lens' GetAssetSpendsRequest (Prelude.Maybe AssetId)@
         * 'Proto.McFollower_Fields.window' @:: Lens' GetAssetSpendsRequest PositionWindow@
         * 'Proto.McFollower_Fields.maybe'window' @:: Lens' GetAssetSpendsRequest (Prelude.Maybe PositionWindow)@
         * 'Proto.McFollower_Fields.limit' @:: Lens' GetAssetSpendsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.offset' @:: Lens' GetAssetSpendsRequest Data.Word.Word32@ -}
data GetAssetSpendsRequest
  = GetAssetSpendsRequest'_constructor {_GetAssetSpendsRequest'asset :: !(Prelude.Maybe AssetId),
                                        _GetAssetSpendsRequest'window :: !(Prelude.Maybe PositionWindow),
                                        _GetAssetSpendsRequest'limit :: !Data.Word.Word32,
                                        _GetAssetSpendsRequest'offset :: !Data.Word.Word32,
                                        _GetAssetSpendsRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetAssetSpendsRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "asset" AssetId where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'asset
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'asset = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "maybe'asset" (Prelude.Maybe AssetId) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'asset
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'asset = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "window" PositionWindow where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'window
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'window = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "maybe'window" (Prelude.Maybe PositionWindow) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'window
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'window = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "limit" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'limit
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'limit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetAssetSpendsRequest "offset" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetAssetSpendsRequest'offset
           (\ x__ y__ -> x__ {_GetAssetSpendsRequest'offset = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetAssetSpendsRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetAssetSpendsRequest"
  packedMessageDescriptor _
    = "\n\
      \\NAKGetAssetSpendsRequest\DC2,\n\
      \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC25\n\
      \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
      \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
      \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        asset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "asset"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AssetId)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asset")) ::
              Data.ProtoLens.FieldDescriptor GetAssetSpendsRequest
        window__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "window"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor PositionWindow)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'window")) ::
              Data.ProtoLens.FieldDescriptor GetAssetSpendsRequest
        limit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "limit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"limit")) ::
              Data.ProtoLens.FieldDescriptor GetAssetSpendsRequest
        offset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"offset")) ::
              Data.ProtoLens.FieldDescriptor GetAssetSpendsRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, asset__field_descriptor),
           (Data.ProtoLens.Tag 2, window__field_descriptor),
           (Data.ProtoLens.Tag 3, limit__field_descriptor),
           (Data.ProtoLens.Tag 4, offset__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetAssetSpendsRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetAssetSpendsRequest'_unknownFields = y__})
  defMessage
    = GetAssetSpendsRequest'_constructor
        {_GetAssetSpendsRequest'asset = Prelude.Nothing,
         _GetAssetSpendsRequest'window = Prelude.Nothing,
         _GetAssetSpendsRequest'limit = Data.ProtoLens.fieldDefault,
         _GetAssetSpendsRequest'offset = Data.ProtoLens.fieldDefault,
         _GetAssetSpendsRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetAssetSpendsRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetAssetSpendsRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "asset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"asset") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "window"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"window") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "limit"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"limit") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "offset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"offset") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetAssetSpendsRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'asset") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'window") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"limit") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"offset") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData GetAssetSpendsRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetAssetSpendsRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetAssetSpendsRequest'asset x__)
                (Control.DeepSeq.deepseq
                   (_GetAssetSpendsRequest'window x__)
                   (Control.DeepSeq.deepseq
                      (_GetAssetSpendsRequest'limit x__)
                      (Control.DeepSeq.deepseq (_GetAssetSpendsRequest'offset x__) ()))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.hash' @:: Lens' GetBlockByHashRequest Data.ByteString.ByteString@ -}
data GetBlockByHashRequest
  = GetBlockByHashRequest'_constructor {_GetBlockByHashRequest'hash :: !Data.ByteString.ByteString,
                                        _GetBlockByHashRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetBlockByHashRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetBlockByHashRequest "hash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBlockByHashRequest'hash
           (\ x__ y__ -> x__ {_GetBlockByHashRequest'hash = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetBlockByHashRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetBlockByHashRequest"
  packedMessageDescriptor _
    = "\n\
      \\NAKGetBlockByHashRequest\DC2\DC2\n\
      \\EOThash\CAN\SOH \SOH(\fR\EOThash"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        hash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"hash")) ::
              Data.ProtoLens.FieldDescriptor GetBlockByHashRequest
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, hash__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetBlockByHashRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetBlockByHashRequest'_unknownFields = y__})
  defMessage
    = GetBlockByHashRequest'_constructor
        {_GetBlockByHashRequest'hash = Data.ProtoLens.fieldDefault,
         _GetBlockByHashRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetBlockByHashRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetBlockByHashRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"hash") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetBlockByHashRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"hash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetBlockByHashRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetBlockByHashRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetBlockByHashRequest'hash x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.fromBlockNo' @:: Lens' GetBlocksByNumberRangeRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.toBlockNo' @:: Lens' GetBlocksByNumberRangeRequest Data.Word.Word32@ -}
data GetBlocksByNumberRangeRequest
  = GetBlocksByNumberRangeRequest'_constructor {_GetBlocksByNumberRangeRequest'fromBlockNo :: !Data.Word.Word32,
                                                _GetBlocksByNumberRangeRequest'toBlockNo :: !Data.Word.Word32,
                                                _GetBlocksByNumberRangeRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetBlocksByNumberRangeRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetBlocksByNumberRangeRequest "fromBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBlocksByNumberRangeRequest'fromBlockNo
           (\ x__ y__
              -> x__ {_GetBlocksByNumberRangeRequest'fromBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBlocksByNumberRangeRequest "toBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBlocksByNumberRangeRequest'toBlockNo
           (\ x__ y__
              -> x__ {_GetBlocksByNumberRangeRequest'toBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetBlocksByNumberRangeRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetBlocksByNumberRangeRequest"
  packedMessageDescriptor _
    = "\n\
      \\GSGetBlocksByNumberRangeRequest\DC2\"\n\
      \\rfrom_block_no\CAN\SOH \SOH(\rR\vfromBlockNo\DC2\RS\n\
      \\vto_block_no\CAN\STX \SOH(\rR\ttoBlockNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fromBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "from_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"fromBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetBlocksByNumberRangeRequest
        toBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "to_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"toBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetBlocksByNumberRangeRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, fromBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, toBlockNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetBlocksByNumberRangeRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetBlocksByNumberRangeRequest'_unknownFields = y__})
  defMessage
    = GetBlocksByNumberRangeRequest'_constructor
        {_GetBlocksByNumberRangeRequest'fromBlockNo = Data.ProtoLens.fieldDefault,
         _GetBlocksByNumberRangeRequest'toBlockNo = Data.ProtoLens.fieldDefault,
         _GetBlocksByNumberRangeRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetBlocksByNumberRangeRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetBlocksByNumberRangeRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "from_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"fromBlockNo") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "to_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"toBlockNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetBlocksByNumberRangeRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"fromBlockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"toBlockNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData GetBlocksByNumberRangeRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetBlocksByNumberRangeRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetBlocksByNumberRangeRequest'fromBlockNo x__)
                (Control.DeepSeq.deepseq
                   (_GetBlocksByNumberRangeRequest'toBlockNo x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.icsAddress' @:: Lens' GetBridgeTxsRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.reserveAddress' @:: Lens' GetBridgeTxsRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.token' @:: Lens' GetBridgeTxsRequest AssetId@
         * 'Proto.McFollower_Fields.maybe'token' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe AssetId)@
         * 'Proto.McFollower_Fields.toBlockNo' @:: Lens' GetBridgeTxsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.maxTxs' @:: Lens' GetBridgeTxsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.maybe'maxTxs' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe Data.Word.Word32)@
         * 'Proto.McFollower_Fields.maybe'lower' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe GetBridgeTxsRequest'Lower)@
         * 'Proto.McFollower_Fields.maybe'afterBlockNo' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe Data.Word.Word32)@
         * 'Proto.McFollower_Fields.afterBlockNo' @:: Lens' GetBridgeTxsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.maybe'afterPosition' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe Position)@
         * 'Proto.McFollower_Fields.afterPosition' @:: Lens' GetBridgeTxsRequest Position@
         * 'Proto.McFollower_Fields.maybe'fromPosition' @:: Lens' GetBridgeTxsRequest (Prelude.Maybe Position)@
         * 'Proto.McFollower_Fields.fromPosition' @:: Lens' GetBridgeTxsRequest Position@ -}
data GetBridgeTxsRequest
  = GetBridgeTxsRequest'_constructor {_GetBridgeTxsRequest'icsAddress :: !Data.Text.Text,
                                      _GetBridgeTxsRequest'reserveAddress :: !Data.Text.Text,
                                      _GetBridgeTxsRequest'token :: !(Prelude.Maybe AssetId),
                                      _GetBridgeTxsRequest'toBlockNo :: !Data.Word.Word32,
                                      _GetBridgeTxsRequest'maxTxs :: !(Prelude.Maybe Data.Word.Word32),
                                      _GetBridgeTxsRequest'lower :: !(Prelude.Maybe GetBridgeTxsRequest'Lower),
                                      _GetBridgeTxsRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetBridgeTxsRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data GetBridgeTxsRequest'Lower
  = GetBridgeTxsRequest'AfterBlockNo !Data.Word.Word32 |
    GetBridgeTxsRequest'AfterPosition !Position |
    GetBridgeTxsRequest'FromPosition !Position
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "icsAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'icsAddress
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'icsAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "reserveAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'reserveAddress
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'reserveAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "token" AssetId where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'token
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'token = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'token" (Prelude.Maybe AssetId) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'token
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'token = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "toBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'toBlockNo
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'toBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maxTxs" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'maxTxs
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'maxTxs = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'maxTxs" (Prelude.Maybe Data.Word.Word32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'maxTxs
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'maxTxs = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'lower" (Prelude.Maybe GetBridgeTxsRequest'Lower) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'afterBlockNo" (Prelude.Maybe Data.Word.Word32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (GetBridgeTxsRequest'AfterBlockNo x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'AfterBlockNo y__))
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "afterBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (GetBridgeTxsRequest'AfterBlockNo x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'AfterBlockNo y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'afterPosition" (Prelude.Maybe Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (GetBridgeTxsRequest'AfterPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'AfterPosition y__))
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "afterPosition" Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (GetBridgeTxsRequest'AfterPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'AfterPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "maybe'fromPosition" (Prelude.Maybe Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (GetBridgeTxsRequest'FromPosition x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'FromPosition y__))
instance Data.ProtoLens.Field.HasField GetBridgeTxsRequest "fromPosition" Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetBridgeTxsRequest'lower
           (\ x__ y__ -> x__ {_GetBridgeTxsRequest'lower = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (GetBridgeTxsRequest'FromPosition x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap GetBridgeTxsRequest'FromPosition y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message GetBridgeTxsRequest where
  messageName _ = Data.Text.pack "mcfollower.v1.GetBridgeTxsRequest"
  packedMessageDescriptor _
    = "\n\
      \\DC3GetBridgeTxsRequest\DC2\US\n\
      \\vics_address\CAN\SOH \SOH(\tR\n\
      \icsAddress\DC2'\n\
      \\SIreserve_address\CAN\STX \SOH(\tR\SOreserveAddress\DC2,\n\
      \\ENQtoken\CAN\ETX \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQtoken\DC2&\n\
      \\SOafter_block_no\CAN\EOT \SOH(\rH\NULR\fafterBlockNo\DC2@\n\
      \\SOafter_position\CAN\ENQ \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\rafterPosition\DC2>\n\
      \\rfrom_position\CAN\ACK \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\ffromPosition\DC2\RS\n\
      \\vto_block_no\CAN\a \SOH(\rR\ttoBlockNo\DC2\FS\n\
      \\amax_txs\CAN\b \SOH(\rH\SOHR\ACKmaxTxs\136\SOH\SOHB\a\n\
      \\ENQlowerB\n\
      \\n\
      \\b_max_txs"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        icsAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ics_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"icsAddress")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        reserveAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "reserve_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"reserveAddress")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        token__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "token"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AssetId)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'token")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        toBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "to_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"toBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        maxTxs__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_txs"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'maxTxs")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        afterBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "after_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'afterBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        afterPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "after_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'afterPosition")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
        fromPosition__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "from_position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fromPosition")) ::
              Data.ProtoLens.FieldDescriptor GetBridgeTxsRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, icsAddress__field_descriptor),
           (Data.ProtoLens.Tag 2, reserveAddress__field_descriptor),
           (Data.ProtoLens.Tag 3, token__field_descriptor),
           (Data.ProtoLens.Tag 7, toBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 8, maxTxs__field_descriptor),
           (Data.ProtoLens.Tag 4, afterBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 5, afterPosition__field_descriptor),
           (Data.ProtoLens.Tag 6, fromPosition__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetBridgeTxsRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetBridgeTxsRequest'_unknownFields = y__})
  defMessage
    = GetBridgeTxsRequest'_constructor
        {_GetBridgeTxsRequest'icsAddress = Data.ProtoLens.fieldDefault,
         _GetBridgeTxsRequest'reserveAddress = Data.ProtoLens.fieldDefault,
         _GetBridgeTxsRequest'token = Prelude.Nothing,
         _GetBridgeTxsRequest'toBlockNo = Data.ProtoLens.fieldDefault,
         _GetBridgeTxsRequest'maxTxs = Prelude.Nothing,
         _GetBridgeTxsRequest'lower = Prelude.Nothing,
         _GetBridgeTxsRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetBridgeTxsRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetBridgeTxsRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "ics_address"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"icsAddress") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "reserve_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"reserveAddress") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "token"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"token") y x)
                        56
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "to_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"toBlockNo") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_txs"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"maxTxs") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "after_block_no"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"afterBlockNo") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "after_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"afterPosition") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "from_position"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"fromPosition") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetBridgeTxsRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"icsAddress") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"reserveAddress") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'token") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"toBlockNo") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'maxTxs") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v)
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                   ((Prelude..)
                                      Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                      _v))
                         ((Data.Monoid.<>)
                            (case
                                 Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'lower") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just (GetBridgeTxsRequest'AfterBlockNo v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                                      ((Prelude..)
                                         Data.ProtoLens.Encoding.Bytes.putVarInt
                                         Prelude.fromIntegral v)
                               (Prelude.Just (GetBridgeTxsRequest'AfterPosition v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v)
                               (Prelude.Just (GetBridgeTxsRequest'FromPosition v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData GetBridgeTxsRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetBridgeTxsRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetBridgeTxsRequest'icsAddress x__)
                (Control.DeepSeq.deepseq
                   (_GetBridgeTxsRequest'reserveAddress x__)
                   (Control.DeepSeq.deepseq
                      (_GetBridgeTxsRequest'token x__)
                      (Control.DeepSeq.deepseq
                         (_GetBridgeTxsRequest'toBlockNo x__)
                         (Control.DeepSeq.deepseq
                            (_GetBridgeTxsRequest'maxTxs x__)
                            (Control.DeepSeq.deepseq (_GetBridgeTxsRequest'lower x__) ()))))))
instance Control.DeepSeq.NFData GetBridgeTxsRequest'Lower where
  rnf (GetBridgeTxsRequest'AfterBlockNo x__)
    = Control.DeepSeq.rnf x__
  rnf (GetBridgeTxsRequest'AfterPosition x__)
    = Control.DeepSeq.rnf x__
  rnf (GetBridgeTxsRequest'FromPosition x__)
    = Control.DeepSeq.rnf x__
_GetBridgeTxsRequest'AfterBlockNo ::
  Data.ProtoLens.Prism.Prism' GetBridgeTxsRequest'Lower Data.Word.Word32
_GetBridgeTxsRequest'AfterBlockNo
  = Data.ProtoLens.Prism.prism'
      GetBridgeTxsRequest'AfterBlockNo
      (\ p__
         -> case p__ of
              (GetBridgeTxsRequest'AfterBlockNo p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_GetBridgeTxsRequest'AfterPosition ::
  Data.ProtoLens.Prism.Prism' GetBridgeTxsRequest'Lower Position
_GetBridgeTxsRequest'AfterPosition
  = Data.ProtoLens.Prism.prism'
      GetBridgeTxsRequest'AfterPosition
      (\ p__
         -> case p__ of
              (GetBridgeTxsRequest'AfterPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_GetBridgeTxsRequest'FromPosition ::
  Data.ProtoLens.Prism.Prism' GetBridgeTxsRequest'Lower Position
_GetBridgeTxsRequest'FromPosition
  = Data.ProtoLens.Prism.prism'
      GetBridgeTxsRequest'FromPosition
      (\ p__
         -> case p__ of
              (GetBridgeTxsRequest'FromPosition p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' GetEpochNonceRequest Data.Word.Word32@ -}
data GetEpochNonceRequest
  = GetEpochNonceRequest'_constructor {_GetEpochNonceRequest'epochNo :: !Data.Word.Word32,
                                       _GetEpochNonceRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetEpochNonceRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetEpochNonceRequest "epochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetEpochNonceRequest'epochNo
           (\ x__ y__ -> x__ {_GetEpochNonceRequest'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetEpochNonceRequest where
  messageName _ = Data.Text.pack "mcfollower.v1.GetEpochNonceRequest"
  packedMessageDescriptor _
    = "\n\
      \\DC4GetEpochNonceRequest\DC2\EM\n\
      \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"epochNo")) ::
              Data.ProtoLens.FieldDescriptor GetEpochNonceRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, epochNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetEpochNonceRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetEpochNonceRequest'_unknownFields = y__})
  defMessage
    = GetEpochNonceRequest'_constructor
        {_GetEpochNonceRequest'epochNo = Data.ProtoLens.fieldDefault,
         _GetEpochNonceRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetEpochNonceRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetEpochNonceRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetEpochNonceRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"epochNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetEpochNonceRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetEpochNonceRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetEpochNonceRequest'epochNo x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.nonce' @:: Lens' GetEpochNonceResponse Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.maybe'nonce' @:: Lens' GetEpochNonceResponse (Prelude.Maybe Data.ByteString.ByteString)@ -}
data GetEpochNonceResponse
  = GetEpochNonceResponse'_constructor {_GetEpochNonceResponse'nonce :: !(Prelude.Maybe Data.ByteString.ByteString),
                                        _GetEpochNonceResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetEpochNonceResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetEpochNonceResponse "nonce" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetEpochNonceResponse'nonce
           (\ x__ y__ -> x__ {_GetEpochNonceResponse'nonce = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetEpochNonceResponse "maybe'nonce" (Prelude.Maybe Data.ByteString.ByteString) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetEpochNonceResponse'nonce
           (\ x__ y__ -> x__ {_GetEpochNonceResponse'nonce = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetEpochNonceResponse where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetEpochNonceResponse"
  packedMessageDescriptor _
    = "\n\
      \\NAKGetEpochNonceResponse\DC2\EM\n\
      \\ENQnonce\CAN\SOH \SOH(\fH\NULR\ENQnonce\136\SOH\SOHB\b\n\
      \\ACK_nonce"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nonce__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "nonce"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'nonce")) ::
              Data.ProtoLens.FieldDescriptor GetEpochNonceResponse
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, nonce__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetEpochNonceResponse'_unknownFields
        (\ x__ y__ -> x__ {_GetEpochNonceResponse'_unknownFields = y__})
  defMessage
    = GetEpochNonceResponse'_constructor
        {_GetEpochNonceResponse'nonce = Prelude.Nothing,
         _GetEpochNonceResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetEpochNonceResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetEpochNonceResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "nonce"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"nonce") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetEpochNonceResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'nonce") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((\ bs
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt
                                   (Prelude.fromIntegral (Data.ByteString.length bs)))
                                (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetEpochNonceResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetEpochNonceResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetEpochNonceResponse'nonce x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.maxBlockNo' @:: Lens' GetHighestBlockInWindowRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.minSlot' @:: Lens' GetHighestBlockInWindowRequest Data.Word.Word64@
         * 'Proto.McFollower_Fields.maxSlot' @:: Lens' GetHighestBlockInWindowRequest Data.Word.Word64@
         * 'Proto.McFollower_Fields.minTimeUnixMillis' @:: Lens' GetHighestBlockInWindowRequest Data.Int.Int64@
         * 'Proto.McFollower_Fields.maxTimeUnixMillis' @:: Lens' GetHighestBlockInWindowRequest Data.Int.Int64@ -}
data GetHighestBlockInWindowRequest
  = GetHighestBlockInWindowRequest'_constructor {_GetHighestBlockInWindowRequest'maxBlockNo :: !Data.Word.Word32,
                                                 _GetHighestBlockInWindowRequest'minSlot :: !Data.Word.Word64,
                                                 _GetHighestBlockInWindowRequest'maxSlot :: !Data.Word.Word64,
                                                 _GetHighestBlockInWindowRequest'minTimeUnixMillis :: !Data.Int.Int64,
                                                 _GetHighestBlockInWindowRequest'maxTimeUnixMillis :: !Data.Int.Int64,
                                                 _GetHighestBlockInWindowRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetHighestBlockInWindowRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetHighestBlockInWindowRequest "maxBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetHighestBlockInWindowRequest'maxBlockNo
           (\ x__ y__
              -> x__ {_GetHighestBlockInWindowRequest'maxBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetHighestBlockInWindowRequest "minSlot" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetHighestBlockInWindowRequest'minSlot
           (\ x__ y__ -> x__ {_GetHighestBlockInWindowRequest'minSlot = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetHighestBlockInWindowRequest "maxSlot" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetHighestBlockInWindowRequest'maxSlot
           (\ x__ y__ -> x__ {_GetHighestBlockInWindowRequest'maxSlot = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetHighestBlockInWindowRequest "minTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetHighestBlockInWindowRequest'minTimeUnixMillis
           (\ x__ y__
              -> x__ {_GetHighestBlockInWindowRequest'minTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetHighestBlockInWindowRequest "maxTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetHighestBlockInWindowRequest'maxTimeUnixMillis
           (\ x__ y__
              -> x__ {_GetHighestBlockInWindowRequest'maxTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetHighestBlockInWindowRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetHighestBlockInWindowRequest"
  packedMessageDescriptor _
    = "\n\
      \\RSGetHighestBlockInWindowRequest\DC2 \n\
      \\fmax_block_no\CAN\SOH \SOH(\rR\n\
      \maxBlockNo\DC2\EM\n\
      \\bmin_slot\CAN\STX \SOH(\EOTR\aminSlot\DC2\EM\n\
      \\bmax_slot\CAN\ETX \SOH(\EOTR\amaxSlot\DC2/\n\
      \\DC4min_time_unix_millis\CAN\EOT \SOH(\ETXR\DC1minTimeUnixMillis\DC2/\n\
      \\DC4max_time_unix_millis\CAN\ENQ \SOH(\ETXR\DC1maxTimeUnixMillis"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        maxBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetHighestBlockInWindowRequest
        minSlot__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "min_slot"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"minSlot")) ::
              Data.ProtoLens.FieldDescriptor GetHighestBlockInWindowRequest
        maxSlot__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_slot"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"maxSlot")) ::
              Data.ProtoLens.FieldDescriptor GetHighestBlockInWindowRequest
        minTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "min_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"minTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor GetHighestBlockInWindowRequest
        maxTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor GetHighestBlockInWindowRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, maxBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, minSlot__field_descriptor),
           (Data.ProtoLens.Tag 3, maxSlot__field_descriptor),
           (Data.ProtoLens.Tag 4, minTimeUnixMillis__field_descriptor),
           (Data.ProtoLens.Tag 5, maxTimeUnixMillis__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetHighestBlockInWindowRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetHighestBlockInWindowRequest'_unknownFields = y__})
  defMessage
    = GetHighestBlockInWindowRequest'_constructor
        {_GetHighestBlockInWindowRequest'maxBlockNo = Data.ProtoLens.fieldDefault,
         _GetHighestBlockInWindowRequest'minSlot = Data.ProtoLens.fieldDefault,
         _GetHighestBlockInWindowRequest'maxSlot = Data.ProtoLens.fieldDefault,
         _GetHighestBlockInWindowRequest'minTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _GetHighestBlockInWindowRequest'maxTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _GetHighestBlockInWindowRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetHighestBlockInWindowRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetHighestBlockInWindowRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"maxBlockNo") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "min_slot"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"minSlot") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "max_slot"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"maxSlot") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "min_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"minTimeUnixMillis") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxTimeUnixMillis") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetHighestBlockInWindowRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"maxBlockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"minSlot") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"maxSlot") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"minTimeUnixMillis") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v
                              = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"maxTimeUnixMillis") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData GetHighestBlockInWindowRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetHighestBlockInWindowRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetHighestBlockInWindowRequest'maxBlockNo x__)
                (Control.DeepSeq.deepseq
                   (_GetHighestBlockInWindowRequest'minSlot x__)
                   (Control.DeepSeq.deepseq
                      (_GetHighestBlockInWindowRequest'maxSlot x__)
                      (Control.DeepSeq.deepseq
                         (_GetHighestBlockInWindowRequest'minTimeUnixMillis x__)
                         (Control.DeepSeq.deepseq
                            (_GetHighestBlockInWindowRequest'maxTimeUnixMillis x__) ())))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' GetLatestBlockForEpochRequest Data.Word.Word32@ -}
data GetLatestBlockForEpochRequest
  = GetLatestBlockForEpochRequest'_constructor {_GetLatestBlockForEpochRequest'epochNo :: !Data.Word.Word32,
                                                _GetLatestBlockForEpochRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestBlockForEpochRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestBlockForEpochRequest "epochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestBlockForEpochRequest'epochNo
           (\ x__ y__ -> x__ {_GetLatestBlockForEpochRequest'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestBlockForEpochRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestBlockForEpochRequest"
  packedMessageDescriptor _
    = "\n\
      \\GSGetLatestBlockForEpochRequest\DC2\EM\n\
      \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"epochNo")) ::
              Data.ProtoLens.FieldDescriptor GetLatestBlockForEpochRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, epochNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestBlockForEpochRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestBlockForEpochRequest'_unknownFields = y__})
  defMessage
    = GetLatestBlockForEpochRequest'_constructor
        {_GetLatestBlockForEpochRequest'epochNo = Data.ProtoLens.fieldDefault,
         _GetLatestBlockForEpochRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestBlockForEpochRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestBlockForEpochRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetLatestBlockForEpochRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"epochNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetLatestBlockForEpochRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestBlockForEpochRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestBlockForEpochRequest'epochNo x__) ())
{- | Fields :
      -}
data GetLatestBlockRequest
  = GetLatestBlockRequest'_constructor {_GetLatestBlockRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestBlockRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message GetLatestBlockRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestBlockRequest"
  packedMessageDescriptor _
    = "\n\
      \\NAKGetLatestBlockRequest"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestBlockRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetLatestBlockRequest'_unknownFields = y__})
  defMessage
    = GetLatestBlockRequest'_constructor
        {_GetLatestBlockRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestBlockRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestBlockRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetLatestBlockRequest"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData GetLatestBlockRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestBlockRequest'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.McFollower_Fields.address' @:: Lens' GetLatestGovernanceOutputRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.policyId' @:: Lens' GetLatestGovernanceOutputRequest Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' GetLatestGovernanceOutputRequest Data.Word.Word32@ -}
data GetLatestGovernanceOutputRequest
  = GetLatestGovernanceOutputRequest'_constructor {_GetLatestGovernanceOutputRequest'address :: !Data.Text.Text,
                                                   _GetLatestGovernanceOutputRequest'policyId :: !Data.ByteString.ByteString,
                                                   _GetLatestGovernanceOutputRequest'blockNo :: !Data.Word.Word32,
                                                   _GetLatestGovernanceOutputRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestGovernanceOutputRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestGovernanceOutputRequest "address" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestGovernanceOutputRequest'address
           (\ x__ y__
              -> x__ {_GetLatestGovernanceOutputRequest'address = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetLatestGovernanceOutputRequest "policyId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestGovernanceOutputRequest'policyId
           (\ x__ y__
              -> x__ {_GetLatestGovernanceOutputRequest'policyId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetLatestGovernanceOutputRequest "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestGovernanceOutputRequest'blockNo
           (\ x__ y__
              -> x__ {_GetLatestGovernanceOutputRequest'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestGovernanceOutputRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestGovernanceOutputRequest"
  packedMessageDescriptor _
    = "\n\
      \ GetLatestGovernanceOutputRequest\DC2\CAN\n\
      \\aaddress\CAN\SOH \SOH(\tR\aaddress\DC2\ESC\n\
      \\tpolicy_id\CAN\STX \SOH(\fR\bpolicyId\DC2\EM\n\
      \\bblock_no\CAN\ETX \SOH(\rR\ablockNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        address__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"address")) ::
              Data.ProtoLens.FieldDescriptor GetLatestGovernanceOutputRequest
        policyId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "policy_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"policyId")) ::
              Data.ProtoLens.FieldDescriptor GetLatestGovernanceOutputRequest
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor GetLatestGovernanceOutputRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, address__field_descriptor),
           (Data.ProtoLens.Tag 2, policyId__field_descriptor),
           (Data.ProtoLens.Tag 3, blockNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestGovernanceOutputRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestGovernanceOutputRequest'_unknownFields = y__})
  defMessage
    = GetLatestGovernanceOutputRequest'_constructor
        {_GetLatestGovernanceOutputRequest'address = Data.ProtoLens.fieldDefault,
         _GetLatestGovernanceOutputRequest'policyId = Data.ProtoLens.fieldDefault,
         _GetLatestGovernanceOutputRequest'blockNo = Data.ProtoLens.fieldDefault,
         _GetLatestGovernanceOutputRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestGovernanceOutputRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestGovernanceOutputRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "address"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"address") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "policy_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"policyId") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetLatestGovernanceOutputRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"address") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"policyId") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData GetLatestGovernanceOutputRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestGovernanceOutputRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestGovernanceOutputRequest'address x__)
                (Control.DeepSeq.deepseq
                   (_GetLatestGovernanceOutputRequest'policyId x__)
                   (Control.DeepSeq.deepseq
                      (_GetLatestGovernanceOutputRequest'blockNo x__) ())))
{- | Fields :
     
         * 'Proto.McFollower_Fields.output' @:: Lens' GetLatestGovernanceOutputResponse GovernanceOutput@
         * 'Proto.McFollower_Fields.maybe'output' @:: Lens' GetLatestGovernanceOutputResponse (Prelude.Maybe GovernanceOutput)@ -}
data GetLatestGovernanceOutputResponse
  = GetLatestGovernanceOutputResponse'_constructor {_GetLatestGovernanceOutputResponse'output :: !(Prelude.Maybe GovernanceOutput),
                                                    _GetLatestGovernanceOutputResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestGovernanceOutputResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestGovernanceOutputResponse "output" GovernanceOutput where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestGovernanceOutputResponse'output
           (\ x__ y__
              -> x__ {_GetLatestGovernanceOutputResponse'output = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetLatestGovernanceOutputResponse "maybe'output" (Prelude.Maybe GovernanceOutput) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestGovernanceOutputResponse'output
           (\ x__ y__
              -> x__ {_GetLatestGovernanceOutputResponse'output = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestGovernanceOutputResponse where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestGovernanceOutputResponse"
  packedMessageDescriptor _
    = "\n\
      \!GetLatestGovernanceOutputResponse\DC2<\n\
      \\ACKoutput\CAN\SOH \SOH(\v2\US.mcfollower.v1.GovernanceOutputH\NULR\ACKoutput\136\SOH\SOHB\t\n\
      \\a_output"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        output__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "output"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor GovernanceOutput)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'output")) ::
              Data.ProtoLens.FieldDescriptor GetLatestGovernanceOutputResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, output__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestGovernanceOutputResponse'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestGovernanceOutputResponse'_unknownFields = y__})
  defMessage
    = GetLatestGovernanceOutputResponse'_constructor
        {_GetLatestGovernanceOutputResponse'output = Prelude.Nothing,
         _GetLatestGovernanceOutputResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestGovernanceOutputResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestGovernanceOutputResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "output"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"output") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetLatestGovernanceOutputResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'output") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetLatestGovernanceOutputResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestGovernanceOutputResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestGovernanceOutputResponse'output x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.securityParameter' @:: Lens' GetLatestStableEpochRequest Data.Word.Word32@ -}
data GetLatestStableEpochRequest
  = GetLatestStableEpochRequest'_constructor {_GetLatestStableEpochRequest'securityParameter :: !Data.Word.Word32,
                                              _GetLatestStableEpochRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestStableEpochRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestStableEpochRequest "securityParameter" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestStableEpochRequest'securityParameter
           (\ x__ y__
              -> x__ {_GetLatestStableEpochRequest'securityParameter = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestStableEpochRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestStableEpochRequest"
  packedMessageDescriptor _
    = "\n\
      \\ESCGetLatestStableEpochRequest\DC2-\n\
      \\DC2security_parameter\CAN\SOH \SOH(\rR\DC1securityParameter"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        securityParameter__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "security_parameter"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"securityParameter")) ::
              Data.ProtoLens.FieldDescriptor GetLatestStableEpochRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, securityParameter__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestStableEpochRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestStableEpochRequest'_unknownFields = y__})
  defMessage
    = GetLatestStableEpochRequest'_constructor
        {_GetLatestStableEpochRequest'securityParameter = Data.ProtoLens.fieldDefault,
         _GetLatestStableEpochRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestStableEpochRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestStableEpochRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "security_parameter"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"securityParameter") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetLatestStableEpochRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"securityParameter") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetLatestStableEpochRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestStableEpochRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestStableEpochRequest'securityParameter x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' GetLatestStableEpochResponse Data.Int.Int64@
         * 'Proto.McFollower_Fields.maybe'epochNo' @:: Lens' GetLatestStableEpochResponse (Prelude.Maybe Data.Int.Int64)@ -}
data GetLatestStableEpochResponse
  = GetLatestStableEpochResponse'_constructor {_GetLatestStableEpochResponse'epochNo :: !(Prelude.Maybe Data.Int.Int64),
                                               _GetLatestStableEpochResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestStableEpochResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestStableEpochResponse "epochNo" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestStableEpochResponse'epochNo
           (\ x__ y__ -> x__ {_GetLatestStableEpochResponse'epochNo = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetLatestStableEpochResponse "maybe'epochNo" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestStableEpochResponse'epochNo
           (\ x__ y__ -> x__ {_GetLatestStableEpochResponse'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestStableEpochResponse where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetLatestStableEpochResponse"
  packedMessageDescriptor _
    = "\n\
      \\FSGetLatestStableEpochResponse\DC2\RS\n\
      \\bepoch_no\CAN\SOH \SOH(\ETXH\NULR\aepochNo\136\SOH\SOHB\v\n\
      \\t_epoch_no"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'epochNo")) ::
              Data.ProtoLens.FieldDescriptor GetLatestStableEpochResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, epochNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestStableEpochResponse'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestStableEpochResponse'_unknownFields = y__})
  defMessage
    = GetLatestStableEpochResponse'_constructor
        {_GetLatestStableEpochResponse'epochNo = Prelude.Nothing,
         _GetLatestStableEpochResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestStableEpochResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestStableEpochResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetLatestStableEpochResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'epochNo") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       ((Prelude..)
                          Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetLatestStableEpochResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestStableEpochResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestStableEpochResponse'epochNo x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.asset' @:: Lens' GetLatestTokenOutputForEpochRequest AssetId@
         * 'Proto.McFollower_Fields.maybe'asset' @:: Lens' GetLatestTokenOutputForEpochRequest (Prelude.Maybe AssetId)@
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' GetLatestTokenOutputForEpochRequest Data.Word.Word32@ -}
data GetLatestTokenOutputForEpochRequest
  = GetLatestTokenOutputForEpochRequest'_constructor {_GetLatestTokenOutputForEpochRequest'asset :: !(Prelude.Maybe AssetId),
                                                      _GetLatestTokenOutputForEpochRequest'epochNo :: !Data.Word.Word32,
                                                      _GetLatestTokenOutputForEpochRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestTokenOutputForEpochRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestTokenOutputForEpochRequest "asset" AssetId where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestTokenOutputForEpochRequest'asset
           (\ x__ y__
              -> x__ {_GetLatestTokenOutputForEpochRequest'asset = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetLatestTokenOutputForEpochRequest "maybe'asset" (Prelude.Maybe AssetId) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestTokenOutputForEpochRequest'asset
           (\ x__ y__
              -> x__ {_GetLatestTokenOutputForEpochRequest'asset = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetLatestTokenOutputForEpochRequest "epochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestTokenOutputForEpochRequest'epochNo
           (\ x__ y__
              -> x__ {_GetLatestTokenOutputForEpochRequest'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestTokenOutputForEpochRequest where
  messageName _
    = Data.Text.pack
        "mcfollower.v1.GetLatestTokenOutputForEpochRequest"
  packedMessageDescriptor _
    = "\n\
      \#GetLatestTokenOutputForEpochRequest\DC2,\n\
      \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC2\EM\n\
      \\bepoch_no\CAN\STX \SOH(\rR\aepochNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        asset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "asset"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AssetId)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asset")) ::
              Data.ProtoLens.FieldDescriptor GetLatestTokenOutputForEpochRequest
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"epochNo")) ::
              Data.ProtoLens.FieldDescriptor GetLatestTokenOutputForEpochRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, asset__field_descriptor),
           (Data.ProtoLens.Tag 2, epochNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestTokenOutputForEpochRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetLatestTokenOutputForEpochRequest'_unknownFields = y__})
  defMessage
    = GetLatestTokenOutputForEpochRequest'_constructor
        {_GetLatestTokenOutputForEpochRequest'asset = Prelude.Nothing,
         _GetLatestTokenOutputForEpochRequest'epochNo = Data.ProtoLens.fieldDefault,
         _GetLatestTokenOutputForEpochRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestTokenOutputForEpochRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestTokenOutputForEpochRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "asset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"asset") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetLatestTokenOutputForEpochRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'asset") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"epochNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData GetLatestTokenOutputForEpochRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestTokenOutputForEpochRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestTokenOutputForEpochRequest'asset x__)
                (Control.DeepSeq.deepseq
                   (_GetLatestTokenOutputForEpochRequest'epochNo x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.output' @:: Lens' GetLatestTokenOutputForEpochResponse TokenTxOutput@
         * 'Proto.McFollower_Fields.maybe'output' @:: Lens' GetLatestTokenOutputForEpochResponse (Prelude.Maybe TokenTxOutput)@ -}
data GetLatestTokenOutputForEpochResponse
  = GetLatestTokenOutputForEpochResponse'_constructor {_GetLatestTokenOutputForEpochResponse'output :: !(Prelude.Maybe TokenTxOutput),
                                                       _GetLatestTokenOutputForEpochResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetLatestTokenOutputForEpochResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetLatestTokenOutputForEpochResponse "output" TokenTxOutput where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestTokenOutputForEpochResponse'output
           (\ x__ y__
              -> x__ {_GetLatestTokenOutputForEpochResponse'output = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetLatestTokenOutputForEpochResponse "maybe'output" (Prelude.Maybe TokenTxOutput) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetLatestTokenOutputForEpochResponse'output
           (\ x__ y__
              -> x__ {_GetLatestTokenOutputForEpochResponse'output = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetLatestTokenOutputForEpochResponse where
  messageName _
    = Data.Text.pack
        "mcfollower.v1.GetLatestTokenOutputForEpochResponse"
  packedMessageDescriptor _
    = "\n\
      \$GetLatestTokenOutputForEpochResponse\DC29\n\
      \\ACKoutput\CAN\SOH \SOH(\v2\FS.mcfollower.v1.TokenTxOutputH\NULR\ACKoutput\136\SOH\SOHB\t\n\
      \\a_output"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        output__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "output"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor TokenTxOutput)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'output")) ::
              Data.ProtoLens.FieldDescriptor GetLatestTokenOutputForEpochResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, output__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetLatestTokenOutputForEpochResponse'_unknownFields
        (\ x__ y__
           -> x__
                {_GetLatestTokenOutputForEpochResponse'_unknownFields = y__})
  defMessage
    = GetLatestTokenOutputForEpochResponse'_constructor
        {_GetLatestTokenOutputForEpochResponse'output = Prelude.Nothing,
         _GetLatestTokenOutputForEpochResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetLatestTokenOutputForEpochResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetLatestTokenOutputForEpochResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "output"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"output") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetLatestTokenOutputForEpochResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'output") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetLatestTokenOutputForEpochResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetLatestTokenOutputForEpochResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetLatestTokenOutputForEpochResponse'output x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.mappingValidatorAddress' @:: Lens' GetMappingDeregistrationsRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.window' @:: Lens' GetMappingDeregistrationsRequest PositionWindow@
         * 'Proto.McFollower_Fields.maybe'window' @:: Lens' GetMappingDeregistrationsRequest (Prelude.Maybe PositionWindow)@
         * 'Proto.McFollower_Fields.limit' @:: Lens' GetMappingDeregistrationsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.offset' @:: Lens' GetMappingDeregistrationsRequest Data.Word.Word32@ -}
data GetMappingDeregistrationsRequest
  = GetMappingDeregistrationsRequest'_constructor {_GetMappingDeregistrationsRequest'mappingValidatorAddress :: !Data.Text.Text,
                                                   _GetMappingDeregistrationsRequest'window :: !(Prelude.Maybe PositionWindow),
                                                   _GetMappingDeregistrationsRequest'limit :: !Data.Word.Word32,
                                                   _GetMappingDeregistrationsRequest'offset :: !Data.Word.Word32,
                                                   _GetMappingDeregistrationsRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetMappingDeregistrationsRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetMappingDeregistrationsRequest "mappingValidatorAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingDeregistrationsRequest'mappingValidatorAddress
           (\ x__ y__
              -> x__
                   {_GetMappingDeregistrationsRequest'mappingValidatorAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingDeregistrationsRequest "window" PositionWindow where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingDeregistrationsRequest'window
           (\ x__ y__
              -> x__ {_GetMappingDeregistrationsRequest'window = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetMappingDeregistrationsRequest "maybe'window" (Prelude.Maybe PositionWindow) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingDeregistrationsRequest'window
           (\ x__ y__
              -> x__ {_GetMappingDeregistrationsRequest'window = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingDeregistrationsRequest "limit" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingDeregistrationsRequest'limit
           (\ x__ y__ -> x__ {_GetMappingDeregistrationsRequest'limit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingDeregistrationsRequest "offset" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingDeregistrationsRequest'offset
           (\ x__ y__
              -> x__ {_GetMappingDeregistrationsRequest'offset = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetMappingDeregistrationsRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetMappingDeregistrationsRequest"
  packedMessageDescriptor _
    = "\n\
      \ GetMappingDeregistrationsRequest\DC2:\n\
      \\EMmapping_validator_address\CAN\SOH \SOH(\tR\ETBmappingValidatorAddress\DC25\n\
      \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
      \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
      \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mappingValidatorAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "mapping_validator_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"mappingValidatorAddress")) ::
              Data.ProtoLens.FieldDescriptor GetMappingDeregistrationsRequest
        window__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "window"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor PositionWindow)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'window")) ::
              Data.ProtoLens.FieldDescriptor GetMappingDeregistrationsRequest
        limit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "limit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"limit")) ::
              Data.ProtoLens.FieldDescriptor GetMappingDeregistrationsRequest
        offset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"offset")) ::
              Data.ProtoLens.FieldDescriptor GetMappingDeregistrationsRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mappingValidatorAddress__field_descriptor),
           (Data.ProtoLens.Tag 2, window__field_descriptor),
           (Data.ProtoLens.Tag 3, limit__field_descriptor),
           (Data.ProtoLens.Tag 4, offset__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetMappingDeregistrationsRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetMappingDeregistrationsRequest'_unknownFields = y__})
  defMessage
    = GetMappingDeregistrationsRequest'_constructor
        {_GetMappingDeregistrationsRequest'mappingValidatorAddress = Data.ProtoLens.fieldDefault,
         _GetMappingDeregistrationsRequest'window = Prelude.Nothing,
         _GetMappingDeregistrationsRequest'limit = Data.ProtoLens.fieldDefault,
         _GetMappingDeregistrationsRequest'offset = Data.ProtoLens.fieldDefault,
         _GetMappingDeregistrationsRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetMappingDeregistrationsRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetMappingDeregistrationsRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "mapping_validator_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"mappingValidatorAddress") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "window"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"window") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "limit"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"limit") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "offset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"offset") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetMappingDeregistrationsRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"mappingValidatorAddress") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'window") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"limit") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"offset") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData GetMappingDeregistrationsRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetMappingDeregistrationsRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetMappingDeregistrationsRequest'mappingValidatorAddress x__)
                (Control.DeepSeq.deepseq
                   (_GetMappingDeregistrationsRequest'window x__)
                   (Control.DeepSeq.deepseq
                      (_GetMappingDeregistrationsRequest'limit x__)
                      (Control.DeepSeq.deepseq
                         (_GetMappingDeregistrationsRequest'offset x__) ()))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.mappingValidatorAddress' @:: Lens' GetMappingRegistrationsRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.authToken' @:: Lens' GetMappingRegistrationsRequest AssetId@
         * 'Proto.McFollower_Fields.maybe'authToken' @:: Lens' GetMappingRegistrationsRequest (Prelude.Maybe AssetId)@
         * 'Proto.McFollower_Fields.window' @:: Lens' GetMappingRegistrationsRequest PositionWindow@
         * 'Proto.McFollower_Fields.maybe'window' @:: Lens' GetMappingRegistrationsRequest (Prelude.Maybe PositionWindow)@
         * 'Proto.McFollower_Fields.limit' @:: Lens' GetMappingRegistrationsRequest Data.Word.Word32@
         * 'Proto.McFollower_Fields.offset' @:: Lens' GetMappingRegistrationsRequest Data.Word.Word32@ -}
data GetMappingRegistrationsRequest
  = GetMappingRegistrationsRequest'_constructor {_GetMappingRegistrationsRequest'mappingValidatorAddress :: !Data.Text.Text,
                                                 _GetMappingRegistrationsRequest'authToken :: !(Prelude.Maybe AssetId),
                                                 _GetMappingRegistrationsRequest'window :: !(Prelude.Maybe PositionWindow),
                                                 _GetMappingRegistrationsRequest'limit :: !Data.Word.Word32,
                                                 _GetMappingRegistrationsRequest'offset :: !Data.Word.Word32,
                                                 _GetMappingRegistrationsRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetMappingRegistrationsRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "mappingValidatorAddress" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'mappingValidatorAddress
           (\ x__ y__
              -> x__
                   {_GetMappingRegistrationsRequest'mappingValidatorAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "authToken" AssetId where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'authToken
           (\ x__ y__
              -> x__ {_GetMappingRegistrationsRequest'authToken = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "maybe'authToken" (Prelude.Maybe AssetId) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'authToken
           (\ x__ y__
              -> x__ {_GetMappingRegistrationsRequest'authToken = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "window" PositionWindow where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'window
           (\ x__ y__ -> x__ {_GetMappingRegistrationsRequest'window = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "maybe'window" (Prelude.Maybe PositionWindow) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'window
           (\ x__ y__ -> x__ {_GetMappingRegistrationsRequest'window = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "limit" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'limit
           (\ x__ y__ -> x__ {_GetMappingRegistrationsRequest'limit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetMappingRegistrationsRequest "offset" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMappingRegistrationsRequest'offset
           (\ x__ y__ -> x__ {_GetMappingRegistrationsRequest'offset = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetMappingRegistrationsRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetMappingRegistrationsRequest"
  packedMessageDescriptor _
    = "\n\
      \\RSGetMappingRegistrationsRequest\DC2:\n\
      \\EMmapping_validator_address\CAN\SOH \SOH(\tR\ETBmappingValidatorAddress\DC25\n\
      \\n\
      \auth_token\CAN\STX \SOH(\v2\SYN.mcfollower.v1.AssetIdR\tauthToken\DC25\n\
      \\ACKwindow\CAN\ETX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
      \\ENQlimit\CAN\EOT \SOH(\rR\ENQlimit\DC2\SYN\n\
      \\ACKoffset\CAN\ENQ \SOH(\rR\ACKoffset"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mappingValidatorAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "mapping_validator_address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"mappingValidatorAddress")) ::
              Data.ProtoLens.FieldDescriptor GetMappingRegistrationsRequest
        authToken__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "auth_token"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AssetId)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'authToken")) ::
              Data.ProtoLens.FieldDescriptor GetMappingRegistrationsRequest
        window__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "window"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor PositionWindow)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'window")) ::
              Data.ProtoLens.FieldDescriptor GetMappingRegistrationsRequest
        limit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "limit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"limit")) ::
              Data.ProtoLens.FieldDescriptor GetMappingRegistrationsRequest
        offset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"offset")) ::
              Data.ProtoLens.FieldDescriptor GetMappingRegistrationsRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mappingValidatorAddress__field_descriptor),
           (Data.ProtoLens.Tag 2, authToken__field_descriptor),
           (Data.ProtoLens.Tag 3, window__field_descriptor),
           (Data.ProtoLens.Tag 4, limit__field_descriptor),
           (Data.ProtoLens.Tag 5, offset__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetMappingRegistrationsRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetMappingRegistrationsRequest'_unknownFields = y__})
  defMessage
    = GetMappingRegistrationsRequest'_constructor
        {_GetMappingRegistrationsRequest'mappingValidatorAddress = Data.ProtoLens.fieldDefault,
         _GetMappingRegistrationsRequest'authToken = Prelude.Nothing,
         _GetMappingRegistrationsRequest'window = Prelude.Nothing,
         _GetMappingRegistrationsRequest'limit = Data.ProtoLens.fieldDefault,
         _GetMappingRegistrationsRequest'offset = Data.ProtoLens.fieldDefault,
         _GetMappingRegistrationsRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetMappingRegistrationsRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetMappingRegistrationsRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "mapping_validator_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"mappingValidatorAddress") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "auth_token"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"authToken") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "window"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"window") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "limit"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"limit") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "offset"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"offset") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetMappingRegistrationsRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"mappingValidatorAddress") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'authToken") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'window") _x
                    of
                      Prelude.Nothing -> Data.Monoid.mempty
                      (Prelude.Just _v)
                        -> (Data.Monoid.<>)
                             (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                             ((Prelude..)
                                (\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                Data.ProtoLens.encodeMessage _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"limit") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"offset") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData GetMappingRegistrationsRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetMappingRegistrationsRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetMappingRegistrationsRequest'mappingValidatorAddress x__)
                (Control.DeepSeq.deepseq
                   (_GetMappingRegistrationsRequest'authToken x__)
                   (Control.DeepSeq.deepseq
                      (_GetMappingRegistrationsRequest'window x__)
                      (Control.DeepSeq.deepseq
                         (_GetMappingRegistrationsRequest'limit x__)
                         (Control.DeepSeq.deepseq
                            (_GetMappingRegistrationsRequest'offset x__) ())))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' GetMaxTxSizeRequest Data.Word.Word32@ -}
data GetMaxTxSizeRequest
  = GetMaxTxSizeRequest'_constructor {_GetMaxTxSizeRequest'blockNo :: !Data.Word.Word32,
                                      _GetMaxTxSizeRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetMaxTxSizeRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetMaxTxSizeRequest "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMaxTxSizeRequest'blockNo
           (\ x__ y__ -> x__ {_GetMaxTxSizeRequest'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetMaxTxSizeRequest where
  messageName _ = Data.Text.pack "mcfollower.v1.GetMaxTxSizeRequest"
  packedMessageDescriptor _
    = "\n\
      \\DC3GetMaxTxSizeRequest\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor GetMaxTxSizeRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetMaxTxSizeRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetMaxTxSizeRequest'_unknownFields = y__})
  defMessage
    = GetMaxTxSizeRequest'_constructor
        {_GetMaxTxSizeRequest'blockNo = Data.ProtoLens.fieldDefault,
         _GetMaxTxSizeRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetMaxTxSizeRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetMaxTxSizeRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetMaxTxSizeRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetMaxTxSizeRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetMaxTxSizeRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetMaxTxSizeRequest'blockNo x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.maxTxSize' @:: Lens' GetMaxTxSizeResponse Data.Word.Word64@
         * 'Proto.McFollower_Fields.maybe'maxTxSize' @:: Lens' GetMaxTxSizeResponse (Prelude.Maybe Data.Word.Word64)@ -}
data GetMaxTxSizeResponse
  = GetMaxTxSizeResponse'_constructor {_GetMaxTxSizeResponse'maxTxSize :: !(Prelude.Maybe Data.Word.Word64),
                                       _GetMaxTxSizeResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetMaxTxSizeResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetMaxTxSizeResponse "maxTxSize" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMaxTxSizeResponse'maxTxSize
           (\ x__ y__ -> x__ {_GetMaxTxSizeResponse'maxTxSize = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetMaxTxSizeResponse "maybe'maxTxSize" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetMaxTxSizeResponse'maxTxSize
           (\ x__ y__ -> x__ {_GetMaxTxSizeResponse'maxTxSize = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetMaxTxSizeResponse where
  messageName _ = Data.Text.pack "mcfollower.v1.GetMaxTxSizeResponse"
  packedMessageDescriptor _
    = "\n\
      \\DC4GetMaxTxSizeResponse\DC2#\n\
      \\vmax_tx_size\CAN\SOH \SOH(\EOTH\NULR\tmaxTxSize\136\SOH\SOHB\SO\n\
      \\f_max_tx_size"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        maxTxSize__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_tx_size"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'maxTxSize")) ::
              Data.ProtoLens.FieldDescriptor GetMaxTxSizeResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, maxTxSize__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetMaxTxSizeResponse'_unknownFields
        (\ x__ y__ -> x__ {_GetMaxTxSizeResponse'_unknownFields = y__})
  defMessage
    = GetMaxTxSizeResponse'_constructor
        {_GetMaxTxSizeResponse'maxTxSize = Prelude.Nothing,
         _GetMaxTxSizeResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetMaxTxSizeResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetMaxTxSizeResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "max_tx_size"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"maxTxSize") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetMaxTxSizeResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'maxTxSize") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetMaxTxSizeResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetMaxTxSizeResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetMaxTxSizeResponse'maxTxSize x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.epochNo' @:: Lens' GetStakeDistributionRequest Data.Word.Word32@ -}
data GetStakeDistributionRequest
  = GetStakeDistributionRequest'_constructor {_GetStakeDistributionRequest'epochNo :: !Data.Word.Word32,
                                              _GetStakeDistributionRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetStakeDistributionRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetStakeDistributionRequest "epochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStakeDistributionRequest'epochNo
           (\ x__ y__ -> x__ {_GetStakeDistributionRequest'epochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetStakeDistributionRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetStakeDistributionRequest"
  packedMessageDescriptor _
    = "\n\
      \\ESCGetStakeDistributionRequest\DC2\EM\n\
      \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        epochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"epochNo")) ::
              Data.ProtoLens.FieldDescriptor GetStakeDistributionRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, epochNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetStakeDistributionRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetStakeDistributionRequest'_unknownFields = y__})
  defMessage
    = GetStakeDistributionRequest'_constructor
        {_GetStakeDistributionRequest'epochNo = Data.ProtoLens.fieldDefault,
         _GetStakeDistributionRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetStakeDistributionRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetStakeDistributionRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "epoch_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"epochNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetStakeDistributionRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"epochNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetStakeDistributionRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetStakeDistributionRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetStakeDistributionRequest'epochNo x__) ())
{- | Fields :
      -}
data GetStatusRequest
  = GetStatusRequest'_constructor {_GetStatusRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetStatusRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Message GetStatusRequest where
  messageName _ = Data.Text.pack "mcfollower.v1.GetStatusRequest"
  packedMessageDescriptor _
    = "\n\
      \\DLEGetStatusRequest"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetStatusRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetStatusRequest'_unknownFields = y__})
  defMessage
    = GetStatusRequest'_constructor
        {_GetStatusRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetStatusRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetStatusRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetStatusRequest"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData GetStatusRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetStatusRequest'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.McFollower_Fields.tip' @:: Lens' GetStatusResponse Block@
         * 'Proto.McFollower_Fields.maybe'tip' @:: Lens' GetStatusResponse (Prelude.Maybe Block)@
         * 'Proto.McFollower_Fields.immutableTip' @:: Lens' GetStatusResponse Block@
         * 'Proto.McFollower_Fields.maybe'immutableTip' @:: Lens' GetStatusResponse (Prelude.Maybe Block)@
         * 'Proto.McFollower_Fields.securityParameter' @:: Lens' GetStatusResponse Data.Word.Word32@
         * 'Proto.McFollower_Fields.syncing' @:: Lens' GetStatusResponse Prelude.Bool@
         * 'Proto.McFollower_Fields.upstreamTipSlot' @:: Lens' GetStatusResponse Data.Word.Word64@
         * 'Proto.McFollower_Fields.maybe'upstreamTipSlot' @:: Lens' GetStatusResponse (Prelude.Maybe Data.Word.Word64)@
         * 'Proto.McFollower_Fields.upstreamTipBlockNo' @:: Lens' GetStatusResponse Data.Word.Word32@
         * 'Proto.McFollower_Fields.maybe'upstreamTipBlockNo' @:: Lens' GetStatusResponse (Prelude.Maybe Data.Word.Word32)@
         * 'Proto.McFollower_Fields.startBlock' @:: Lens' GetStatusResponse Block@
         * 'Proto.McFollower_Fields.maybe'startBlock' @:: Lens' GetStatusResponse (Prelude.Maybe Block)@
         * 'Proto.McFollower_Fields.backfilling' @:: Lens' GetStatusResponse [Data.Text.Text]@
         * 'Proto.McFollower_Fields.vec'backfilling' @:: Lens' GetStatusResponse (Data.Vector.Vector Data.Text.Text)@
         * 'Proto.McFollower_Fields.networkMagic' @:: Lens' GetStatusResponse Data.Word.Word32@ -}
data GetStatusResponse
  = GetStatusResponse'_constructor {_GetStatusResponse'tip :: !(Prelude.Maybe Block),
                                    _GetStatusResponse'immutableTip :: !(Prelude.Maybe Block),
                                    _GetStatusResponse'securityParameter :: !Data.Word.Word32,
                                    _GetStatusResponse'syncing :: !Prelude.Bool,
                                    _GetStatusResponse'upstreamTipSlot :: !(Prelude.Maybe Data.Word.Word64),
                                    _GetStatusResponse'upstreamTipBlockNo :: !(Prelude.Maybe Data.Word.Word32),
                                    _GetStatusResponse'startBlock :: !(Prelude.Maybe Block),
                                    _GetStatusResponse'backfilling :: !(Data.Vector.Vector Data.Text.Text),
                                    _GetStatusResponse'networkMagic :: !Data.Word.Word32,
                                    _GetStatusResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetStatusResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetStatusResponse "tip" Block where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'tip
           (\ x__ y__ -> x__ {_GetStatusResponse'tip = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetStatusResponse "maybe'tip" (Prelude.Maybe Block) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'tip
           (\ x__ y__ -> x__ {_GetStatusResponse'tip = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "immutableTip" Block where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'immutableTip
           (\ x__ y__ -> x__ {_GetStatusResponse'immutableTip = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetStatusResponse "maybe'immutableTip" (Prelude.Maybe Block) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'immutableTip
           (\ x__ y__ -> x__ {_GetStatusResponse'immutableTip = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "securityParameter" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'securityParameter
           (\ x__ y__ -> x__ {_GetStatusResponse'securityParameter = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "syncing" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'syncing
           (\ x__ y__ -> x__ {_GetStatusResponse'syncing = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "upstreamTipSlot" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'upstreamTipSlot
           (\ x__ y__ -> x__ {_GetStatusResponse'upstreamTipSlot = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetStatusResponse "maybe'upstreamTipSlot" (Prelude.Maybe Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'upstreamTipSlot
           (\ x__ y__ -> x__ {_GetStatusResponse'upstreamTipSlot = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "upstreamTipBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'upstreamTipBlockNo
           (\ x__ y__ -> x__ {_GetStatusResponse'upstreamTipBlockNo = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField GetStatusResponse "maybe'upstreamTipBlockNo" (Prelude.Maybe Data.Word.Word32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'upstreamTipBlockNo
           (\ x__ y__ -> x__ {_GetStatusResponse'upstreamTipBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "startBlock" Block where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'startBlock
           (\ x__ y__ -> x__ {_GetStatusResponse'startBlock = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetStatusResponse "maybe'startBlock" (Prelude.Maybe Block) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'startBlock
           (\ x__ y__ -> x__ {_GetStatusResponse'startBlock = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "backfilling" [Data.Text.Text] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'backfilling
           (\ x__ y__ -> x__ {_GetStatusResponse'backfilling = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField GetStatusResponse "vec'backfilling" (Data.Vector.Vector Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'backfilling
           (\ x__ y__ -> x__ {_GetStatusResponse'backfilling = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetStatusResponse "networkMagic" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetStatusResponse'networkMagic
           (\ x__ y__ -> x__ {_GetStatusResponse'networkMagic = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetStatusResponse where
  messageName _ = Data.Text.pack "mcfollower.v1.GetStatusResponse"
  packedMessageDescriptor _
    = "\n\
      \\DC1GetStatusResponse\DC2+\n\
      \\ETXtip\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.BlockH\NULR\ETXtip\136\SOH\SOH\DC2>\n\
      \\rimmutable_tip\CAN\STX \SOH(\v2\DC4.mcfollower.v1.BlockH\SOHR\fimmutableTip\136\SOH\SOH\DC2-\n\
      \\DC2security_parameter\CAN\ETX \SOH(\rR\DC1securityParameter\DC2\CAN\n\
      \\asyncing\CAN\EOT \SOH(\bR\asyncing\DC2/\n\
      \\DC1upstream_tip_slot\CAN\ENQ \SOH(\EOTH\STXR\SIupstreamTipSlot\136\SOH\SOH\DC26\n\
      \\NAKupstream_tip_block_no\CAN\ACK \SOH(\rH\ETXR\DC2upstreamTipBlockNo\136\SOH\SOH\DC2:\n\
      \\vstart_block\CAN\a \SOH(\v2\DC4.mcfollower.v1.BlockH\EOTR\n\
      \startBlock\136\SOH\SOH\DC2 \n\
      \\vbackfilling\CAN\b \ETX(\tR\vbackfilling\DC2#\n\
      \\rnetwork_magic\CAN\t \SOH(\rR\fnetworkMagicB\ACK\n\
      \\EOT_tipB\DLE\n\
      \\SO_immutable_tipB\DC4\n\
      \\DC2_upstream_tip_slotB\CAN\n\
      \\SYN_upstream_tip_block_noB\SO\n\
      \\f_start_block"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        tip__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tip"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Block)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'tip")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        immutableTip__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "immutable_tip"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Block)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'immutableTip")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        securityParameter__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "security_parameter"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"securityParameter")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        syncing__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "syncing"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"syncing")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        upstreamTipSlot__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "upstream_tip_slot"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'upstreamTipSlot")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        upstreamTipBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "upstream_tip_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'upstreamTipBlockNo")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        startBlock__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_block"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Block)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'startBlock")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        backfilling__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "backfilling"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"backfilling")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
        networkMagic__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "network_magic"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"networkMagic")) ::
              Data.ProtoLens.FieldDescriptor GetStatusResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, tip__field_descriptor),
           (Data.ProtoLens.Tag 2, immutableTip__field_descriptor),
           (Data.ProtoLens.Tag 3, securityParameter__field_descriptor),
           (Data.ProtoLens.Tag 4, syncing__field_descriptor),
           (Data.ProtoLens.Tag 5, upstreamTipSlot__field_descriptor),
           (Data.ProtoLens.Tag 6, upstreamTipBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 7, startBlock__field_descriptor),
           (Data.ProtoLens.Tag 8, backfilling__field_descriptor),
           (Data.ProtoLens.Tag 9, networkMagic__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetStatusResponse'_unknownFields
        (\ x__ y__ -> x__ {_GetStatusResponse'_unknownFields = y__})
  defMessage
    = GetStatusResponse'_constructor
        {_GetStatusResponse'tip = Prelude.Nothing,
         _GetStatusResponse'immutableTip = Prelude.Nothing,
         _GetStatusResponse'securityParameter = Data.ProtoLens.fieldDefault,
         _GetStatusResponse'syncing = Data.ProtoLens.fieldDefault,
         _GetStatusResponse'upstreamTipSlot = Prelude.Nothing,
         _GetStatusResponse'upstreamTipBlockNo = Prelude.Nothing,
         _GetStatusResponse'startBlock = Prelude.Nothing,
         _GetStatusResponse'backfilling = Data.Vector.Generic.empty,
         _GetStatusResponse'networkMagic = Data.ProtoLens.fieldDefault,
         _GetStatusResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetStatusResponse
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Text.Text
             -> Data.ProtoLens.Encoding.Bytes.Parser GetStatusResponse
        loop x mutable'backfilling
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'backfilling <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                              (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                 mutable'backfilling)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'backfilling") frozen'backfilling
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "tip"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"tip") y x)
                                  mutable'backfilling
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "immutable_tip"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"immutableTip") y x)
                                  mutable'backfilling
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "security_parameter"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"securityParameter") y x)
                                  mutable'backfilling
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "syncing"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"syncing") y x)
                                  mutable'backfilling
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "upstream_tip_slot"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"upstreamTipSlot") y x)
                                  mutable'backfilling
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "upstream_tip_block_no"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"upstreamTipBlockNo") y x)
                                  mutable'backfilling
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "start_block"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"startBlock") y x)
                                  mutable'backfilling
                        66
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.getText
                                              (Prelude.fromIntegral len))
                                        "backfilling"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'backfilling y)
                                loop x v
                        72
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "network_magic"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"networkMagic") y x)
                                  mutable'backfilling
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'backfilling
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'backfilling <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'backfilling)
          "GetStatusResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'tip") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'immutableTip") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"securityParameter") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"syncing") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (\ b -> if b then 1 else 0) _v))
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view
                                (Data.ProtoLens.Field.field @"maybe'upstreamTipSlot") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v)
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                         ((Data.Monoid.<>)
                            (case
                                 Lens.Family2.view
                                   (Data.ProtoLens.Field.field @"maybe'upstreamTipBlockNo") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just _v)
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                      ((Prelude..)
                                         Data.ProtoLens.Encoding.Bytes.putVarInt
                                         Prelude.fromIntegral _v))
                            ((Data.Monoid.<>)
                               (case
                                    Lens.Family2.view
                                      (Data.ProtoLens.Field.field @"maybe'startBlock") _x
                                of
                                  Prelude.Nothing -> Data.Monoid.mempty
                                  (Prelude.Just _v)
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                         ((Prelude..)
                                            (\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                            Data.ProtoLens.encodeMessage _v))
                               ((Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                     (\ _v
                                        -> (Data.Monoid.<>)
                                             (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                             ((Prelude..)
                                                (\ bs
                                                   -> (Data.Monoid.<>)
                                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                           (Prelude.fromIntegral
                                                              (Data.ByteString.length bs)))
                                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                                Data.Text.Encoding.encodeUtf8 _v))
                                     (Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"vec'backfilling") _x))
                                  ((Data.Monoid.<>)
                                     (let
                                        _v
                                          = Lens.Family2.view
                                              (Data.ProtoLens.Field.field @"networkMagic") _x
                                      in
                                        if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                            Data.Monoid.mempty
                                        else
                                            (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt 72)
                                              ((Prelude..)
                                                 Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 Prelude.fromIntegral _v))
                                     (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                        (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))))
instance Control.DeepSeq.NFData GetStatusResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetStatusResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetStatusResponse'tip x__)
                (Control.DeepSeq.deepseq
                   (_GetStatusResponse'immutableTip x__)
                   (Control.DeepSeq.deepseq
                      (_GetStatusResponse'securityParameter x__)
                      (Control.DeepSeq.deepseq
                         (_GetStatusResponse'syncing x__)
                         (Control.DeepSeq.deepseq
                            (_GetStatusResponse'upstreamTipSlot x__)
                            (Control.DeepSeq.deepseq
                               (_GetStatusResponse'upstreamTipBlockNo x__)
                               (Control.DeepSeq.deepseq
                                  (_GetStatusResponse'startBlock x__)
                                  (Control.DeepSeq.deepseq
                                     (_GetStatusResponse'backfilling x__)
                                     (Control.DeepSeq.deepseq
                                        (_GetStatusResponse'networkMagic x__) ())))))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.txHash' @:: Lens' GetTxPositionRequest Data.ByteString.ByteString@ -}
data GetTxPositionRequest
  = GetTxPositionRequest'_constructor {_GetTxPositionRequest'txHash :: !Data.ByteString.ByteString,
                                       _GetTxPositionRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetTxPositionRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetTxPositionRequest "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetTxPositionRequest'txHash
           (\ x__ y__ -> x__ {_GetTxPositionRequest'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetTxPositionRequest where
  messageName _ = Data.Text.pack "mcfollower.v1.GetTxPositionRequest"
  packedMessageDescriptor _
    = "\n\
      \\DC4GetTxPositionRequest\DC2\ETB\n\
      \\atx_hash\CAN\SOH \SOH(\fR\ACKtxHash"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor GetTxPositionRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, txHash__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetTxPositionRequest'_unknownFields
        (\ x__ y__ -> x__ {_GetTxPositionRequest'_unknownFields = y__})
  defMessage
    = GetTxPositionRequest'_constructor
        {_GetTxPositionRequest'txHash = Data.ProtoLens.fieldDefault,
         _GetTxPositionRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetTxPositionRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetTxPositionRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetTxPositionRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetTxPositionRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetTxPositionRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetTxPositionRequest'txHash x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.position' @:: Lens' GetTxPositionResponse Position@
         * 'Proto.McFollower_Fields.maybe'position' @:: Lens' GetTxPositionResponse (Prelude.Maybe Position)@ -}
data GetTxPositionResponse
  = GetTxPositionResponse'_constructor {_GetTxPositionResponse'position :: !(Prelude.Maybe Position),
                                        _GetTxPositionResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetTxPositionResponse where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetTxPositionResponse "position" Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetTxPositionResponse'position
           (\ x__ y__ -> x__ {_GetTxPositionResponse'position = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GetTxPositionResponse "maybe'position" (Prelude.Maybe Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetTxPositionResponse'position
           (\ x__ y__ -> x__ {_GetTxPositionResponse'position = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetTxPositionResponse where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetTxPositionResponse"
  packedMessageDescriptor _
    = "\n\
      \\NAKGetTxPositionResponse\DC28\n\
      \\bposition\CAN\SOH \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\bposition\136\SOH\SOHB\v\n\
      \\t_position"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        position__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "position"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'position")) ::
              Data.ProtoLens.FieldDescriptor GetTxPositionResponse
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, position__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetTxPositionResponse'_unknownFields
        (\ x__ y__ -> x__ {_GetTxPositionResponse'_unknownFields = y__})
  defMessage
    = GetTxPositionResponse'_constructor
        {_GetTxPositionResponse'position = Prelude.Nothing,
         _GetTxPositionResponse'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetTxPositionResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser GetTxPositionResponse
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "position"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"position") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GetTxPositionResponse"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'position") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData GetTxPositionResponse where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetTxPositionResponse'_unknownFields x__)
             (Control.DeepSeq.deepseq (_GetTxPositionResponse'position x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.address' @:: Lens' GetUnspentOutputsAtAddressRequest Data.Text.Text@
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' GetUnspentOutputsAtAddressRequest Data.Word.Word32@ -}
data GetUnspentOutputsAtAddressRequest
  = GetUnspentOutputsAtAddressRequest'_constructor {_GetUnspentOutputsAtAddressRequest'address :: !Data.Text.Text,
                                                    _GetUnspentOutputsAtAddressRequest'blockNo :: !Data.Word.Word32,
                                                    _GetUnspentOutputsAtAddressRequest'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GetUnspentOutputsAtAddressRequest where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GetUnspentOutputsAtAddressRequest "address" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetUnspentOutputsAtAddressRequest'address
           (\ x__ y__
              -> x__ {_GetUnspentOutputsAtAddressRequest'address = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GetUnspentOutputsAtAddressRequest "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GetUnspentOutputsAtAddressRequest'blockNo
           (\ x__ y__
              -> x__ {_GetUnspentOutputsAtAddressRequest'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Message GetUnspentOutputsAtAddressRequest where
  messageName _
    = Data.Text.pack "mcfollower.v1.GetUnspentOutputsAtAddressRequest"
  packedMessageDescriptor _
    = "\n\
      \!GetUnspentOutputsAtAddressRequest\DC2\CAN\n\
      \\aaddress\CAN\SOH \SOH(\tR\aaddress\DC2\EM\n\
      \\bblock_no\CAN\STX \SOH(\rR\ablockNo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        address__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"address")) ::
              Data.ProtoLens.FieldDescriptor GetUnspentOutputsAtAddressRequest
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor GetUnspentOutputsAtAddressRequest
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, address__field_descriptor),
           (Data.ProtoLens.Tag 2, blockNo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GetUnspentOutputsAtAddressRequest'_unknownFields
        (\ x__ y__
           -> x__ {_GetUnspentOutputsAtAddressRequest'_unknownFields = y__})
  defMessage
    = GetUnspentOutputsAtAddressRequest'_constructor
        {_GetUnspentOutputsAtAddressRequest'address = Data.ProtoLens.fieldDefault,
         _GetUnspentOutputsAtAddressRequest'blockNo = Data.ProtoLens.fieldDefault,
         _GetUnspentOutputsAtAddressRequest'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GetUnspentOutputsAtAddressRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser GetUnspentOutputsAtAddressRequest
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "address"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"address") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "GetUnspentOutputsAtAddressRequest"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"address") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData GetUnspentOutputsAtAddressRequest where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GetUnspentOutputsAtAddressRequest'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GetUnspentOutputsAtAddressRequest'address x__)
                (Control.DeepSeq.deepseq
                   (_GetUnspentOutputsAtAddressRequest'blockNo x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.datum' @:: Lens' GovernanceOutput Datum@
         * 'Proto.McFollower_Fields.maybe'datum' @:: Lens' GovernanceOutput (Prelude.Maybe Datum)@
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' GovernanceOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.blockHash' @:: Lens' GovernanceOutput Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' GovernanceOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.txHash' @:: Lens' GovernanceOutput Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' GovernanceOutput Data.Word.Word32@ -}
data GovernanceOutput
  = GovernanceOutput'_constructor {_GovernanceOutput'datum :: !(Prelude.Maybe Datum),
                                   _GovernanceOutput'blockNo :: !Data.Word.Word32,
                                   _GovernanceOutput'blockHash :: !Data.ByteString.ByteString,
                                   _GovernanceOutput'txIndex :: !Data.Word.Word32,
                                   _GovernanceOutput'txHash :: !Data.ByteString.ByteString,
                                   _GovernanceOutput'utxoIndex :: !Data.Word.Word32,
                                   _GovernanceOutput'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show GovernanceOutput where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField GovernanceOutput "datum" Datum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'datum
           (\ x__ y__ -> x__ {_GovernanceOutput'datum = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField GovernanceOutput "maybe'datum" (Prelude.Maybe Datum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'datum
           (\ x__ y__ -> x__ {_GovernanceOutput'datum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GovernanceOutput "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'blockNo
           (\ x__ y__ -> x__ {_GovernanceOutput'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GovernanceOutput "blockHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'blockHash
           (\ x__ y__ -> x__ {_GovernanceOutput'blockHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GovernanceOutput "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'txIndex
           (\ x__ y__ -> x__ {_GovernanceOutput'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GovernanceOutput "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'txHash
           (\ x__ y__ -> x__ {_GovernanceOutput'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField GovernanceOutput "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _GovernanceOutput'utxoIndex
           (\ x__ y__ -> x__ {_GovernanceOutput'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Message GovernanceOutput where
  messageName _ = Data.Text.pack "mcfollower.v1.GovernanceOutput"
  packedMessageDescriptor _
    = "\n\
      \\DLEGovernanceOutput\DC2*\n\
      \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
      \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
      \\n\
      \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC2\EM\n\
      \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\ETB\n\
      \\atx_hash\CAN\ENQ \SOH(\fR\ACKtxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\ACK \SOH(\rR\tutxoIndex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        datum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "datum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Datum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'datum")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
        blockHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockHash")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor GovernanceOutput
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, datum__field_descriptor),
           (Data.ProtoLens.Tag 2, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 3, blockHash__field_descriptor),
           (Data.ProtoLens.Tag 4, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 5, txHash__field_descriptor),
           (Data.ProtoLens.Tag 6, utxoIndex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _GovernanceOutput'_unknownFields
        (\ x__ y__ -> x__ {_GovernanceOutput'_unknownFields = y__})
  defMessage
    = GovernanceOutput'_constructor
        {_GovernanceOutput'datum = Prelude.Nothing,
         _GovernanceOutput'blockNo = Data.ProtoLens.fieldDefault,
         _GovernanceOutput'blockHash = Data.ProtoLens.fieldDefault,
         _GovernanceOutput'txIndex = Data.ProtoLens.fieldDefault,
         _GovernanceOutput'txHash = Data.ProtoLens.fieldDefault,
         _GovernanceOutput'utxoIndex = Data.ProtoLens.fieldDefault,
         _GovernanceOutput'_unknownFields = []}
  parseMessage
    = let
        loop ::
          GovernanceOutput
          -> Data.ProtoLens.Encoding.Bytes.Parser GovernanceOutput
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "datum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"datum") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "block_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"blockHash") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "GovernanceOutput"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'datum") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockHash") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"utxoIndex") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                        _v))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData GovernanceOutput where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_GovernanceOutput'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_GovernanceOutput'datum x__)
                (Control.DeepSeq.deepseq
                   (_GovernanceOutput'blockNo x__)
                   (Control.DeepSeq.deepseq
                      (_GovernanceOutput'blockHash x__)
                      (Control.DeepSeq.deepseq
                         (_GovernanceOutput'txIndex x__)
                         (Control.DeepSeq.deepseq
                            (_GovernanceOutput'txHash x__)
                            (Control.DeepSeq.deepseq (_GovernanceOutput'utxoIndex x__) ()))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.block' @:: Lens' OptionalBlock Block@
         * 'Proto.McFollower_Fields.maybe'block' @:: Lens' OptionalBlock (Prelude.Maybe Block)@ -}
data OptionalBlock
  = OptionalBlock'_constructor {_OptionalBlock'block :: !(Prelude.Maybe Block),
                                _OptionalBlock'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show OptionalBlock where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField OptionalBlock "block" Block where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _OptionalBlock'block
           (\ x__ y__ -> x__ {_OptionalBlock'block = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField OptionalBlock "maybe'block" (Prelude.Maybe Block) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _OptionalBlock'block
           (\ x__ y__ -> x__ {_OptionalBlock'block = y__}))
        Prelude.id
instance Data.ProtoLens.Message OptionalBlock where
  messageName _ = Data.Text.pack "mcfollower.v1.OptionalBlock"
  packedMessageDescriptor _
    = "\n\
      \\rOptionalBlock\DC2/\n\
      \\ENQblock\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.BlockH\NULR\ENQblock\136\SOH\SOHB\b\n\
      \\ACK_block"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        block__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Block)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'block")) ::
              Data.ProtoLens.FieldDescriptor OptionalBlock
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, block__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _OptionalBlock'_unknownFields
        (\ x__ y__ -> x__ {_OptionalBlock'_unknownFields = y__})
  defMessage
    = OptionalBlock'_constructor
        {_OptionalBlock'block = Prelude.Nothing,
         _OptionalBlock'_unknownFields = []}
  parseMessage
    = let
        loop ::
          OptionalBlock -> Data.ProtoLens.Encoding.Bytes.Parser OptionalBlock
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "block"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"block") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "OptionalBlock"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'block") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData OptionalBlock where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_OptionalBlock'_unknownFields x__)
             (Control.DeepSeq.deepseq (_OptionalBlock'block x__) ())
{- | Fields :
     
         * 'Proto.McFollower_Fields.txHash' @:: Lens' OutputRef Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.index' @:: Lens' OutputRef Data.Word.Word32@ -}
data OutputRef
  = OutputRef'_constructor {_OutputRef'txHash :: !Data.ByteString.ByteString,
                            _OutputRef'index :: !Data.Word.Word32,
                            _OutputRef'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show OutputRef where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField OutputRef "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _OutputRef'txHash (\ x__ y__ -> x__ {_OutputRef'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField OutputRef "index" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _OutputRef'index (\ x__ y__ -> x__ {_OutputRef'index = y__}))
        Prelude.id
instance Data.ProtoLens.Message OutputRef where
  messageName _ = Data.Text.pack "mcfollower.v1.OutputRef"
  packedMessageDescriptor _
    = "\n\
      \\tOutputRef\DC2\ETB\n\
      \\atx_hash\CAN\SOH \SOH(\fR\ACKtxHash\DC2\DC4\n\
      \\ENQindex\CAN\STX \SOH(\rR\ENQindex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor OutputRef
        index__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"index")) ::
              Data.ProtoLens.FieldDescriptor OutputRef
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, txHash__field_descriptor),
           (Data.ProtoLens.Tag 2, index__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _OutputRef'_unknownFields
        (\ x__ y__ -> x__ {_OutputRef'_unknownFields = y__})
  defMessage
    = OutputRef'_constructor
        {_OutputRef'txHash = Data.ProtoLens.fieldDefault,
         _OutputRef'index = Data.ProtoLens.fieldDefault,
         _OutputRef'_unknownFields = []}
  parseMessage
    = let
        loop :: OutputRef -> Data.ProtoLens.Encoding.Bytes.Parser OutputRef
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"index") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "OutputRef"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"index") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData OutputRef where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_OutputRef'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_OutputRef'txHash x__)
                (Control.DeepSeq.deepseq (_OutputRef'index x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' Position Data.Word.Word32@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' Position Data.Word.Word32@ -}
data Position
  = Position'_constructor {_Position'blockNo :: !Data.Word.Word32,
                           _Position'txIndex :: !Data.Word.Word32,
                           _Position'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Position where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Position "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Position'blockNo (\ x__ y__ -> x__ {_Position'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Position "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Position'txIndex (\ x__ y__ -> x__ {_Position'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Message Position where
  messageName _ = Data.Text.pack "mcfollower.v1.Position"
  packedMessageDescriptor _
    = "\n\
      \\bPosition\DC2\EM\n\
      \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\EM\n\
      \\btx_index\CAN\STX \SOH(\rR\atxIndex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor Position
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor Position
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 2, txIndex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Position'_unknownFields
        (\ x__ y__ -> x__ {_Position'_unknownFields = y__})
  defMessage
    = Position'_constructor
        {_Position'blockNo = Data.ProtoLens.fieldDefault,
         _Position'txIndex = Data.ProtoLens.fieldDefault,
         _Position'_unknownFields = []}
  parseMessage
    = let
        loop :: Position -> Data.ProtoLens.Encoding.Bytes.Parser Position
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Position"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Position where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Position'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Position'blockNo x__)
                (Control.DeepSeq.deepseq (_Position'txIndex x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.fromInclusive' @:: Lens' PositionWindow Position@
         * 'Proto.McFollower_Fields.maybe'fromInclusive' @:: Lens' PositionWindow (Prelude.Maybe Position)@
         * 'Proto.McFollower_Fields.toExclusive' @:: Lens' PositionWindow Position@
         * 'Proto.McFollower_Fields.maybe'toExclusive' @:: Lens' PositionWindow (Prelude.Maybe Position)@ -}
data PositionWindow
  = PositionWindow'_constructor {_PositionWindow'fromInclusive :: !(Prelude.Maybe Position),
                                 _PositionWindow'toExclusive :: !(Prelude.Maybe Position),
                                 _PositionWindow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show PositionWindow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField PositionWindow "fromInclusive" Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _PositionWindow'fromInclusive
           (\ x__ y__ -> x__ {_PositionWindow'fromInclusive = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField PositionWindow "maybe'fromInclusive" (Prelude.Maybe Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _PositionWindow'fromInclusive
           (\ x__ y__ -> x__ {_PositionWindow'fromInclusive = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField PositionWindow "toExclusive" Position where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _PositionWindow'toExclusive
           (\ x__ y__ -> x__ {_PositionWindow'toExclusive = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField PositionWindow "maybe'toExclusive" (Prelude.Maybe Position) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _PositionWindow'toExclusive
           (\ x__ y__ -> x__ {_PositionWindow'toExclusive = y__}))
        Prelude.id
instance Data.ProtoLens.Message PositionWindow where
  messageName _ = Data.Text.pack "mcfollower.v1.PositionWindow"
  packedMessageDescriptor _
    = "\n\
      \\SOPositionWindow\DC2>\n\
      \\SOfrom_inclusive\CAN\SOH \SOH(\v2\ETB.mcfollower.v1.PositionR\rfromInclusive\DC2:\n\
      \\fto_exclusive\CAN\STX \SOH(\v2\ETB.mcfollower.v1.PositionR\vtoExclusive"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fromInclusive__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "from_inclusive"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fromInclusive")) ::
              Data.ProtoLens.FieldDescriptor PositionWindow
        toExclusive__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "to_exclusive"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Position)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'toExclusive")) ::
              Data.ProtoLens.FieldDescriptor PositionWindow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, fromInclusive__field_descriptor),
           (Data.ProtoLens.Tag 2, toExclusive__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _PositionWindow'_unknownFields
        (\ x__ y__ -> x__ {_PositionWindow'_unknownFields = y__})
  defMessage
    = PositionWindow'_constructor
        {_PositionWindow'fromInclusive = Prelude.Nothing,
         _PositionWindow'toExclusive = Prelude.Nothing,
         _PositionWindow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          PositionWindow
          -> Data.ProtoLens.Encoding.Bytes.Parser PositionWindow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "from_inclusive"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"fromInclusive") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "to_exclusive"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"toExclusive") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "PositionWindow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'fromInclusive") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'toExclusive") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData PositionWindow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_PositionWindow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_PositionWindow'fromInclusive x__)
                (Control.DeepSeq.deepseq (_PositionWindow'toExclusive x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.datum' @:: Lens' RegistrationRow Datum@
         * 'Proto.McFollower_Fields.maybe'datum' @:: Lens' RegistrationRow (Prelude.Maybe Datum)@
         * 'Proto.McFollower_Fields.blockNo' @:: Lens' RegistrationRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.blockHash' @:: Lens' RegistrationRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.blockTimeUnixMillis' @:: Lens' RegistrationRow Data.Int.Int64@
         * 'Proto.McFollower_Fields.txIndex' @:: Lens' RegistrationRow Data.Word.Word32@
         * 'Proto.McFollower_Fields.txHash' @:: Lens' RegistrationRow Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' RegistrationRow Data.Word.Word32@ -}
data RegistrationRow
  = RegistrationRow'_constructor {_RegistrationRow'datum :: !(Prelude.Maybe Datum),
                                  _RegistrationRow'blockNo :: !Data.Word.Word32,
                                  _RegistrationRow'blockHash :: !Data.ByteString.ByteString,
                                  _RegistrationRow'blockTimeUnixMillis :: !Data.Int.Int64,
                                  _RegistrationRow'txIndex :: !Data.Word.Word32,
                                  _RegistrationRow'txHash :: !Data.ByteString.ByteString,
                                  _RegistrationRow'utxoIndex :: !Data.Word.Word32,
                                  _RegistrationRow'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show RegistrationRow where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField RegistrationRow "datum" Datum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'datum
           (\ x__ y__ -> x__ {_RegistrationRow'datum = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RegistrationRow "maybe'datum" (Prelude.Maybe Datum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'datum
           (\ x__ y__ -> x__ {_RegistrationRow'datum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "blockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'blockNo
           (\ x__ y__ -> x__ {_RegistrationRow'blockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "blockHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'blockHash
           (\ x__ y__ -> x__ {_RegistrationRow'blockHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "blockTimeUnixMillis" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'blockTimeUnixMillis
           (\ x__ y__ -> x__ {_RegistrationRow'blockTimeUnixMillis = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "txIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'txIndex
           (\ x__ y__ -> x__ {_RegistrationRow'txIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "txHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'txHash
           (\ x__ y__ -> x__ {_RegistrationRow'txHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField RegistrationRow "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RegistrationRow'utxoIndex
           (\ x__ y__ -> x__ {_RegistrationRow'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Message RegistrationRow where
  messageName _ = Data.Text.pack "mcfollower.v1.RegistrationRow"
  packedMessageDescriptor _
    = "\n\
      \\SIRegistrationRow\DC2*\n\
      \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
      \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
      \\n\
      \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC23\n\
      \\SYNblock_time_unix_millis\CAN\EOT \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
      \\btx_index\CAN\ENQ \SOH(\rR\atxIndex\DC2\ETB\n\
      \\atx_hash\CAN\ACK \SOH(\fR\ACKtxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\a \SOH(\rR\tutxoIndex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        datum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "datum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Datum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'datum")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        blockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"blockNo")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        blockHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockHash")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        blockTimeUnixMillis__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "block_time_unix_millis"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"blockTimeUnixMillis")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        txIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txIndex")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        txHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"txHash")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor RegistrationRow
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, datum__field_descriptor),
           (Data.ProtoLens.Tag 2, blockNo__field_descriptor),
           (Data.ProtoLens.Tag 3, blockHash__field_descriptor),
           (Data.ProtoLens.Tag 4, blockTimeUnixMillis__field_descriptor),
           (Data.ProtoLens.Tag 5, txIndex__field_descriptor),
           (Data.ProtoLens.Tag 6, txHash__field_descriptor),
           (Data.ProtoLens.Tag 7, utxoIndex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RegistrationRow'_unknownFields
        (\ x__ y__ -> x__ {_RegistrationRow'_unknownFields = y__})
  defMessage
    = RegistrationRow'_constructor
        {_RegistrationRow'datum = Prelude.Nothing,
         _RegistrationRow'blockNo = Data.ProtoLens.fieldDefault,
         _RegistrationRow'blockHash = Data.ProtoLens.fieldDefault,
         _RegistrationRow'blockTimeUnixMillis = Data.ProtoLens.fieldDefault,
         _RegistrationRow'txIndex = Data.ProtoLens.fieldDefault,
         _RegistrationRow'txHash = Data.ProtoLens.fieldDefault,
         _RegistrationRow'utxoIndex = Data.ProtoLens.fieldDefault,
         _RegistrationRow'_unknownFields = []}
  parseMessage
    = let
        loop ::
          RegistrationRow
          -> Data.ProtoLens.Encoding.Bytes.Parser RegistrationRow
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "datum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"datum") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_no"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"blockNo") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "block_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"blockHash") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "block_time_unix_millis"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"blockTimeUnixMillis") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_index"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txIndex") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "tx_hash"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"txHash") y x)
                        56
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RegistrationRow"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'datum") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockNo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"blockHash") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"blockTimeUnixMillis") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txIndex") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txHash") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                     ((\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                        _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view (Data.ProtoLens.Field.field @"utxoIndex") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                                        ((Prelude..)
                                           Data.ProtoLens.Encoding.Bytes.putVarInt
                                           Prelude.fromIntegral _v))
                               (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                  (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))
instance Control.DeepSeq.NFData RegistrationRow where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RegistrationRow'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_RegistrationRow'datum x__)
                (Control.DeepSeq.deepseq
                   (_RegistrationRow'blockNo x__)
                   (Control.DeepSeq.deepseq
                      (_RegistrationRow'blockHash x__)
                      (Control.DeepSeq.deepseq
                         (_RegistrationRow'blockTimeUnixMillis x__)
                         (Control.DeepSeq.deepseq
                            (_RegistrationRow'txIndex x__)
                            (Control.DeepSeq.deepseq
                               (_RegistrationRow'txHash x__)
                               (Control.DeepSeq.deepseq (_RegistrationRow'utxoIndex x__) ())))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.poolHash' @:: Lens' StakePoolEntry Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.stake' @:: Lens' StakePoolEntry Data.Word.Word64@ -}
data StakePoolEntry
  = StakePoolEntry'_constructor {_StakePoolEntry'poolHash :: !Data.ByteString.ByteString,
                                 _StakePoolEntry'stake :: !Data.Word.Word64,
                                 _StakePoolEntry'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show StakePoolEntry where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField StakePoolEntry "poolHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _StakePoolEntry'poolHash
           (\ x__ y__ -> x__ {_StakePoolEntry'poolHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField StakePoolEntry "stake" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _StakePoolEntry'stake
           (\ x__ y__ -> x__ {_StakePoolEntry'stake = y__}))
        Prelude.id
instance Data.ProtoLens.Message StakePoolEntry where
  messageName _ = Data.Text.pack "mcfollower.v1.StakePoolEntry"
  packedMessageDescriptor _
    = "\n\
      \\SOStakePoolEntry\DC2\ESC\n\
      \\tpool_hash\CAN\SOH \SOH(\fR\bpoolHash\DC2\DC4\n\
      \\ENQstake\CAN\STX \SOH(\EOTR\ENQstake"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        poolHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "pool_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"poolHash")) ::
              Data.ProtoLens.FieldDescriptor StakePoolEntry
        stake__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stake"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"stake")) ::
              Data.ProtoLens.FieldDescriptor StakePoolEntry
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, poolHash__field_descriptor),
           (Data.ProtoLens.Tag 2, stake__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _StakePoolEntry'_unknownFields
        (\ x__ y__ -> x__ {_StakePoolEntry'_unknownFields = y__})
  defMessage
    = StakePoolEntry'_constructor
        {_StakePoolEntry'poolHash = Data.ProtoLens.fieldDefault,
         _StakePoolEntry'stake = Data.ProtoLens.fieldDefault,
         _StakePoolEntry'_unknownFields = []}
  parseMessage
    = let
        loop ::
          StakePoolEntry
          -> Data.ProtoLens.Encoding.Bytes.Parser StakePoolEntry
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "pool_hash"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"poolHash") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "stake"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"stake") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "StakePoolEntry"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"poolHash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"stake") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData StakePoolEntry where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_StakePoolEntry'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_StakePoolEntry'poolHash x__)
                (Control.DeepSeq.deepseq (_StakePoolEntry'stake x__) ()))
{- | Fields :
     
         * 'Proto.McFollower_Fields.originTxHash' @:: Lens' TokenTxOutput Data.ByteString.ByteString@
         * 'Proto.McFollower_Fields.utxoIndex' @:: Lens' TokenTxOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.txEpochNo' @:: Lens' TokenTxOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.txBlockNo' @:: Lens' TokenTxOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.txSlotNo' @:: Lens' TokenTxOutput Data.Word.Word64@
         * 'Proto.McFollower_Fields.txBlockIndex' @:: Lens' TokenTxOutput Data.Word.Word32@
         * 'Proto.McFollower_Fields.datum' @:: Lens' TokenTxOutput Datum@
         * 'Proto.McFollower_Fields.maybe'datum' @:: Lens' TokenTxOutput (Prelude.Maybe Datum)@ -}
data TokenTxOutput
  = TokenTxOutput'_constructor {_TokenTxOutput'originTxHash :: !Data.ByteString.ByteString,
                                _TokenTxOutput'utxoIndex :: !Data.Word.Word32,
                                _TokenTxOutput'txEpochNo :: !Data.Word.Word32,
                                _TokenTxOutput'txBlockNo :: !Data.Word.Word32,
                                _TokenTxOutput'txSlotNo :: !Data.Word.Word64,
                                _TokenTxOutput'txBlockIndex :: !Data.Word.Word32,
                                _TokenTxOutput'datum :: !(Prelude.Maybe Datum),
                                _TokenTxOutput'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TokenTxOutput where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField TokenTxOutput "originTxHash" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'originTxHash
           (\ x__ y__ -> x__ {_TokenTxOutput'originTxHash = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "utxoIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'utxoIndex
           (\ x__ y__ -> x__ {_TokenTxOutput'utxoIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "txEpochNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'txEpochNo
           (\ x__ y__ -> x__ {_TokenTxOutput'txEpochNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "txBlockNo" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'txBlockNo
           (\ x__ y__ -> x__ {_TokenTxOutput'txBlockNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "txSlotNo" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'txSlotNo
           (\ x__ y__ -> x__ {_TokenTxOutput'txSlotNo = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "txBlockIndex" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'txBlockIndex
           (\ x__ y__ -> x__ {_TokenTxOutput'txBlockIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TokenTxOutput "datum" Datum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'datum
           (\ x__ y__ -> x__ {_TokenTxOutput'datum = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField TokenTxOutput "maybe'datum" (Prelude.Maybe Datum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TokenTxOutput'datum
           (\ x__ y__ -> x__ {_TokenTxOutput'datum = y__}))
        Prelude.id
instance Data.ProtoLens.Message TokenTxOutput where
  messageName _ = Data.Text.pack "mcfollower.v1.TokenTxOutput"
  packedMessageDescriptor _
    = "\n\
      \\rTokenTxOutput\DC2$\n\
      \\SOorigin_tx_hash\CAN\SOH \SOH(\fR\foriginTxHash\DC2\GS\n\
      \\n\
      \utxo_index\CAN\STX \SOH(\rR\tutxoIndex\DC2\RS\n\
      \\vtx_epoch_no\CAN\ETX \SOH(\rR\ttxEpochNo\DC2\RS\n\
      \\vtx_block_no\CAN\EOT \SOH(\rR\ttxBlockNo\DC2\FS\n\
      \\n\
      \tx_slot_no\CAN\ENQ \SOH(\EOTR\btxSlotNo\DC2$\n\
      \\SOtx_block_index\CAN\ACK \SOH(\rR\ftxBlockIndex\DC2/\n\
      \\ENQdatum\CAN\a \SOH(\v2\DC4.mcfollower.v1.DatumH\NULR\ENQdatum\136\SOH\SOHB\b\n\
      \\ACK_datum"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        originTxHash__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "origin_tx_hash"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"originTxHash")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        utxoIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "utxo_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"utxoIndex")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        txEpochNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_epoch_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txEpochNo")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        txBlockNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_block_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txBlockNo")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        txSlotNo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_slot_no"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txSlotNo")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        txBlockIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "tx_block_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"txBlockIndex")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
        datum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "datum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Datum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'datum")) ::
              Data.ProtoLens.FieldDescriptor TokenTxOutput
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, originTxHash__field_descriptor),
           (Data.ProtoLens.Tag 2, utxoIndex__field_descriptor),
           (Data.ProtoLens.Tag 3, txEpochNo__field_descriptor),
           (Data.ProtoLens.Tag 4, txBlockNo__field_descriptor),
           (Data.ProtoLens.Tag 5, txSlotNo__field_descriptor),
           (Data.ProtoLens.Tag 6, txBlockIndex__field_descriptor),
           (Data.ProtoLens.Tag 7, datum__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TokenTxOutput'_unknownFields
        (\ x__ y__ -> x__ {_TokenTxOutput'_unknownFields = y__})
  defMessage
    = TokenTxOutput'_constructor
        {_TokenTxOutput'originTxHash = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'utxoIndex = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'txEpochNo = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'txBlockNo = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'txSlotNo = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'txBlockIndex = Data.ProtoLens.fieldDefault,
         _TokenTxOutput'datum = Prelude.Nothing,
         _TokenTxOutput'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TokenTxOutput -> Data.ProtoLens.Encoding.Bytes.Parser TokenTxOutput
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "origin_tx_hash"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"originTxHash") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "utxo_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"utxoIndex") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_epoch_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txEpochNo") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_block_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txBlockNo") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "tx_slot_no"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"txSlotNo") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "tx_block_index"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"txBlockIndex") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "datum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"datum") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "TokenTxOutput"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"originTxHash") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"utxoIndex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txEpochNo") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txBlockNo") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"txSlotNo") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                         ((Data.Monoid.<>)
                            (let
                               _v
                                 = Lens.Family2.view (Data.ProtoLens.Field.field @"txBlockIndex") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                        _v))
                            ((Data.Monoid.<>)
                               (case
                                    Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'datum") _x
                                of
                                  Prelude.Nothing -> Data.Monoid.mempty
                                  (Prelude.Just _v)
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                         ((Prelude..)
                                            (\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                            Data.ProtoLens.encodeMessage _v))
                               (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                  (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))
instance Control.DeepSeq.NFData TokenTxOutput where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TokenTxOutput'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_TokenTxOutput'originTxHash x__)
                (Control.DeepSeq.deepseq
                   (_TokenTxOutput'utxoIndex x__)
                   (Control.DeepSeq.deepseq
                      (_TokenTxOutput'txEpochNo x__)
                      (Control.DeepSeq.deepseq
                         (_TokenTxOutput'txBlockNo x__)
                         (Control.DeepSeq.deepseq
                            (_TokenTxOutput'txSlotNo x__)
                            (Control.DeepSeq.deepseq
                               (_TokenTxOutput'txBlockIndex x__)
                               (Control.DeepSeq.deepseq (_TokenTxOutput'datum x__) ())))))))
{- | Fields :
     
         * 'Proto.McFollower_Fields.hi' @:: Lens' Uint128 Data.Word.Word64@
         * 'Proto.McFollower_Fields.lo' @:: Lens' Uint128 Data.Word.Word64@ -}
data Uint128
  = Uint128'_constructor {_Uint128'hi :: !Data.Word.Word64,
                          _Uint128'lo :: !Data.Word.Word64,
                          _Uint128'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Uint128 where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Uint128 "hi" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Uint128'hi (\ x__ y__ -> x__ {_Uint128'hi = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Uint128 "lo" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Uint128'lo (\ x__ y__ -> x__ {_Uint128'lo = y__}))
        Prelude.id
instance Data.ProtoLens.Message Uint128 where
  messageName _ = Data.Text.pack "mcfollower.v1.Uint128"
  packedMessageDescriptor _
    = "\n\
      \\aUint128\DC2\SO\n\
      \\STXhi\CAN\SOH \SOH(\ACKR\STXhi\DC2\SO\n\
      \\STXlo\CAN\STX \SOH(\ACKR\STXlo"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        hi__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "hi"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"hi")) ::
              Data.ProtoLens.FieldDescriptor Uint128
        lo__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "lo"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"lo")) ::
              Data.ProtoLens.FieldDescriptor Uint128
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, hi__field_descriptor),
           (Data.ProtoLens.Tag 2, lo__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Uint128'_unknownFields
        (\ x__ y__ -> x__ {_Uint128'_unknownFields = y__})
  defMessage
    = Uint128'_constructor
        {_Uint128'hi = Data.ProtoLens.fieldDefault,
         _Uint128'lo = Data.ProtoLens.fieldDefault,
         _Uint128'_unknownFields = []}
  parseMessage
    = let
        loop :: Uint128 -> Data.ProtoLens.Encoding.Bytes.Parser Uint128
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        9 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "hi"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"hi") y x)
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "lo"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"lo") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Uint128"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"hi") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 9)
                      (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
             ((Data.Monoid.<>)
                (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"lo") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Uint128 where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Uint128'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Uint128'hi x__) (Control.DeepSeq.deepseq (_Uint128'lo x__) ()))
data McFollower = McFollower {}
instance Data.ProtoLens.Service.Types.Service McFollower where
  type ServiceName McFollower = "McFollower"
  type ServicePackage McFollower = "mcfollower.v1"
  type ServiceMethods McFollower = '["getAssetCreates",
                                     "getAssetSpends",
                                     "getBlockByHash",
                                     "getBlocksByNumberRange",
                                     "getBridgeTxs",
                                     "getEpochNonce",
                                     "getHighestBlockInWindow",
                                     "getLatestBlock",
                                     "getLatestBlockForEpoch",
                                     "getLatestGovernanceOutput",
                                     "getLatestStableEpoch",
                                     "getLatestTokenOutputForEpoch",
                                     "getMappingDeregistrations",
                                     "getMappingRegistrations",
                                     "getMaxTxSize",
                                     "getStakeDistribution",
                                     "getStatus",
                                     "getTxPosition",
                                     "getUnspentOutputsAtAddress"]
  packedServiceDescriptor _
    = "\n\
      \\n\
      \McFollower\DC2N\n\
      \\tGetStatus\DC2\US.mcfollower.v1.GetStatusRequest\SUB .mcfollower.v1.GetStatusResponse\DC2T\n\
      \\SOGetLatestBlock\DC2$.mcfollower.v1.GetLatestBlockRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2^\n\
      \\SYNGetBlocksByNumberRange\DC2,.mcfollower.v1.GetBlocksByNumberRangeRequest\SUB\DC4.mcfollower.v1.Block0\SOH\DC2f\n\
      \\ETBGetHighestBlockInWindow\DC2-.mcfollower.v1.GetHighestBlockInWindowRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2T\n\
      \\SOGetBlockByHash\DC2$.mcfollower.v1.GetBlockByHashRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2Z\n\
      \\rGetTxPosition\DC2#.mcfollower.v1.GetTxPositionRequest\SUB$.mcfollower.v1.GetTxPositionResponse\DC2P\n\
      \\fGetBridgeTxs\DC2\".mcfollower.v1.GetBridgeTxsRequest\SUB\SUB.mcfollower.v1.BridgeTxRow0\SOH\DC2d\n\
      \\SYNGetLatestBlockForEpoch\DC2,.mcfollower.v1.GetLatestBlockForEpochRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2o\n\
      \\DC4GetLatestStableEpoch\DC2*.mcfollower.v1.GetLatestStableEpochRequest\SUB+.mcfollower.v1.GetLatestStableEpochResponse\DC2c\n\
      \\DC4GetStakeDistribution\DC2*.mcfollower.v1.GetStakeDistributionRequest\SUB\GS.mcfollower.v1.StakePoolEntry0\SOH\DC2\135\SOH\n\
      \\FSGetLatestTokenOutputForEpoch\DC22.mcfollower.v1.GetLatestTokenOutputForEpochRequest\SUB3.mcfollower.v1.GetLatestTokenOutputForEpochResponse\DC2Z\n\
      \\rGetEpochNonce\DC2#.mcfollower.v1.GetEpochNonceRequest\SUB$.mcfollower.v1.GetEpochNonceResponse\DC2q\n\
      \\SUBGetUnspentOutputsAtAddress\DC20.mcfollower.v1.GetUnspentOutputsAtAddressRequest\SUB\US.mcfollower.v1.AddressOutputRow0\SOH\DC2j\n\
      \\ETBGetMappingRegistrations\DC2-.mcfollower.v1.GetMappingRegistrationsRequest\SUB\RS.mcfollower.v1.RegistrationRow0\SOH\DC2p\n\
      \\EMGetMappingDeregistrations\DC2/.mcfollower.v1.GetMappingDeregistrationsRequest\SUB .mcfollower.v1.DeregistrationRow0\SOH\DC2Y\n\
      \\SIGetAssetCreates\DC2%.mcfollower.v1.GetAssetCreatesRequest\SUB\GS.mcfollower.v1.AssetCreateRow0\SOH\DC2V\n\
      \\SOGetAssetSpends\DC2$.mcfollower.v1.GetAssetSpendsRequest\SUB\FS.mcfollower.v1.AssetSpendRow0\SOH\DC2W\n\
      \\fGetMaxTxSize\DC2\".mcfollower.v1.GetMaxTxSizeRequest\SUB#.mcfollower.v1.GetMaxTxSizeResponse\DC2~\n\
      \\EMGetLatestGovernanceOutput\DC2/.mcfollower.v1.GetLatestGovernanceOutputRequest\SUB0.mcfollower.v1.GetLatestGovernanceOutputResponse"
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getStatus" where
  type MethodName McFollower "getStatus" = "GetStatus"
  type MethodInput McFollower "getStatus" = GetStatusRequest
  type MethodOutput McFollower "getStatus" = GetStatusResponse
  type MethodStreamingType McFollower "getStatus" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getLatestBlock" where
  type MethodName McFollower "getLatestBlock" = "GetLatestBlock"
  type MethodInput McFollower "getLatestBlock" = GetLatestBlockRequest
  type MethodOutput McFollower "getLatestBlock" = OptionalBlock
  type MethodStreamingType McFollower "getLatestBlock" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getBlocksByNumberRange" where
  type MethodName McFollower "getBlocksByNumberRange" = "GetBlocksByNumberRange"
  type MethodInput McFollower "getBlocksByNumberRange" = GetBlocksByNumberRangeRequest
  type MethodOutput McFollower "getBlocksByNumberRange" = Block
  type MethodStreamingType McFollower "getBlocksByNumberRange" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getHighestBlockInWindow" where
  type MethodName McFollower "getHighestBlockInWindow" = "GetHighestBlockInWindow"
  type MethodInput McFollower "getHighestBlockInWindow" = GetHighestBlockInWindowRequest
  type MethodOutput McFollower "getHighestBlockInWindow" = OptionalBlock
  type MethodStreamingType McFollower "getHighestBlockInWindow" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getBlockByHash" where
  type MethodName McFollower "getBlockByHash" = "GetBlockByHash"
  type MethodInput McFollower "getBlockByHash" = GetBlockByHashRequest
  type MethodOutput McFollower "getBlockByHash" = OptionalBlock
  type MethodStreamingType McFollower "getBlockByHash" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getTxPosition" where
  type MethodName McFollower "getTxPosition" = "GetTxPosition"
  type MethodInput McFollower "getTxPosition" = GetTxPositionRequest
  type MethodOutput McFollower "getTxPosition" = GetTxPositionResponse
  type MethodStreamingType McFollower "getTxPosition" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getBridgeTxs" where
  type MethodName McFollower "getBridgeTxs" = "GetBridgeTxs"
  type MethodInput McFollower "getBridgeTxs" = GetBridgeTxsRequest
  type MethodOutput McFollower "getBridgeTxs" = BridgeTxRow
  type MethodStreamingType McFollower "getBridgeTxs" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getLatestBlockForEpoch" where
  type MethodName McFollower "getLatestBlockForEpoch" = "GetLatestBlockForEpoch"
  type MethodInput McFollower "getLatestBlockForEpoch" = GetLatestBlockForEpochRequest
  type MethodOutput McFollower "getLatestBlockForEpoch" = OptionalBlock
  type MethodStreamingType McFollower "getLatestBlockForEpoch" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getLatestStableEpoch" where
  type MethodName McFollower "getLatestStableEpoch" = "GetLatestStableEpoch"
  type MethodInput McFollower "getLatestStableEpoch" = GetLatestStableEpochRequest
  type MethodOutput McFollower "getLatestStableEpoch" = GetLatestStableEpochResponse
  type MethodStreamingType McFollower "getLatestStableEpoch" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getStakeDistribution" where
  type MethodName McFollower "getStakeDistribution" = "GetStakeDistribution"
  type MethodInput McFollower "getStakeDistribution" = GetStakeDistributionRequest
  type MethodOutput McFollower "getStakeDistribution" = StakePoolEntry
  type MethodStreamingType McFollower "getStakeDistribution" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getLatestTokenOutputForEpoch" where
  type MethodName McFollower "getLatestTokenOutputForEpoch" = "GetLatestTokenOutputForEpoch"
  type MethodInput McFollower "getLatestTokenOutputForEpoch" = GetLatestTokenOutputForEpochRequest
  type MethodOutput McFollower "getLatestTokenOutputForEpoch" = GetLatestTokenOutputForEpochResponse
  type MethodStreamingType McFollower "getLatestTokenOutputForEpoch" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getEpochNonce" where
  type MethodName McFollower "getEpochNonce" = "GetEpochNonce"
  type MethodInput McFollower "getEpochNonce" = GetEpochNonceRequest
  type MethodOutput McFollower "getEpochNonce" = GetEpochNonceResponse
  type MethodStreamingType McFollower "getEpochNonce" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getUnspentOutputsAtAddress" where
  type MethodName McFollower "getUnspentOutputsAtAddress" = "GetUnspentOutputsAtAddress"
  type MethodInput McFollower "getUnspentOutputsAtAddress" = GetUnspentOutputsAtAddressRequest
  type MethodOutput McFollower "getUnspentOutputsAtAddress" = AddressOutputRow
  type MethodStreamingType McFollower "getUnspentOutputsAtAddress" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getMappingRegistrations" where
  type MethodName McFollower "getMappingRegistrations" = "GetMappingRegistrations"
  type MethodInput McFollower "getMappingRegistrations" = GetMappingRegistrationsRequest
  type MethodOutput McFollower "getMappingRegistrations" = RegistrationRow
  type MethodStreamingType McFollower "getMappingRegistrations" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getMappingDeregistrations" where
  type MethodName McFollower "getMappingDeregistrations" = "GetMappingDeregistrations"
  type MethodInput McFollower "getMappingDeregistrations" = GetMappingDeregistrationsRequest
  type MethodOutput McFollower "getMappingDeregistrations" = DeregistrationRow
  type MethodStreamingType McFollower "getMappingDeregistrations" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getAssetCreates" where
  type MethodName McFollower "getAssetCreates" = "GetAssetCreates"
  type MethodInput McFollower "getAssetCreates" = GetAssetCreatesRequest
  type MethodOutput McFollower "getAssetCreates" = AssetCreateRow
  type MethodStreamingType McFollower "getAssetCreates" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getAssetSpends" where
  type MethodName McFollower "getAssetSpends" = "GetAssetSpends"
  type MethodInput McFollower "getAssetSpends" = GetAssetSpendsRequest
  type MethodOutput McFollower "getAssetSpends" = AssetSpendRow
  type MethodStreamingType McFollower "getAssetSpends" = 'Data.ProtoLens.Service.Types.ServerStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getMaxTxSize" where
  type MethodName McFollower "getMaxTxSize" = "GetMaxTxSize"
  type MethodInput McFollower "getMaxTxSize" = GetMaxTxSizeRequest
  type MethodOutput McFollower "getMaxTxSize" = GetMaxTxSizeResponse
  type MethodStreamingType McFollower "getMaxTxSize" = 'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl McFollower "getLatestGovernanceOutput" where
  type MethodName McFollower "getLatestGovernanceOutput" = "GetLatestGovernanceOutput"
  type MethodInput McFollower "getLatestGovernanceOutput" = GetLatestGovernanceOutputRequest
  type MethodOutput McFollower "getLatestGovernanceOutput" = GetLatestGovernanceOutputResponse
  type MethodStreamingType McFollower "getLatestGovernanceOutput" = 'Data.ProtoLens.Service.Types.NonStreaming
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\DC1mc_follower.proto\DC2\rmcfollower.v1\"\177\SOH\n\
    \\ENQBlock\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\DC2\n\
    \\EOThash\CAN\STX \SOH(\fR\EOThash\DC2\EM\n\
    \\bepoch_no\CAN\ETX \SOH(\rR\aepochNo\DC2\ETB\n\
    \\aslot_no\CAN\EOT \SOH(\EOTR\ACKslotNo\DC2*\n\
    \\DC1time_unix_seconds\CAN\ENQ \SOH(\ETXR\SItimeUnixSeconds\DC2\EM\n\
    \\btx_count\CAN\ACK \SOH(\EOTR\atxCount\"J\n\
    \\rOptionalBlock\DC2/\n\
    \\ENQblock\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.BlockH\NULR\ENQblock\136\SOH\SOHB\b\n\
    \\ACK_block\"@\n\
    \\bPosition\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\EM\n\
    \\btx_index\CAN\STX \SOH(\rR\atxIndex\"\140\SOH\n\
    \\SOPositionWindow\DC2>\n\
    \\SOfrom_inclusive\CAN\SOH \SOH(\v2\ETB.mcfollower.v1.PositionR\rfromInclusive\DC2:\n\
    \\fto_exclusive\CAN\STX \SOH(\v2\ETB.mcfollower.v1.PositionR\vtoExclusive\"E\n\
    \\aAssetId\DC2\ESC\n\
    \\tpolicy_id\CAN\SOH \SOH(\fR\bpolicyId\DC2\GS\n\
    \\n\
    \asset_name\CAN\STX \SOH(\fR\tassetName\":\n\
    \\tOutputRef\DC2\ETB\n\
    \\atx_hash\CAN\SOH \SOH(\fR\ACKtxHash\DC2\DC4\n\
    \\ENQindex\CAN\STX \SOH(\rR\ENQindex\"\ESC\n\
    \\ENQDatum\DC2\DC2\n\
    \\EOTcbor\CAN\SOH \SOH(\fR\EOTcbor\")\n\
    \\aUint128\DC2\SO\n\
    \\STXhi\CAN\SOH \SOH(\ACKR\STXhi\DC2\SO\n\
    \\STXlo\CAN\STX \SOH(\ACKR\STXlo\"\DC2\n\
    \\DLEGetStatusRequest\"\143\EOT\n\
    \\DC1GetStatusResponse\DC2+\n\
    \\ETXtip\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.BlockH\NULR\ETXtip\136\SOH\SOH\DC2>\n\
    \\rimmutable_tip\CAN\STX \SOH(\v2\DC4.mcfollower.v1.BlockH\SOHR\fimmutableTip\136\SOH\SOH\DC2-\n\
    \\DC2security_parameter\CAN\ETX \SOH(\rR\DC1securityParameter\DC2\CAN\n\
    \\asyncing\CAN\EOT \SOH(\bR\asyncing\DC2/\n\
    \\DC1upstream_tip_slot\CAN\ENQ \SOH(\EOTH\STXR\SIupstreamTipSlot\136\SOH\SOH\DC26\n\
    \\NAKupstream_tip_block_no\CAN\ACK \SOH(\rH\ETXR\DC2upstreamTipBlockNo\136\SOH\SOH\DC2:\n\
    \\vstart_block\CAN\a \SOH(\v2\DC4.mcfollower.v1.BlockH\EOTR\n\
    \startBlock\136\SOH\SOH\DC2 \n\
    \\vbackfilling\CAN\b \ETX(\tR\vbackfilling\DC2#\n\
    \\rnetwork_magic\CAN\t \SOH(\rR\fnetworkMagicB\ACK\n\
    \\EOT_tipB\DLE\n\
    \\SO_immutable_tipB\DC4\n\
    \\DC2_upstream_tip_slotB\CAN\n\
    \\SYN_upstream_tip_block_noB\SO\n\
    \\f_start_block\"\ETB\n\
    \\NAKGetLatestBlockRequest\"c\n\
    \\GSGetBlocksByNumberRangeRequest\DC2\"\n\
    \\rfrom_block_no\CAN\SOH \SOH(\rR\vfromBlockNo\DC2\RS\n\
    \\vto_block_no\CAN\STX \SOH(\rR\ttoBlockNo\"\218\SOH\n\
    \\RSGetHighestBlockInWindowRequest\DC2 \n\
    \\fmax_block_no\CAN\SOH \SOH(\rR\n\
    \maxBlockNo\DC2\EM\n\
    \\bmin_slot\CAN\STX \SOH(\EOTR\aminSlot\DC2\EM\n\
    \\bmax_slot\CAN\ETX \SOH(\EOTR\amaxSlot\DC2/\n\
    \\DC4min_time_unix_millis\CAN\EOT \SOH(\ETXR\DC1minTimeUnixMillis\DC2/\n\
    \\DC4max_time_unix_millis\CAN\ENQ \SOH(\ETXR\DC1maxTimeUnixMillis\"+\n\
    \\NAKGetBlockByHashRequest\DC2\DC2\n\
    \\EOThash\CAN\SOH \SOH(\fR\EOThash\"/\n\
    \\DC4GetTxPositionRequest\DC2\ETB\n\
    \\atx_hash\CAN\SOH \SOH(\fR\ACKtxHash\"^\n\
    \\NAKGetTxPositionResponse\DC28\n\
    \\bposition\CAN\SOH \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\bposition\136\SOH\SOHB\v\n\
    \\t_position\"\138\ETX\n\
    \\DC3GetBridgeTxsRequest\DC2\US\n\
    \\vics_address\CAN\SOH \SOH(\tR\n\
    \icsAddress\DC2'\n\
    \\SIreserve_address\CAN\STX \SOH(\tR\SOreserveAddress\DC2,\n\
    \\ENQtoken\CAN\ETX \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQtoken\DC2&\n\
    \\SOafter_block_no\CAN\EOT \SOH(\rH\NULR\fafterBlockNo\DC2@\n\
    \\SOafter_position\CAN\ENQ \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\rafterPosition\DC2>\n\
    \\rfrom_position\CAN\ACK \SOH(\v2\ETB.mcfollower.v1.PositionH\NULR\ffromPosition\DC2\RS\n\
    \\vto_block_no\CAN\a \SOH(\rR\ttoBlockNo\DC2\FS\n\
    \\amax_txs\CAN\b \SOH(\rH\SOHR\ACKmaxTxs\136\SOH\SOHB\a\n\
    \\ENQlowerB\n\
    \\n\
    \\b_max_txs\"\130\ETX\n\
    \\vBridgeTxRow\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\EM\n\
    \\btx_index\CAN\STX \SOH(\rR\atxIndex\DC2\ETB\n\
    \\atx_hash\CAN\ETX \SOH(\fR\ACKtxHash\DC21\n\
    \\DC2c2m_metadatum_cbor\CAN\EOT \SOH(\fH\NULR\DLEc2mMetadatumCbor\136\SOH\SOH\DC23\n\
    \\tbridge_in\CAN\ENQ \SOH(\v2\SYN.mcfollower.v1.Uint128R\bbridgeIn\DC25\n\
    \\n\
    \bridge_out\CAN\ACK \SOH(\v2\SYN.mcfollower.v1.Uint128R\tbridgeOut\DC25\n\
    \\n\
    \reserve_in\CAN\a \SOH(\v2\SYN.mcfollower.v1.Uint128R\treserveIn\DC27\n\
    \\vreserve_out\CAN\b \SOH(\v2\SYN.mcfollower.v1.Uint128R\n\
    \reserveOutB\NAK\n\
    \\DC3_c2m_metadatum_cbor\":\n\
    \\GSGetLatestBlockForEpochRequest\DC2\EM\n\
    \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo\"L\n\
    \\ESCGetLatestStableEpochRequest\DC2-\n\
    \\DC2security_parameter\CAN\SOH \SOH(\rR\DC1securityParameter\"K\n\
    \\FSGetLatestStableEpochResponse\DC2\RS\n\
    \\bepoch_no\CAN\SOH \SOH(\ETXH\NULR\aepochNo\136\SOH\SOHB\v\n\
    \\t_epoch_no\"8\n\
    \\ESCGetStakeDistributionRequest\DC2\EM\n\
    \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo\"C\n\
    \\SOStakePoolEntry\DC2\ESC\n\
    \\tpool_hash\CAN\SOH \SOH(\fR\bpoolHash\DC2\DC4\n\
    \\ENQstake\CAN\STX \SOH(\EOTR\ENQstake\"n\n\
    \#GetLatestTokenOutputForEpochRequest\DC2,\n\
    \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC2\EM\n\
    \\bepoch_no\CAN\STX \SOH(\rR\aepochNo\"\147\STX\n\
    \\rTokenTxOutput\DC2$\n\
    \\SOorigin_tx_hash\CAN\SOH \SOH(\fR\foriginTxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\STX \SOH(\rR\tutxoIndex\DC2\RS\n\
    \\vtx_epoch_no\CAN\ETX \SOH(\rR\ttxEpochNo\DC2\RS\n\
    \\vtx_block_no\CAN\EOT \SOH(\rR\ttxBlockNo\DC2\FS\n\
    \\n\
    \tx_slot_no\CAN\ENQ \SOH(\EOTR\btxSlotNo\DC2$\n\
    \\SOtx_block_index\CAN\ACK \SOH(\rR\ftxBlockIndex\DC2/\n\
    \\ENQdatum\CAN\a \SOH(\v2\DC4.mcfollower.v1.DatumH\NULR\ENQdatum\136\SOH\SOHB\b\n\
    \\ACK_datum\"l\n\
    \$GetLatestTokenOutputForEpochResponse\DC29\n\
    \\ACKoutput\CAN\SOH \SOH(\v2\FS.mcfollower.v1.TokenTxOutputH\NULR\ACKoutput\136\SOH\SOHB\t\n\
    \\a_output\"1\n\
    \\DC4GetEpochNonceRequest\DC2\EM\n\
    \\bepoch_no\CAN\SOH \SOH(\rR\aepochNo\"<\n\
    \\NAKGetEpochNonceResponse\DC2\EM\n\
    \\ENQnonce\CAN\SOH \SOH(\fH\NULR\ENQnonce\136\SOH\SOHB\b\n\
    \\ACK_nonce\"X\n\
    \!GetUnspentOutputsAtAddressRequest\DC2\CAN\n\
    \\aaddress\CAN\SOH \SOH(\tR\aaddress\DC2\EM\n\
    \\bblock_no\CAN\STX \SOH(\rR\ablockNo\"\232\STX\n\
    \\DLEAddressOutputRow\DC2 \n\
    \\futxo_tx_hash\CAN\SOH \SOH(\fR\n\
    \utxoTxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\STX \SOH(\rR\tutxoIndex\DC2\RS\n\
    \\vtx_block_no\CAN\ETX \SOH(\rR\ttxBlockNo\DC2\FS\n\
    \\n\
    \tx_slot_no\CAN\EOT \SOH(\EOTR\btxSlotNo\DC2\RS\n\
    \\vtx_epoch_no\CAN\ENQ \SOH(\rR\ttxEpochNo\DC2)\n\
    \\DC1tx_index_in_block\CAN\ACK \SOH(\rR\SOtxIndexInBlock\DC2\CAN\n\
    \\aaddress\CAN\a \SOH(\tR\aaddress\DC2/\n\
    \\ENQdatum\CAN\b \SOH(\v2\DC4.mcfollower.v1.DatumH\NULR\ENQdatum\136\SOH\SOH\DC25\n\
    \\ttx_inputs\CAN\t \ETX(\v2\CAN.mcfollower.v1.OutputRefR\btxInputsB\b\n\
    \\ACK_datum\"\248\SOH\n\
    \\RSGetMappingRegistrationsRequest\DC2:\n\
    \\EMmapping_validator_address\CAN\SOH \SOH(\tR\ETBmappingValidatorAddress\DC25\n\
    \\n\
    \auth_token\CAN\STX \SOH(\v2\SYN.mcfollower.v1.AssetIdR\tauthToken\DC25\n\
    \\ACKwindow\CAN\ETX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
    \\ENQlimit\CAN\EOT \SOH(\rR\ENQlimit\DC2\SYN\n\
    \\ACKoffset\CAN\ENQ \SOH(\rR\ACKoffset\"\255\SOH\n\
    \\SIRegistrationRow\DC2*\n\
    \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
    \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
    \\n\
    \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC23\n\
    \\SYNblock_time_unix_millis\CAN\EOT \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
    \\btx_index\CAN\ENQ \SOH(\rR\atxIndex\DC2\ETB\n\
    \\atx_hash\CAN\ACK \SOH(\fR\ACKtxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\a \SOH(\rR\tutxoIndex\"\195\SOH\n\
    \ GetMappingDeregistrationsRequest\DC2:\n\
    \\EMmapping_validator_address\CAN\SOH \SOH(\tR\ETBmappingValidatorAddress\DC25\n\
    \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
    \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
    \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset\"\163\STX\n\
    \\DC1DeregistrationRow\DC2*\n\
    \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
    \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
    \\n\
    \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC23\n\
    \\SYNblock_time_unix_millis\CAN\EOT \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
    \\btx_index\CAN\ENQ \SOH(\rR\atxIndex\DC2\ETB\n\
    \\atx_hash\CAN\ACK \SOH(\fR\ACKtxHash\DC2 \n\
    \\futxo_tx_hash\CAN\a \SOH(\fR\n\
    \utxoTxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\b \SOH(\rR\tutxoIndex\"\171\SOH\n\
    \\SYNGetAssetCreatesRequest\DC2,\n\
    \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC25\n\
    \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
    \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
    \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset\"\149\STX\n\
    \\SOAssetCreateRow\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\GS\n\
    \\n\
    \block_hash\CAN\STX \SOH(\fR\tblockHash\DC23\n\
    \\SYNblock_time_unix_millis\CAN\ETX \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
    \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\SUB\n\
    \\bquantity\CAN\ENQ \SOH(\EOTR\bquantity\DC2%\n\
    \\SOholder_address\CAN\ACK \SOH(\tR\rholderAddress\DC2\ETB\n\
    \\atx_hash\CAN\a \SOH(\fR\ACKtxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\b \SOH(\rR\tutxoIndex\"\170\SOH\n\
    \\NAKGetAssetSpendsRequest\DC2,\n\
    \\ENQasset\CAN\SOH \SOH(\v2\SYN.mcfollower.v1.AssetIdR\ENQasset\DC25\n\
    \\ACKwindow\CAN\STX \SOH(\v2\GS.mcfollower.v1.PositionWindowR\ACKwindow\DC2\DC4\n\
    \\ENQlimit\CAN\ETX \SOH(\rR\ENQlimit\DC2\SYN\n\
    \\ACKoffset\CAN\EOT \SOH(\rR\ACKoffset\"\199\STX\n\
    \\rAssetSpendRow\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\DC2\GS\n\
    \\n\
    \block_hash\CAN\STX \SOH(\fR\tblockHash\DC23\n\
    \\SYNblock_time_unix_millis\CAN\ETX \SOH(\ETXR\DC3blockTimeUnixMillis\DC2\EM\n\
    \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\SUB\n\
    \\bquantity\CAN\ENQ \SOH(\EOTR\bquantity\DC2%\n\
    \\SOholder_address\CAN\ACK \SOH(\tR\rholderAddress\DC2 \n\
    \\futxo_tx_hash\CAN\a \SOH(\fR\n\
    \utxoTxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\b \SOH(\rR\tutxoIndex\DC2(\n\
    \\DLEspending_tx_hash\CAN\t \SOH(\fR\SOspendingTxHash\"0\n\
    \\DC3GetMaxTxSizeRequest\DC2\EM\n\
    \\bblock_no\CAN\SOH \SOH(\rR\ablockNo\"K\n\
    \\DC4GetMaxTxSizeResponse\DC2#\n\
    \\vmax_tx_size\CAN\SOH \SOH(\EOTH\NULR\tmaxTxSize\136\SOH\SOHB\SO\n\
    \\f_max_tx_size\"t\n\
    \ GetLatestGovernanceOutputRequest\DC2\CAN\n\
    \\aaddress\CAN\SOH \SOH(\tR\aaddress\DC2\ESC\n\
    \\tpolicy_id\CAN\STX \SOH(\fR\bpolicyId\DC2\EM\n\
    \\bblock_no\CAN\ETX \SOH(\rR\ablockNo\"\203\SOH\n\
    \\DLEGovernanceOutput\DC2*\n\
    \\ENQdatum\CAN\SOH \SOH(\v2\DC4.mcfollower.v1.DatumR\ENQdatum\DC2\EM\n\
    \\bblock_no\CAN\STX \SOH(\rR\ablockNo\DC2\GS\n\
    \\n\
    \block_hash\CAN\ETX \SOH(\fR\tblockHash\DC2\EM\n\
    \\btx_index\CAN\EOT \SOH(\rR\atxIndex\DC2\ETB\n\
    \\atx_hash\CAN\ENQ \SOH(\fR\ACKtxHash\DC2\GS\n\
    \\n\
    \utxo_index\CAN\ACK \SOH(\rR\tutxoIndex\"l\n\
    \!GetLatestGovernanceOutputResponse\DC2<\n\
    \\ACKoutput\CAN\SOH \SOH(\v2\US.mcfollower.v1.GovernanceOutputH\NULR\ACKoutput\136\SOH\SOHB\t\n\
    \\a_output2\253\SO\n\
    \\n\
    \McFollower\DC2N\n\
    \\tGetStatus\DC2\US.mcfollower.v1.GetStatusRequest\SUB .mcfollower.v1.GetStatusResponse\DC2T\n\
    \\SOGetLatestBlock\DC2$.mcfollower.v1.GetLatestBlockRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2^\n\
    \\SYNGetBlocksByNumberRange\DC2,.mcfollower.v1.GetBlocksByNumberRangeRequest\SUB\DC4.mcfollower.v1.Block0\SOH\DC2f\n\
    \\ETBGetHighestBlockInWindow\DC2-.mcfollower.v1.GetHighestBlockInWindowRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2T\n\
    \\SOGetBlockByHash\DC2$.mcfollower.v1.GetBlockByHashRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2Z\n\
    \\rGetTxPosition\DC2#.mcfollower.v1.GetTxPositionRequest\SUB$.mcfollower.v1.GetTxPositionResponse\DC2P\n\
    \\fGetBridgeTxs\DC2\".mcfollower.v1.GetBridgeTxsRequest\SUB\SUB.mcfollower.v1.BridgeTxRow0\SOH\DC2d\n\
    \\SYNGetLatestBlockForEpoch\DC2,.mcfollower.v1.GetLatestBlockForEpochRequest\SUB\FS.mcfollower.v1.OptionalBlock\DC2o\n\
    \\DC4GetLatestStableEpoch\DC2*.mcfollower.v1.GetLatestStableEpochRequest\SUB+.mcfollower.v1.GetLatestStableEpochResponse\DC2c\n\
    \\DC4GetStakeDistribution\DC2*.mcfollower.v1.GetStakeDistributionRequest\SUB\GS.mcfollower.v1.StakePoolEntry0\SOH\DC2\135\SOH\n\
    \\FSGetLatestTokenOutputForEpoch\DC22.mcfollower.v1.GetLatestTokenOutputForEpochRequest\SUB3.mcfollower.v1.GetLatestTokenOutputForEpochResponse\DC2Z\n\
    \\rGetEpochNonce\DC2#.mcfollower.v1.GetEpochNonceRequest\SUB$.mcfollower.v1.GetEpochNonceResponse\DC2q\n\
    \\SUBGetUnspentOutputsAtAddress\DC20.mcfollower.v1.GetUnspentOutputsAtAddressRequest\SUB\US.mcfollower.v1.AddressOutputRow0\SOH\DC2j\n\
    \\ETBGetMappingRegistrations\DC2-.mcfollower.v1.GetMappingRegistrationsRequest\SUB\RS.mcfollower.v1.RegistrationRow0\SOH\DC2p\n\
    \\EMGetMappingDeregistrations\DC2/.mcfollower.v1.GetMappingDeregistrationsRequest\SUB .mcfollower.v1.DeregistrationRow0\SOH\DC2Y\n\
    \\SIGetAssetCreates\DC2%.mcfollower.v1.GetAssetCreatesRequest\SUB\GS.mcfollower.v1.AssetCreateRow0\SOH\DC2V\n\
    \\SOGetAssetSpends\DC2$.mcfollower.v1.GetAssetSpendsRequest\SUB\FS.mcfollower.v1.AssetSpendRow0\SOH\DC2W\n\
    \\fGetMaxTxSize\DC2\".mcfollower.v1.GetMaxTxSizeRequest\SUB#.mcfollower.v1.GetMaxTxSizeResponse\DC2~\n\
    \\EMGetLatestGovernanceOutput\DC2/.mcfollower.v1.GetLatestGovernanceOutputRequest\SUB0.mcfollower.v1.GetLatestGovernanceOutputResponseJ\187\216\STX\n\
    \\a\DC2\ENQN\NUL\208\ACK\SOH\n\
    \\142$\n\
    \\SOH\f\DC2\ETXN\NUL\DC22\131$ Copyright (c) 2026, Seungheon Oh\n\
    \ SPDX-License-Identifier: BSD-3-Clause\n\
    \\n\
    \ mc-follower gRPC contract: the interface between mc-follower, a Cardano\n\
    \ indexer, and a Midnight node that reads its Cardano data from it instead\n\
    \ of cardano-db-sync.\n\
    \\n\
    \ The canonical copy of this file lives in the mc-follower repository\n\
    \ (https://github.com/SeungheonOh/mc-follower). Companion documents there:\n\
    \ docs/CONTRACT.md (the SQL each RPC replaces, the node's row-source traits,\n\
    \ data-model semantics) and docs/SPEC.md (design).\n\
    \\n\
    \ Every RPC except GetStatus replaces exactly one SQL query that a running\n\
    \ Midnight node executes against cardano-db-sync (GetBlockByHash replaces two\n\
    \ queries that differ only in one selected column). \"Replaces\" means: same\n\
    \ filters, same total ordering, same limit/offset semantics, same columns,\n\
    \ evaluated against the indexer's current chain (volatile blocks included),\n\
    \ exactly as db-sync answers against its current database.\n\
    \\n\
    \ Comments name the node's functions and source files, with these\n\
    \ abbreviations for paths in the midnight-node repository:\n\
    \   PC   = partner-chains/toolkit/data-sources/db-sync/src\n\
    \   MF   = primitives/mainchain-follower/src\n\
    \\n\
    \ Fidelity rules referenced as \"SPEC 4.x\" (docs/SPEC.md section 4):\n\
    \   4.addr      address rendering (db-sync renderAddress: bech32 / base58)\n\
    \   4.time      block time = slot start time, whole seconds UTC\n\
    \   4.txidx     tx_count and tx index include phase-2-invalid transactions\n\
    \   4.invalid   phase-2-invalid txs: only collateral-return output at index\n\
    \               len(regular outputs); inputs are the collateral inputs; no\n\
    \               metadata, no witness datums\n\
    \   4.datum     datum resolvable if inline, or its hash appeared in the witness\n\
    \               set of a valid transaction; original bytes served\n\
    \   4.meta      metadata only for valid transactions\n\
    \   4.ebb       EBBs have no block number; excluded from block-number queries\n\
    \\n\
    \ Conventions:\n\
    \   * Hashes, policy ids, asset names, pool hashes and nonces are raw bytes\n\
    \     (32 / 28 / 0..32 / 28 / 32 bytes respectively).\n\
    \   * Addresses are the exact text db-sync stores in `tx_out.address`\n\
    \     (SPEC 4.addr). Address filters are TEXT EQUALITY on that rendering,\n\
    \     never on decoded address bytes (see CONTRACT.md section 3).\n\
    \   * Block numbers are uint32 (Rust BlockNumber(u32), decoded from INT4).\n\
    \     Epoch numbers are uint32 (Rust EpochNumber(u32), INT4). Slots are\n\
    \     uint64 (Rust SlotNumber(u64), INT8). Transaction index within block is\n\
    \     uint32 (Rust TxIndexInBlock(u32), INT4). Output index is uint32 on the\n\
    \     wire but always < 2^15 (Rust TxIndex(u16), db-sync `txindex` smallint).\n\
    \   * A \"position\" is (block_no, tx_index); positions are totally ordered\n\
    \     lexicographically, matching both SQL row comparisons and the Rust\n\
    \     CardanoPosition / TxOrderingKey orderings.\n\
    \   * Absence of a row is encoded in the response (`optional` fields or an\n\
    \     empty stream) where db-sync would return zero rows too. Where the\n\
    \     indexer cannot vouch that db-sync would have no row (data it does not\n\
    \     know yet), it answers UNAVAILABLE instead, never an empty result.\n\
    \\n\
    \ Error model (all RPCs):\n\
    \   * OK with an absent/empty result: the query legitimately has no rows.\n\
    \   * UNAVAILABLE: the store cannot be opened (missing, or of another\n\
    \     network or watch set); no block is indexed yet; a block number bound\n\
    \     above the indexed tip; an epoch bound of GetLatestBlockForEpoch or\n\
    \     GetLatestTokenOutputForEpoch that is not complete in the index (not\n\
    \     below the tip's epoch); or epoch data the indexer does not know (yet):\n\
    \     an epoch nonce, a stake distribution, or a max_tx_size gated by an\n\
    \     unacknowledged proposal (see those RPCs). The node treats this like a\n\
    \     failed Postgres connection (an error from the data source).\n\
    \   * FAILED_PRECONDITION: the request names an address or policy the\n\
    \     indexer is not configured to index. Must never be answered with an empty\n\
    \     result, because db-sync would have returned rows.\n\
    \   * OUT_OF_RANGE: a returned value the wire type cannot carry (a bridge\n\
    \     sum of 2^128 or more). Values the node fails to decode in Rust but the\n\
    \     wire can carry are returned as they are, and the Rust client fails.\n\
    \   * INVALID_ARGUMENT: malformed request (wrong hash length, missing\n\
    \     required message, limit or offset of 2^31 or more).\n\
    \   * INTERNAL: anything unexpected, including stored epoch data that\n\
    \     contradicts itself (a driver nonce that differs from the shipped one).\n\
    \   * Each RPC is answered from one read snapshot of the store (one SQLite\n\
    \     read transaction for the whole stream).\n\
    \\n\
    \\b\n\
    \\SOH\STX\DC2\ETXP\NUL\SYN\n\
    \\193\SOH\n\
    \\STX\ACK\NUL\DC2\ENQR\NUL\214\ETX\SOH\"\179\SOH ---------------------------------------------------------------------\n\
    \ Indexer status (no SQL equivalent).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\n\
    \\n\
    \\ETX\ACK\NUL\SOH\DC2\ETXR\b\DC2\n\
    \\225\SOH\n\
    \\EOT\ACK\NUL\STX\NUL\DC2\ETXZ\STX>\SUB\211\SOH Tip, immutable extent and sync state of the indexer. Not used by the\n\
    \ existing data-source logic (which derives freshness from GetLatestBlock);\n\
    \ intended for health checks, operator tooling and startup probes.\n\
    \\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETXZ\ACK\SI\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETXZ\DLE \n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETXZ+<\n\
    \\165\ACK\n\
    \\EOT\ACK\NUL\STX\SOH\DC2\ETXj\STXD\SUB\191\EOT Replaces: get_latest_block_info, PC/db_model.rs.\n\
    \   SELECT block_no, hash, epoch_no, slot_no, time FROM block\n\
    \   WHERE block_no IS NOT NULL ORDER BY block_no DESC LIMIT 1\n\
    \ Ordering: block_no DESC. Limit: 1. Bounds: none.\n\
    \ Returns the highest-numbered block of the indexer's current chain\n\
    \ (volatile part included), or nothing if no block is indexed.\n\
    \ Fidelity: SPEC 4.time, 4.ebb.\n\
    \ Callers: BlockDataSourceImpl::get_latest_block_info (PC/block/mod.rs),\n\
    \   is_cardano_ok (PC/block/mod.rs), get_stable_block_by_hash_from_db\n\
    \   (PC/block/mod.rs), fill_cache (PC/block/mod.rs).\n\
    \2\213\SOH ---------------------------------------------------------------------\n\
    \ Block data source (PC/block, used by mc_hash, sidechain_rpc, bridge).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\SOH\DC2\ETXj\ACK\DC4\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\STX\DC2\ETXj\NAK*\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\SOH\ETX\DC2\ETXj5B\n\
    \\243\ETX\n\
    \\EOT\ACK\NUL\STX\STX\DC2\ETXt\STXS\SUB\229\ETX Replaces: get_blocks_by_numbers, PC/db_model.rs.\n\
    \   SELECT block_no, hash, epoch_no, slot_no, time FROM block\n\
    \   WHERE block_no >= $from AND block_no <= $to ORDER BY block_no ASC\n\
    \ Ordering: block_no ASC (total: block_no is unique on one chain).\n\
    \ Bounds: from_block_no inclusive, to_block_no inclusive. Limit: none.\n\
    \ Empty stream if from > to. Fidelity: SPEC 4.time, 4.ebb.\n\
    \ Caller: BlockDataSourceImpl::fill_cache (PC/block/mod.rs); the range\n\
    \ is at most cache_size (100) + 1 blocks.\n\
    \\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\SOH\DC2\ETXt\ACK\FS\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\STX\DC2\ETXt\GS:\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\ACK\DC2\ETXtEK\n\
    \\f\n\
    \\ENQ\ACK\NUL\STX\STX\ETX\DC2\ETXtLQ\n\
    \\241\a\n\
    \\EOT\ACK\NUL\STX\ETX\DC2\EOT\135\SOH\STXV\SUB\226\a Replaces: get_highest_block, PC/db_model.rs.\n\
    \   SELECT block_no, hash, epoch_no, slot_no, time FROM block\n\
    \   WHERE block_no <= $max_block AND $min_slot <= slot_no AND slot_no <= $max_slot\n\
    \     AND $min_time <= time AND time <= $max_time\n\
    \   ORDER BY block_no DESC LIMIT 1\n\
    \ Ordering: block_no DESC. Limit: 1.\n\
    \ Bounds: block_no <= max_block_no (inclusive); slot in\n\
    \   [min_slot, max_slot] (both inclusive); time in [min_time, max_time]\n\
    \   (both inclusive). Times are compared at millisecond precision: the\n\
    \   Rust bounds are NaiveDateTime values with millisecond resolution\n\
    \   (reference timestamp minus a TimeDelta in ms), while block time is\n\
    \   whole seconds, so the server compares block.time_unix_seconds * 1000\n\
    \   against the *_unix_millis bounds.\n\
    \ Fidelity: SPEC 4.time, 4.ebb (EBBs never match: no block_no).\n\
    \ Caller: BlockDataSourceImpl::get_latest_block (PC/block/mod.rs);\n\
    \   all bound values are computed in Rust from node config and the\n\
    \   reference timestamp (CONTRACT.md section 4).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ETX\SOH\DC2\EOT\135\SOH\ACK\GS\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ETX\STX\DC2\EOT\135\SOH\RS<\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ETX\ETX\DC2\EOT\135\SOHGT\n\
    \\251\b\n\
    \\EOT\ACK\NUL\STX\EOT\DC2\EOT\155\SOH\STXD\SUB\236\b Replaces two queries that differ only in the `tx_count` column:\n\
    \   * get_block_by_hash, PC/db_model.rs\n\
    \       SELECT block_no, hash, epoch_no, slot_no, time FROM block WHERE hash = $1\n\
    \   * get_block_by_hash, MF/db/queries/cnight_observation.rs\n\
    \       SELECT block_no, hash, epoch_no, slot_no, time, tx_count FROM block WHERE hash = $1\n\
    \ Ordering: n/a (hash is unique). Limit: at most one row.\n\
    \ Returns the block if it is on the indexer's current chain.\n\
    \ EBB (no block number): returned as absent. db-sync would return a row\n\
    \ with NULL block_no that fails to decode in Rust (an error); see\n\
    \ CONTRACT.md section 5, item R9.\n\
    \ Fidelity: SPEC 4.time, 4.txidx (tx_count counts phase-2-invalid txs), 4.ebb.\n\
    \ Callers: BlockDataSourceImpl::get_block_by_hash (PC/block/mod.rs),\n\
    \   get_stable_block_by_hash_from_db (PC/block/mod.rs),\n\
    \   TokenBridgeDataSourceImpl::get_transfers (PC/bridge/mod.rs),\n\
    \   MidnightCNightObservationDataSourceImpl::get_utxos_up_to_capacity\n\
    \   (MF/data_source/cnight_observation.rs),\n\
    \   FederatedAuthorityObservationDataSourceImpl::get_federated_authority_data\n\
    \   (MF/data_source/federated_authority_observation.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\EOT\SOH\DC2\EOT\155\SOH\ACK\DC4\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\EOT\STX\DC2\EOT\155\SOH\NAK*\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\EOT\ETX\DC2\EOT\155\SOH5B\n\
    \\198\ENQ\n\
    \\EOT\ACK\NUL\STX\ENQ\DC2\EOT\170\SOH\STXJ\SUB\139\EOT Replaces: get_block_info_for_tx_hash, PC/db_model.rs.\n\
    \   SELECT block.block_no, tx.block_index FROM tx JOIN block ON block.id = tx.block_id\n\
    \   WHERE tx.hash = $1\n\
    \ Ordering: n/a. Limit: at most one row (tx hash unique on one chain).\n\
    \ Any transaction of the current chain, valid or phase-2-invalid.\n\
    \ Fidelity: SPEC 4.txidx.\n\
    \ Callers: TokenBridgeDataSourceImpl::resolve_tx_position\n\
    \   (PC/bridge/mod.rs), CachedTokenBridgeDataSourceImpl::resolve_tx_position\n\
    \   (PC/bridge/cache.rs, only on a miss in the in-memory tx cache).\n\
    \2\169\SOH ---------------------------------------------------------------------\n\
    \ Token bridge (PC/bridge).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ENQ\SOH\DC2\EOT\170\SOH\ACK\DC3\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ENQ\STX\DC2\EOT\170\SOH\DC4(\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ENQ\ETX\DC2\EOT\170\SOH3H\n\
    \\159\DC1\n\
    \\EOT\ACK\NUL\STX\ACK\DC2\EOT\208\SOH\STXE\SUB\144\DC1 Replaces: get_bridge_txs, PC/db_model.rs (both tx_in variants,\n\
    \ PC/db_model.rs; the gRPC semantics equal the `tx_in` table\n\
    \ variant, see CONTRACT.md section 3, item S10).\n\
    \ Row definition, for each transaction T of the current chain such that:\n\
    \   (a) T produced at least one output at ics_address carrying\n\
    \       (policy_id, asset_name)  [relevant_txs, PC/db_model.rs],\n\
    \   (b) block_no(T) <= to_block_no (inclusive),\n\
    \   (c) T is strictly after / at-or-after the lower bound (see `lower`),\n\
    \   (d) bridge_out > bridge_in OR reserve_in > reserve_out\n\
    \       (PC/db_model.rs), compared as exact integers,\n\
    \ return one row with:\n\
    \   bridge_in   = sum of the asset quantity over outputs at ics_address\n\
    \                 consumed by T (inputs of T; collateral inputs if T is\n\
    \                 phase-2-invalid; reference inputs never count),\n\
    \   bridge_out  = sum over outputs of T at ics_address,\n\
    \   reserve_in  = sum over outputs at reserve_address consumed by T,\n\
    \   reserve_out = sum over outputs of T at reserve_address,\n\
    \   c2m_metadatum_cbor = metadatum of T under label 6500973\n\
    \                 (TOKEN_TRANSFER_METADATUM_KEY) if T is valid and has it.\n\
    \ Each sum is over one row per (output, asset); an output carries at most\n\
    \ one quantity of a given (policy, name), so no join multiplication.\n\
    \ Missing sums are 0 (COALESCE). Spends are counted regardless of whether\n\
    \ the spent output was created before or after the lower bound.\n\
    \ Ordering: (block_no ASC, tx_index ASC) - total.\n\
    \ Limit: max_txs if set; unlimited if unset (SQL `LIMIT null`).\n\
    \ Callers: TokenBridgeDataSourceImpl::get_transfers (PC/bridge/mod.rs,\n\
    \   limit max_transfers+1), CachedTokenBridgeDataSourceImpl::fill_cache\n\
    \   (PC/bridge/cache.rs, no limit, lower bound Block(from-1), upper\n\
    \   bound min(to + lookahead, latest stable)).\n\
    \ Fidelity: SPEC 4.addr (text equality on both addresses), 4.txidx,\n\
    \   4.invalid (collateral return output counts as an output, collateral\n\
    \   inputs count as inputs), 4.meta.\n\
    \ Rust decodes each sum with BigDecimal::to_u64 (NativeTokenAmount,\n\
    \ PC/db_model.rs): a returned row with a sum > u64::MAX makes the\n\
    \ whole query fail. The server returns exact 128-bit sums; the Rust client\n\
    \ reproduces the failure.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ACK\SOH\DC2\EOT\208\SOH\ACK\DC2\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ACK\STX\DC2\EOT\208\SOH\DC3&\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ACK\ACK\DC2\EOT\208\SOH17\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\ACK\ETX\DC2\EOT\208\SOH8C\n\
    \\203\b\n\
    \\EOT\ACK\NUL\STX\a\DC2\EOT\230\SOH\STXT\SUB\220\ACK Replaces: get_latest_block_for_epoch,\n\
    \ MF/data_source/candidates_data_source/db_model.rs.\n\
    \   SELECT block_no, hash, epoch_no, slot_no FROM block\n\
    \   WHERE epoch_no <= $1 AND slot_no IS NOT NULL AND block_no IS NOT NULL\n\
    \   ORDER BY slot_no DESC LIMIT 1\n\
    \ Ordering: slot_no DESC (total among non-EBB blocks: one block per slot).\n\
    \ Limit: 1. Bounds: epoch_no <= epoch (inclusive). The block's epoch is the\n\
    \ epoch of its slot (CONTRACT.md section 3, item S8).\n\
    \ UNAVAILABLE unless `epoch` is complete in the index (below the tip's\n\
    \ epoch): any further block of the tip's epoch would be the answer.\n\
    \ Fidelity: SPEC 4.ebb. Rust reads only block_no\n\
    \ (candidates_data_source/mod.rs); the full Block is returned.\n\
    \ Caller: CandidatesDataSourceImpl::get_last_block_for_epoch\n\
    \   (candidates_data_source/mod.rs). Reached only via get_candidates\n\
    \   (RPC only in node-2.1.101).\n\
    \2\221\SOH ---------------------------------------------------------------------\n\
    \ Authority selection (Midnight's own,\n\
    \ MF/data_source/candidates_data_source).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\a\SOH\DC2\EOT\230\SOH\ACK\FS\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\a\STX\DC2\EOT\230\SOH\GS:\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\a\ETX\DC2\EOT\230\SOHER\n\
    \\239\ACK\n\
    \\EOT\ACK\NUL\STX\b\DC2\EOT\247\SOH\STX_\SUB\224\ACK Replaces: get_latest_stable_epoch,\n\
    \ MF/data_source/candidates_data_source/db_model.rs.\n\
    \   SELECT stable_block.epoch_no - 1 AS epoch_no\n\
    \   FROM block INNER JOIN block AS stable_block\n\
    \     ON block.block_no - $k = stable_block.block_no\n\
    \   WHERE block.block_no IS NOT NULL ORDER BY block.block_no DESC LIMIT 1\n\
    \ Semantics: let tip = highest block_no; if tip >= k, return\n\
    \   epoch_no(block number tip - k) - 1; otherwise absent.\n\
    \ Ordering: block_no DESC. Limit: 1.\n\
    \ The value can be -1 (stable block in epoch 0); Rust decodes the column\n\
    \ into EpochNumber(u32) via i32 -> u32 try_into, which fails on -1. The\n\
    \ server returns the signed value; the Rust client reproduces the failure.\n\
    \ Caller: CandidateDataSourceCached::can_use_caching_for_request\n\
    \   (candidates_data_source/cached.rs). security_parameter is node\n\
    \   config (CARDANO_SECURITY_PARAMETER), passed through.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\b\SOH\DC2\EOT\247\SOH\ACK\SUB\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\b\STX\DC2\EOT\247\SOH\ESC6\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\b\ETX\DC2\EOT\247\SOHA]\n\
    \\175\n\
    \\n\
    \\EOT\ACK\NUL\STX\t\DC2\EOT\143\STX\STXX\SUB\160\n\
    \ Replaces: get_stake_distribution,\n\
    \ MF/data_source/candidates_data_source/db_model.rs.\n\
    \   SELECT ph.hash_raw AS pool_hash, SUM(es.amount) AS stake\n\
    \   FROM epoch_stake es INNER JOIN pool_hash ph ON es.pool_id = ph.id\n\
    \   WHERE es.epoch_no = $1 GROUP BY ph.hash_raw\n\
    \ One row per pool with stake in db-sync `epoch_stake` for `epoch`,\n\
    \ stake = sum over that pool's delegations (SPEC section 3 \"Pool stake\").\n\
    \ Ordering: the SQL has none; the server streams by pool_hash ASC. Rust\n\
    \ folds into a HashMap (candidates_data_source/mod.rs), so order is\n\
    \ not observable.\n\
    \ Served only when the indexer holds the complete distribution for that\n\
    \ epoch. Empty stream for epochs before the first Shelley epoch, where\n\
    \ db-sync has no rows either. Otherwise (not obtained yet, incomplete,\n\
    \ outside what the indexer's sources reach) UNAVAILABLE: Rust maps an\n\
    \ empty map to `stake_delegation: None` for every candidate\n\
    \ (candidates_data_source/mod.rs), so partial or missing data must never\n\
    \ be served as empty (CONTRACT.md section 5, item R7).\n\
    \ Rust decodes stake with BigDecimal::to_u64 (StakeDelegation,\n\
    \ PC/../utils/db-sync-sqlx/src/lib.rs); a per-pool sum cannot exceed\n\
    \ the lovelace supply, so uint64 is sufficient.\n\
    \ Caller: CandidatesDataSourceImpl::get_candidates\n\
    \   (candidates_data_source/mod.rs). RPC only in node-2.1.101.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\t\SOH\DC2\EOT\143\STX\ACK\SUB\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\t\STX\DC2\EOT\143\STX\ESC6\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\t\ACK\DC2\EOT\143\STXAG\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\t\ETX\DC2\EOT\143\STXHV\n\
    \\169\SO\n\
    \\EOT\ACK\NUL\STX\n\
    \\DC2\EOT\175\STX\STXw\SUB\154\SO Replaces: get_token_utxo_for_epoch,\n\
    \ MF/data_source/candidates_data_source/db_model.rs, together with the\n\
    \ multi_asset id resolution it depends on (MF/db/multi_asset_cache.rs).\n\
    \   SELECT origin_tx.hash, tx_out.index, origin_block.epoch_no,\n\
    \          origin_block.block_no, origin_block.slot_no, origin_tx.block_index,\n\
    \          datum.value\n\
    \   FROM ma_tx_out JOIN tx_out JOIN tx origin_tx JOIN block origin_block\n\
    \   LEFT JOIN datum ON tx_out.data_hash = datum.hash\n\
    \   WHERE ma_tx_out.ident = ident(policy, name) AND origin_block.epoch_no <= $epoch\n\
    \   ORDER BY tx_block_no DESC, origin_tx.block_index DESC LIMIT 1\n\
    \ Semantics: the most recently created output (any address, spent or\n\
    \ unspent - NO spent-ness check) carrying any positive quantity of the\n\
    \ exact asset (policy_id, asset_name), created in a block whose epoch is\n\
    \ <= epoch. If the (policy, name) pair never appeared on chain the result\n\
    \ is absent (multi_asset_cache returns None -> no query,\n\
    \ candidates_data_source/mod.rs).\n\
    \ Ordering: (block_no DESC, tx_index DESC). NOT total: two outputs of the\n\
    \ same transaction both carrying the asset tie. The server breaks the tie\n\
    \ by output index DESC (CONTRACT.md section 5, item R1).\n\
    \ UNAVAILABLE unless `epoch` is complete in the index (below the tip's\n\
    \ epoch): any further block of the tip's epoch can change the answer.\n\
    \ Limit: 1.\n\
    \ Datum: LEFT JOIN, then decoded with the strict DbDatum decoder\n\
    \ (TokenTxOutput.datum: Option<DbDatum>): absent -> None (Rust then returns\n\
    \ ExpectedDataNotFound, candidates_data_source/mod.rs); present but not\n\
    \ decodable -> the whole query fails. `datum` is set iff SPEC 4.datum\n\
    \ resolves the output's datum.\n\
    \ Fidelity: SPEC 4.datum, 4.invalid, 4.txidx.\n\
    \ Caller: CandidatesDataSourceImpl::get_ariadne_parameters\n\
    \   (candidates_data_source/mod.rs); asset_name is empty in practice.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\n\
    \\SOH\DC2\EOT\175\STX\ACK\"\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\n\
    \\STX\DC2\EOT\175\STX#F\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\n\
    \\ETX\DC2\EOT\175\STXQu\n\
    \\202\a\n\
    \\EOT\ACK\NUL\STX\v\DC2\EOT\193\STX\STXJ\SUB\187\a Replaces: get_epoch_nonce,\n\
    \ MF/data_source/candidates_data_source/db_model.rs.\n\
    \   SELECT nonce FROM epoch_param WHERE epoch_no = $1\n\
    \ Returns the epoch nonce in force during `epoch` (db-sync epoch_param\n\
    \ row for that epoch). Sources, in order: the nonce table shipped with the\n\
    \ indexer, nonces supplied to it at run time, and the nonces its driver\n\
    \ computes from block headers.\n\
    \ Absent only where db-sync has no row or a NULL nonce: epochs before the\n\
    \ table (Byron) and the neutral nonce. A nonce the indexer does not know\n\
    \ (yet), and a driver nonce while the driver disagrees with a local node,\n\
    \ are answered UNAVAILABLE, never absent: the node's authority selection\n\
    \ turns an absent nonce into the empty nonce. A driver nonce that\n\
    \ contradicts the shipped one is INTERNAL. Rust caches only present values\n\
    \ (candidates_data_source/cached.rs). Limit: at most one row.\n\
    \ Caller: CandidatesDataSourceImpl::get_epoch_nonce\n\
    \   (candidates_data_source/mod.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\v\SOH\DC2\EOT\193\STX\ACK\DC3\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\v\STX\DC2\EOT\193\STX\DC4(\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\v\ETX\DC2\EOT\193\STX3H\n\
    \\138\v\n\
    \\EOT\ACK\NUL\STX\f\DC2\EOT\219\STX\STXf\SUB\251\n\
    \ Replaces: get_utxos_for_address,\n\
    \ MF/data_source/candidates_data_source/db_model.rs, both variants\n\
    \ (tx_in table, consumed_by_tx_id). gRPC semantics equal the\n\
    \ `tx_in` table variant (CONTRACT.md section 3, item S10).\n\
    \ Semantics: every output whose address text equals `address`, created in\n\
    \ a block with block_no <= block_no, and not consumed by any transaction\n\
    \ in a block with block_no <= block_no (i.e. unspent as of the END of\n\
    \ block `block_no`; a spend inside block `block_no` hides the output).\n\
    \ Spends include collateral inputs of phase-2-invalid txs; reference inputs\n\
    \ are not spends.\n\
    \ tx_inputs: all inputs of the creating transaction (collateral inputs if\n\
    \ it is phase-2-invalid), ordered by (tx_hash bytes ASC, index ASC)\n\
    \ (array_agg ... ORDER BY consumes_tx.hash, index). The SQL renders them as\n\
    \ \"hex#index\" strings; Rust parses them back into UtxoId, so the wire\n\
    \ carries them structured.\n\
    \ datum: LEFT JOIN, decoded with DbDatumIfValid (NULL or undecodable ->\n\
    \ None, row kept). `datum` is set iff SPEC 4.datum resolves the datum.\n\
    \ Ordering: the SQL has NO ORDER BY (row order unspecified); the server\n\
    \ streams in (block_no ASC, tx_index ASC, output_index ASC). See\n\
    \ CONTRACT.md section 5, item R2.\n\
    \ Limit: none.\n\
    \ Fidelity: SPEC 4.addr, 4.datum, 4.invalid, 4.txidx.\n\
    \ Caller: CandidatesDataSourceImpl::get_registered_candidates\n\
    \   (candidates_data_source/mod.rs). RPC only in node-2.1.101.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\f\SOH\DC2\EOT\219\STX\ACK \n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\f\STX\DC2\EOT\219\STX!B\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\f\ACK\DC2\EOT\219\STXMS\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\f\ETX\DC2\EOT\219\STXTd\n\
    \\189\SI\n\
    \\EOT\ACK\NUL\STX\r\DC2\EOT\128\ETX\STX_\SUB\161\ENQ Replaces: get_registrations, MF/db/queries/cnight_observation.rs.\n\
    \ Rows: every output O such that\n\
    \   O.address text = mapping_validator_address,\n\
    \   O carries exactly quantity 1 of auth_token (policy, name)\n\
    \     (ma_tx_out.quantity = 1; other assets on O are irrelevant),\n\
    \   O's datum is resolvable (INNER JOIN datum, SPEC 4.datum),\n\
    \   creating tx position in the window.\n\
    \ No spent-ness check.\n\
    \ Ordering: (block_no ASC, tx_index ASC, output_index ASC) - total.\n\
    \ Datum decoding in Rust: DbDatumIfValid (undecodable -> None -> row\n\
    \ dropped after counting).\n\
    \ Fidelity: SPEC 4.addr, 4.datum, 4.invalid, 4.txidx, 4.time.\n\
    \ Caller: get_registration_utxos (cnight_observation.rs).\n\
    \2\138\n\
    \ ---------------------------------------------------------------------\n\
    \ cNIGHT observation (MF/data_source/cnight_observation.rs).\n\
    \\n\
    \ Common window semantics for the four range RPCs below (PagedQuery,\n\
    \ MF/db/types.rs): a row's position P is the position of the\n\
    \ transaction named per RPC (creating tx or spending tx). A row is in the\n\
    \ window iff from_inclusive <= P < to_exclusive, i.e.\n\
    \   (block_no > from.block_no OR (block_no = from.block_no AND tx_index >= from.tx_index))\n\
    \   AND (block_no < to.block_no OR (block_no = to.block_no AND tx_index < to.tx_index)).\n\
    \ In practice `to_exclusive` is (tip.block_no, tip.tx_count + 1)\n\
    \ (cnight_observation.rs, types.rs).\n\
    \ Limit/offset: ORDER BY <key> LIMIT limit OFFSET offset, applied after\n\
    \ filtering; limit and offset are each < 2^31 (asserted in Rust). The node\n\
    \ currently always sends offset 0 (cnight_observation.rs).\n\
    \ The db-sync id-range pre-filters (get_low_bounds / get_high_bounds,\n\
    \ queries/cnight_observation.rs) are supersets of the window and\n\
    \ are not part of this contract.\n\
    \ Rows that Rust later drops (undecodable datum, non-base address) are\n\
    \ still returned: they count toward the limit and toward the\n\
    \ \"page filled its cap\" frontier (cnight_observation.rs).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\r\SOH\DC2\EOT\128\ETX\ACK\GS\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\r\STX\DC2\EOT\128\ETX\RS<\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\r\ACK\DC2\EOT\128\ETXGM\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\r\ETX\DC2\EOT\128\ETXN]\n\
    \\199\ENQ\n\
    \\EOT\ACK\NUL\STX\SO\DC2\EOT\143\ETX\STXe\SUB\184\ENQ Replaces: get_deregistrations, MF/db/queries/cnight_observation.rs.\n\
    \ Rows: one per (spending transaction T, spent output O) such that\n\
    \   O.address text = mapping_validator_address,\n\
    \   O's datum is resolvable (INNER JOIN datum, SPEC 4.datum),\n\
    \   T's position in the window,\n\
    \   T consumes O (inputs of T; collateral inputs if T is phase-2-invalid;\n\
    \   reference inputs never).\n\
    \ NO auth-token or asset filter: any output at the address counts.\n\
    \ Ordering: (block_no ASC, tx_index ASC, utxo_tx_hash ASC (bytes),\n\
    \   utxo_index ASC) - total.\n\
    \ Datum decoding in Rust: DbDatumIfValid.\n\
    \ Fidelity: SPEC 4.addr, 4.datum, 4.invalid, 4.txidx, 4.time.\n\
    \ Caller: get_deregistration_utxos (cnight_observation.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SO\SOH\DC2\EOT\143\ETX\ACK\US\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SO\STX\DC2\EOT\143\ETX @\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SO\ACK\DC2\EOT\143\ETXKQ\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SO\ETX\DC2\EOT\143\ETXRc\n\
    \\177\ENQ\n\
    \\EOT\ACK\NUL\STX\SI\DC2\EOT\156\ETX\STXN\SUB\162\ENQ Replaces: get_asset_creates, MF/db/queries/cnight_observation.rs.\n\
    \ Rows: every output O carrying asset (policy, name) at ANY address,\n\
    \ creating tx position in the window. quantity = O's quantity of that\n\
    \ asset. holder_address = O.address text.\n\
    \ Ordering: (block_no ASC, tx_index ASC, output_index ASC) - total.\n\
    \ The SQL casts quantity to BIGINT; Postgres fails the query if it exceeds\n\
    \ i64::MAX. The server returns the raw uint64; the Rust client must fail\n\
    \ when quantity > i64::MAX.\n\
    \ Fidelity: SPEC 4.addr (Rust parses holder_address as bech32 and skips\n\
    \   non-base / base58 addresses), 4.invalid, 4.txidx, 4.time.\n\
    \ Caller: get_asset_create_utxos (cnight_observation.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SI\SOH\DC2\EOT\156\ETX\ACK\NAK\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SI\STX\DC2\EOT\156\ETX\SYN,\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SI\ACK\DC2\EOT\156\ETX7=\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\SI\ETX\DC2\EOT\156\ETX>L\n\
    \\237\EOT\n\
    \\EOT\ACK\NUL\STX\DLE\DC2\EOT\169\ETX\STXK\SUB\222\EOT Replaces: get_asset_spends, MF/db/queries/cnight_observation.rs.\n\
    \ Rows: one per (spending transaction T, spent output O) where O carries\n\
    \ asset (policy, name) at any address and T's position is in the window\n\
    \ (inputs of T; collateral inputs if T is phase-2-invalid; reference\n\
    \ inputs never). block_* / tx_index are T's; quantity / holder_address /\n\
    \ utxo_* are O's.\n\
    \ Ordering: (block_no ASC, tx_index ASC, utxo_tx_hash ASC (bytes),\n\
    \   utxo_index ASC) - total.\n\
    \ Same BIGINT note as GetAssetCreates.\n\
    \ Fidelity: SPEC 4.addr, 4.invalid, 4.txidx, 4.time.\n\
    \ Caller: get_asset_spend_utxos (cnight_observation.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DLE\SOH\DC2\EOT\169\ETX\ACK\DC4\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DLE\STX\DC2\EOT\169\ETX\NAK*\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DLE\ACK\DC2\EOT\169\ETX5;\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DLE\ETX\DC2\EOT\169\ETX<I\n\
    \\145\a\n\
    \\EOT\ACK\NUL\STX\DC1\DC2\EOT\185\ETX\STXG\SUB\130\a Replaces: get_max_tx_size, MF/db/queries/cnight_observation.rs.\n\
    \   SELECT MAX(epoch_param.max_tx_size)::BIGINT FROM block\n\
    \   JOIN epoch_param ON epoch_param.epoch_no = block.epoch_no\n\
    \   WHERE block.block_no = $1\n\
    \ Returns the protocol parameter maxTxSize in force in the epoch of block\n\
    \ `block_no`: a local node's value for that epoch if the indexer has one,\n\
    \ else the indexer's per-network table. Absent if the block is unknown or\n\
    \ the table does not cover its epoch (Byron), as db-sync has no row then\n\
    \ (Rust then fails with MissingEpochParams, cnight_observation.rs).\n\
    \ UNAVAILABLE if `block_no` is above the indexed tip, or if a proposal to\n\
    \ change maxTxSize that could be in force in the epoch has not been\n\
    \ acknowledged by the operator (the message names it).\n\
    \ Caller: get_utxos_up_to_capacity (cnight_observation.rs), only for\n\
    \   ObservationBound::Cost, with block_no = start position block.\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC1\SOH\DC2\EOT\185\ETX\ACK\DC2\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC1\STX\DC2\EOT\185\ETX\DC3&\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC1\ETX\DC2\EOT\185\ETX1E\n\
    \\158\f\n\
    \\EOT\ACK\NUL\STX\DC2\DC2\EOT\213\ETX\STXn\SUB\167\n\
    \ Replaces: get_governance_body_utxo,\n\
    \ MF/db/queries/federated_authority_observation.rs.\n\
    \   SELECT datum.value, block.block_no, block.hash, tx.block_index, tx.hash, tx_out.index\n\
    \   FROM tx_out JOIN datum ON tx_out.data_hash = datum.hash JOIN tx JOIN block\n\
    \   JOIN ma_tx_out JOIN multi_asset ma ON ma.id = ma_tx_out.ident\n\
    \   WHERE tx_out.address = $1 AND ma.policy = $2 AND block.block_no <= $3\n\
    \   ORDER BY block.block_no DESC, tx.block_index DESC LIMIT 1\n\
    \ Semantics: the most recently created output (NO spent-ness check) at\n\
    \ `address` (text equality) carrying any asset of `policy_id` (any asset\n\
    \ name), with a resolvable datum (INNER JOIN, SPEC 4.datum), created in a\n\
    \ block with block_no <= block_no (inclusive).\n\
    \ An output carrying several asset names of the policy yields several\n\
    \ identical rows in SQL; irrelevant under LIMIT 1.\n\
    \ Ordering: (block_no DESC, tx_index DESC). NOT total across two outputs\n\
    \ of the same transaction; the server breaks the tie by output index DESC\n\
    \ (CONTRACT.md section 5, item R1). Limit: 1.\n\
    \ Datum decoding in Rust: strict DbDatum (GovernanceBodyUtxoRow.full_datum,\n\
    \   MF/db/types.rs): undecodable -> the whole query fails.\n\
    \ Fidelity: SPEC 4.addr, 4.datum, 4.invalid, 4.txidx.\n\
    \ Callers: get_federated_authority_data\n\
    \   (federated_authority_observation.rs council, technical committee).\n\
    \2\229\SOH ---------------------------------------------------------------------\n\
    \ Federated authority observation\n\
    \ (MF/data_source/federated_authority_observation.rs).\n\
    \ ---------------------------------------------------------------------\n\
    \\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC2\SOH\DC2\EOT\213\ETX\ACK\US\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC2\STX\DC2\EOT\213\ETX @\n\
    \\r\n\
    \\ENQ\ACK\NUL\STX\DC2\ETX\DC2\EOT\213\ETXKl\n\
    \\150\ETX\n\
    \\STX\EOT\NUL\DC2\ACK\224\ETX\NUL\238\ETX\SOH\SUB\224\SOH A block of the indexer's current chain. Mirrors PC/db_model.rs (Block),\n\
    \ MF/db/types.rs (Block, with tx_count) and\n\
    \ MF/data_source/candidates_data_source/db_model.rs (Block, no time).\n\
    \ EBBs are never returned (SPEC 4.ebb).\n\
    \2\164\SOH =========================================================================\n\
    \ Shared types\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\NUL\SOH\DC2\EOT\224\ETX\b\r\n\
    \ \n\
    \\EOT\EOT\NUL\STX\NUL\DC2\EOT\225\ETX\STX\SYN\"\DC2 BlockNumber(u32)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\NUL\ENQ\DC2\EOT\225\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\EOT\225\ETX\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\EOT\225\ETX\DC4\NAK\n\
    \\CAN\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\EOT\226\ETX\STX\DC1\"\n\
    \ 32 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\ENQ\DC2\EOT\226\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\EOT\226\ETX\b\f\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\EOT\226\ETX\SI\DLE\n\
    \;\n\
    \\EOT\EOT\NUL\STX\STX\DC2\EOT\227\ETX\STX\SYN\"- EpochNumber(u32); epoch of the block's slot\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\ENQ\DC2\EOT\227\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\EOT\227\ETX\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\EOT\227\ETX\DC4\NAK\n\
    \\US\n\
    \\EOT\EOT\NUL\STX\ETX\DC2\EOT\228\ETX\STX\NAK\"\DC1 SlotNumber(u64)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\ENQ\DC2\EOT\228\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\SOH\DC2\EOT\228\ETX\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\ETX\DC2\EOT\228\ETX\DC3\DC4\n\
    \\155\STX\n\
    \\EOT\EOT\NUL\STX\EOT\DC2\EOT\233\ETX\STX\RS\SUB\140\STX Slot start time, whole seconds since the Unix epoch, UTC (SPEC 4.time).\n\
    \ Rust ends with: MainchainBlock.timestamp = seconds (u64,\n\
    \ PC/db_model.rs); NaiveDateTime for window checks (PC/block/mod.rs);\n\
    \ CardanoPosition.block_timestamp = seconds * 1000 (MF/db/types.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\ENQ\DC2\EOT\233\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\SOH\DC2\EOT\233\ETX\b\EM\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\ETX\DC2\EOT\233\ETX\FS\GS\n\
    \\190\SOH\n\
    \\EOT\EOT\NUL\STX\ENQ\DC2\EOT\237\ETX\STX\SYN\SUB\175\SOH Number of transactions in the block, phase-2-invalid included\n\
    \ (SPEC 4.txidx). Rust: i64 (MF/db/types.rs), used as the tip's\n\
    \ CardanoPosition.tx_index_in_block via `as u32`.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\ENQ\DC2\EOT\237\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\SOH\DC2\EOT\237\ETX\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\ETX\DC2\EOT\237\ETX\DC4\NAK\n\
    \\f\n\
    \\STX\EOT\SOH\DC2\ACK\240\ETX\NUL\242\ETX\SOH\n\
    \\v\n\
    \\ETX\EOT\SOH\SOH\DC2\EOT\240\ETX\b\NAK\n\
    \\f\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\EOT\241\ETX\STX\ESC\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\EOT\241\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\EOT\241\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\EOT\241\ETX\DC1\SYN\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\EOT\241\ETX\EM\SUB\n\
    \:\n\
    \\STX\EOT\STX\DC2\ACK\245\ETX\NUL\248\ETX\SOH\SUB, (block_no, tx_index). Lexicographic order.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\STX\SOH\DC2\EOT\245\ETX\b\DLE\n\
    \\f\n\
    \\EOT\EOT\STX\STX\NUL\DC2\EOT\246\ETX\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ENQ\DC2\EOT\246\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\EOT\246\ETX\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\EOT\246\ETX\DC4\NAK\n\
    \D\n\
    \\EOT\EOT\STX\STX\SOH\DC2\EOT\247\ETX\STX\SYN\"6 index of the transaction in its block (SPEC 4.txidx)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ENQ\DC2\EOT\247\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\EOT\247\ETX\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\EOT\247\ETX\DC4\NAK\n\
    \I\n\
    \\STX\EOT\ETX\DC2\ACK\251\ETX\NUL\254\ETX\SOH\SUB; Half-open position window [from_inclusive, to_exclusive).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ETX\SOH\DC2\EOT\251\ETX\b\SYN\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\EOT\252\ETX\STX\RS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\EOT\252\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\EOT\252\ETX\v\EM\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\EOT\252\ETX\FS\GS\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\EOT\253\ETX\STX\FS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\EOT\253\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\EOT\253\ETX\v\ETB\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\EOT\253\ETX\SUB\ESC\n\
    \O\n\
    \\STX\EOT\EOT\DC2\ACK\129\EOT\NUL\132\EOT\SOH\SUBA Native asset identifier (multi_asset.policy, multi_asset.name).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\129\EOT\b\SI\n\
    \\CAN\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\130\EOT\STX\SYN\"\n\
    \ 28 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ENQ\DC2\EOT\130\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\130\EOT\b\DC1\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\130\EOT\DC4\NAK\n\
    \@\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\EOT\131\EOT\STX\ETB\"2 0..32 bytes; empty name is the empty byte string\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ENQ\DC2\EOT\131\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\EOT\131\EOT\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\EOT\131\EOT\NAK\SYN\n\
    \6\n\
    \\STX\EOT\ENQ\DC2\ACK\135\EOT\NUL\138\EOT\SOH\SUB( Transaction output reference (UtxoId).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ENQ\SOH\DC2\EOT\135\EOT\b\DC1\n\
    \\CAN\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\EOT\136\EOT\STX\DC4\"\n\
    \ 32 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ENQ\DC2\EOT\136\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\EOT\136\EOT\b\SI\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\EOT\136\EOT\DC2\DC3\n\
    \\SYN\n\
    \\EOT\EOT\ENQ\STX\SOH\DC2\EOT\137\EOT\STX\DC3\"\b < 2^15\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ENQ\DC2\EOT\137\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\EOT\137\EOT\t\SO\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\EOT\137\EOT\DC1\DC2\n\
    \\174\ACK\n\
    \\STX\EOT\ACK\DC2\ACK\154\EOT\NUL\156\EOT\SOH\SUB\159\ACK A resolved datum (SPEC 4.datum). `cbor` is the original on-chain bytes of\n\
    \ the Plutus data whose blake2b-256 hash equals the output's datum hash\n\
    \ (inline datum bytes, or the witness-set datum bytes).\n\
    \\n\
    \ Presence rules, preserving the SQL join semantics:\n\
    \   * INNER JOIN queries (registrations, deregistrations, governance): a row\n\
    \     exists only if the datum is resolvable, so the field is always set.\n\
    \   * LEFT JOIN queries (token output, address outputs): unset iff the\n\
    \     output has no datum hash or the hash is not resolvable (SQL NULL).\n\
    \\n\
    \ The Rust client must turn `cbor` into the same PlutusData (or the same\n\
    \ \"absent\"/error outcome) that db-sync's JSON + encode_json_value_to_plutus_datum\n\
    \ path produces; see CONTRACT.md section 3, item S5. The server never decodes\n\
    \ or re-encodes datums.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ACK\SOH\DC2\EOT\154\EOT\b\r\n\
    \\f\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\EOT\155\EOT\STX\DC1\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ENQ\DC2\EOT\155\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\EOT\155\EOT\b\f\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\EOT\155\EOT\SI\DLE\n\
    \}\n\
    \\STX\EOT\a\DC2\ACK\160\EOT\NUL\163\EOT\SOH\SUBo Unsigned integer up to 2^128-1, for sums that the SQL computes as\n\
    \ unbounded NUMERIC. value = hi * 2^64 + lo.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\a\SOH\DC2\EOT\160\EOT\b\SI\n\
    \\f\n\
    \\EOT\EOT\a\STX\NUL\DC2\EOT\161\EOT\STX\DC1\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ENQ\DC2\EOT\161\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\EOT\161\EOT\n\
    \\f\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\EOT\161\EOT\SI\DLE\n\
    \\f\n\
    \\EOT\EOT\a\STX\SOH\DC2\EOT\162\EOT\STX\DC1\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ENQ\DC2\EOT\162\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\SOH\DC2\EOT\162\EOT\n\
    \\f\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ETX\DC2\EOT\162\EOT\SI\DLE\n\
    \\171\SOH\n\
    \\STX\EOT\b\DC2\EOT\169\EOT\NUL\ESC2\158\SOH =========================================================================\n\
    \ Status\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\b\SOH\DC2\EOT\169\EOT\b\CAN\n\
    \\f\n\
    \\STX\EOT\t\DC2\ACK\171\EOT\NUL\196\EOT\SOH\n\
    \\v\n\
    \\ETX\EOT\t\SOH\DC2\EOT\171\EOT\b\EM\n\
    \U\n\
    \\EOT\EOT\t\STX\NUL\DC2\EOT\173\EOT\STX\EM\SUBG Highest block of the current chain (same row GetLatestBlock returns).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\EOT\DC2\EOT\173\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ACK\DC2\EOT\173\EOT\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\EOT\173\EOT\DC1\DC4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\EOT\173\EOT\ETB\CAN\n\
    \\197\SOH\n\
    \\EOT\EOT\t\STX\SOH\DC2\EOT\177\EOT\STX#\SUB\182\SOH Highest block that can no longer be rolled back by the upstream\n\
    \ (tip.block_no - k, k = the indexer's configured security parameter).\n\
    \ Absent while fewer than k blocks are indexed.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\EOT\DC2\EOT\177\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ACK\DC2\EOT\177\EOT\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\SOH\DC2\EOT\177\EOT\DC1\RS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ETX\DC2\EOT\177\EOT!\"\n\
    \R\n\
    \\EOT\EOT\t\STX\STX\DC2\EOT\179\EOT\STX \SUBD Security parameter k the indexer uses for its own rollback window.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ENQ\DC2\EOT\179\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\SOH\DC2\EOT\179\EOT\t\ESC\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ETX\DC2\EOT\179\EOT\RS\US\n\
    \\197\SOH\n\
    \\EOT\EOT\t\STX\ETX\DC2\EOT\183\EOT\STX\DC3\SUB\182\SOH True while the indexer is behind its upstream (initial sync, catch-up\n\
    \ after reconnect), or while any backfill is in progress. Always false\n\
    \ for a server that does not sync itself.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ENQ\DC2\EOT\183\EOT\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\SOH\DC2\EOT\183\EOT\a\SO\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ETX\DC2\EOT\183\EOT\DC1\DC2\n\
    \\150\SOH\n\
    \\EOT\EOT\t\STX\EOT\DC2\EOT\186\EOT\STX(\SUB\135\SOH Upstream tip as last reported by chain-sync (slot and block number), for\n\
    \ lag reporting. Absent before the first chain-sync exchange.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\EOT\DC2\EOT\186\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ENQ\DC2\EOT\186\EOT\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\SOH\DC2\EOT\186\EOT\DC2#\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ETX\DC2\EOT\186\EOT&'\n\
    \\f\n\
    \\EOT\EOT\t\STX\ENQ\DC2\EOT\187\EOT\STX,\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\EOT\DC2\EOT\187\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ENQ\DC2\EOT\187\EOT\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\SOH\DC2\EOT\187\EOT\DC2'\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ETX\DC2\EOT\187\EOT*+\n\
    \R\n\
    \\EOT\EOT\t\STX\ACK\DC2\EOT\189\EOT\STX!\SUBD First block the index covers (configured per-network start point).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\EOT\DC2\EOT\189\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ACK\DC2\EOT\189\EOT\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\SOH\DC2\EOT\189\EOT\DC1\FS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ETX\DC2\EOT\189\EOT\US \n\
    \\207\SOH\n\
    \\EOT\EOT\t\STX\a\DC2\EOT\193\EOT\STX\"\SUB\192\SOH Backfills in progress, as human-readable identifiers. Today only stake\n\
    \ distributions the indexer expects to obtain:\n\
    \ \"stake-distribution:epoch:N\". Requests for one of these get UNAVAILABLE.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\EOT\DC2\EOT\193\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ENQ\DC2\EOT\193\EOT\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\SOH\DC2\EOT\193\EOT\DC2\GS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ETX\DC2\EOT\193\EOT !\n\
    \:\n\
    \\EOT\EOT\t\STX\b\DC2\EOT\195\EOT\STX\ESC\SUB, Cardano network magic the indexer follows.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\ENQ\DC2\EOT\195\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\SOH\DC2\EOT\195\EOT\t\SYN\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\ETX\DC2\EOT\195\EOT\EM\SUB\n\
    \\182\SOH\n\
    \\STX\EOT\n\
    \\DC2\EOT\202\EOT\NUL 2\169\SOH =========================================================================\n\
    \ Block data source\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\n\
    \\SOH\DC2\EOT\202\EOT\b\GS\n\
    \\f\n\
    \\STX\EOT\v\DC2\ACK\204\EOT\NUL\207\EOT\SOH\n\
    \\v\n\
    \\ETX\EOT\v\SOH\DC2\EOT\204\EOT\b%\n\
    \\EM\n\
    \\EOT\EOT\v\STX\NUL\DC2\EOT\205\EOT\STX\ESC\"\v inclusive\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ENQ\DC2\EOT\205\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\EOT\205\EOT\t\SYN\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\EOT\205\EOT\EM\SUB\n\
    \\EM\n\
    \\EOT\EOT\v\STX\SOH\DC2\EOT\206\EOT\STX\EM\"\v inclusive\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ENQ\DC2\EOT\206\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\EOT\206\EOT\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\EOT\206\EOT\ETB\CAN\n\
    \\f\n\
    \\STX\EOT\f\DC2\ACK\209\EOT\NUL\215\EOT\SOH\n\
    \\v\n\
    \\ETX\EOT\f\SOH\DC2\EOT\209\EOT\b&\n\
    \(\n\
    \\EOT\EOT\f\STX\NUL\DC2\EOT\210\EOT\STX\SUB\"\SUB block_no <= max_block_no\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\EOT\210\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\EOT\210\EOT\t\NAK\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\EOT\210\EOT\CAN\EM\n\
    \#\n\
    \\EOT\EOT\f\STX\SOH\DC2\EOT\211\EOT\STX\SYN\"\NAK min_slot <= slot_no\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ENQ\DC2\EOT\211\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\SOH\DC2\EOT\211\EOT\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ETX\DC2\EOT\211\EOT\DC4\NAK\n\
    \#\n\
    \\EOT\EOT\f\STX\STX\DC2\EOT\212\EOT\STX\SYN\"\NAK slot_no <= max_slot\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ENQ\DC2\EOT\212\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\SOH\DC2\EOT\212\EOT\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ETX\DC2\EOT\212\EOT\DC4\NAK\n\
    \/\n\
    \\EOT\EOT\f\STX\ETX\DC2\EOT\213\EOT\STX!\"! min_time <= time (ms precision)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ENQ\DC2\EOT\213\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\SOH\DC2\EOT\213\EOT\b\FS\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ETX\DC2\EOT\213\EOT\US \n\
    \/\n\
    \\EOT\EOT\f\STX\EOT\DC2\EOT\214\EOT\STX!\"! time <= max_time (ms precision)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\ENQ\DC2\EOT\214\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\SOH\DC2\EOT\214\EOT\b\FS\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\ETX\DC2\EOT\214\EOT\US \n\
    \\f\n\
    \\STX\EOT\r\DC2\ACK\217\EOT\NUL\219\EOT\SOH\n\
    \\v\n\
    \\ETX\EOT\r\SOH\DC2\EOT\217\EOT\b\GS\n\
    \\CAN\n\
    \\EOT\EOT\r\STX\NUL\DC2\EOT\218\EOT\STX\DC1\"\n\
    \ 32 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ENQ\DC2\EOT\218\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\SOH\DC2\EOT\218\EOT\b\f\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ETX\DC2\EOT\218\EOT\SI\DLE\n\
    \\179\SOH\n\
    \\STX\EOT\SO\DC2\ACK\225\EOT\NUL\227\EOT\SOH2\164\SOH =========================================================================\n\
    \ Token bridge\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SO\SOH\DC2\EOT\225\EOT\b\FS\n\
    \\CAN\n\
    \\EOT\EOT\SO\STX\NUL\DC2\EOT\226\EOT\STX\DC4\"\n\
    \ 32 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\ENQ\DC2\EOT\226\EOT\STX\a\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\SOH\DC2\EOT\226\EOT\b\SI\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\ETX\DC2\EOT\226\EOT\DC2\DC3\n\
    \5\n\
    \\STX\EOT\SI\DC2\ACK\230\EOT\NUL\232\EOT\SOH\SUB' Mirrors TxBlockInfo (PC/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SI\SOH\DC2\EOT\230\EOT\b\GS\n\
    \\f\n\
    \\EOT\EOT\SI\STX\NUL\DC2\EOT\231\EOT\STX!\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\EOT\DC2\EOT\231\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\ACK\DC2\EOT\231\EOT\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\SOH\DC2\EOT\231\EOT\DC4\FS\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\ETX\DC2\EOT\231\EOT\US \n\
    \\f\n\
    \\STX\EOT\DLE\DC2\ACK\234\EOT\NUL\250\EOT\SOH\n\
    \\v\n\
    \\ETX\EOT\DLE\SOH\DC2\EOT\234\EOT\b\ESC\n\
    \=\n\
    \\EOT\EOT\DLE\STX\NUL\DC2\EOT\235\EOT\STX\EM\"/ illiquid circulation supply validator address\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\ENQ\DC2\EOT\235\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\SOH\DC2\EOT\235\EOT\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\ETX\DC2\EOT\235\EOT\ETB\CAN\n\
    \)\n\
    \\EOT\EOT\DLE\STX\SOH\DC2\EOT\236\EOT\STX\GS\"\ESC reserve validator address\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\ENQ\DC2\EOT\236\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\SOH\DC2\EOT\236\EOT\t\CAN\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\ETX\DC2\EOT\236\EOT\ESC\FS\n\
    \+\n\
    \\EOT\EOT\DLE\STX\STX\DC2\EOT\237\EOT\STX\DC4\"\GS bridge token (policy, name)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\ACK\DC2\EOT\237\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\SOH\DC2\EOT\237\EOT\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\ETX\DC2\EOT\237\EOT\DC2\DC3\n\
    \X\n\
    \\EOT\EOT\DLE\b\NUL\DC2\ACK\240\EOT\STX\247\EOT\ETX\SUBH Lower bound, mirroring ResolvedBridgeDataCheckpoint\n\
    \ (PC/db_model.rs).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\b\NUL\SOH\DC2\EOT\240\EOT\b\r\n\
    \9\n\
    \\EOT\EOT\DLE\STX\ETX\DC2\EOT\242\EOT\EOT\RS\SUB+ Block{number}: block_no > after_block_no.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ETX\ENQ\DC2\EOT\242\EOT\EOT\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ETX\SOH\DC2\EOT\242\EOT\v\EM\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ETX\ETX\DC2\EOT\242\EOT\FS\GS\n\
    \O\n\
    \\EOT\EOT\DLE\STX\EOT\DC2\EOT\244\EOT\EOT \SUBA Tx{block_number, tx_ix}: (block_no, tx_index) > after_position.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\EOT\ACK\DC2\EOT\244\EOT\EOT\f\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\EOT\SOH\DC2\EOT\244\EOT\r\ESC\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\EOT\ETX\DC2\EOT\244\EOT\RS\US\n\
    \^\n\
    \\EOT\EOT\DLE\STX\ENQ\DC2\EOT\246\EOT\EOT\US\SUBP TxReserveTransfer{block_number, tx_ix}: (block_no, tx_index) >= from_position.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ENQ\ACK\DC2\EOT\246\EOT\EOT\f\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ENQ\SOH\DC2\EOT\246\EOT\r\SUB\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ENQ\ETX\DC2\EOT\246\EOT\GS\RS\n\
    \3\n\
    \\EOT\EOT\DLE\STX\ACK\DC2\EOT\248\EOT\STX\EM\"% block_no <= to_block_no (inclusive)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ACK\ENQ\DC2\EOT\248\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ACK\SOH\DC2\EOT\248\EOT\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\ACK\ETX\DC2\EOT\248\EOT\ETB\CAN\n\
    \'\n\
    \\EOT\EOT\DLE\STX\a\DC2\EOT\249\EOT\STX\RS\"\EM LIMIT; unset = no limit\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\a\EOT\DC2\EOT\249\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\a\ENQ\DC2\EOT\249\EOT\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\a\SOH\DC2\EOT\249\EOT\DC2\EM\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\a\ETX\DC2\EOT\249\EOT\FS\GS\n\
    \2\n\
    \\STX\EOT\DC1\DC2\ACK\253\EOT\NUL\139\ENQ\SOH\SUB$ Mirrors BridgeTx (PC/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DC1\SOH\DC2\EOT\253\EOT\b\DC3\n\
    \)\n\
    \\EOT\EOT\DC1\STX\NUL\DC2\EOT\254\EOT\STX\SYN\"\ESC block_number: BlockNumber\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\ENQ\DC2\EOT\254\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\SOH\DC2\EOT\254\EOT\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\ETX\DC2\EOT\254\EOT\DC4\NAK\n\
    \%\n\
    \\EOT\EOT\DC1\STX\SOH\DC2\EOT\255\EOT\STX\SYN\"\ETB tx_ix: TxIndexInBlock\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\ENQ\DC2\EOT\255\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\SOH\DC2\EOT\255\EOT\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\ETX\DC2\EOT\255\EOT\DC4\NAK\n\
    \\US\n\
    \\EOT\EOT\DC1\STX\STX\DC2\EOT\128\ENQ\STX\DC4\"\DC1 tx_hash: TxHash\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\ENQ\DC2\EOT\128\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\SOH\DC2\EOT\128\ENQ\b\SI\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\ETX\DC2\EOT\128\ENQ\DC2\DC3\n\
    \\200\STX\n\
    \\EOT\EOT\DC1\STX\ETX\DC2\EOT\134\ENQ\STX(\SUB\185\STX c2m_metadata: CBOR of the metadatum under label 6500973 in T's\n\
    \ auxiliary data (the value only, not the label map). Unset when T has no\n\
    \ such label (or T is phase-2-invalid, SPEC 4.meta). The Rust client maps\n\
    \ it to the Option<JsonValue> that metadata_to_recipient consumes; see\n\
    \ CONTRACT.md section 3, item S6.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\EOT\DC2\EOT\134\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\ENQ\DC2\EOT\134\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\SOH\DC2\EOT\134\ENQ\DC1#\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\ETX\DC2\EOT\134\ENQ&'\n\
    \\f\n\
    \\EOT\EOT\DC1\STX\EOT\DC2\EOT\135\ENQ\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\ACK\DC2\EOT\135\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\SOH\DC2\EOT\135\ENQ\n\
    \\DC3\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\ETX\DC2\EOT\135\ENQ\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\DC1\STX\ENQ\DC2\EOT\136\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\ACK\DC2\EOT\136\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\SOH\DC2\EOT\136\ENQ\n\
    \\DC4\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\ETX\DC2\EOT\136\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\DC1\STX\ACK\DC2\EOT\137\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\ACK\DC2\EOT\137\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\SOH\DC2\EOT\137\ENQ\n\
    \\DC4\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\ETX\DC2\EOT\137\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\DC1\STX\a\DC2\EOT\138\ENQ\STX\SUB\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\ACK\DC2\EOT\138\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\SOH\DC2\EOT\138\ENQ\n\
    \\NAK\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\ETX\DC2\EOT\138\ENQ\CAN\EM\n\
    \\186\SOH\n\
    \\STX\EOT\DC2\DC2\ACK\145\ENQ\NUL\147\ENQ\SOH2\171\SOH =========================================================================\n\
    \ Authority selection\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DC2\SOH\DC2\EOT\145\ENQ\b%\n\
    \,\n\
    \\EOT\EOT\DC2\STX\NUL\DC2\EOT\146\ENQ\STX\SYN\"\RS epoch_no <= this (inclusive)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\ENQ\DC2\EOT\146\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\SOH\DC2\EOT\146\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\ETX\DC2\EOT\146\ENQ\DC4\NAK\n\
    \\f\n\
    \\STX\EOT\DC3\DC2\ACK\149\ENQ\NUL\151\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\DC3\SOH\DC2\EOT\149\ENQ\b#\n\
    \\RS\n\
    \\EOT\EOT\DC3\STX\NUL\DC2\EOT\150\ENQ\STX \"\DLE k, node config\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\ENQ\DC2\EOT\150\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\SOH\DC2\EOT\150\ENQ\t\ESC\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\ETX\DC2\EOT\150\ENQ\RS\US\n\
    \\f\n\
    \\STX\EOT\DC4\DC2\ACK\153\ENQ\NUL\156\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\DC4\SOH\DC2\EOT\153\ENQ\b$\n\
    \W\n\
    \\EOT\EOT\DC4\STX\NUL\DC2\EOT\155\ENQ\STX\RS\SUBI stable_block.epoch_no - 1; may be -1. Absent when tip < k or no blocks.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC4\STX\NUL\EOT\DC2\EOT\155\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC4\STX\NUL\ENQ\DC2\EOT\155\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\DC4\STX\NUL\SOH\DC2\EOT\155\ENQ\DC1\EM\n\
    \\r\n\
    \\ENQ\EOT\DC4\STX\NUL\ETX\DC2\EOT\155\ENQ\FS\GS\n\
    \\f\n\
    \\STX\EOT\NAK\DC2\ACK\158\ENQ\NUL\160\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\NAK\SOH\DC2\EOT\158\ENQ\b#\n\
    \\f\n\
    \\EOT\EOT\NAK\STX\NUL\DC2\EOT\159\ENQ\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\NAK\STX\NUL\ENQ\DC2\EOT\159\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\NAK\STX\NUL\SOH\DC2\EOT\159\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\NAK\STX\NUL\ETX\DC2\EOT\159\ENQ\DC4\NAK\n\
    \L\n\
    \\STX\EOT\SYN\DC2\ACK\163\ENQ\NUL\166\ENQ\SOH\SUB> Mirrors StakePoolEntry (candidates_data_source/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SYN\SOH\DC2\EOT\163\ENQ\b\SYN\n\
    \-\n\
    \\EOT\EOT\SYN\STX\NUL\DC2\EOT\164\ENQ\STX\SYN\"\US 28 bytes (pool_hash.hash_raw)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\NUL\ENQ\DC2\EOT\164\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\NUL\SOH\DC2\EOT\164\ENQ\b\DC1\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\NUL\ETX\DC2\EOT\164\ENQ\DC4\NAK\n\
    \)\n\
    \\EOT\EOT\SYN\STX\SOH\DC2\EOT\165\ENQ\STX\DC3\"\ESC lovelace, summed per pool\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\SOH\ENQ\DC2\EOT\165\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\SOH\SOH\DC2\EOT\165\ENQ\t\SO\n\
    \\r\n\
    \\ENQ\EOT\SYN\STX\SOH\ETX\DC2\EOT\165\ENQ\DC1\DC2\n\
    \\f\n\
    \\STX\EOT\ETB\DC2\ACK\168\ENQ\NUL\171\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\ETB\SOH\DC2\EOT\168\ENQ\b+\n\
    \$\n\
    \\EOT\EOT\ETB\STX\NUL\DC2\EOT\169\ENQ\STX\DC4\"\SYN exact (policy, name)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\NUL\ACK\DC2\EOT\169\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\NUL\SOH\DC2\EOT\169\ENQ\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\NUL\ETX\DC2\EOT\169\ENQ\DC2\DC3\n\
    \9\n\
    \\EOT\EOT\ETB\STX\SOH\DC2\EOT\170\ENQ\STX\SYN\"+ origin block epoch_no <= this (inclusive)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\SOH\ENQ\DC2\EOT\170\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\SOH\SOH\DC2\EOT\170\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\ETB\STX\SOH\ETX\DC2\EOT\170\ENQ\DC4\NAK\n\
    \K\n\
    \\STX\EOT\CAN\DC2\ACK\174\ENQ\NUL\182\ENQ\SOH\SUB= Mirrors TokenTxOutput (candidates_data_source/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\CAN\SOH\DC2\EOT\174\ENQ\b\NAK\n\
    \\CAN\n\
    \\EOT\EOT\CAN\STX\NUL\DC2\EOT\175\ENQ\STX\ESC\"\n\
    \ 32 bytes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\NUL\ENQ\DC2\EOT\175\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\NUL\SOH\DC2\EOT\175\ENQ\b\SYN\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\NUL\ETX\DC2\EOT\175\ENQ\EM\SUB\n\
    \\FS\n\
    \\EOT\EOT\CAN\STX\SOH\DC2\EOT\176\ENQ\STX\CAN\"\SO TxIndex(u16)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\SOH\ENQ\DC2\EOT\176\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\SOH\SOH\DC2\EOT\176\ENQ\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\SOH\ETX\DC2\EOT\176\ENQ\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\CAN\STX\STX\DC2\EOT\177\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\STX\ENQ\DC2\EOT\177\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\STX\SOH\DC2\EOT\177\ENQ\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\STX\ETX\DC2\EOT\177\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\CAN\STX\ETX\DC2\EOT\178\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ETX\ENQ\DC2\EOT\178\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ETX\SOH\DC2\EOT\178\ENQ\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ETX\ETX\DC2\EOT\178\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\CAN\STX\EOT\DC2\EOT\179\ENQ\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\EOT\ENQ\DC2\EOT\179\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\EOT\SOH\DC2\EOT\179\ENQ\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\EOT\ETX\DC2\EOT\179\ENQ\SYN\ETB\n\
    \\RS\n\
    \\EOT\EOT\CAN\STX\ENQ\DC2\EOT\180\ENQ\STX\FS\"\DLE TxIndexInBlock\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ENQ\ENQ\DC2\EOT\180\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ENQ\SOH\DC2\EOT\180\ENQ\t\ETB\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ENQ\ETX\DC2\EOT\180\ENQ\SUB\ESC\n\
    \0\n\
    \\EOT\EOT\CAN\STX\ACK\DC2\EOT\181\ENQ\STX\ESC\"\" LEFT JOIN; strict decode in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ACK\EOT\DC2\EOT\181\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ACK\ACK\DC2\EOT\181\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ACK\SOH\DC2\EOT\181\ENQ\DC1\SYN\n\
    \\r\n\
    \\ENQ\EOT\CAN\STX\ACK\ETX\DC2\EOT\181\ENQ\EM\SUB\n\
    \\f\n\
    \\STX\EOT\EM\DC2\ACK\184\ENQ\NUL\186\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\EM\SOH\DC2\EOT\184\ENQ\b,\n\
    \\f\n\
    \\EOT\EOT\EM\STX\NUL\DC2\EOT\185\ENQ\STX$\n\
    \\r\n\
    \\ENQ\EOT\EM\STX\NUL\EOT\DC2\EOT\185\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EM\STX\NUL\ACK\DC2\EOT\185\ENQ\v\CAN\n\
    \\r\n\
    \\ENQ\EOT\EM\STX\NUL\SOH\DC2\EOT\185\ENQ\EM\US\n\
    \\r\n\
    \\ENQ\EOT\EM\STX\NUL\ETX\DC2\EOT\185\ENQ\"#\n\
    \\f\n\
    \\STX\EOT\SUB\DC2\ACK\188\ENQ\NUL\190\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\SUB\SOH\DC2\EOT\188\ENQ\b\FS\n\
    \\f\n\
    \\EOT\EOT\SUB\STX\NUL\DC2\EOT\189\ENQ\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\SUB\STX\NUL\ENQ\DC2\EOT\189\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\SUB\STX\NUL\SOH\DC2\EOT\189\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\SUB\STX\NUL\ETX\DC2\EOT\189\ENQ\DC4\NAK\n\
    \Q\n\
    \\STX\EOT\ESC\DC2\ACK\193\ENQ\NUL\195\ENQ\SOH\SUBC Mirrors MainchainEpochNonce (candidates_data_source/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ESC\SOH\DC2\EOT\193\ENQ\b\GS\n\
    \%\n\
    \\EOT\EOT\ESC\STX\NUL\DC2\EOT\194\ENQ\STX\ESC\"\ETB 32 bytes when present\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ESC\STX\NUL\EOT\DC2\EOT\194\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ESC\STX\NUL\ENQ\DC2\EOT\194\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\ESC\STX\NUL\SOH\DC2\EOT\194\ENQ\DC1\SYN\n\
    \\r\n\
    \\ENQ\EOT\ESC\STX\NUL\ETX\DC2\EOT\194\ENQ\EM\SUB\n\
    \\f\n\
    \\STX\EOT\FS\DC2\ACK\197\ENQ\NUL\200\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT\FS\SOH\DC2\EOT\197\ENQ\b)\n\
    \E\n\
    \\EOT\EOT\FS\STX\NUL\DC2\EOT\198\ENQ\STX\NAK\"7 committee candidate validator address (text equality)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\NUL\ENQ\DC2\EOT\198\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\NUL\SOH\DC2\EOT\198\ENQ\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\NUL\ETX\DC2\EOT\198\ENQ\DC3\DC4\n\
    \C\n\
    \\EOT\EOT\FS\STX\SOH\DC2\EOT\199\ENQ\STX\SYN\"5 created at <= block_no, not consumed at <= block_no\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\SOH\ENQ\DC2\EOT\199\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\SOH\SOH\DC2\EOT\199\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\FS\STX\SOH\ETX\DC2\EOT\199\ENQ\DC4\NAK\n\
    \g\n\
    \\STX\EOT\GS\DC2\ACK\204\ENQ\NUL\217\ENQ\SOH\SUBY Mirrors MainchainTxOutputRow / MainchainTxOutput\n\
    \ (candidates_data_source/db_model.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\GS\SOH\DC2\EOT\204\ENQ\b\CAN\n\
    \\US\n\
    \\EOT\EOT\GS\STX\NUL\DC2\EOT\205\ENQ\STX\EM\"\DC1 utxo_id_tx_hash\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\NUL\ENQ\DC2\EOT\205\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\NUL\SOH\DC2\EOT\205\ENQ\b\DC4\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\NUL\ETX\DC2\EOT\205\ENQ\ETB\CAN\n\
    \+\n\
    \\EOT\EOT\GS\STX\SOH\DC2\EOT\206\ENQ\STX\CAN\"\GS utxo_id_index: TxIndex(u16)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\SOH\ENQ\DC2\EOT\206\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\SOH\SOH\DC2\EOT\206\ENQ\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\SOH\ETX\DC2\EOT\206\ENQ\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\GS\STX\STX\DC2\EOT\207\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\STX\ENQ\DC2\EOT\207\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\STX\SOH\DC2\EOT\207\ENQ\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\STX\ETX\DC2\EOT\207\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\GS\STX\ETX\DC2\EOT\208\ENQ\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ETX\ENQ\DC2\EOT\208\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ETX\SOH\DC2\EOT\208\ENQ\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ETX\ETX\DC2\EOT\208\ENQ\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\GS\STX\EOT\DC2\EOT\209\ENQ\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\EOT\ENQ\DC2\EOT\209\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\EOT\SOH\DC2\EOT\209\ENQ\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\EOT\ETX\DC2\EOT\209\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\GS\STX\ENQ\DC2\EOT\210\ENQ\STX\US\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ENQ\ENQ\DC2\EOT\210\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ENQ\SOH\DC2\EOT\210\ENQ\t\SUB\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ENQ\ETX\DC2\EOT\210\ENQ\GS\RS\n\
    \#\n\
    \\EOT\EOT\GS\STX\ACK\DC2\EOT\211\ENQ\STX\NAK\"\NAK tx_out.address text\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ACK\ENQ\DC2\EOT\211\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ACK\SOH\DC2\EOT\211\ENQ\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\ACK\ETX\DC2\EOT\211\ENQ\DC3\DC4\n\
    \1\n\
    \\EOT\EOT\GS\STX\a\DC2\EOT\212\ENQ\STX\ESC\"# LEFT JOIN; DbDatumIfValid in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\a\EOT\DC2\EOT\212\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\a\ACK\DC2\EOT\212\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\a\SOH\DC2\EOT\212\ENQ\DC1\SYN\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\a\ETX\DC2\EOT\212\ENQ\EM\SUB\n\
    \\179\SOH\n\
    \\EOT\EOT\GS\STX\b\DC2\EOT\216\ENQ\STX#\SUB\164\SOH Inputs of the creating transaction, ordered by (tx_hash bytes ASC,\n\
    \ index ASC). The SQL emits them as \"hex#index\" strings that Rust parses\n\
    \ with UtxoId::from_str.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\b\EOT\DC2\EOT\216\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\b\ACK\DC2\EOT\216\ENQ\v\DC4\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\b\SOH\DC2\EOT\216\ENQ\NAK\RS\n\
    \\r\n\
    \\ENQ\EOT\GS\STX\b\ETX\DC2\EOT\216\ENQ!\"\n\
    \\185\SOH\n\
    \\STX\EOT\RS\DC2\ACK\223\ENQ\NUL\231\ENQ\SOH2\170\SOH =========================================================================\n\
    \ cNIGHT observation\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT\RS\SOH\DC2\EOT\223\ENQ\b&\n\
    \\GS\n\
    \\EOT\EOT\RS\STX\NUL\DC2\EOT\224\ENQ\STX'\"\SI text equality\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\NUL\ENQ\DC2\EOT\224\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\NUL\SOH\DC2\EOT\224\ENQ\t\"\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\NUL\ETX\DC2\EOT\224\ENQ%&\n\
    \\150\SOH\n\
    \\EOT\EOT\RS\STX\SOH\DC2\EOT\227\ENQ\STX\EM\SUB\135\SOH Auth token: policy = mapping validator script hash, name = auth token\n\
    \ asset name (cnight_observation.rs). Rows require quantity = 1.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\SOH\ACK\DC2\EOT\227\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\SOH\SOH\DC2\EOT\227\ENQ\n\
    \\DC4\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\SOH\ETX\DC2\EOT\227\ENQ\ETB\CAN\n\
    \$\n\
    \\EOT\EOT\RS\STX\STX\DC2\EOT\228\ENQ\STX\FS\"\SYN creating tx position\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\STX\ACK\DC2\EOT\228\ENQ\STX\DLE\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\STX\SOH\DC2\EOT\228\ENQ\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\STX\ETX\DC2\EOT\228\ENQ\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\RS\STX\ETX\DC2\EOT\229\ENQ\STX\DC3\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\ETX\ENQ\DC2\EOT\229\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\ETX\SOH\DC2\EOT\229\ENQ\t\SO\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\ETX\ETX\DC2\EOT\229\ENQ\DC1\DC2\n\
    \\f\n\
    \\EOT\EOT\RS\STX\EOT\DC2\EOT\230\ENQ\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\EOT\ENQ\DC2\EOT\230\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\EOT\SOH\DC2\EOT\230\ENQ\t\SI\n\
    \\r\n\
    \\ENQ\EOT\RS\STX\EOT\ETX\DC2\EOT\230\ENQ\DC2\DC3\n\
    \9\n\
    \\STX\EOT\US\DC2\ACK\234\ENQ\NUL\244\ENQ\SOH\SUB+ Mirrors RegistrationRow (MF/db/types.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT\US\SOH\DC2\EOT\234\ENQ\b\ETB\n\
    \?\n\
    \\EOT\EOT\US\STX\NUL\DC2\EOT\235\ENQ\STX\DC2\"1 always set (INNER JOIN); DbDatumIfValid in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\US\STX\NUL\ACK\DC2\EOT\235\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\US\STX\NUL\SOH\DC2\EOT\235\ENQ\b\r\n\
    \\r\n\
    \\ENQ\EOT\US\STX\NUL\ETX\DC2\EOT\235\ENQ\DLE\DC1\n\
    \\f\n\
    \\EOT\EOT\US\STX\SOH\DC2\EOT\236\ENQ\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\US\STX\SOH\ENQ\DC2\EOT\236\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\US\STX\SOH\SOH\DC2\EOT\236\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\US\STX\SOH\ETX\DC2\EOT\236\ENQ\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT\US\STX\STX\DC2\EOT\237\ENQ\STX\ETB\n\
    \\r\n\
    \\ENQ\EOT\US\STX\STX\ENQ\DC2\EOT\237\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\US\STX\STX\SOH\DC2\EOT\237\ENQ\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\US\STX\STX\ETX\DC2\EOT\237\ENQ\NAK\SYN\n\
    \\138\SOH\n\
    \\EOT\EOT\US\STX\ETX\DC2\EOT\240\ENQ\STX#\SUB| Rust ends with CardanoPosition.block_timestamp in ms\n\
    \ (TimestampUnixMillis(i64)); always a multiple of 1000 (SPEC 4.time).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ETX\ENQ\DC2\EOT\240\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ETX\SOH\DC2\EOT\240\ENQ\b\RS\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ETX\ETX\DC2\EOT\240\ENQ!\"\n\
    \\f\n\
    \\EOT\EOT\US\STX\EOT\DC2\EOT\241\ENQ\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\US\STX\EOT\ENQ\DC2\EOT\241\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\US\STX\EOT\SOH\DC2\EOT\241\ENQ\t\DC1\n\
    \\r\n\
    \\ENQ\EOT\US\STX\EOT\ETX\DC2\EOT\241\ENQ\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT\US\STX\ENQ\DC2\EOT\242\ENQ\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ENQ\ENQ\DC2\EOT\242\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ENQ\SOH\DC2\EOT\242\ENQ\b\SI\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ENQ\ETX\DC2\EOT\242\ENQ\DC2\DC3\n\
    \\f\n\
    \\EOT\EOT\US\STX\ACK\DC2\EOT\243\ENQ\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ACK\ENQ\DC2\EOT\243\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ACK\SOH\DC2\EOT\243\ENQ\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\US\STX\ACK\ETX\DC2\EOT\243\ENQ\SYN\ETB\n\
    \\f\n\
    \\STX\EOT \DC2\ACK\246\ENQ\NUL\251\ENQ\SOH\n\
    \\v\n\
    \\ETX\EOT \SOH\DC2\EOT\246\ENQ\b(\n\
    \\GS\n\
    \\EOT\EOT \STX\NUL\DC2\EOT\247\ENQ\STX'\"\SI text equality\n\
    \\n\
    \\r\n\
    \\ENQ\EOT \STX\NUL\ENQ\DC2\EOT\247\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT \STX\NUL\SOH\DC2\EOT\247\ENQ\t\"\n\
    \\r\n\
    \\ENQ\EOT \STX\NUL\ETX\DC2\EOT\247\ENQ%&\n\
    \$\n\
    \\EOT\EOT \STX\SOH\DC2\EOT\248\ENQ\STX\FS\"\SYN spending tx position\n\
    \\n\
    \\r\n\
    \\ENQ\EOT \STX\SOH\ACK\DC2\EOT\248\ENQ\STX\DLE\n\
    \\r\n\
    \\ENQ\EOT \STX\SOH\SOH\DC2\EOT\248\ENQ\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT \STX\SOH\ETX\DC2\EOT\248\ENQ\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT \STX\STX\DC2\EOT\249\ENQ\STX\DC3\n\
    \\r\n\
    \\ENQ\EOT \STX\STX\ENQ\DC2\EOT\249\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT \STX\STX\SOH\DC2\EOT\249\ENQ\t\SO\n\
    \\r\n\
    \\ENQ\EOT \STX\STX\ETX\DC2\EOT\249\ENQ\DC1\DC2\n\
    \\f\n\
    \\EOT\EOT \STX\ETX\DC2\EOT\250\ENQ\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT \STX\ETX\ENQ\DC2\EOT\250\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT \STX\ETX\SOH\DC2\EOT\250\ENQ\t\SI\n\
    \\r\n\
    \\ENQ\EOT \STX\ETX\ETX\DC2\EOT\250\ENQ\DC2\DC3\n\
    \;\n\
    \\STX\EOT!\DC2\ACK\254\ENQ\NUL\135\ACK\SOH\SUB- Mirrors DeregistrationRow (MF/db/types.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT!\SOH\DC2\EOT\254\ENQ\b\EM\n\
    \?\n\
    \\EOT\EOT!\STX\NUL\DC2\EOT\255\ENQ\STX\DC2\"1 always set (INNER JOIN); DbDatumIfValid in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\NUL\ACK\DC2\EOT\255\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT!\STX\NUL\SOH\DC2\EOT\255\ENQ\b\r\n\
    \\r\n\
    \\ENQ\EOT!\STX\NUL\ETX\DC2\EOT\255\ENQ\DLE\DC1\n\
    \\RS\n\
    \\EOT\EOT!\STX\SOH\DC2\EOT\128\ACK\STX\SYN\"\DLE spending block\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\SOH\ENQ\DC2\EOT\128\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT!\STX\SOH\SOH\DC2\EOT\128\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT!\STX\SOH\ETX\DC2\EOT\128\ACK\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT!\STX\STX\DC2\EOT\129\ACK\STX\ETB\n\
    \\r\n\
    \\ENQ\EOT!\STX\STX\ENQ\DC2\EOT\129\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT!\STX\STX\SOH\DC2\EOT\129\ACK\b\DC2\n\
    \\r\n\
    \\ENQ\EOT!\STX\STX\ETX\DC2\EOT\129\ACK\NAK\SYN\n\
    \\f\n\
    \\EOT\EOT!\STX\ETX\DC2\EOT\130\ACK\STX#\n\
    \\r\n\
    \\ENQ\EOT!\STX\ETX\ENQ\DC2\EOT\130\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT!\STX\ETX\SOH\DC2\EOT\130\ACK\b\RS\n\
    \\r\n\
    \\ENQ\EOT!\STX\ETX\ETX\DC2\EOT\130\ACK!\"\n\
    \*\n\
    \\EOT\EOT!\STX\EOT\DC2\EOT\131\ACK\STX\SYN\"\FS spending tx index in block\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\EOT\ENQ\DC2\EOT\131\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT!\STX\EOT\SOH\DC2\EOT\131\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT!\STX\EOT\ETX\DC2\EOT\131\ACK\DC4\NAK\n\
    \ \n\
    \\EOT\EOT!\STX\ENQ\DC2\EOT\132\ACK\STX\DC4\"\DC2 spending tx hash\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\ENQ\ENQ\DC2\EOT\132\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT!\STX\ENQ\SOH\DC2\EOT\132\ACK\b\SI\n\
    \\r\n\
    \\ENQ\EOT!\STX\ENQ\ETX\DC2\EOT\132\ACK\DC2\DC3\n\
    \&\n\
    \\EOT\EOT!\STX\ACK\DC2\EOT\133\ACK\STX\EM\"\CAN spent output's tx hash\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\ACK\ENQ\DC2\EOT\133\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT!\STX\ACK\SOH\DC2\EOT\133\ACK\b\DC4\n\
    \\r\n\
    \\ENQ\EOT!\STX\ACK\ETX\DC2\EOT\133\ACK\ETB\CAN\n\
    \$\n\
    \\EOT\EOT!\STX\a\DC2\EOT\134\ACK\STX\CAN\"\SYN spent output's index\n\
    \\n\
    \\r\n\
    \\ENQ\EOT!\STX\a\ENQ\DC2\EOT\134\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT!\STX\a\SOH\DC2\EOT\134\ACK\t\DC3\n\
    \\r\n\
    \\ENQ\EOT!\STX\a\ETX\DC2\EOT\134\ACK\SYN\ETB\n\
    \\f\n\
    \\STX\EOT\"\DC2\ACK\137\ACK\NUL\142\ACK\SOH\n\
    \\v\n\
    \\ETX\EOT\"\SOH\DC2\EOT\137\ACK\b\RS\n\
    \%\n\
    \\EOT\EOT\"\STX\NUL\DC2\EOT\138\ACK\STX\DC4\"\ETB cNIGHT (policy, name)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\"\STX\NUL\ACK\DC2\EOT\138\ACK\STX\t\n\
    \\r\n\
    \\ENQ\EOT\"\STX\NUL\SOH\DC2\EOT\138\ACK\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\"\STX\NUL\ETX\DC2\EOT\138\ACK\DC2\DC3\n\
    \$\n\
    \\EOT\EOT\"\STX\SOH\DC2\EOT\139\ACK\STX\FS\"\SYN creating tx position\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\"\STX\SOH\ACK\DC2\EOT\139\ACK\STX\DLE\n\
    \\r\n\
    \\ENQ\EOT\"\STX\SOH\SOH\DC2\EOT\139\ACK\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT\"\STX\SOH\ETX\DC2\EOT\139\ACK\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\"\STX\STX\DC2\EOT\140\ACK\STX\DC3\n\
    \\r\n\
    \\ENQ\EOT\"\STX\STX\ENQ\DC2\EOT\140\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT\"\STX\STX\SOH\DC2\EOT\140\ACK\t\SO\n\
    \\r\n\
    \\ENQ\EOT\"\STX\STX\ETX\DC2\EOT\140\ACK\DC1\DC2\n\
    \\f\n\
    \\EOT\EOT\"\STX\ETX\DC2\EOT\141\ACK\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT\"\STX\ETX\ENQ\DC2\EOT\141\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT\"\STX\ETX\SOH\DC2\EOT\141\ACK\t\SI\n\
    \\r\n\
    \\ENQ\EOT\"\STX\ETX\ETX\DC2\EOT\141\ACK\DC2\DC3\n\
    \8\n\
    \\STX\EOT#\DC2\ACK\145\ACK\NUL\155\ACK\SOH\SUB* Mirrors AssetCreateRow (MF/db/types.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT#\SOH\DC2\EOT\145\ACK\b\SYN\n\
    \\f\n\
    \\EOT\EOT#\STX\NUL\DC2\EOT\146\ACK\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT#\STX\NUL\ENQ\DC2\EOT\146\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT#\STX\NUL\SOH\DC2\EOT\146\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT#\STX\NUL\ETX\DC2\EOT\146\ACK\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT#\STX\SOH\DC2\EOT\147\ACK\STX\ETB\n\
    \\r\n\
    \\ENQ\EOT#\STX\SOH\ENQ\DC2\EOT\147\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT#\STX\SOH\SOH\DC2\EOT\147\ACK\b\DC2\n\
    \\r\n\
    \\ENQ\EOT#\STX\SOH\ETX\DC2\EOT\147\ACK\NAK\SYN\n\
    \\f\n\
    \\EOT\EOT#\STX\STX\DC2\EOT\148\ACK\STX#\n\
    \\r\n\
    \\ENQ\EOT#\STX\STX\ENQ\DC2\EOT\148\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT#\STX\STX\SOH\DC2\EOT\148\ACK\b\RS\n\
    \\r\n\
    \\ENQ\EOT#\STX\STX\ETX\DC2\EOT\148\ACK!\"\n\
    \\f\n\
    \\EOT\EOT#\STX\ETX\DC2\EOT\149\ACK\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT#\STX\ETX\ENQ\DC2\EOT\149\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT#\STX\ETX\SOH\DC2\EOT\149\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT#\STX\ETX\ETX\DC2\EOT\149\ACK\DC4\NAK\n\
    \R\n\
    \\EOT\EOT#\STX\EOT\DC2\EOT\151\ACK\STX\SYN\SUBD Rust field is i64 (SQL ::BIGINT cast). Client fails if > i64::MAX.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT#\STX\EOT\ENQ\DC2\EOT\151\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT#\STX\EOT\SOH\DC2\EOT\151\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT#\STX\EOT\ETX\DC2\EOT\151\ACK\DC4\NAK\n\
    \#\n\
    \\EOT\EOT#\STX\ENQ\DC2\EOT\152\ACK\STX\FS\"\NAK tx_out.address text\n\
    \\n\
    \\r\n\
    \\ENQ\EOT#\STX\ENQ\ENQ\DC2\EOT\152\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT#\STX\ENQ\SOH\DC2\EOT\152\ACK\t\ETB\n\
    \\r\n\
    \\ENQ\EOT#\STX\ENQ\ETX\DC2\EOT\152\ACK\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT#\STX\ACK\DC2\EOT\153\ACK\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT#\STX\ACK\ENQ\DC2\EOT\153\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT#\STX\ACK\SOH\DC2\EOT\153\ACK\b\SI\n\
    \\r\n\
    \\ENQ\EOT#\STX\ACK\ETX\DC2\EOT\153\ACK\DC2\DC3\n\
    \\f\n\
    \\EOT\EOT#\STX\a\DC2\EOT\154\ACK\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT#\STX\a\ENQ\DC2\EOT\154\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT#\STX\a\SOH\DC2\EOT\154\ACK\t\DC3\n\
    \\r\n\
    \\ENQ\EOT#\STX\a\ETX\DC2\EOT\154\ACK\SYN\ETB\n\
    \\f\n\
    \\STX\EOT$\DC2\ACK\157\ACK\NUL\162\ACK\SOH\n\
    \\v\n\
    \\ETX\EOT$\SOH\DC2\EOT\157\ACK\b\GS\n\
    \%\n\
    \\EOT\EOT$\STX\NUL\DC2\EOT\158\ACK\STX\DC4\"\ETB cNIGHT (policy, name)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT$\STX\NUL\ACK\DC2\EOT\158\ACK\STX\t\n\
    \\r\n\
    \\ENQ\EOT$\STX\NUL\SOH\DC2\EOT\158\ACK\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT$\STX\NUL\ETX\DC2\EOT\158\ACK\DC2\DC3\n\
    \$\n\
    \\EOT\EOT$\STX\SOH\DC2\EOT\159\ACK\STX\FS\"\SYN spending tx position\n\
    \\n\
    \\r\n\
    \\ENQ\EOT$\STX\SOH\ACK\DC2\EOT\159\ACK\STX\DLE\n\
    \\r\n\
    \\ENQ\EOT$\STX\SOH\SOH\DC2\EOT\159\ACK\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT$\STX\SOH\ETX\DC2\EOT\159\ACK\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT$\STX\STX\DC2\EOT\160\ACK\STX\DC3\n\
    \\r\n\
    \\ENQ\EOT$\STX\STX\ENQ\DC2\EOT\160\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT$\STX\STX\SOH\DC2\EOT\160\ACK\t\SO\n\
    \\r\n\
    \\ENQ\EOT$\STX\STX\ETX\DC2\EOT\160\ACK\DC1\DC2\n\
    \\f\n\
    \\EOT\EOT$\STX\ETX\DC2\EOT\161\ACK\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT$\STX\ETX\ENQ\DC2\EOT\161\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT$\STX\ETX\SOH\DC2\EOT\161\ACK\t\SI\n\
    \\r\n\
    \\ENQ\EOT$\STX\ETX\ETX\DC2\EOT\161\ACK\DC2\DC3\n\
    \7\n\
    \\STX\EOT%\DC2\ACK\165\ACK\NUL\175\ACK\SOH\SUB) Mirrors AssetSpendRow (MF/db/types.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT%\SOH\DC2\EOT\165\ACK\b\NAK\n\
    \\RS\n\
    \\EOT\EOT%\STX\NUL\DC2\EOT\166\ACK\STX\SYN\"\DLE spending block\n\
    \\n\
    \\r\n\
    \\ENQ\EOT%\STX\NUL\ENQ\DC2\EOT\166\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT%\STX\NUL\SOH\DC2\EOT\166\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT%\STX\NUL\ETX\DC2\EOT\166\ACK\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT%\STX\SOH\DC2\EOT\167\ACK\STX\ETB\n\
    \\r\n\
    \\ENQ\EOT%\STX\SOH\ENQ\DC2\EOT\167\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT%\STX\SOH\SOH\DC2\EOT\167\ACK\b\DC2\n\
    \\r\n\
    \\ENQ\EOT%\STX\SOH\ETX\DC2\EOT\167\ACK\NAK\SYN\n\
    \\f\n\
    \\EOT\EOT%\STX\STX\DC2\EOT\168\ACK\STX#\n\
    \\r\n\
    \\ENQ\EOT%\STX\STX\ENQ\DC2\EOT\168\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT%\STX\STX\SOH\DC2\EOT\168\ACK\b\RS\n\
    \\r\n\
    \\ENQ\EOT%\STX\STX\ETX\DC2\EOT\168\ACK!\"\n\
    \*\n\
    \\EOT\EOT%\STX\ETX\DC2\EOT\169\ACK\STX\SYN\"\FS spending tx index in block\n\
    \\n\
    \\r\n\
    \\ENQ\EOT%\STX\ETX\ENQ\DC2\EOT\169\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT%\STX\ETX\SOH\DC2\EOT\169\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT%\STX\ETX\ETX\DC2\EOT\169\ACK\DC4\NAK\n\
    \4\n\
    \\EOT\EOT%\STX\EOT\DC2\EOT\170\ACK\STX\SYN\"& spent output's quantity; i64 in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT%\STX\EOT\ENQ\DC2\EOT\170\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT%\STX\EOT\SOH\DC2\EOT\170\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT%\STX\EOT\ETX\DC2\EOT\170\ACK\DC4\NAK\n\
    \+\n\
    \\EOT\EOT%\STX\ENQ\DC2\EOT\171\ACK\STX\FS\"\GS spent output's address text\n\
    \\n\
    \\r\n\
    \\ENQ\EOT%\STX\ENQ\ENQ\DC2\EOT\171\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT%\STX\ENQ\SOH\DC2\EOT\171\ACK\t\ETB\n\
    \\r\n\
    \\ENQ\EOT%\STX\ENQ\ETX\DC2\EOT\171\ACK\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT%\STX\ACK\DC2\EOT\172\ACK\STX\EM\n\
    \\r\n\
    \\ENQ\EOT%\STX\ACK\ENQ\DC2\EOT\172\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT%\STX\ACK\SOH\DC2\EOT\172\ACK\b\DC4\n\
    \\r\n\
    \\ENQ\EOT%\STX\ACK\ETX\DC2\EOT\172\ACK\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT%\STX\a\DC2\EOT\173\ACK\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT%\STX\a\ENQ\DC2\EOT\173\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT%\STX\a\SOH\DC2\EOT\173\ACK\t\DC3\n\
    \\r\n\
    \\ENQ\EOT%\STX\a\ETX\DC2\EOT\173\ACK\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT%\STX\b\DC2\EOT\174\ACK\STX\GS\n\
    \\r\n\
    \\ENQ\EOT%\STX\b\ENQ\DC2\EOT\174\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT%\STX\b\SOH\DC2\EOT\174\ACK\b\CAN\n\
    \\r\n\
    \\ENQ\EOT%\STX\b\ETX\DC2\EOT\174\ACK\ESC\FS\n\
    \\f\n\
    \\STX\EOT&\DC2\ACK\177\ACK\NUL\179\ACK\SOH\n\
    \\v\n\
    \\ETX\EOT&\SOH\DC2\EOT\177\ACK\b\ESC\n\
    \\f\n\
    \\EOT\EOT&\STX\NUL\DC2\EOT\178\ACK\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT&\STX\NUL\ENQ\DC2\EOT\178\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT&\STX\NUL\SOH\DC2\EOT\178\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT&\STX\NUL\ETX\DC2\EOT\178\ACK\DC4\NAK\n\
    \\f\n\
    \\STX\EOT'\DC2\ACK\181\ACK\NUL\184\ACK\SOH\n\
    \\v\n\
    \\ETX\EOT'\SOH\DC2\EOT\181\ACK\b\FS\n\
    \-\n\
    \\EOT\EOT'\STX\NUL\DC2\EOT\183\ACK\STX\"\SUB\US Bytes. Rust type Option<i64>.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT'\STX\NUL\EOT\DC2\EOT\183\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT'\STX\NUL\ENQ\DC2\EOT\183\ACK\v\DC1\n\
    \\r\n\
    \\ENQ\EOT'\STX\NUL\SOH\DC2\EOT\183\ACK\DC2\GS\n\
    \\r\n\
    \\ENQ\EOT'\STX\NUL\ETX\DC2\EOT\183\ACK !\n\
    \\198\SOH\n\
    \\STX\EOT(\DC2\ACK\190\ACK\NUL\194\ACK\SOH2\183\SOH =========================================================================\n\
    \ Federated authority observation\n\
    \ =========================================================================\n\
    \\n\
    \\v\n\
    \\ETX\EOT(\SOH\DC2\EOT\190\ACK\b(\n\
    \F\n\
    \\EOT\EOT(\STX\NUL\DC2\EOT\191\ACK\STX\NAK\"8 council or technical committee address (text equality)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT(\STX\NUL\ENQ\DC2\EOT\191\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT(\STX\NUL\SOH\DC2\EOT\191\ACK\t\DLE\n\
    \\r\n\
    \\ENQ\EOT(\STX\NUL\ETX\DC2\EOT\191\ACK\DC3\DC4\n\
    \?\n\
    \\EOT\EOT(\STX\SOH\DC2\EOT\192\ACK\STX\SYN\"1 28 bytes; any asset name of this policy matches\n\
    \\n\
    \\r\n\
    \\ENQ\EOT(\STX\SOH\ENQ\DC2\EOT\192\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT(\STX\SOH\SOH\DC2\EOT\192\ACK\b\DC1\n\
    \\r\n\
    \\ENQ\EOT(\STX\SOH\ETX\DC2\EOT\192\ACK\DC4\NAK\n\
    \7\n\
    \\EOT\EOT(\STX\STX\DC2\EOT\193\ACK\STX\SYN\") created at block_no <= this (inclusive)\n\
    \\n\
    \\r\n\
    \\ENQ\EOT(\STX\STX\ENQ\DC2\EOT\193\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT(\STX\STX\SOH\DC2\EOT\193\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT(\STX\STX\ETX\DC2\EOT\193\ACK\DC4\NAK\n\
    \?\n\
    \\STX\EOT)\DC2\ACK\197\ACK\NUL\204\ACK\SOH\SUB1 Mirrors GovernanceBodyUtxoRow (MF/db/types.rs).\n\
    \\n\
    \\v\n\
    \\ETX\EOT)\SOH\DC2\EOT\197\ACK\b\CAN\n\
    \?\n\
    \\EOT\EOT)\STX\NUL\DC2\EOT\198\ACK\STX\DC2\"1 always set (INNER JOIN); strict DbDatum in Rust\n\
    \\n\
    \\r\n\
    \\ENQ\EOT)\STX\NUL\ACK\DC2\EOT\198\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT)\STX\NUL\SOH\DC2\EOT\198\ACK\b\r\n\
    \\r\n\
    \\ENQ\EOT)\STX\NUL\ETX\DC2\EOT\198\ACK\DLE\DC1\n\
    \\f\n\
    \\EOT\EOT)\STX\SOH\DC2\EOT\199\ACK\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT)\STX\SOH\ENQ\DC2\EOT\199\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT)\STX\SOH\SOH\DC2\EOT\199\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT)\STX\SOH\ETX\DC2\EOT\199\ACK\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT)\STX\STX\DC2\EOT\200\ACK\STX\ETB\n\
    \\r\n\
    \\ENQ\EOT)\STX\STX\ENQ\DC2\EOT\200\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT)\STX\STX\SOH\DC2\EOT\200\ACK\b\DC2\n\
    \\r\n\
    \\ENQ\EOT)\STX\STX\ETX\DC2\EOT\200\ACK\NAK\SYN\n\
    \\f\n\
    \\EOT\EOT)\STX\ETX\DC2\EOT\201\ACK\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT)\STX\ETX\ENQ\DC2\EOT\201\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT)\STX\ETX\SOH\DC2\EOT\201\ACK\t\DC1\n\
    \\r\n\
    \\ENQ\EOT)\STX\ETX\ETX\DC2\EOT\201\ACK\DC4\NAK\n\
    \\f\n\
    \\EOT\EOT)\STX\EOT\DC2\EOT\202\ACK\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT)\STX\EOT\ENQ\DC2\EOT\202\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT)\STX\EOT\SOH\DC2\EOT\202\ACK\b\SI\n\
    \\r\n\
    \\ENQ\EOT)\STX\EOT\ETX\DC2\EOT\202\ACK\DC2\DC3\n\
    \\f\n\
    \\EOT\EOT)\STX\ENQ\DC2\EOT\203\ACK\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT)\STX\ENQ\ENQ\DC2\EOT\203\ACK\STX\b\n\
    \\r\n\
    \\ENQ\EOT)\STX\ENQ\SOH\DC2\EOT\203\ACK\t\DC3\n\
    \\r\n\
    \\ENQ\EOT)\STX\ENQ\ETX\DC2\EOT\203\ACK\SYN\ETB\n\
    \\f\n\
    \\STX\EOT*\DC2\ACK\206\ACK\NUL\208\ACK\SOH\n\
    \\v\n\
    \\ETX\EOT*\SOH\DC2\EOT\206\ACK\b)\n\
    \\f\n\
    \\EOT\EOT*\STX\NUL\DC2\EOT\207\ACK\STX'\n\
    \\r\n\
    \\ENQ\EOT*\STX\NUL\EOT\DC2\EOT\207\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT*\STX\NUL\ACK\DC2\EOT\207\ACK\v\ESC\n\
    \\r\n\
    \\ENQ\EOT*\STX\NUL\SOH\DC2\EOT\207\ACK\FS\"\n\
    \\r\n\
    \\ENQ\EOT*\STX\NUL\ETX\DC2\EOT\207\ACK%&b\ACKproto3"