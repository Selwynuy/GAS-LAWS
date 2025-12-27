import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';

/// Root widget that sets up Material theming and routes.
class ScubaGasLawsApp extends StatelessWidget {
  const ScubaGasLawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boyle\'s Law Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF99CAE8)),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

