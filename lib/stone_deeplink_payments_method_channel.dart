import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stone_payments/enums/type_installment_enum.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/models/transaction.dart';
import 'package:stone_payments/models/transaction_deeplink.dart';

import 'stone_deeplink_payments_platform_interface.dart';

/// The [MethodChannelStoneDeeplinkPayments] class is the default implementation
/// of [StoneDeeplinkPaymentsPlatform], using method channels to communicate
/// with native platform code for handling Stone payments and refunds.
///
/// This implementation manages state to ensure only one operation is
/// processed at a time and handles communication with the native platform
/// via the `MethodChannel`.
class MethodChannelStoneDeeplinkPayments extends StoneDeeplinkPaymentsPlatform {
  static final _controller = StreamController<TransactionDeeplink>.broadcast();
  static Stream<TransactionDeeplink> get onTransaction => _controller.stream;

  /// The [MethodChannel] used to interact with native platform code.
  ///
  /// This channel communicates with the platform using the channel name `stone_payments`.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_payments');

  /// Tracks whether a payment or refund operation is currently in progress.
  bool _transactionInProgress = false;

  /// Creates an instance of [MethodChannelStoneDeeplinkPayments].
  MethodChannelStoneDeeplinkPayments() {
    methodChannel.setMethodCallHandler((call) async {
      _transactionInProgress = false;
      try {
        if (call.method == 'onDeeplinkResponse') {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(call.arguments);
          final tx = TransactionDeeplink.fromMap(data);
          _controller.add(tx);
        }
      } catch (e) {
        rethrow;
      }
    });
  }

  /// Processes a payment request via the native platform.
  ///
  /// [amount] is the payment amount and must be greater than zero.
  /// [transactionType] specifies the type of payment (credit or debit).
  /// [orderId] is the transaction identifier and cannot be empty.
  /// [installmentCount] specifies the number of installments (between 1 and 12).
  /// Returns a [Transaction] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> transaction({
    required double amount,
    required TypeTransactionEnum transactionType,
    required String orderId,
    int installmentCount = 1,
    TypeInstallmentEnum installmentType = TypeInstallmentEnum.none,
  }) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      await methodChannel.invokeMethod(
        'transactionDeeplink',
        <String, dynamic>{
          'amount': amount,
          'transactionType': transactionType.name,
          'orderId': orderId,
          'installmentCount': installmentCount.toString(),
          'installmentType': installmentType.name,
        },
      );
      _transactionInProgress = false;
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }

  /// Processes a refund request via the native platform.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [atk] is the acquirer transaction key.
  ///
  /// Returns a [Transaction] object containing the refund details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> cancel({
    required double amount,
    required String? atk,
  }) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      await methodChannel.invokeMethod(
        'cancelDeeplink',
        <String, dynamic>{
          'amount': amount,
          'atk': atk,
        },
      );
      _transactionInProgress = false;
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }
}
