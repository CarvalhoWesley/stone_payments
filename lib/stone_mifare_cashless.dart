import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stone_payments/enums/mifare_key_type_enum.dart';
import 'package:stone_payments/models/mifare_cashless_card.dart';
import 'package:stone_payments/stone_payments.dart';

/// Cartão de evento (cashless) sobre Mifare Classic 1K.
///
/// Usa o mesmo layout de blocos do plugin pagseguro_smart_flutter, então um
/// cartão aberto em um terminal PagSeguro pode ser lido aqui e vice-versa.
///
/// Cada método é uma operação completa: aguarda o cartão, autentica, lê/grava
/// e desliga o cartão no final. Erros de regra lançam [MifareCashlessException];
/// erros do leitor lançam [PlatformException].
class StoneMifareCashless {
  StoneMifareCashless._();

  // Layout dos blocos (igual ao NFCConstants do pagseguro_smart_flutter)
  static const int _valueBlock = 1;
  static const int _nameBlock = 2;
  static const int _cpfBlock = 4;
  static const int _tagBlock = 5;
  static const int _cellPhoneBlock = 6;
  static const int _openedBlock = 8;
  static const int _eventIdBlock = 9;
  static const int _openValueBlock = 12;

  static const List<int> _dataBlocks = [
    _valueBlock,
    _nameBlock,
    _cpfBlock,
    _tagBlock,
    _cellPhoneBlock,
    _openedBlock,
    _eventIdBlock,
    _openValueBlock,
  ];

  static final Uint8List _defaultKey = Uint8List.fromList(List.filled(6, 0xFF));

  /// Lê todos os dados do cartão.
  ///
  /// Se [eventId] for informado, recusa cartão de outro evento
  /// (`evento_nao_compativel`). Cartão sem evento gravado é aceito.
  static Future<MifareCashlessCard> readCard({
    String? eventId,
    Uint8List? key,
  }) {
    return _session(key, (s) async {
      final card = await _readAll(s);
      _checkEvent(card, eventId);
      return card;
    });
  }

  /// Abre (cadastra) o cartão com saldo inicial [value].
  ///
  /// Falha com `cartao_ja_aberto` se o cartão já estiver aberto.
  static Future<MifareCashlessCard> openCard({
    required double value,
    required String eventId,
    String name = '',
    String cpf = '',
    String tag = '',
    String cellPhone = '',
    Uint8List? key,
  }) {
    _checkValue(value);
    // Valida tudo antes de gravar para não deixar o cartão aberto pela metade
    for (final field in [name, cpf, tag, cellPhone, eventId]) {
      if (utf8.encode(field).length > 16) {
        throw MifareCashlessException(
            'valor_invalido', '"$field" passa de 16 bytes');
      }
    }
    return _session(key, (s) async {
      if (await s.readText(_openedBlock) == '1') {
        throw const MifareCashlessException(
            'cartao_ja_aberto', 'O cartão já está aberto');
      }
      await s.writeText(_valueBlock, _formatValue(value));
      await s.writeText(_nameBlock, name);
      await s.writeText(_cpfBlock, cpf);
      await s.writeText(_tagBlock, tag);
      await s.writeText(_cellPhoneBlock, cellPhone);
      await s.writeText(_eventIdBlock, eventId);
      await s.writeText(_openValueBlock, _formatValue(value));
      await s.writeText(_openedBlock, '1');
      return _readAll(s);
    });
  }

  /// Recarrega [value] no saldo. Retorna o cartão atualizado.
  static Future<MifareCashlessCard> recharge({
    required double value,
    String? eventId,
    Uint8List? key,
  }) {
    _checkValue(value);
    return _session(key, (s) async {
      final card = await _readOpenCard(s, eventId);
      await s.writeText(_valueBlock, _formatValue(card.value + value));
      await s.writeText(_openValueBlock, _formatValue(card.openValue + value));
      return _readAll(s);
    });
  }

  /// Debita [value] do saldo. Falha com `saldo_insuficiente` se não houver saldo.
  static Future<MifareCashlessCard> debit({
    required double value,
    String? eventId,
    Uint8List? key,
  }) {
    _checkValue(value);
    return _session(key, (s) async {
      final card = await _readOpenCard(s, eventId);
      if (card.value < value) {
        throw MifareCashlessException('saldo_insuficiente',
            'Saldo insuficiente: ${card.value.toStringAsFixed(2)}');
      }
      await s.writeText(_valueBlock, _formatValue(card.value - value));
      return _readAll(s);
    });
  }

