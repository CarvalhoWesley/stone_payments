import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_payments/enums/mifare_key_type_enum.dart';
import 'package:stone_payments/stone_payments.dart';

/// Chave usada para autenticar os setores, compartilhada entre as abas Cartão e Blocos.
class MifareKeyConfig {
  MifareKeyConfig._();

  static final key = TextEditingController(text: 'FFFFFFFFFFFF');
  static final keyType = ValueNotifier(MifareKeyTypeEnum.typeA);

  static Uint8List parseKey() {
    final hex = key.text.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (hex.isEmpty) return Uint8List.fromList(List.filled(6, 0xFF));
    if (hex.length != 12) {
      throw 'A chave deve ter 6 bytes (12 caracteres hex)';
    }
    return Uint8List.fromList(List.generate(
        6, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }
}

/// Operações de baixo nível sobre o Mifare Classic 1K (16 setores x 4 blocos).
/// Os blocos são numerados de 0 a 63 e convertidos para setor + bloco relativo.
class MifareSession {
  MifareSession._();

  static int sectorOf(int block) => block ~/ 4;
  static int relativeOf(int block) => block % 4;

  static String toHex(Uint8List data) => data
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');

  static String toText(Uint8List data) =>
      utf8.decode(data.where((b) => b != 0).toList(), allowMalformed: true);

  static Future<void> _auth(int sector) =>
      StonePayments.mifareAuthenticateSector(
        keyType: MifareKeyConfig.keyType.value,
        key: MifareKeyConfig.parseKey(),
        sector: sector,
      );

  /// Detecta o cartão, autentica o setor do [block], executa [action] e desliga o cartão.
  static Future<T> withCard<T>(int block, Future<T> Function() action) async {
    MifareKeyConfig.parseKey(); // valida a chave antes de esperar o cartão
    await StonePayments.mifareDetectCard();
    try {
      await _auth(sectorOf(block));
      return await action();
    } finally {
      await StonePayments.mifarePowerOff();
    }
  }

  static Future<String> readUid() async {
    try {
      final card = await StonePayments.mifareDetectCard();
      return card?.uuidHex ?? '';
    } finally {
      await StonePayments.mifarePowerOff();
    }
  }

  static Future<Uint8List> readBlock(int block) => withCard(block, () async {
        return await StonePayments.mifareReadBlock(
              sector: sectorOf(block),
              block: relativeOf(block),
            ) ??
            Uint8List(0);
      });

  static Future<void> writeText(int block, String text) {
    final bytes = utf8.encode(text);
    if (bytes.length > 16) throw 'O texto deve ter no máximo 16 bytes';
    return withCard(
      block,
      () => StonePayments.mifareWriteBlock(
        sector: sectorOf(block),
        block: relativeOf(block),
        data: Uint8List(16)..setAll(0, bytes),
      ),
    );
  }

  /// Executa uma operação de bloco de valor; origem e destino no mesmo setor.
  static Future<void> valueOperation(int block, int targetBlock,
      Future<void> Function(int sector, int relative, int targetRelative) op) {
    if (sectorOf(block) != sectorOf(targetBlock)) {
      throw 'Origem e destino precisam estar no mesmo setor';
    }
    return withCard(block,
        () => op(sectorOf(block), relativeOf(block), relativeOf(targetBlock)));
  }

  static Future<String> diagnoseBlock(int block) async {
    final report = StringBuffer();
    final card = await StonePayments.mifareDetectCard();
    report.writeln('UID: ${card?.uuidHex}');
    report.writeln(
        'Bloco $block = setor ${sectorOf(block)}, bloco ${relativeOf(block)}');
    try {
      await _auth(sectorOf(block));
      report.writeln('Autenticação: OK');
      final data = await StonePayments.mifareReadBlock(
          sector: sectorOf(block), block: relativeOf(block));
      final bytes = data ?? Uint8List(0);
      report.writeln('Hex:   ${toHex(bytes)}');
      report.writeln('Texto: "${toText(bytes)}"');
    } on PlatformException catch (e) {
      report.writeln('Falhou: [${e.code}] ${e.message}');
    } finally {
      await StonePayments.mifarePowerOff();
    }
    return report.toString();
  }

  /// Lê os 16 setores numa única aproximação. Uma autenticação que falha
  /// derruba a sessão do cartão, então ele é detectado de novo antes do próximo setor.
  static Future<String> diagnoseAllSectors() async {
    MifareKeyConfig.parseKey();
    final report = StringBuffer();
    var detected = false;
    try {
      for (var sector = 0; sector < 16; sector++) {
        if (!detected) {
          final card = await StonePayments.mifareDetectCard();
          if (sector == 0) report.writeln('UID: ${card?.uuidHex}\n');
          detected = true;
        }
        report.writeln('Setor $sector');
        try {
          await _auth(sector);
          for (var block = 0; block < 4; block++) {
            final data = await StonePayments.mifareReadBlock(
                sector: sector, block: block);
            report.writeln(
                '  ${(sector * 4 + block).toString().padLeft(2)}: ${toHex(data ?? Uint8List(0))}');
          }
        } on PlatformException catch (e) {
          report.writeln('  ERRO: ${e.message}');
          await StonePayments.mifarePowerOff();
          detected = false;
        }
      }
    } finally {
      if (detected) await StonePayments.mifarePowerOff();
    }
    return report.toString();
  }
}

/// Campos de chave (hex + tipo A/B), usados nas abas que autenticam setores.
class MifareKeyFields extends StatelessWidget {
  const MifareKeyFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: MifareKeyConfig.key,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F ]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Chave hex (vazio = padrão)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: MifareKeyConfig.keyType,
            builder: (context, keyType, _) =>
                SegmentedButton<MifareKeyTypeEnum>(
              segments: const [
                ButtonSegment(
                    value: MifareKeyTypeEnum.typeA, label: Text('Chave A')),
                ButtonSegment(
                    value: MifareKeyTypeEnum.typeB, label: Text('Chave B')),
              ],
              selected: {keyType},
              onSelectionChanged: (v) =>
                  MifareKeyConfig.keyType.value = v.first,
            ),
          ),
        ],
      ),
    );
  }
}
