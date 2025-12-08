import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Small graph widget for the top right panel
class SmallGraph extends StatelessWidget {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  const SmallGraph({
    super.key,
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _SmallGraphPainter(
          points: points,
          currentVolume: currentVolume,
          currentPressure: currentPressure,
        ),
      ),
    );
  }
}

class _SmallGraphPainter extends CustomPainter {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  _SmallGraphPainter({
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1;

    const padding = 20.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding * 2;

    final maxVolume = points.map((p) => p.dx).reduce(math.max).clamp(1.0, 10.0);
    final maxPressure = points.map((p) => p.dy).reduce(math.max).clamp(1.0, 5.0);

    // Draw axes
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    // Draw curve
    if (points.length > 1) {
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final x = padding + (point.dx / maxVolume) * graphWidth;
        final y = size.height - padding - (point.dy / maxPressure) * graphHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Labels
    final textStyle = TextStyle(
      color: Colors.grey.shade800,
      fontSize: 8,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: 'PRESSURE (PSI)', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(padding, 0));

    final volumePainter = TextPainter(
      text: TextSpan(text: 'VOLUME (L)', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    volumePainter.layout();
    volumePainter.paint(
      canvas,
      Offset(size.width - volumePainter.width - padding, size.height - padding + 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Full-size pressure-volume graph for the dialog
class PressureVolumeGraph extends StatelessWidget {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  const PressureVolumeGraph({
    super.key,
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _GraphPainter(
          points: points,
          currentVolume: currentVolume,
          currentPressure: currentPressure,
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  _GraphPainter({
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double leftPadding = 50;
    final double bottomPadding = 50;
    final double rightPadding = 20;
    final double topPadding = 20;

    final double graphWidth = size.width - leftPadding - rightPadding;
    final double graphHeight = size.height - topPadding - bottomPadding;

    final Offset origin = Offset(leftPadding, size.height - bottomPadding);

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2;

    // Draw axes
    canvas.drawLine(origin, Offset(origin.dx + graphWidth, origin.dy), axisPaint);
    canvas.drawLine(origin, Offset(origin.dx, origin.dy - graphHeight), axisPaint);

    // Calculate max values
    final maxVolume = points.map((p) => p.dx).reduce(math.max).clamp(1.0, 10.0);
    final maxPressure = points.map((p) => p.dy).reduce(math.max).clamp(1.0, 5.0);

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = origin.dy - (i * graphHeight / 5);
      canvas.drawLine(Offset(origin.dx, y), Offset(origin.dx + graphWidth, y), gridPaint);
    }

    for (int i = 0; i <= 5; i++) {
      final x = origin.dx + (i * graphWidth / 5);
      canvas.drawLine(Offset(x, origin.dy), Offset(x, origin.dy - graphHeight), gridPaint);
    }

    // Draw curve
    if (points.length > 1) {
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final x = origin.dx + (point.dx / maxVolume) * graphWidth;
        final y = origin.dy - (point.dy / maxPressure) * graphHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw current point
    if (currentVolume > 0 && currentPressure > 0) {
      final x = origin.dx + (currentVolume / maxVolume) * graphWidth;
      final y = origin.dy - (currentPressure / maxPressure) * graphHeight;

      final pointPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
    }

    // Labels
    final textStyle = TextStyle(color: Colors.grey.shade800, fontSize: 12);
    final textPainter = TextPainter(
      text: TextSpan(text: 'Pressure (atm)', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height / 2 - textPainter.height / 2));

    final volumePainter = TextPainter(
      text: TextSpan(text: 'Volume (L)', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    volumePainter.layout();
    volumePainter.paint(
      canvas,
      Offset(size.width / 2 - volumePainter.width / 2, size.height - 30),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

