import 'dart:ui';

import 'package:flutter/material.dart';

/// Simple visual representation of a lung that expands / shrinks with volume.
///
/// This is intentionally abstract (just a shape) so you can swap in nicer art later.
class LungsWidget extends StatelessWidget {
  /// Value between 0 and 1 mapping min->max lung volume.
  final double normalizedVolume;

  const LungsWidget({
    super.key,
    required this.normalizedVolume,
  });

  @override
  Widget build(BuildContext context) {
    // Use a TweenAnimationBuilder to smoothly animate the volume changes.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: normalizedVolume),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, volume, child) {
        return CustomPaint(
          painter: _LungsPainter(normalizedVolume: volume),
          size: const Size(140, 200), // Adjusted size for oblong shape
        );
      },
    );
  }
}

class _LungsPainter extends CustomPainter {
  final double normalizedVolume;

  _LungsPainter({required this.normalizedVolume});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint lungPaint = Paint()
      ..color = Colors.pink.shade200.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final Paint outline = Paint()
      ..color = Colors.pink.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final double w = size.width;
    final double h = size.height;

    // Define the min and max dimensions for the lung shape
    final double minWidth = w * 0.3;
    final double maxWidth = w * 0.9;
    final double minHeight = h * 0.2;
    final double maxHeight = h * 0.95;

    // Interpolate width and height based on normalizedVolume.
    // Height expands more than width to create an oblong (elliptical) shape.
    final double lungWidth = lerpDouble(minWidth, maxWidth, normalizedVolume)!;
    final double lungHeight = lerpDouble(minHeight, maxHeight, normalizedVolume)!;

    // Center the shape in the canvas.
    final Rect lungRect = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: lungWidth,
      height: lungHeight,
    );

    // An oval shape (ellipse) fits the "oblongated" description well.
    canvas.drawOval(lungRect, lungPaint);
    canvas.drawOval(lungRect, outline);
  }

  @override
  bool shouldRepaint(covariant _LungsPainter oldDelegate) {
    // Repaint whenever the volume changes to drive the animation.
    return oldDelegate.normalizedVolume != normalizedVolume;
  }
}


