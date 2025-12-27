import 'package:flutter/material.dart';

/// True or False Quiz for Combined Gas Law.
class TrueFalseActivity extends StatefulWidget {
  const TrueFalseActivity({super.key});

  @override
  State<TrueFalseActivity> createState() => _TrueFalseActivityState();
}

class _TrueFalseActivityState extends State<TrueFalseActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("True or False"),
      ),
      body: const Center(
        child: Text(
          'True or False Quiz\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

