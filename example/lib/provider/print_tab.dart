import 'package:flutter/material.dart';
import 'package:stone_payments/enums/type_owner_print_enum.dart';
import 'package:stone_payments/stone_payments.dart';

import '../core/app_log.dart';
import '../core/print_samples.dart';
import '../core/ui.dart';
import 'provider_store.dart';

class ProviderPrintTab extends StatefulWidget {
  const ProviderPrintTab({super.key});

  @override
  State<ProviderPrintTab> createState() => _ProviderPrintTabState();
}

class _ProviderPrintTabState extends State<ProviderPrintTab> with ActionRunner {
  @override
  LogSource get logSource => LogSource.provider;

  @override
  Widget build(BuildContext context) {
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Impressão livre',
        hint:
            'Imprime texto e imagem pela impressora do terminal (PosPrintProvider).',
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.asset('assets/flutter5786.png', width: 80),
            ),
          ),
          ActionWrap(children: [
            ActionButton(
              label: 'Imprimir texto',
              icon: Icons.text_snippet,
              onPressed: enabled
                  ? () => run('Imprimir texto', () async {
                        await StonePayments.print(
                            await samplePrintItems(withImage: false));
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Imprimir texto + imagem',
              icon: Icons.image,
              primary: true,
              onPressed: enabled
                  ? () => run('Imprimir texto + imagem', () async {
                        await StonePayments.print(await samplePrintItems());
                        return null;
                      })
                  : null,
            ),
          ]),
        ],
      ),
      ValueListenableBuilder(
        valueListenable: ProviderStore.hasReceipt,
        builder: (context, hasReceipt, _) => Section(
          title: 'Comprovante da última transação',
          hint: hasReceipt
              ? 'Reimprime a via da última transação feita pelo Provider.'
              : 'Disponível depois de uma transação aprovada.',
          children: [
            ActionWrap(children: [
              ActionButton(
                label: 'Via do cliente',
                icon: Icons.person,
                onPressed: enabled && hasReceipt
                    ? () => run(
                        'Via do cliente',
                        () => StonePayments.printReceipt(
                            TypeOwnerPrintEnum.client))
                    : null,
              ),
              ActionButton(
                label: 'Via do estabelecimento',
                icon: Icons.store,
                onPressed: enabled && hasReceipt
                    ? () => run(
                        'Via do estabelecimento',
                        () => StonePayments.printReceipt(
                            TypeOwnerPrintEnum.merchant))
                    : null,
              ),
            ]),
          ],
        ),
      ),
    ]);
  }
}
