import 'dart:async';

import 'package:flutter/foundation.dart';
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
  static StreamSubscription<TransactionDeeplink> Function(
    ValueChanged<TransactionDeeplink>?, {
    bool? cancelOnError,
    VoidCallback? onDone,
    Function? onError,
  }) get onTransactionListener =>
      StoneDeeplinkPaymentsPlatform.onTransaction.listen;

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
    TypeTransactionEnum? transactionType,
    String? orderId,
    int? installmentCount,
    TypeInstallmentEnum? installmentType,
    String? returnSchema,
  }) async {
    try {
      assert(amount > 0, 'Amount must be greater than 0.');

      // Delegate the payment process to the platform
      return StoneDeeplinkPaymentsPlatform.instance.transaction(
        amount: amount,
        transactionType: transactionType,
        orderId: orderId,
        installmentCount: installmentCount,
        installmentType: installmentType,
        returnSchema: returnSchema,
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
    double? amount,
    String? atk,
    String? returnSchema,
  }) async {
    try {
      // Delegate the refund process to the platform
      return StoneDeeplinkPaymentsPlatform.instance.cancel(
        amount: amount,
        atk: atk,
        returnSchema: returnSchema,
      );
    } catch (e) {
      // Emit the error through the stream
      rethrow;
    }
  }
}
