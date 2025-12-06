import 'package:flutter/material.dart';
import '../logic/diving_physics.dart';

/// Top panel that shows depth, pressure, lung volume, and O2 tank level.
class InfoPanel extends StatelessWidget {
  final DivingState state;

  const InfoPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildColumn(
            label: 'Depth',
            value: '${state.depthMeters.toStringAsFixed(1)} m',
            style: textStyle,
          ),
          _buildColumn(
            label: 'Pressure',
            value: '${state.pressureAtm.toStringAsFixed(2)} atm',
            style: textStyle,
          ),
          _buildColumn(
            label: 'Lung Vol',
            value: '${state.lungVolumeLiters.toStringAsFixed(2)} L',
            style: textStyle,
          ),
          _buildColumn(
            label: 'O₂ Tank',
            value: '${state.oxygenTankPercent.toStringAsFixed(0)} %',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required String label,
    required String value,
    required TextStyle? style,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style?.copyWith(fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: style),
      ],
    );
  }
}


