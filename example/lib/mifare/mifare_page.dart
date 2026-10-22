import 'package:flutter/material.dart';

import 'blocks_tab.dart';
import 'card_tab.dart';
import 'event_tab.dart';

/// Funções Mifare: identificação do cartão, cartão de evento e acesso a blocos.
class MifarePage extends StatelessWidget {
  const MifarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(icon: Icon(Icons.badge), text: 'Cartão'),
            Tab(icon: Icon(Icons.confirmation_number), text: 'Evento'),
            Tab(icon: Icon(Icons.grid_view), text: 'Blocos'),
          ]),
          Expanded(
            child: TabBarView(children: [
              MifareCardTab(),
              MifareEventTab(),
              MifareBlocksTab(),
            ]),
          ),
        ],
      ),
    );
  }
}
