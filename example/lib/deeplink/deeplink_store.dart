import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stone_payments/models/transaction_deeplink.dart';
import 'package:stone_payments/stone_deeplink_payments.dart';

import '../core/app_log.dart';

/// Estado compartilhado entre as abas do Deeplink.
///
/// O resultado de pagamentos e cancelamentos volta de forma assíncrona,
/// quando o app da Stone devolve o controle; por isso fica num listener global.
class DeeplinkStore {
  DeeplinkStore._();

  static final transactions = ValueNotifier<List<TransactionDeeplink>>([]);

  static StreamSubscription<TransactionDeeplink>? _subscription;

  static void listen() {
    _subscription ??= StoneDeeplinkPayments.onTransactionListener((t) {
      if (t.success ?? false) {
        transactions.value = [t, ...transactions.value];
        AppLog.add(LogSource.deeplink,
            'Retorno OK: ${t.type ?? ''} R\$ ${amountToDouble(t.amount).toStringAsFixed(2)} | ATK ${t.atk}');
      } else {
        AppLog.add(LogSource.deeplink, 'Retorno com falha: ${t.code ?? ''}',
            isError: true);
      }
    }, onError: (Object e) {
      AppLog.add(LogSource.deeplink, 'Erro no retorno: $e', isError: true);
    });
  }

  static void remove(TransactionDeeplink t) {
    transactions.value = transactions.value.where((e) => e != t).toList();
  }

  /// O deeplink devolve o valor em centavos (ex.: "1050" = R$ 10,50).
  static double amountToDouble(String? amount) =>
      (double.tryParse(amount ?? '') ?? 0) / 100;
}
