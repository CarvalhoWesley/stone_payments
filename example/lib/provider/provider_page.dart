import 'package:flutter/material.dart';

import 'payment_tab.dart';
import 'print_tab.dart';
import 'transactions_tab.dart';

/// Pagamentos e impressão pelo SDK da Stone (providers).
class ProviderPage extends StatelessWidget {
  const ProviderPage({super.key});

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
              ProviderPaymentTab(),
              ProviderTransactionsTab(),
              ProviderPrintTab(),
            ]),
          ),
        ],
      ),
    );
  }
}
