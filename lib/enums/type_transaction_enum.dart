/// Enum to define the type of transaction
/// This enum is used to define the type of transaction
/// Credit or Debit
/// The value is used as a flag to define the type of transaction
/// 0 = Debit
/// 1 = Credit
/// 2 = Voucher
/// 4 = PIX
enum TypeTransactionEnum {
  /// Debit
  debit(0),

  /// Credit
  credit(1),

  /// Voucher
  voucher(2),

  /// PIX
  pix(4);

  /// Values of the enum
  final int value;

  const TypeTransactionEnum(this.value);
}

/// Converts the enum value to a string extension.

extension TypeTransactionEnumExtension on TypeTransactionEnum {
  /// Converts the enum value to a string
  String get name {
    switch (this) {
      case TypeTransactionEnum.debit:
        return 'DEBIT';
      case TypeTransactionEnum.credit:
        return 'CREDIT';
      case TypeTransactionEnum.voucher:
        return 'VOUCHER';
      case TypeTransactionEnum.pix:
        return 'PIX';
    }
  }
}
