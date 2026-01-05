import 'package:flutter/material.dart';

/// Cryo-sim Activity for Combined Gas Law.
class CryoSimActivity extends StatefulWidget {
  const CryoSimActivity({super.key});

  @override
  State<CryoSimActivity> createState() => _CryoSimActivityState();
}

class _CryoSimActivityState extends State<CryoSimActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cryo-sim"),
      ),
      body: const Center(
        child: Text(
          'Cryo-sim Activity\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

