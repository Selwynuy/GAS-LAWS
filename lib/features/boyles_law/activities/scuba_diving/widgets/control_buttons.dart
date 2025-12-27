import 'package:flutter/material.dart';

/// Bottom row of control buttons.
///
/// The callbacks are provided by the game screen so that UI and logic stay separated.
class ControlButtons extends StatelessWidget {
  final VoidCallback onAscendSlowly;
  final VoidCallback onExhale;
  final VoidCallback onEmergencyAscent;
  final VoidCallback onDescend;

  const ControlButtons({
    super.key,
    required this.onAscendSlowly,
    required this.onExhale,
    required this.onEmergencyAscent,
    required this.onDescend,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context: context,
              label: 'Ascend\nSlowly',
              color: colors.primary,
              onPressed: onAscendSlowly,
            ),
            _buildButton(
              context: context,
              label: 'Exhale',
              color: colors.secondary,
              onPressed: onExhale,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context: context,
              label: 'Emergency\nAscent',
              color: colors.error,
              onPressed: onEmergencyAscent,
            ),
            _buildButton(
              context: context,
              label: 'Descend',
              color: colors.tertiaryContainer,
              onPressed: onDescend,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}


