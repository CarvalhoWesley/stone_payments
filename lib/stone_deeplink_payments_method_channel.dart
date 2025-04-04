import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/models/transaction.dart';

import 'stone_deeplink_payments_platform_interface.dart';

/// The [MethodChannelStoneDeeplinkPayments] class is the default implementation
/// of [StoneDeeplinkPaymentsPlatform], using method channels to communicate
/// with native platform code for handling Stone payments and refunds.
///
/// This implementation manages state to ensure only one operation is
/// processed at a time and handles communication with the native platform
/// via the `MethodChannel`.
class MethodChannelStoneDeeplinkPayments extends StoneDeeplinkPaymentsPlatform {
  /// The [MethodChannel] used to interact with native platform code.
  ///
  /// This channel communicates with the platform using the channel name `stone_payments`.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_payments');

  /// Tracks whether a payment or refund operation is currently in progress.
  bool _transactionInProgress = false;

  /// Processes a payment request via the native platform.
  ///
  /// [amount] is the payment amount and must be greater than zero.
  /// [transactionType] specifies the type of payment (credit or debit).
  /// [callerId] is the transaction identifier and cannot be empty.
  /// [installmentCount] specifies the number of installments (between 1 and 12).
  /// [creditType] (optional) specifies the credit type for credit payments (creditMerchant or creditIssuer).
  /// Returns a [Transaction] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<Transaction?> transaction({
    required double amount,
    required TypeTransactionEnum transactionType,
    required String orderId,
    int installmentCount = 1,
  }) async {
    try {
      if (_transactionInProgress) {
        return null;
      }

      _transactionInProgress = true;

      final result = await methodChannel.invokeMethod<String>(
        'transactionDeeplink',
        <String, dynamic>{
          'amount': amount,
          'transactionType': transactionType.name,
          'orderId': orderId,
          'installmentCount': installmentCount,
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

  /// Processes a refund request via the native platform.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [transactionDate] (optional) specifies the date of the original transaction,
  /// formatted as `dd/MM/yy`.
  /// [cvNumber] (optional) is the control number of the transaction (CV).
  /// [originTerminal] (optional) identifies the origin terminal.
  ///
  /// Returns a [Transaction] object containing the refund details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<Transaction?> cancel({
    required double amount,
    DateTime? transactionDate,
    String? cvNumber,
    String? originTerminal,
  }) async {
    try {
      if (_transactionInProgress) {
        return null;
      }

      _transactionInProgress = true;

      final result = await methodChannel.invokeMethod<String>(
        'refundDeeplink',
        <String, dynamic>{
          'amount': amount,
          'cvNumber': cvNumber,
          'originTerminal': originTerminal,
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
}
