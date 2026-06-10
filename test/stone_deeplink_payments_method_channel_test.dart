import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_payments/enums/item_print_type_enum.dart';
import 'package:stone_payments/models/item_print_model.dart';
import 'package:stone_payments/stone_deeplink_payments_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelStoneDeeplinkPayments();
  const channel = MethodChannel('stone_payments');
  MethodCall? capturedMethodCall;

  setUp(() {
    capturedMethodCall = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      capturedMethodCall = methodCall;
      if (methodCall.method == 'printDeeplink') {
        return 'started';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('print sends printable content as deeplink json', () async {
    final items = <ItemPrintModel>[
      const ItemPrintModel(
        type: ItemPrintTypeEnum.text,
        data: 'Hello',
      ),
      const ItemPrintModel(
        type: ItemPrintTypeEnum.image,
        data: 'base64-image',
      ),
    ];

    await platform.print(items: items);

  expect(capturedMethodCall, isNotNull);
  expect(capturedMethodCall!.method, 'printDeeplink');

  final arguments =
    Map<String, dynamic>.from(capturedMethodCall!.arguments as Map);
    expect(arguments['showFeedbackScreen'], isTrue);
    expect(arguments['returnSchema'], 'stone_example');

    final printableContent = jsonDecode(arguments['printableContent'] as String)
        as List<dynamic>;
    expect(printableContent, hasLength(2));
    expect(printableContent[0], {
      'type': 'text',
      'content': 'Hello',
    });
    expect(printableContent[1], {
      'type': 'image',
      'imagePath': 'base64-image',
    });
  });
}