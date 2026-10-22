import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stone_payments/enums/mifare_key_type_enum.dart';
import 'package:stone_payments/enums/type_owner_print_enum.dart';
import 'package:stone_payments/models/transaction.dart';

import 'enums/type_transaction_enum.dart';
import 'models/item_print_model.dart';
import 'models/mifare_card.dart';
import 'stone_payments_platform_interface.dart';

/// Classe responsável por interagir com a plataforma de pagamentos da Stone.
class StonePayments {
  /// Processa um pagamento na plataforma da Stone.
  ///
  /// Parâmetros:
  ///
  /// * `value` (required) - Valor do pagamento. Deve ser maior que zero.
  /// * `typeTransaction` (required) - Tipo de transação (crédito ou débito).
  /// * `installment` (optional) - Número de parcelas (padrão é 1). Deve ser maior que zero e menor que 13.
  /// * `printReceipt` (optional) - Opção para imprimir o comprovante (padrão é nulo).
  ///
  /// Retorna:
  ///
  /// * Uma `Future<String?>` com o status do pagamento. O valor pode ser nulo em caso de erro.
  @Deprecated('Use transaction() instead.')
  static Future<String?> payment({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
  }) {
    assert(value > 0, 'O valor do pagamento deve ser maior que zero.');
    assert(
      installment > 0 && installment < 13,
      'O número de parcelas deve ser maior que zero e menor que 13.',
    );
    if (typeTransaction == TypeTransactionEnum.debit) {
      assert(installment == 1, 'Pagamentos débito não pode ser parcelados.');
    }

    return StonePaymentsPlatform.instance.payment(
      value: value,
      typeTransaction: typeTransaction,
      installment: installment,
      printReceipt: printReceipt,
    );
  }

  /// Processa uma transação na plataforma da Stone.
  ///
  /// Parâmetros:
  ///
  /// * `value` (required) - Valor do pagamento. Deve ser maior que zero.
  /// * `typeTransaction` (required) - Tipo de transação (crédito ou débito).
  /// * `installment` (optional) - Número de parcelas (padrão é 1). Deve ser maior que zero e menor que 13.
  /// * `printReceipt` (optional) - Opção para imprimir o comprovante (padrão é nulo).
  /// * `onPixQrCode` (optional) - Função de retorno para tratar o QR Code do PIX.
  ///
  /// Retorna:
  ///
  /// * Uma `Future<Transaction?>` com o objeto da transação. O valor pode ser nulo em caso de erro.
  static Future<Transaction?> transaction({
    required double value,
    required TypeTransactionEnum typeTransaction,
    int installment = 1,
    bool? printReceipt,
    ValueChanged<String>? onPixQrCode,
  }) {
    assert(value > 0, 'O valor do pagamento deve ser maior que zero.');
    assert(
      installment > 0 && installment < 13,
      'O número de parcelas deve ser maior que zero e menor que 13.',
    );
    if (typeTransaction == TypeTransactionEnum.debit) {
      assert(installment == 1, 'Pagamentos débito não pode ser parcelados.');
    }

    return StonePaymentsPlatform.instance.transaction(
      value: value,
      typeTransaction: typeTransaction,
      installment: installment,
      printReceipt: printReceipt,
      onPixQrCode: onPixQrCode,
    );
  }

  /// Ativação do SDK da Stone Payments.
  ///
  /// Parâmetros:
  ///
  /// * `appName` (required) - Nome do aplicativo.
  /// * `stoneCode` (required) - Código da Stone.
  /// * `qrCodeProviderId` (optional) - ID do provedor do QR Code.
  /// * `qrCodeAuthorization` (optional) - Autorização do QR Code.
  ///
  /// Retorna:
  ///
  /// * Uma `Future<String?>` com o status da ativação. O valor pode ser nulo em caso de erro.
  static Future<String?> activateStone({
    required String appName,
    required String stoneCode,
    String? qrCodeProviderId,
    String? qrCodeAuthorization,
  }) {
    return StonePaymentsPlatform.instance.activateStone(
      appName: appName,
      stoneCode: stoneCode,
      qrCodeProviderId: qrCodeProviderId,
      qrCodeAuthorization: qrCodeAuthorization,
    );
  }

