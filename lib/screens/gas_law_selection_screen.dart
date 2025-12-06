import 'package:flutter/material.dart';
import 'package:scuba_gas_laws_game/screens/boyles_law_activity.dart';
import 'package:scuba_gas_laws_game/screens/settings_screen.dart';

/// Screen for selecting which gas law to explore.
class GasLawSelectionScreen extends StatelessWidget {
  const GasLawSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF003366),
              Color(0xFF006699),
              Color(0xFF001122),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with icons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Settings button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.settings, color: Colors.white, size: 24),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    // Info/Help button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                      ),
                      onPressed: () {
                        // TODO: Show info dialog
                      },
                    ),
                    // Home button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.home, color: Colors.white, size: 24),
                      ),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Stack(
                  children: [
                    // Spotlight effect
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Gas law buttons
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GasLawButton(
                            title: "Boyle's Law",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BoylesLawActivity()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _GasLawButton(
                            title: "Charles Law",
                            onPressed: () {
                              // TODO: Navigate to Charles Law screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Charles Law coming soon!')),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _GasLawButton(
                            title: "Mixed Gas Law",
                            onPressed: () {
                              // TODO: Navigate to Mixed Gas Law screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mixed Gas Law coming soon!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Lab scene at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _LabSceneWithScientist(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glowing gas law selection button.
class _GasLawButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;

  const _GasLawButton({
    required this.title,
    required this.onPressed,
  });

  @override
  State<_GasLawButton> createState() => _GasLawButtonState();
}

class _GasLawButtonState extends State<_GasLawButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlue.withOpacity(_glowAnimation.value * 0.8),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
          ),
          child: SizedBox(
            width: 280,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lab scene with scientist character at the bottom.
class _LabSceneWithScientist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Lab bench
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          // Glassware and scientist
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left side glassware
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ConicalFlask(color: Colors.purple.shade300),
                    const SizedBox(height: 8),
                    _StirringRod(),
                  ],
                ),
                // Retort stand with flask
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoundBottomFlask(color: Colors.pink.shade300, hasBubbles: true),
                    const SizedBox(height: 4),
                    _RetortStand(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TestTube(color: Colors.orange.shade300),
                        const SizedBox(width: 8),
                        _TestTube(color: Colors.teal.shade300),
                      ],
                    ),
                  ],
                ),
                // Center - scientist and beaker
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ScientistCharacter(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Beaker(color: Colors.orange.shade300),
                        const SizedBox(width: 12),
                        _TestTube(color: Colors.purple.shade300),
                      ],
                    ),
                  ],
                ),
                // Right side glassware
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundBottomFlask(color: Colors.green.shade300, hasBubbles: true),
                        const SizedBox(width: 8),
                        _RoundBottomFlask(color: Colors.pink.shade300, hasBubbles: false),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _RetortStand(),
                    const SizedBox(height: 4),
                    _TestTube(color: Colors.red.shade300),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConicalFlask extends StatelessWidget {
  final Color color;

  const _ConicalFlask({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _RoundBottomFlask extends StatelessWidget {
  final Color color;
  final bool hasBubbles;

  const _RoundBottomFlask({required this.color, required this.hasBubbles});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 35,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        if (hasBubbles)
          Positioned(
            top: -8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
                const SizedBox(width: 2),
                Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TestTube extends StatelessWidget {
  final Color color;

  const _TestTube({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 35,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _Beaker extends StatelessWidget {
  final Color color;

  const _Beaker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _RetortStand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 25,
      color: Colors.grey.shade700,
    );
  }
}

class _StirringRod extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _ScientistCharacter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lab coat body
          Positioned(
            bottom: 0,
            child: Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 0,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade400, width: 2),
              ),
            ),
          ),
          // Goggles
          Positioned(
            top: 8,
            child: Container(
              width: 45,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.orange.shade300.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade600, width: 2),
              ),
            ),
          ),
          // Smile
          Positioned(
            top: 20,
            child: Container(
              width: 20,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          // Right hand (gesturing)
          Positioned(
            right: 0,
            top: 25,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade400, width: 1),
              ),
            ),
          ),
          // Paper on bench
          Positioned(
            bottom: 5,
            left: -10,
            child: Container(
              width: 20,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

