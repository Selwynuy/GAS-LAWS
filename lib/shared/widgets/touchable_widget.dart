import 'package:flutter/material.dart';
import '../../core/services/sound_service.dart';

/// Wrapper widget that plays a touch sound on tap
class TouchableWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;

  const TouchableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playTouchSound();
        onTap?.call();
      },
      onTapDown: (details) {
        SoundService().playTouchSound();
        onTapDown?.call();
      },
      onTapUp: (details) {
        onTapUp?.call();
      },
      onTapCancel: () {
        onTapCancel?.call();
      },
      child: child,
    );
  }
}

/// Extension to easily wrap widgets with touch sound
extension TouchableExtension on Widget {
  Widget withTouchSound({
    VoidCallback? onTap,
    VoidCallback? onTapDown,
    VoidCallback? onTapUp,
    VoidCallback? onTapCancel,
  }) {
    return TouchableWidget(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: this,
    );
  }
}

