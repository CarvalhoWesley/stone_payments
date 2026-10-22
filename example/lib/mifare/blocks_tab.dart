import 'package:flutter/material.dart';
import 'package:stone_payments/stone_payments.dart';

import '../core/app_log.dart';
import '../core/ui.dart';
import 'mifare_session.dart';

/// Leitura e gravação genérica de blocos, e operações de bloco de valor.
class MifareBlocksTab extends StatefulWidget {
  const MifareBlocksTab({super.key});

  @override
  State<MifareBlocksTab> createState() => _MifareBlocksTabState();
}

class _MifareBlocksTabState extends State<MifareBlocksTab>
    with ActionRunner, AutomaticKeepAliveClientMixin {
  final _block = TextEditingController(text: '13');
  final _text = TextEditingController(text: 'teste');
  final _targetBlock = TextEditingController(text: '14');
  final _value = TextEditingController(text: '1');

  @override
  LogSource get logSource => LogSource.mifare;

  @override
  bool get wantKeepAlive => true;

  int get _blockNum => int.parse(_block.text);
  int get _targetNum => int.parse(_targetBlock.text);
  int get _valueNum => int.parse(_value.text);

  @override
  void dispose() {
    for (final c in [_block, _text, _targetBlock, _value]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      const Section(
        title: 'Chave do setor',
        children: [MifareKeyFields()],
      ),
      Section(
        title: 'Ler / gravar bloco',
        hint: 'Blocos 0-63. Evite 1-12 (cartão de evento). Bloco 0 e trailers '
            '(3, 7, 11...) não aceitam gravação.',
        children: [
          FieldWrap(children: [
            AppField(
                controller: _block,
                label: 'Bloco (0-63)',
                numeric: true,
                width: 120),
            AppField(
                controller: _text, label: 'Texto (máx. 16 bytes)', width: 200),
          ]),
          ActionWrap(children: [
            ActionButton(
              label: 'Ler texto',
              icon: Icons.text_fields,
              primary: true,
              onPressed: enabled
                  ? () => run(
                      'Ler bloco $_blockNum',
                      () => MifareSession.readBlock(_blockNum)
                          .then((d) => '"${MifareSession.toText(d)}"'))
                  : null,
            ),
            ActionButton(
              label: 'Ler bytes',
              icon: Icons.data_array,
              onPressed: enabled
                  ? () => run(
                      'Ler bloco $_blockNum',
                      () => MifareSession.readBlock(_blockNum)
                          .then(MifareSession.toHex))
                  : null,
            ),
            ActionButton(
              label: 'Gravar texto',
              icon: Icons.edit,
              onPressed: enabled
                  ? () => run('Gravar bloco $_blockNum', () async {
                        final data = await MifareSession.writeText(
                            _blockNum, _text.text);
                        return 'gravado e conferido: "${MifareSession.toText(data)}" '
                            '| ${MifareSession.toHex(data)}';
                      })
                  : null,
            ),
            ActionButton(
              label: 'Diagnóstico do bloco',
              icon: Icons.manage_search,
              onPressed: enabled
                  ? () => run('Diagnóstico bloco $_blockNum', () async {
                        final report =
                            await MifareSession.diagnoseBlock(_blockNum);
                        if (context.mounted) {
                          showTextDialog(context, 'Bloco $_blockNum', report);
                        }
                        return '\n$report';
                      })
                  : null,
            ),
          ]),
        ],
      ),
      Section(
        title: 'Blocos de valor',
        hint: 'Usa o "Bloco" acima como origem; destino no mesmo setor. '
            'O bloco precisa estar no formato de bloco de valor.',
        children: [
          FieldWrap(children: [
            AppField(
                controller: _targetBlock,
                label: 'Bloco destino',
                numeric: true,
                width: 120),
            AppField(
                controller: _value,
                label: 'Valor (0-127)',
                numeric: true,
                width: 120),
          ]),
          ActionWrap(children: [
            ActionButton(
              label: 'Incrementar',
              icon: Icons.add,
              onPressed: enabled
                  ? () => run('Incrementar bloco $_blockNum', () async {
                        await MifareSession.valueOperation(
                            _blockNum,
                            _blockNum,
                            (s, b, _) => StonePayments.mifareIncrementValue(
                                sector: s, block: b, value: _valueNum));
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Decrementar',
              icon: Icons.remove,
              onPressed: enabled
                  ? () => run('Decrementar bloco $_blockNum', () async {
                        await MifareSession.valueOperation(
                            _blockNum,
                            _blockNum,
                            (s, b, _) => StonePayments.mifareDecrementValue(
                                sector: s, block: b, value: _valueNum));
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Backup',
              icon: Icons.copy,
              onPressed: enabled
                  ? () => run('Backup $_blockNum → $_targetNum', () async {
                        await MifareSession.valueOperation(
                            _blockNum,
                            _targetNum,
                            (s, b, t) => StonePayments.mifareBackupBlock(
                                sector: s, srcBlock: b, dstBlock: t));
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Restaurar',
              icon: Icons.restore,
              onPressed: enabled
                  ? () => run('Restaurar $_blockNum → $_targetNum', () async {
                        await MifareSession.valueOperation(
                            _blockNum,
                            _targetNum,
                            (s, b, t) => StonePayments.mifareRestoreBlock(
                                sector: s, srcBlock: b, dstBlock: t));
                        return null;
                      })
                  : null,
            ),
          ]),
        ],
      ),
    ]);
  }
}