  /// Estorna [value] de volta ao saldo (ex.: cancelamento de um débito).
  static Future<MifareCashlessCard> refund({
    required double value,
    String? eventId,
    Uint8List? key,
  }) {
    _checkValue(value);
    return _session(key, (s) async {
      final card = await _readOpenCard(s, eventId);
      await s.writeText(_valueBlock, _formatValue(card.value + value));
      return _readAll(s);
    });
  }

  /// Apaga todos os dados do cartão de evento (o cartão volta a ficar fechado).
  static Future<void> format({Uint8List? key}) {
    return _session(key, (s) async {
      for (final block in _dataBlocks) {
        await s.write(block, Uint8List(16));
      }
    });
  }

  // ===== Internos =====

  static Future<T> _session<T>(
      Uint8List? key, Future<T> Function(_CardSession s) action) async {
    final card = await StonePayments.mifareDetectCard();
    try {
      return await action(
          _CardSession(card?.uuidHex ?? '', key ?? _defaultKey));
    } finally {
      await StonePayments.mifarePowerOff();
    }
  }

  static Future<MifareCashlessCard> _readAll(_CardSession s) async {
    return MifareCashlessCard(
      uuid: s.uuid,
      value: _parseValue(await s.readText(_valueBlock)),
      openValue: _parseValue(await s.readText(_openValueBlock)),
      name: await s.readText(_nameBlock),
      cpf: await s.readText(_cpfBlock),
      tag: await s.readText(_tagBlock),
      cellPhone: await s.readText(_cellPhoneBlock),
      opened: await s.readText(_openedBlock) == '1',
      eventId: await s.readText(_eventIdBlock),
    );
  }

  static Future<MifareCashlessCard> _readOpenCard(
      _CardSession s, String? eventId) async {
    final card = await _readAll(s);
    if (!card.opened) {
      throw const MifareCashlessException(
          'cartao_nao_aberto', 'O cartão não está aberto');
    }
    _checkEvent(card, eventId);
    return card;
  }

  static void _checkEvent(MifareCashlessCard card, String? eventId) {
    if (eventId == null || card.eventId.isEmpty) return;
    if (card.eventId != eventId.trim()) {
      throw MifareCashlessException(
          'evento_nao_compativel', 'Cartão pertence ao evento ${card.eventId}');
    }
  }

  static void _checkValue(double value) {
    if (value <= 0) {
      throw const MifareCashlessException(
          'valor_invalido', 'O valor deve ser maior que zero');
    }
  }

  // Valores gravados como texto com '*' à esquerda, ex.: "**********50.00"
  static String _formatValue(double value) =>
      value.toStringAsFixed(2).padLeft(16, '*');

  static double _parseValue(String text) =>
      double.tryParse(text.replaceAll('*', '').trim()) ?? 0;
}

/// Cartão detectado: autentica o setor de cada bloco só uma vez.
class _CardSession {
  final String uuid;
  final Uint8List key;
  int? _authSector;

  _CardSession(this.uuid, this.key);

  Future<void> _auth(int block) async {
    final sector = block ~/ 4;
    if (_authSector == sector) return;
    await StonePayments.mifareAuthenticateSector(
      keyType: MifareKeyTypeEnum.typeA,
      key: key,
      sector: sector,
    );
    _authSector = sector;
  }

  Future<Uint8List> read(int block) async {
    await _auth(block);
    return await StonePayments.mifareReadBlock(
            sector: block ~/ 4, block: block % 4) ??
        Uint8List(16);
  }

  Future<void> write(int block, Uint8List data) async {
    await _auth(block);
    await StonePayments.mifareWriteBlock(
        sector: block ~/ 4, block: block % 4, data: data);
  }

  Future<String> readText(int block) async {
    final data = await read(block);
    return utf8
        .decode(data.where((b) => b != 0).toList(), allowMalformed: true)
        .trim();
  }

  Future<void> writeText(int block, String text) {
    final bytes = utf8.encode(text);
    if (bytes.length > 16) {
      throw MifareCashlessException(
          'valor_invalido', '"$text" passa de 16 bytes');
    }
    return write(block, Uint8List(16)..setAll(0, bytes));
  }
}
