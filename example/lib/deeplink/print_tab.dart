import 'package:flutter/material.dart';
import 'package:stone_payments/stone_deeplink_payments.dart';

import '../core/app_log.dart';
import '../core/print_samples.dart';
import '../core/ui.dart';

class DeeplinkPrintTab extends StatefulWidget {
  const DeeplinkPrintTab({super.key});

  @override
  State<DeeplinkPrintTab> createState() => _DeeplinkPrintTabState();
}

class _DeeplinkPrintTabState extends State<DeeplinkPrintTab> with ActionRunner {
  @override
  LogSource get logSource => LogSource.deeplink;

  Future<String?> _print({required bool withImage}) async {
    await StoneDeeplinkPayments.print(
        items: await samplePrintItems(withImage: withImage));
    return 'impressão enviada ao app da Stone';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Impressão via deeplink',
        hint: 'O app da Stone faz a impressão e mostra a tela de confirmação. '
            'Imagens grandes podem passar do limite do deeplink.',
        children: [
          ActionWrap(children: [
            ActionButton(
              label: 'Imprimir texto',
              icon: Icons.text_snippet,
              primary: true,
              onPressed: enabled
                  ? () => run('Imprimir texto (deeplink)',
                      () => _print(withImage: false))
                  : null,
            ),
            ActionButton(
              label: 'Imprimir texto + imagem',
              icon: Icons.image,
              onPressed: enabled
                  ? () => run('Imprimir texto + imagem (deeplink)',
                      () => _print(withImage: true))
                  : null,
            ),
          ]),
        ],
      ),
    ]);
  }
}
