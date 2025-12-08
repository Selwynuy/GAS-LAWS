import 'package:flutter/material.dart';

/// Visual representation of lungs that expands / shrinks with volume using image asset.
class LungsWidget extends StatefulWidget {
  /// Value between 0 and 1 mapping min->max lung volume.
  final double normalizedVolume;

  const LungsWidget({
    super.key,
    required this.normalizedVolume,
  });

  @override
  State<LungsWidget> createState() => _LungsWidgetState();
}

class _LungsWidgetState extends State<LungsWidget> {
  late double _previousVolume;
  late double _currentVolume;

  @override
  void initState() {
    super.initState();
    _previousVolume = widget.normalizedVolume;
    _currentVolume = widget.normalizedVolume;
  }

  @override
  void didUpdateWidget(LungsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.normalizedVolume != widget.normalizedVolume) {
      // Store previous value and update current for smooth transition
      _previousVolume = _currentVolume;
      _currentVolume = widget.normalizedVolume;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a TweenAnimationBuilder to smoothly animate from previous to new value
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.normalizedVolume), // Force rebuild when value changes
      tween: Tween<double>(begin: _previousVolume, end: widget.normalizedVolume),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, volume, child) {
        // Interpolate size based on normalizedVolume
        // Min size: 40% of base, Max size: 85% of base (keeps lungs within diver's chest)
        final double minScale = 0.4;
        final double maxScale = 0.85;
        final double scale = minScale + (maxScale - minScale) * volume.clamp(0.0, 1.0);
        
        return Transform.scale(
          scale: scale,
          child: Image.asset(
            'assets/Lungs2.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}


