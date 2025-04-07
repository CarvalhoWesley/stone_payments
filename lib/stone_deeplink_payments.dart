import 'dart:async';

import 'package:stone_payments/enums/type_installment_enum.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/models/transaction_deeplink.dart';
import 'package:stone_payments/stone_deeplink_payments_platform_interface.dart';
import 'package:stone_payments/models/transaction.dart';

/// The [StoneDeeplinkPayments] class provides methods to perform
/// payments and refunds using the Stone platform via deeplinks.
///
/// This class validates input parameters and delegates operations
/// to the platform interface [StoneDeeplinkPaymentsPlatform].
class StoneDeeplinkPayments {
  static Stream<TransactionDeeplink> get onTransaction =>
      StoneDeeplinkPaymentsPlatform.onTransaction;

  /// Processes a payment with the provided parameters.
  ///
  /// [amount] is the payment amount and must be greater than zero.
  /// [transactionType] specifies the type of payment (credit or debit).
  /// [orderId] is the transaction identifier and cannot be empty.
  /// [installmentCount] specifies the number of installments (between 1 and 12).
  ///
  /// Returns a [Transaction] object containing transaction details, or
  /// `null` if the transaction fails.
  ///
  /// Throws an exception if:
  /// - [amount] is less than or equal to 0.
  /// - [installmentCount] is less than 1 or greater than 12.
  /// - [orderId] is empty.
  /// - The number of installments is not 1 for debit payment types.
  static Future<void> transaction({
    required double amount,
    required TypeTransactionEnum transactionType,
    required String orderId,
    int installmentCount = 1,
    TypeInstallmentEnum installmentType = TypeInstallmentEnum.none,
  }) async {
    assert(amount > 0, 'The payment amount must be greater than zero');
    assert(orderId.isNotEmpty, 'The client identifier cannot be empty');
    if (transactionType == TypeTransactionEnum.debit) {
      assert(installmentCount == 1,
          'Installments must equal 1 for debit payments');
    }

    try {
      // Delegate the payment process to the platform
      return StoneDeeplinkPaymentsPlatform.instance.transaction(
        amount: amount,
        transactionType: transactionType,
        orderId: orderId,
        installmentCount: installmentCount,
      );
    } catch (e) {
      // Emit the error through the stream
      rethrow;
    }
  }

  /// Processes a refund for a transaction based on the provided parameters.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [atk] is the acquirer transaction key.
  ///
  /// Returns a [Transaction] object containing refund details, or
  /// `null` if the operation fails.
  ///
  /// Throws an exception if:
  /// - [amount] is less than or equal to 0.
  static Future<void> cancel({
    required double amount,
    required String? atk,
  }) async {
    assert(amount > 0, 'The refund amount must be greater than zero');
    assert(atk != null && atk.isNotEmpty, 'The atk is required');

    try {
      // Delegate the refund process to the platform
      return StoneDeeplinkPaymentsPlatform.instance.cancel(
        amount: amount,
        atk: atk,
      );
    } catch (e) {
      // Emit the error through the stream
      rethrow;
    }
  }
}
