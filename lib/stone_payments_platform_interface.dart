import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:stone_payments/enums/mifare_key_type_enum.dart';
import 'package:stone_payments/enums/type_owner_print_enum.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/models/item_print_model.dart';
import 'package:stone_payments/models/mifare_card.dart';
import 'package:stone_payments/models/transaction.dart';

import 'stone_payments_method_channel.dart';

/// The interface that implementations of stone_payments must implement.
abstract class StonePaymentsPlatform extends PlatformInterface {
  /// Constructs a StonePaymentsPlatform.
  StonePaymentsPlatform() : super(token: _token);

  static final Object _token = Object();

  static StonePaymentsPlatform _instance = MethodChannelStonePayments();

  /// The default instance of [StonePaymentsPlatform] to use.
  ///
  /// Defaults to [MethodChannelStonePayments].
  static StonePaymentsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StonePaymentsPlatform] when
  /// they register themselves.
  static set instance(StonePaymentsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream of messages
  Stream<String> get onMessage;

  /// Payment
  Future<String?> payment({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
  }) {
    throw UnimplementedError('payment() has not been implemented.');
  }

  /// Transaction
  Future<Transaction?> transaction({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
    ValueChanged<String>? onPixQrCode,
  }) {
    throw UnimplementedError('payment() has not been implemented.');
  }

  /// Activate Stone
  Future<String?> activateStone({
    required String appName,
    required String stoneCode,
    String? qrCodeProviderId,
    String? qrCodeAuthorization,
  }) {
    throw UnimplementedError('activateStone() has not been implemented.');
  }

  /// Print
  Future<String?> print(List<ItemPrintModel> items) {
    throw UnimplementedError('print() has not been implemented.');
  }

  /// Print Receipt
  Future<String?> printReceipt(TypeOwnerPrintEnum type) {
    throw UnimplementedError('printReceipt() has not been implemented.');
  }

  /// Abort
  Future<String?> abortPayment() {
    throw UnimplementedError('abortPayment() has not been implemented.');
  }

  /// Cancel Payment with ITK (Initiator Transaction Key)
  Future<Transaction?> cancelPayment({
    required String initiatorTransactionKey,
    bool? printReceipt,
  }) {
    throw UnimplementedError('cancelPayment() has not been implemented.');
  }

  // /// Cancel Payment with ATK (Acquirer Transaction Key)
  // Future<Transaction?> cancelPaymentWithATK({
  //   required String acquirerTransactionKey,
  //   bool? printReceipt,
  // }) {
  //   throw UnimplementedError('cancelPaymentWithATK() has not been implemented.');
  // }

  /// Cancel Payment with Authorization Code
  Future<Transaction?> cancelPaymentWithAuthorizationCode({
    required String authorizationCode,
    bool? printReceipt,
  }) {
    throw UnimplementedError(
        'cancelPaymentWithAuthorizationCode() has not been implemented.');
  }

  /// Mifare - Detect card
  Future<MifareCard?> mifareDetectCard() {
    throw UnimplementedError('mifareDetectCard() has not been implemented.');
  }

  /// Mifare - Authenticate sector
  Future<void> mifareAuthenticateSector({
    required MifareKeyTypeEnum keyType,
    required Uint8List key,
    required int sector,
  }) {
    throw UnimplementedError(
        'mifareAuthenticateSector() has not been implemented.');
  }

  /// Mifare - Read block
  Future<Uint8List?> mifareReadBlock({
    required int sector,
    required int block,
  }) {
    throw UnimplementedError('mifareReadBlock() has not been implemented.');
  }

  /// Mifare - Write block
  Future<void> mifareWriteBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) {
    throw UnimplementedError('mifareWriteBlock() has not been implemented.');
  }

  /// Mifare - Backup value block
  Future<void> mifareBackupBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) {
    throw UnimplementedError('mifareBackupBlock() has not been implemented.');
  }

  /// Mifare - Restore value block
  Future<void> mifareRestoreBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) {
    throw UnimplementedError('mifareRestoreBlock() has not been implemented.');
  }

  /// Mifare - Increment value block
  Future<void> mifareIncrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    throw UnimplementedError(
        'mifareIncrementValue() has not been implemented.');
  }

  /// Mifare - Decrement value block
  Future<void> mifareDecrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    throw UnimplementedError(
        'mifareDecrementValue() has not been implemented.');
  }

  /// Mifare - Power off card
  Future<void> mifarePowerOff() {
    throw UnimplementedError('mifarePowerOff() has not been implemented.');
  }

  /// Mifare - Cancel detection
  Future<void> mifareCancelDetection() {
    throw UnimplementedError(
        'mifareCancelDetection() has not been implemented.');
  }
}
