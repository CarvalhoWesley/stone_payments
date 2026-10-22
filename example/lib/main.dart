import 'package:flutter/material.dart';
import 'package:stone_payments/stone_payments.dart';

import 'core/app_log.dart';
import 'deeplink/deeplink_page.dart';
import 'deeplink/deeplink_store.dart';
import 'logs/logs_page.dart';
import 'mifare/mifare_page.dart';
import 'provider/provider_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final result = await StonePayments.activateStone(
      appName: 'My App',
      stoneCode: '12345678',
      qrCodeAuthorization: 'TOKEN',
      qrCodeProviderId: 'PROVIDER_ID',
    );
    AppLog.add(LogSource.system, 'Ativação: $result');
  } catch (e) {
    AppLog.add(LogSource.system, 'Falha na ativação: $e', isError: true);
  }

  // Mensagens de status do SDK (Provider) e retornos do Deeplink vão para o log central
  StonePayments.onMessageListener((message) {
    AppLog.add(LogSource.provider, 'SDK: $message');
  });
  DeeplinkStore.listen();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stone Payments',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00A868),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = [
    'Provider (SDK)',
    'Deeplink',
    'Mifare',
    'Logs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          ProviderPage(),
          DeeplinkPage(),
          MifarePage(),
          LogsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.point_of_sale), label: 'Provider'),
          const NavigationDestination(
              icon: Icon(Icons.open_in_new), label: 'Deeplink'),
          const NavigationDestination(
              icon: Icon(Icons.contactless), label: 'Mifare'),
          NavigationDestination(
            icon: ValueListenableBuilder(
              valueListenable: AppLog.entries,
              builder: (context, entries, _) => Badge(
                isLabelVisible: entries.any((e) => e.isError),
                child: const Icon(Icons.terminal),
              ),
            ),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
