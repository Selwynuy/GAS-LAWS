import 'package:flutter/material.dart';

/// Underwater background using ocean background image.
class UnderwaterBackground extends StatelessWidget {
  const UnderwaterBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/Ocean_Background.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

