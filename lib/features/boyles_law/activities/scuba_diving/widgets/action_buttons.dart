import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/services/sound_service.dart';

/// Action button for diver controls (Ascend, Exhale, etc.)
class ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;
  final bool isSecondary;
  final bool allowHold; // If false, only triggers on single click

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isPrimary = false,
    this.isSecondary = false,
    this.allowHold = true,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _holdTimer;
  bool _isHeld = false;

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
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    SoundService().playTouchSound();
    _controller.forward();
    _isHeld = true;
    
    // Immediate action on press
    widget.onPressed();
    
    // Start repeating timer only if hold is allowed
    if (widget.allowHold) {
      _holdTimer?.cancel();
      _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isHeld && mounted) {
          widget.onPressed();
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _isHeld = false;
    _holdTimer?.cancel();
    _controller.reverse();
  }

  void _handleTapCancel() {
    _isHeld = false;
    _holdTimer?.cancel();
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
                color: widget.color.withValues(alpha: widget.isPrimary ? 0.8 : 0.5),
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
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        foregroundColor: Colors.blue.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

