import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← adăugat pentru SystemChrome
import 'pages/loading_page.dart';
import 'pages/home_page.dart';
import 'pages/tickets_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← necesar înainte de SystemChrome
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicatie Licenta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x00006AFF)),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingPage(),
        '/home': (context) => const HomePage(),
        '/tickets': (context) => const TicketsPage(),
      },
    );
  }
}
