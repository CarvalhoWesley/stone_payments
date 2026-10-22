/// Dados do cartão de evento (cashless) gravados no Mifare Classic.
class MifareCashlessCard {
  /// UID do cartão em hexadecimal.
  final String uuid;

  /// Saldo atual.
  final double value;

  /// Total já carregado no cartão (abertura + recargas).
  final double openValue;

  /// Nome do portador.
  final String name;

  /// CPF do portador.
  final String cpf;

  /// Número da tag.
  final String tag;

  /// Celular do portador.
  final String cellPhone;

  /// Indica se o cartão está aberto.
  final bool opened;

  /// ID do evento gravado no cartão (vazio se não houver).
  final String eventId;

  /// Cria um [MifareCashlessCard].
  const MifareCashlessCard({
    required this.uuid,
    required this.value,
    required this.openValue,
    required this.name,
    required this.cpf,
    required this.tag,
    required this.cellPhone,
    required this.opened,
    required this.eventId,
  });

  @override
  String toString() => 'MifareCashlessCard(uuid: $uuid, value: $value, '
      'openValue: $openValue, name: $name, cpf: $cpf, tag: $tag, '
      'cellPhone: $cellPhone, opened: $opened, eventId: $eventId)';
}

/// Erro de regra do cartão de evento.
///
/// Códigos possíveis: `cartao_ja_aberto`, `cartao_nao_aberto`,
/// `evento_nao_compativel`, `saldo_insuficiente`, `valor_invalido`,
/// `formatacao_incompleta`.
class MifareCashlessException implements Exception {
  /// Código do erro.
  final String code;

  /// Mensagem legível.
  final String message;

  /// Cria um [MifareCashlessException].
  const MifareCashlessException(this.code, this.message);

  @override
  String toString() => 'MifareCashlessException($code): $message';
}
