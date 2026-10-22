import 'package:flutter/foundation.dart';
import 'package:stone_payments/models/transaction.dart';

/// Estado compartilhado entre as abas do Provider.
class ProviderStore {
  ProviderStore._();

  /// Transações aprovadas nesta sessão.
  static final transactions = ValueNotifier<List<Transaction>>([]);

  /// QR Code do último PIX gerado.
  static final pixQrCode = ValueNotifier<Uint8List?>(null);

  /// Indica se há uma transação para imprimir o comprovante.
  static final hasReceipt = ValueNotifier<bool>(false);

  static void addTransaction(Transaction t) {
    transactions.value = [t, ...transactions.value];
    hasReceipt.value = true;
  }

  static void removeTransaction(Transaction t) {
    transactions.value = transactions.value.where((e) => e != t).toList();
  }
}
