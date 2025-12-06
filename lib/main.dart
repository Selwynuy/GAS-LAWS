import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

// Entry point of the app.
void main() {
  runApp(const ScubaGasLawsApp());
}

/// Root widget that sets up Material theming and routes.
class ScubaGasLawsApp extends StatelessWidget {
  const ScubaGasLawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boyle\'s Law Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF99CAE8)),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}


