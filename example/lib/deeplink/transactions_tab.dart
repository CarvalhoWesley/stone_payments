import 'package:flutter/material.dart';
import 'package:stone_payments/models/transaction_deeplink.dart';
import 'package:stone_payments/stone_deeplink_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';
import 'deeplink_store.dart';

class DeeplinkTransactionsTab extends StatefulWidget {
  const DeeplinkTransactionsTab({super.key});

  @override
  State<DeeplinkTransactionsTab> createState() =>
      _DeeplinkTransactionsTabState();
}

class _DeeplinkTransactionsTabState extends State<DeeplinkTransactionsTab>
    with ActionRunner {
  @override
  LogSource get logSource => LogSource.deeplink;

  Future<String?> _cancel(TransactionDeeplink t) async {
    await StoneDeeplinkPayments.cancel(
      amount: DeeplinkStore.amountToDouble(t.amount),
      atk: t.atk,
    );
    DeeplinkStore.remove(t);
    return 'app da Stone aberto para o cancelamento';
  }

  @override
  Widget build(BuildContext context) {
    return ActionPage(busy: busy, children: [
      ValueListenableBuilder(
        valueListenable: DeeplinkStore.transactions,
        builder: (context, transactions, _) => Section(
          title: 'Transações aprovadas',
          hint: transactions.isEmpty
              ? 'Nenhuma transação nesta sessão. Faça um pagamento na aba Pagamento.'
              : 'Cancelar abre o app da Stone para estornar a transação.',
          children: [
            for (final t in transactions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt),
                title: Text(
                    'R\$ ${DeeplinkStore.amountToDouble(t.amount).toStringAsFixed(2)} · ${t.type ?? ''}'),
                subtitle: Text('${t.brand ?? ''} · ATK ${t.atk ?? '-'}'),
                trailing: IconButton(
                  tooltip: 'Cancelar transação',
                  icon: const Icon(Icons.undo),
                  onPressed: busy
                      ? null
                      : () async {
                          if (await confirm(
                              context, 'Cancelar a transação ${t.atk}?')) {
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