  /// Imprime um arquivo a partir de uma lista de textos e imagens.
  ///
  /// Parâmetros:
  ///
  /// * `items` (required) - Lista de itens a serem impressos.
  ///
  /// Retorna:
  ///
  /// * Uma `Future<String?>` com o status da impressão. O valor pode ser nulo em caso de erro.
  static Future<String?> print(List<ItemPrintModel> items) {
    return StonePaymentsPlatform.instance.print(items);
  }

  /// Retorna um [StreamSubscription] que escuta as mensagens da plataforma da Stone.
  ///
  /// Parâmetros:
  ///
  /// * `onMessage` - Função de retorno para tratar as mensagens da plataforma da Stone.
  /// * `cancelOnError` (optional) - Se definido como true, o [StreamSubscription] será cancelado em caso de erro.
  /// * `onDone` (optional) - Função de retorno para lidar com a conclusão da transmissão.
  /// * `onError` (optional) - Função de retorno para lidar com erros no stream.
  ///
  /// Retorna:
  ///
  /// * Uma função que retorna um [StreamSubscription<String>] para escutar as mensagens da plataforma da Stone.
  static StreamSubscription<String> Function(
    ValueChanged<String>?, {
    bool? cancelOnError,
    VoidCallback? onDone,
    Function? onError,
  }) get onMessageListener => StonePaymentsPlatform.instance.onMessage.listen;

  /// Imprime o comprovante de pagamento.
  ///
  /// Parâmetros:
  ///
  /// * `type` (required) - Tipo de via a ser impresso, do cliente ou do estabelecimento.
  ///
  /// Retorna:
  ///
  /// * Uma `Future<String?>` com o status da impressão. O valor pode ser nulo em caso de erro.
  static Future<String?> printReceipt(TypeOwnerPrintEnum type) {
    return StonePaymentsPlatform.instance.printReceipt(type);
  }

  /// Aborta a transação atual.
  ///
  static Future<String?> abortPayment() {
    return StonePaymentsPlatform.instance.abortPayment();
  }

  /// Cancela um pagamento com a chave da transação definido pela sua aplicação.
  ///
  /// Parâmetros:
  ///
  /// * `initiatorTransactionKey` (required) - Chave da transação definida pela sua aplicação.
  /// * `printReceipt` (optional) - Opção para imprimir o comprovante (padrão é nulo).
  ///
  /// Retorna:
  ///
  /// * Uma `Future<Transaction?>` com o objeto da transação. O valor pode ser nulo em caso de erro.
  static Future<Transaction?> cancelPayment({
    required String initiatorTransactionKey,
    bool? printReceipt,
  }) {
    assert(
        initiatorTransactionKey != "", 'A chave da transação deve ser válida.');

    return StonePaymentsPlatform.instance.cancelPayment(
      initiatorTransactionKey: initiatorTransactionKey,
      printReceipt: printReceipt,
    );
  }

  // /// Cancela um pagamento com a chave da transação do adquirente.
  // ///
  // /// Parâmetros:
  // ///
  // /// * `acquirerTransactionKey` (required) - Chave da transação do adquirente.
  // /// * `printReceipt` (optional) - Opção para imprimir o comprovante (padrão é nulo).
  // ///
  // /// Retorna:
  // ///
  // /// * Uma `Future<Transaction?>` com o objeto da transação. O valor pode ser nulo em caso de erro.
  // static Future<Transaction?> cancelPaymentWithATK({
  //   required String acquirerTransactionKey,
  //   bool? printReceipt,
  // }) {
  //   assert(acquirerTransactionKey != "", 'A chave de transação do adquirente deve ser válida.');

  //   return StonePaymentsPlatform.instance.cancelPaymentWithATK(
  //     acquirerTransactionKey: acquirerTransactionKey,
  //     printReceipt: printReceipt,
  //   );
  // }

