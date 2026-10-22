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

  bool _showFeedbackScreen = true;

  Future<String?> _print({required bool withImage}) async {
    await StoneDeeplinkPayments.print(
      items: await samplePrintItems(withImage: withImage),
      showFeedbackScreen: _showFeedbackScreen,
    );
    return 'impressão enviada ao app da Stone';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Impressão via deeplink',
        hint: 'O app da Stone faz a impressão. '
            'Imagens grandes podem passar do limite do deeplink.',
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mostrar tela de confirmação'),
            subtitle: const Text(
                'showFeedbackScreen: o app da Stone exibe o resultado da impressão antes de voltar'),
            value: _showFeedbackScreen,
            onChanged: busy
                ? null
                : (value) => setState(() => _showFeedbackScreen = value),
          ),
          const SizedBox(height: 8),
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
