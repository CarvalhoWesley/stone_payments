import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stone_payments/enums/mifare_key_type_enum.dart';
import 'package:stone_payments/enums/status_transaction_enum.dart';
import 'package:stone_payments/enums/type_owner_print_enum.dart';
import 'package:stone_payments/models/mifare_card.dart';
import 'package:stone_payments/models/transaction.dart';

import 'enums/type_transaction_enum.dart';
import 'models/item_print_model.dart';
import 'stone_payments_platform_interface.dart';

/// An implementation of [StonePaymentsPlatform] that uses method channels.
class MethodChannelStonePayments extends StonePaymentsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_payments');

  final _paymentController = StreamController<String>.broadcast();

  bool _transactionInProgress = false;

  ValueChanged<String>? _currentOnPixQrCode;

  @override
  Stream<String> get onMessage => _paymentController.stream;

  /// Constructor and method channel initialization
  MethodChannelStonePayments() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'message':
          _paymentController
              .add(StatusTransactionEnum.fromName(call.arguments));
          break;
        case 'pixQrCode':
          _currentOnPixQrCode?.call(call.arguments);
          break;
        default:
          _paymentController.add(call.arguments);
          break;
      }
    });
  }

  @override
  Future<String?> payment({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
  }) async {
    final result = await methodChannel.invokeMethod<String>(
      'payment',
      <String, dynamic>{
        'value': value,
        'typeTransaction': typeTransaction.value,
        'installment': installment,
        'printReceipt': printReceipt,
      },
    );

    return result;
  }

  @override
  Future<Transaction?> transaction({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
    ValueChanged<String>? onPixQrCode,
  }) async {
    try {
      if (_transactionInProgress) {
        return null;
      }

      _transactionInProgress = true;

      _currentOnPixQrCode = onPixQrCode;

      final result = await methodChannel.invokeMethod<String>(
        'transaction',
        <String, dynamic>{
          'value': value,
          'typeTransaction': typeTransaction.value,
          'installment': installment,
          'printReceipt': printReceipt,
        },
      );

      if (result == null) {
        return null;
      }

      _transactionInProgress = false;

      return Transaction.fromJson(result);
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }

  @override
  Future<String?> activateStone({
    required String appName,
    required String stoneCode,
    String? qrCodeProviderId,
    String? qrCodeAuthorization,
  }) async {
    final result = await methodChannel.invokeMethod<String>(
      'activateStone',
      <String, dynamic>{
        'appName': appName,
        'stoneCode': stoneCode,
        'qrCodeProviderId': qrCodeProviderId,
        'qrCodeAuthorization': qrCodeAuthorization,
      },
    );

    return result;
  }

  @override
  Future<String?> print(List<ItemPrintModel> items) async {
    final result = await methodChannel.invokeMethod<String>(
      'print',
      <String, dynamic>{
        'items':
            items.map<Map<String, dynamic>>((item) => item.toMap()).toList(),
      },
    );

    return result;
  }

  @override
  Future<String?> printReceipt(TypeOwnerPrintEnum type) async {
    final result = await methodChannel.invokeMethod<String>(
      'printReceipt',
      <String, dynamic>{
        'type': type.value,
      },
    );

    return result;
  }

  @override
  Future<String?> abortPayment() async {
    final result = await methodChannel.invokeMethod<String>('abortPayment');

    return result;
  }

  @override
  Future<Transaction?> cancelPayment({
    required String initiatorTransactionKey,
    bool? printReceipt,
  }) async {
    if (_transactionInProgress) {
      return null;
    }

    _transactionInProgress = true;

    final result = await methodChannel.invokeMethod<String>(
      'cancelPayment',
      <String, dynamic>{
        'initiatorTransactionKey': initiatorTransactionKey,
        'printReceipt': printReceipt,
      },
    );
    if (result == null) {
      return null;
    }

    _transactionInProgress = false;

    return Transaction.fromJson(result);
  }

  // @override
  // Future<Transaction?> cancelPaymentWithATK({
  //   required String acquirerTransactionKey,
  //   bool? printReceipt,
  // }) async {
  //   if (_transactionInProgress) {
  //     return null;
  //   }

  //   _transactionInProgress = true;

  //   final result = await methodChannel.invokeMethod<String>(
  //     'cancelPaymentWithATK',
  //     <String, dynamic>{
  //       'acquirerTransactionKey': acquirerTransactionKey,
  //       'printReceipt': printReceipt,
  //     },
  //   );
  //   if (result == null) {
  //     return null;
  //   }

  //   _transactionInProgress = false;

  //   return Transaction.fromJson(result);
  // }

  @override
  Future<Transaction?> cancelPaymentWithAuthorizationCode({
    required String authorizationCode,
    bool? printReceipt,
  }) async {
    if (_transactionInProgress) {
      return null;
    }

    _transactionInProgress = true;

    final result = await methodChannel.invokeMethod<String>(
      'cancelPaymentWithAuthorizationCode',
      <String, dynamic>{
        'authorizationCode': authorizationCode,
        'printReceipt': printReceipt,
      },
    );
    if (result == null) {
      return null;
    }

    _transactionInProgress = false;

    return Transaction.fromJson(result);
  }

  @override
  Future<MifareCard?> mifareDetectCard() async {
    final result = await methodChannel.invokeMethod<Map>('mifareDetectCard');
    if (result == null) {
      return null;
    }

    return MifareCard.fromMap(result);
  }

  @override
  Future<void> mifareAuthenticateSector({
    required MifareKeyTypeEnum keyType,
    required Uint8List key,
    required int sector,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareAuthenticateSector',
      <String, dynamic>{
        'keyType': keyType.value,
        'key': key,
        'sector': sector,
      },
    );
  }

  @override
  Future<Uint8List?> mifareReadBlock({
    required int sector,
    required int block,
  }) async {
    return methodChannel.invokeMethod<Uint8List>(
      'mifareReadBlock',
      <String, dynamic>{
        'sector': sector,
        'block': block,
      },
    );
  }

  @override
  Future<void> mifareWriteBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareWriteBlock',
      <String, dynamic>{
        'sector': sector,
        'block': block,
        'data': data,
      },
    );
  }

  @override
  Future<void> mifareBackupBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareBackupBlock',
      <String, dynamic>{
        'sector': sector,
        'srcBlock': srcBlock,
        'dstBlock': dstBlock,
      },
    );
  }

  @override
  Future<void> mifareRestoreBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareRestoreBlock',
      <String, dynamic>{
        'sector': sector,
        'srcBlock': srcBlock,
        'dstBlock': dstBlock,
      },
    );
  }

  @override
  Future<void> mifareIncrementValue({
    required int sector,
    required int block,
    required int value,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareIncrementValue',
      <String, dynamic>{
        'sector': sector,
        'block': block,
        'value': value,
      },
    );
  }

  @override
  Future<void> mifareDecrementValue({
    required int sector,
    required int block,
    required int value,
  }) async {
    await methodChannel.invokeMethod<bool>(
      'mifareDecrementValue',
      <String, dynamic>{
        'sector': sector,
        'block': block,
        'value': value,
      },
    );
  }

  @override
  Future<void> mifarePowerOff() async {
    await methodChannel.invokeMethod<bool>('mifarePowerOff');
  }

  @override
  Future<void> mifareCancelDetection() async {
    await methodChannel.invokeMethod<bool>('mifareCancelDetection');
  }
}
