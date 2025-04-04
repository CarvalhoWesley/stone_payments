/// Enum to define the type of transaction
/// This enum is used to define the type of transaction
/// Credit or Debit
/// The value is used as a flag to define the type of transaction
/// 0 = Merchant
/// 1 = Issuer
/// 2 = None
enum TypeInstallmentEnum {
  /// Merchant
  merchant(0),

  /// Issuer
  issuer(1),

  /// None
  none(2);

  /// Values of the enum
  final int value;

  const TypeInstallmentEnum(this.value);
}

/// Converts the enum value to a string extension.

extension TypeInstallmentEnumExtension on TypeInstallmentEnum {
  /// Converts the enum value to a string
  String get name {
    switch (this) {
      case TypeInstallmentEnum.merchant:
        return 'MERCHANT';
      case TypeInstallmentEnum.issuer:
        return 'ISSUER';
      case TypeInstallmentEnum.none:
        return 'NONE';
    }
  }
}
