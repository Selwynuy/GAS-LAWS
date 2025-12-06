import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Small Volume vs Pressure chart using fl_chart.
///
/// This keeps just a short history so it stays light.
class VolumePressureChart extends StatelessWidget {
  final List<VolumePressurePoint> points;

  const VolumePressureChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final double minP = points.map((e) => e.pressure).reduce((a, b) => a < b ? a : b);
    final double maxP = points.map((e) => e.pressure).reduce((a, b) => a > b ? a : b);
    final double minV = points.map((e) => e.volume).reduce((a, b) => a < b ? a : b);
    final double maxV = points.map((e) => e.volume).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Volume vs Pressure',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: minP,
                maxX: maxP,
                minY: minV,
                maxY: maxV,
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.cyanAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    spots: points
                        .map(
                          (p) => FlSpot(p.pressure, p.volume),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolumePressurePoint {
  final double pressure;
  final double volume;

  VolumePressurePoint({
    required this.pressure,
    required this.volume,
  });
}


