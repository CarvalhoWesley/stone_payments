import 'package:flutter/material.dart';
import 'package:stone_payments/enums/type_installment_enum.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/stone_deeplink_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';

class DeeplinkPaymentTab extends StatefulWidget {
  const DeeplinkPaymentTab({super.key});

  @override
  State<DeeplinkPaymentTab> createState() => _DeeplinkPaymentTabState();
}

class _DeeplinkPaymentTabState extends State<DeeplinkPaymentTab>
    with ActionRunner, AutomaticKeepAliveClientMixin {
  final _value = TextEditingController(text: '10.50');

  @override
  LogSource get logSource => LogSource.deeplink;

  @override
  bool get wantKeepAlive => true;

  Future<String?> _pay(TypeTransactionEnum type, {int installments = 1}) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    await StoneDeeplinkPayments.transaction(
      amount: parseAmount(_value.text),
      transactionType: type,
      installmentCount: installments,
      installmentType: installments > 1 ? TypeInstallmentEnum.merchant : null,
      orderId: orderId,
    );
    return 'app da Stone aberto (pedido $orderId). O resultado chega na aba Logs.';
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Nova transação',
        hint:
            'Abre o app de pagamento da Stone. Ao terminar, o resultado volta '
            'para este app e aparece em Transações e na aba Logs.',
        children: [
          FieldWrap(children: [
            AppField(controller: _value, label: 'Valor (R\$)', numeric: true),
          ]),
          ActionWrap(children: [
            ActionButton(
              label: 'Crédito',
              icon: Icons.credit_card,
              primary: true,
              onPressed: enabled
                  ? () => run('Crédito', () => _pay(TypeTransactionEnum.credit))
                  : null,
            ),
            ActionButton(
              label: 'Crédito 2x',
              icon: Icons.credit_card,
              onPressed: enabled
                  ? () => run('Crédito 2x',
                      () => _pay(TypeTransactionEnum.credit, installments: 2))
                  : null,
            ),
            ActionButton(
              label: 'Débito',
              icon: Icons.payment,
              onPressed: enabled
                  ? () => run('Débito', () => _pay(TypeTransactionEnum.debit))
                  : null,
            ),
            ActionButton(
              label: 'PIX',
              icon: Icons.qr_code,
              onPressed: enabled
                  ? () => run('PIX', () => _pay(TypeTransactionEnum.pix))
                  : null,
            ),
          ]),
        ],
      ),
    ]);
  }
}
