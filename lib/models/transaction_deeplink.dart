// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Transaction Deeplink
class TransactionDeeplink {
  /// Amount
  final String? amount;

  /// Acquirer transaction key
  final String? atk;

  /// Authorization code
  final String? authorizationCode;

  /// Authorization DateTime
  final String? authorizationDateTime;

  /// Card brand
  final String? brand;

  /// Code
  final String? code;

  /// Installment count
  final String? installmentCount;

  /// ITK
  final String? itk;

  /// Order ID
  final String? orderId;

  /// Pan
  final String? pan;

  /// Success
  final bool? success;

  /// Type
  final String? type;

  TransactionDeeplink({
    this.amount,
    this.atk,
    this.authorizationCode,
    this.authorizationDateTime,
    this.brand,
    this.code,
    this.installmentCount,
    this.itk,
    this.orderId,
    this.pan,
    this.success,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'atk': atk,
      'authorizationCode': authorizationCode,
      'authorizationDateTime': authorizationDateTime,
      'brand': brand,
      'code': code,
      'installmentCount': installmentCount,
      'itk': itk,
      'orderId': orderId,
      'pan': pan,
      'success': success,
      'type': type,
    };
  }

  factory TransactionDeeplink.fromMap(Map<String, dynamic> map) {
    return TransactionDeeplink(
      amount: map['amount'] != null ? map['amount'] as String : null,
      atk: map['atk'] != null ? map['atk'] as String : null,
      authorizationCode: map['authorizationCode'] != null
          ? map['authorizationCode'] as String
          : null,
      authorizationDateTime: map['authorizationDateTime'] != null
          ? map['authorizationDateTime'] as String
          : null,
      brand: map['brand'] != null ? map['brand'] as String : null,
      code: map['code'] != null ? map['code'] as String : null,
      installmentCount: map['installmentCount'] != null
          ? map['installmentCount'] as String
          : null,
      itk: map['itk'] != null ? map['itk'] as String : null,
      orderId: map['orderId'] != null ? map['orderId'] as String : null,
      pan: map['pan'] != null ? map['pan'] as String : null,
      success: map['success'] != null ? (map['success'] == "true") : null,
      type: map['type'] != null ? map['type'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionDeeplink.fromJson(String source) =>
      TransactionDeeplink.fromMap(json.decode(source) as Map<String, dynamic>);
}
