import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/stone_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';
import 'provider_store.dart';

class ProviderPaymentTab extends StatefulWidget {
  const ProviderPaymentTab({super.key});

  @override
  State<ProviderPaymentTab> createState() => _ProviderPaymentTabState();
}

class _ProviderPaymentTabState extends State<ProviderPaymentTab>
    with ActionRunner, AutomaticKeepAliveClientMixin {
  final _value = TextEditingController(text: '10.50');

  @override
  LogSource get logSource => LogSource.provider;

  @override
  bool get wantKeepAlive => true;

  Future<String?> _pay(TypeTransactionEnum type, {int installment = 1}) async {
    ProviderStore.pixQrCode.value = null;
    final result = await StonePayments.transaction(
      value: parseAmount(_value.text),
      typeTransaction: type,
      installment: installment,
      printReceipt: true,
      onPixQrCode: (qrCode) {
        ProviderStore.pixQrCode.value =
            base64Decode(qrCode.replaceAll('\n', ''));
        AppLog.add(LogSource.provider, 'QR Code PIX recebido');
      },
    );
    if (result == null) return 'sem retorno (transação já em andamento?)';
    if (result.transactionStatus == 'APPROVED') {
      ProviderStore.addTransaction(result);
    }
    return '${result.transactionStatus} | ITK ${result.initiatorTransactionKey}';
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
        hint: 'O pagamento roda no próprio app pelo SDK da Stone. '
            'Mensagens de status do SDK aparecem na aba Logs.',
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
                      () => _pay(TypeTransactionEnum.credit, installment: 2))
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
      Section(
        title: 'Transação em andamento',
        children: [
          ActionWrap(children: [
            // Sempre ativo: serve justamente para interromper a transação em curso
            ActionButton(
              label: 'Abortar transação',
              icon: Icons.cancel,
              danger: true,
              onPressed: () =>
                  run('Abortar', () => StonePayments.abortPayment()),
            ),
          ]),
        ],
      ),
      ValueListenableBuilder(
        valueListenable: ProviderStore.pixQrCode,
        builder: (context, qrCode, _) => qrCode == null
            ? const SizedBox.shrink()
            : Section(
                title: 'QR Code PIX',
                children: [Center(child: Image.memory(qrCode, height: 200))],
              ),
      ),
    ]);
  }
}
