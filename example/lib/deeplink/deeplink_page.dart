import 'package:flutter/material.dart';

import 'payment_tab.dart';
import 'print_tab.dart';
import 'transactions_tab.dart';

/// Pagamentos e impressão pelo app da Stone, via deeplink.
class DeeplinkPage extends StatelessWidget {
  const DeeplinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(icon: Icon(Icons.point_of_sale), text: 'Pagamento'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transações'),
            Tab(icon: Icon(Icons.print), text: 'Impressão'),
          ]),
          Expanded(
            child: TabBarView(children: [
              DeeplinkPaymentTab(),
              DeeplinkTransactionsTab(),
              DeeplinkPrintTab(),
            ]),
          ),
        ],
      ),
    );
  }
}
