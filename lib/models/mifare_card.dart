import 'dart:typed_data';

/// Cartão Mifare detectado pelo PosMifareProvider.
class MifareCard {
  /// UID do cartão.
  final Uint8List uuid;

  /// Propriedades do cartão retornadas pelo SDK.
  final Map<String, dynamic> properties;

  /// Cria um [MifareCard].
  const MifareCard({required this.uuid, required this.properties});

  /// UID do cartão em hexadecimal.
  String get uuidHex =>
      uuid.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

  /// Cria um [MifareCard] a partir do mapa retornado pela plataforma.
  factory MifareCard.fromMap(Map<dynamic, dynamic> map) {
    return MifareCard(
      uuid: map['uuid'] as Uint8List? ?? Uint8List(0),
      properties: Map<String, dynamic>.from(map['properties'] as Map? ?? {}),
    );
  }
}
