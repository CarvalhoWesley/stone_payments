import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_payments/enums/item_print_type_enum.dart';
import 'package:stone_payments/enums/type_installment_enum.dart';
import 'package:stone_payments/enums/type_owner_print_enum.dart';
import 'package:stone_payments/enums/type_transaction_enum.dart';
import 'package:stone_payments/models/item_print_model.dart';
import 'package:stone_payments/models/transaction.dart';
import 'package:stone_payments/models/transaction_deeplink.dart';
import 'package:stone_payments/stone_deeplink_payments.dart';
import 'package:stone_payments/stone_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StonePayments.activateStone(
    appName: 'My App',
    stoneCode: '12345678',
    qrCodeAuthorization: 'TOKEN',
    qrCodeProviderId: 'PROVIDER_ID',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<String> listen;
  late StreamSubscription listenDeeplink;
  Uint8List? image;
  TextEditingController valueController = TextEditingController();

  ValueNotifier message = ValueNotifier<String>('Running...');
  ValueNotifier transactionSuccefull = ValueNotifier<bool>(false);
  ValueNotifier transactions = ValueNotifier<List>([]);

  @override
  void initState() {
    listen = StonePayments.onMessageListener((message) {
      this.message.value = message;
    });

    listenDeeplink = StoneDeeplinkPayments.onTransaction.listen((transaction) {
      if (transaction.success ?? false) {
        transactionSuccefull.value = true;
        transactions.value.add(transaction);
        transactions.notifyListeners();
      }
    });

    valueController.text = '10.50';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Valor',
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("SDK Provider"),
                ),
                Wrap(
                  children: [
                    //CREDITO
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        final valor = double.parse(valueController.text);

                        if (listen.isPaused) {
                          listen.resume();
                        }

                        try {
                          final result = await StonePayments.transaction(
                            value: valor,
                            typeTransaction: TypeTransactionEnum.credit,
                            printReceipt: true,
                          );
                          if (result == null) return;
                          if (result.transactionStatus == "APPROVED") {
                            transactionSuccefull.value = true;
                            transactions.value.add(result);
                            transactions.notifyListeners();
                          }
                          debugPrint(result.toJson());
                        } catch (e) {
                          listen.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('CRÉDITO'),
                    ),
                    const SizedBox(width: 10),
                    //CREDITO - 2X
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        if (listen.isPaused) {
                          listen.resume();
                        }

                        final valor = double.parse(valueController.text);
                        try {
                          final result = await StonePayments.transaction(
                            value: valor,
                            typeTransaction: TypeTransactionEnum.credit,
                            installment: 2,
                            printReceipt: true,
                          );
                          if (result == null) return;
                          if (result.transactionStatus == "APPROVED") {
                            transactionSuccefull.value = true;
                            transactions.value.add(result);
                            transactions.notifyListeners();
                          }
                          debugPrint(result.toJson());
                        } catch (e) {
                          listen.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('CRÉDITO - 2X'),
                    ),
                    const SizedBox(width: 10),
                    //DÉBITO
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        if (listen.isPaused) {
                          listen.resume();
                        }

                        final valor = double.parse(valueController.text);
                        try {
                          final result = await StonePayments.transaction(
                            value: valor,
                            typeTransaction: TypeTransactionEnum.debit,
                            printReceipt: true,
                          );
                          if (result == null) return;
                          if (result.transactionStatus == "APPROVED") {
                            transactionSuccefull.value = true;
                            transactions.value.add(result);
                            transactions.notifyListeners();
                          }
                          debugPrint(result.toJson());
                        } catch (e) {
                          listen.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('DÉBITO'),
                    ),
                    const SizedBox(width: 10),
                    //PIX
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        if (listen.isPaused) {
                          listen.resume();
                        }

                        final valor = double.parse(valueController.text);
                        try {
                          final result = await StonePayments.transaction(
                            value: valor,
                            typeTransaction: TypeTransactionEnum.pix,
                            printReceipt: true,
                            onPixQrCode: (String value) async {
                              final qrCodeBase64 = value.replaceAll('\n', '');
                              final bytes = base64Decode(qrCodeBase64);
                              setState(() {
                                image = bytes;
                              });
                            },
                          );
                          if (result == null) return;
                          if (result.transactionStatus == "APPROVED") {
                            transactionSuccefull.value = true;
                            transactions.value.add(result);
                            transactions.notifyListeners();
                          }
                          debugPrint(result.toJson());
                        } catch (e) {
                          listen.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('PIX'),
                    ),
                    const SizedBox(width: 10),
                    //ABORTAR TRANSAÇÃO
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        if (listen.isPaused) {
                          listen.resume();
                        }

                        try {
                          final result = await StonePayments.abortPayment();
                          if (result == null) return;

                          if (result == "ABORTED") {
                            message.value = "Transação abortada com sucesso";
                          }

                          debugPrint(result.toString());
                        } catch (e) {
                          listen.pause();
                          message.value = "Falha ao abortar transação";
                        }
                      },
                      child: const Text('ABORTAR TRANSAÇÃO'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Deeplink"),
                ),
                Wrap(
                  children: [
                    //CREDITO
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        final valor = double.parse(valueController.text);

                        if (listenDeeplink.isPaused) {
                          listenDeeplink.resume();
                        }

                        try {
                          await StoneDeeplinkPayments.transaction(
                            amount: valor,
                            transactionType: TypeTransactionEnum.credit,
                            orderId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          );
                        } catch (e) {
                          listenDeeplink.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('CRÉDITO'),
                    ),
                    const SizedBox(width: 10),
                    //CREDITO - 2X
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        final valor = double.parse(valueController.text);
                        if (listenDeeplink.isPaused) {
                          listenDeeplink.resume();
                        }

                        try {
                          await StoneDeeplinkPayments.transaction(
                            amount: valor,
                            transactionType: TypeTransactionEnum.credit,
                            installmentType: TypeInstallmentEnum.none,
                            installmentCount: 1,
                            orderId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          );
                        } catch (e) {
                          listenDeeplink.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('CRÉDITO - 2X'),
                    ),
                    const SizedBox(width: 10),
                    //DÉBITO
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        final valor = double.parse(valueController.text);

                        if (listenDeeplink.isPaused) {
                          listenDeeplink.resume();
                        }

                        try {
                          await StoneDeeplinkPayments.transaction(
                            amount: valor,
                            transactionType: TypeTransactionEnum.debit,
                            orderId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          );
                        } catch (e) {
                          listenDeeplink.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('DÉBITO'),
                    ),
                    const SizedBox(width: 10),
                    //PIX
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (valueController.text.isEmpty) return;

                        if (listenDeeplink.isPaused) {
                          listenDeeplink.resume();
                        }

                        final valor = double.parse(valueController.text);
                        try {
                          await StoneDeeplinkPayments.transaction(
                            amount: valor,
                            transactionType: TypeTransactionEnum.pix,
                            orderId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          );
                        } catch (e) {
                          listenDeeplink.pause();
                          message.value = "Falha no pagamento";
                        }
                      },
                      child: const Text('PIX'),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                if (image != null)
                  Image.memory(
                    image!,
                    height: 100,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(width: 100, 'assets/flutter5786.png'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      var byteData =
                          await rootBundle.load('assets/flutter5786.png');
                      var imgBase64 =
                          base64Encode(byteData.buffer.asUint8List());

                      var items = [
                        const ItemPrintModel(
                          type: ItemPrintTypeEnum.text,
                          data: 'Teste Título',
                        ),
                        const ItemPrintModel(
                          type: ItemPrintTypeEnum.text,
                          data: 'Teste Subtítulo',
                        ),
                        ItemPrintModel(
                          type: ItemPrintTypeEnum.image,
                          data: imgBase64,
                        ),
                        if (image != null)
                          ItemPrintModel(
                            type: ItemPrintTypeEnum.image,
                            data: base64Encode(image!.toList()),
                          ),
                      ];

                      await StonePayments.print(items);
                    } catch (e) {
                      message.value = "Falha no pagamento";
                    }
                  },
                  child: const Text('Teste de Impressão'),
                ),
                ValueListenableBuilder(
                    valueListenable: transactionSuccefull,
                    builder: (context, transactionSuccefull, child) {
                      if (transactionSuccefull) {
                        return ElevatedButton(
                          onPressed: () async {
                            try {
                              await StonePayments.printReceipt(
                                  TypeOwnerPrintEnum.client);
                            } catch (e) {
                              message.value = "Falha no pagamento";
                            }
                          },
                          child: const Text('Imprimir Via Cliente'),
                        );
                      }
                      return const SizedBox();
                    }),
                const SizedBox(height: 20),
                const Text('Mensagem retorno:'),
                ValueListenableBuilder(
                    valueListenable: message,
                    builder: (context, message, child) {
                      return Text(message.toString());
                    }),
                ValueListenableBuilder(
                    valueListenable: transactions,
                    builder: (context, _transactions, child) {
                      if (_transactions.isEmpty) return const SizedBox();

                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text('Transações:'),
                          ..._transactions
                              .map((transaction) => ListTile(
                                    title: Text((transaction is Transaction)
                                        ? transaction.initiatorTransactionKey
                                            .toString()
                                        : transaction.itk),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // final result =
                                        //     await StoneDeeplinkPayments.cancel(

                                        //         initiatorTransactionKey:
                                        //             (transaction is Transaction)
                                        //                 ? transaction
                                        //                     .initiatorTransactionKey
                                        //                     .toString()
                                        //                 : transaction.itk,
                                        //         printReceipt: true);
                                        // if (result == null) return;
                                        // if (result.transactionStatus ==
                                        //     "CANCELLED") {
                                        //   transactionSuccefull.value = true;
                                        //   transactions.value
                                        //       .remove(transaction);
                                        //   transactions.notifyListeners();
                                        // }
                                        // debugPrint(result.toJson());
                                        transaction as TransactionDeeplink;
                                        await StoneDeeplinkPayments.cancel(
                                          amount: _convertAmountToDouble(
                                              transaction.amount),
                                          atk: transaction.atk,
                                        );
                                      },
                                    ),
                                  ))
                              .toList()
                        ],
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _convertAmountToDouble(String? amount) {
    if (amount == null) return 0.0;
    if (amount.isEmpty) return 0.0;
    try {
      final doubleValue = double.parse(amount) / 100;
      return doubleValue;
    } catch (e) {
      log(e.toString());
    }
  }
}
