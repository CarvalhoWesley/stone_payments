import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stone_payments/enums/item_print_type_enum.dart';
import 'package:stone_payments/models/item_print_model.dart';

/// Itens de exemplo usados nos testes de impressão.
Future<List<ItemPrintModel>> samplePrintItems({bool withImage = true}) async {
  final items = [
    const ItemPrintModel(type: ItemPrintTypeEnum.text, data: 'Teste Título'),
    const ItemPrintModel(type: ItemPrintTypeEnum.text, data: 'Teste Subtítulo'),
  ];
  if (withImage) {
    final bytes = await rootBundle.load('assets/flutter5786.png');
    items.add(ItemPrintModel(
      type: ItemPrintTypeEnum.image,
      data: base64Encode(bytes.buffer.asUint8List()),
    ));
  }
  return items;
}
