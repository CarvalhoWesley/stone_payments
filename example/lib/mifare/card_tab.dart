import 'package:flutter/material.dart';
import 'package:stone_payments/stone_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';
import 'mifare_session.dart';

class MifareCardTab extends StatefulWidget {
  const MifareCardTab({super.key});

  @override
  State<MifareCardTab> createState() => _MifareCardTabState();
}

class _MifareCardTabState extends State<MifareCardTab>
    with ActionRunner, AutomaticKeepAliveClientMixin {
  @override
  LogSource get logSource => LogSource.mifare;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Identificador (UID)',
        hint: 'Leia o mesmo cartão várias vezes: o ID precisa se repetir para '
            'servir de identificador no servidor.',
        children: [
          ActionWrap(children: [
            ActionButton(
              label: 'Ler ID do cartão',
              icon: Icons.contactless,
              primary: true,
              onPressed: enabled
                  ? () => run('Ler ID', () async {
                        final id = await MifareSession.readUid();
                        if (context.mounted) {
                          showTextDialog(context, 'ID do cartão', id,
                              fontSize: 22);
                        }
                        return id;
                      })
                  : null,
            ),
          ]),
        ],
      ),
      Section(
        title: 'Diagnóstico',
        hint: 'Lê todos os 16 setores com a chave abaixo. Mantenha o cartão '
            'encostado até terminar.',
        children: [
          const MifareKeyFields(),
          ActionWrap(children: [
            ActionButton(
              label: 'Ler todos os setores',
              icon: Icons.manage_search,
              onPressed: enabled
                  ? () => run('Diagnóstico completo', () async {
                        final report = await MifareSession.diagnoseAllSectors();
                        if (context.mounted) {
                          showTextDialog(context, 'Setores do cartão', report,
                              fontSize: 11);
                        }
                        return '\n$report';
                      })
                  : null,
            ),
          ]),
        ],
      ),
      Section(
        title: 'Espera pelo cartão',
        children: [
          ActionWrap(children: [
            // Sempre ativo: interrompe uma detecção em andamento
            ActionButton(
              label: 'Cancelar detecção',
              icon: Icons.cancel,
              danger: true,
              onPressed: () => run('Cancelar detecção', () async {
                await StonePayments.mifareCancelDetection();
                return null;
              }),
            ),
          ]),
        ],
      ),
    ]);
  }
}
