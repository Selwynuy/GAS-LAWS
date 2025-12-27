import 'package:flutter/material.dart';

/// Rubber Boat Experiment for Charles Law.
class RubberBoatActivity extends StatefulWidget {
  const RubberBoatActivity({super.key});

  @override
  State<RubberBoatActivity> createState() => _RubberBoatActivityState();
}

class _RubberBoatActivityState extends State<RubberBoatActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rubber Boat Experiment"),
      ),
      body: const Center(
        child: Text(
          'Rubber Boat Experiment\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

