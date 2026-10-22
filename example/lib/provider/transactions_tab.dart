import 'package:flutter/material.dart';
import 'package:stone_payments/models/transaction.dart';
import 'package:stone_payments/stone_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';
import 'provider_store.dart';

class ProviderTransactionsTab extends StatefulWidget {
  const ProviderTransactionsTab({super.key});

  @override
  State<ProviderTransactionsTab> createState() =>
      _ProviderTransactionsTabState();
}

class _ProviderTransactionsTabState extends State<ProviderTransactionsTab>
    with ActionRunner {
  @override
  LogSource get logSource => LogSource.provider;

  Future<String?> _cancel(Transaction t) async {
    final result = await StonePayments.cancelPayment(
      initiatorTransactionKey: t.initiatorTransactionKey ?? '',
      printReceipt: true,
    );
    if (result?.transactionStatus == 'CANCELLED') {
      ProviderStore.removeTransaction(t);
    }
    return result?.transactionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return ActionPage(busy: busy, children: [
      ValueListenableBuilder(
        valueListenable: ProviderStore.transactions,
        builder: (context, transactions, _) => Section(
          title: 'Transações aprovadas',
          hint: transactions.isEmpty
              ? 'Nenhuma transação nesta sessão. Faça um pagamento na aba Pagamento.'
              : 'Cancelar estorna a transação e imprime o comprovante.',
          children: [
            for (final t in transactions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt),
                title: Text(
                    'R\$ ${t.amount ?? '-'} · ${t.typeOfTransactionEnum ?? ''}'),
                subtitle: Text(
                    '${t.cardBrandName ?? ''} · ITK ${t.initiatorTransactionKey ?? '-'}'),
                trailing: IconButton(
                  tooltip: 'Cancelar transação',
                  icon: const Icon(Icons.undo),
                  onPressed: busy
                      ? null
                      : () async {
                          if (await confirm(context,
                              'Cancelar a transação ${t.initiatorTransactionKey}?')) {
                            run('Cancelar transação', () => _cancel(t));
                          }
                        },
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}
