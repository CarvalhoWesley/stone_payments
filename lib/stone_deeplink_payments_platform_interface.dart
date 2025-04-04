import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/stone_deeplink_payments_method_channel.dart';
import 'package:stone_payments/models/transaction.dart';

/// The [StoneDeeplinkPaymentsPlatform] abstract class defines the contract
/// for platform-specific implementations of Stone deeplink payments.
///
/// This class acts as an interface, delegating calls to a specific platform
/// implementation. By default, the [MethodChannelStoneDeeplinkPayments]
/// implementation is used.
///
/// Developers can override the platform implementation by setting
/// [StoneDeeplinkPaymentsPlatform.instance] to a custom implementation.
abstract class StoneDeeplinkPaymentsPlatform {
  /// The current instance of [StoneDeeplinkPaymentsPlatform].
  ///
  /// By default, this is set to [MethodChannelStoneDeeplinkPayments].
  static StoneDeeplinkPaymentsPlatform _instance =
      MethodChannelStoneDeeplinkPayments();

  /// Gets the current platform-specific implementation instance.
  static StoneDeeplinkPaymentsPlatform get instance => _instance;

  /// Sets the platform-specific implementation instance.
  ///
  /// This allows for custom implementations, such as mocks for testing.
  ///
  /// Example:
  /// ```dart
  /// StoneDeeplinkPaymentsPlatform.instance = MockStoneDeeplinkPaymentsPlatform();
  /// ```
  static set instance(StoneDeeplinkPaymentsPlatform instance) {
    _instance = instance;
  }

  /// Processes a payment with the provided parameters.
  ///
  /// [amount] is the payment amount and must be greater than zero.
  /// [transactionType] specifies the type of payment (credit, debit, voucher or pix).
  /// [orderId] is the transaction identifier and cannot be empty.
  /// [installmentCount] specifies the number of installments.
  /// [creditType] (optional) specifies the credit type for credit payments (creditMerchant or creditIssuer).
  /// Returns a [Transaction] object containing transaction details, or
  /// `null` if the transaction fails.
  ///
  /// This method must be implemented by a platform-specific class.
  Future<Transaction?> transaction({
    required double amount,
    required TypeTransactionEnum transactionType,
    required String orderId,
    int installmentCount,
  });

  /// Processes a refund for a transaction with the provided parameters.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [transactionDate] (optional) specifies the date of the original transaction.
  /// [cvNumber] (optional) is the control number of the transaction (CV).
  /// [originTerminal] (optional) identifies the origin terminal.
  ///
  /// Returns a [Transaction] object containing refund details, or
  /// `null` if the operation fails.
  ///
  /// This method must be implemented by a platform-specific class.
  Future<Transaction?> cancel({
    required double amount,
    DateTime? transactionDate,
    String? cvNumber,
    String? originTerminal,
  });
}
