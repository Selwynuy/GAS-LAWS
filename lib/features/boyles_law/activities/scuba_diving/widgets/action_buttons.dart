import 'package:flutter/material.dart';
import '../../../../../core/services/sound_service.dart';

/// Action button for diver controls (Ascend, Exhale, etc.)
class ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;
  final bool isSecondary;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isPrimary = false,
    this.isSecondary = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    SoundService().playTouchSound();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(widget.isPrimary ? 0.8 : 0.5),
                blurRadius: widget.isPrimary ? 20 : 15,
                spreadRadius: widget.isPrimary ? 4 : 3,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(
              minWidth: 80,
              minHeight: 80,
            ),
            child: Center(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature button for Volume, Pressure, Temperature, Graph, Calculator
class FeatureButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const FeatureButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        SoundService().playTouchSound();
        onPressed();
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.blue.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

