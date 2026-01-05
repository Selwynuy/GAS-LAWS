import 'package:flutter/material.dart';
import '../../core/services/sound_service.dart';

/// Button wrapper that plays touch sound on tap
class SoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SoundButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () {
              SoundService().playTouchSound();
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// TextButton wrapper with touch sound
class SoundTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SoundTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              SoundService().playTouchSound();
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// IconButton wrapper with touch sound
class SoundIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? tooltip;

  const SoundIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.style,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: onPressed == null
          ? null
          : () {
              SoundService().playTouchSound();
              onPressed?.call();
            },
      style: style,
      tooltip: tooltip,
    );
  }
}

