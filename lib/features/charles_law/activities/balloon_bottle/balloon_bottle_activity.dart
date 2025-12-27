import 'package:flutter/material.dart';

/// Balloon and Bottle Experiment for Charles Law.
class BalloonBottleActivity extends StatefulWidget {
  const BalloonBottleActivity({super.key});

  @override
  State<BalloonBottleActivity> createState() => _BalloonBottleActivityState();
}

class _BalloonBottleActivityState extends State<BalloonBottleActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Balloon and Bottle Experiment"),
      ),
      body: const Center(
        child: Text(
          'Balloon and Bottle Experiment\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