  /// Cancela um pagamento com o authorizationCode.
  ///
  /// Parâmetros:
  ///
  /// * `authorizationCode` (required) - Código de autorização da transação.
  /// * `printReceipt` (optional) - Opção para imprimir o comprovante (padrão é nulo).
  ///
  /// Retorna:
  ///
  /// * Uma `Future<Transaction?>` com o objeto da transação. O valor pode ser nulo em caso de erro.
  static Future<Transaction?> cancelPaymentWithAuthorizationCode({
    required String authorizationCode,
    bool? printReceipt,
  }) {
    assert(authorizationCode != "", 'O código de autorização deve ser válido.');

    return StonePaymentsPlatform.instance.cancelPaymentWithAuthorizationCode(
      authorizationCode: authorizationCode,
      printReceipt: printReceipt,
    );
  }

  /// Aguarda a aproximação de um cartão Mifare e o ativa (PosMifareProvider).
  ///
  /// Após as operações no cartão, chame [mifarePowerOff].
  ///
  /// Retorna:
  ///
  /// * Uma `Future<MifareCard?>` com o UID e as propriedades do cartão.
  static Future<MifareCard?> mifareDetectCard() {
    return StonePaymentsPlatform.instance.mifareDetectCard();
  }

  /// Autentica um setor do cartão Mifare.
  ///
  /// Parâmetros:
  ///
  /// * `keyType` (required) - Tipo da chave (A ou B).
  /// * `key` (required) - Chave de 6 bytes.
  /// * `sector` (required) - Setor a ser autenticado.
  static Future<void> mifareAuthenticateSector({
    required MifareKeyTypeEnum keyType,
    required Uint8List key,
    required int sector,
  }) {
    assert(key.length == 6, 'A chave Mifare deve ter 6 bytes.');

    return StonePaymentsPlatform.instance.mifareAuthenticateSector(
      keyType: keyType,
      key: key,
      sector: sector,
    );
  }

  /// Lê um bloco (16 bytes) de um setor autenticado.
  static Future<Uint8List?> mifareReadBlock({
    required int sector,
    required int block,
  }) {
    return StonePaymentsPlatform.instance.mifareReadBlock(
      sector: sector,
      block: block,
    );
  }

  /// Escreve um bloco (16 bytes) em um setor autenticado.
  static Future<void> mifareWriteBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) {
    assert(data.length == 16, 'O bloco Mifare deve ter 16 bytes.');

    return StonePaymentsPlatform.instance.mifareWriteBlock(
      sector: sector,
      block: block,
      data: data,
    );
  }

  /// Faz backup de um bloco de valor de `srcBlock` para `dstBlock`.
  static Future<void> mifareBackupBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) {
    return StonePaymentsPlatform.instance.mifareBackupBlock(
      sector: sector,
      srcBlock: srcBlock,
      dstBlock: dstBlock,
    );
  }

  /// Restaura um bloco de valor de `srcBlock` para `dstBlock`.
  static Future<void> mifareRestoreBlock({
    required int sector,
    required int srcBlock,
    required int dstBlock,
  }) {
    return StonePaymentsPlatform.instance.mifareRestoreBlock(
      sector: sector,
      srcBlock: srcBlock,
      dstBlock: dstBlock,
    );
  }

  /// Incrementa um bloco de valor. O SDK aceita `value` de 1 byte (0 a 127).
  static Future<void> mifareIncrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    assert(value >= 0 && value <= 127, 'O valor deve estar entre 0 e 127.');

    return StonePaymentsPlatform.instance.mifareIncrementValue(
      sector: sector,
      block: block,
      value: value,
    );
  }

  /// Decrementa um bloco de valor. O SDK aceita `value` de 1 byte (0 a 127).
  static Future<void> mifareDecrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    assert(value >= 0 && value <= 127, 'O valor deve estar entre 0 e 127.');

    return StonePaymentsPlatform.instance.mifareDecrementValue(
      sector: sector,
      block: block,
      value: value,
    );
  }

  /// Desliga o cartão Mifare e encerra a sessão.
  static Future<void> mifarePowerOff() {
    return StonePaymentsPlatform.instance.mifarePowerOff();
  }

  /// Cancela a detecção de cartão Mifare em andamento.
  static Future<void> mifareCancelDetection() {
    return StonePaymentsPlatform.instance.mifareCancelDetection();
  }
}
