import 'package:flutter/material.dart';
import 'package:scuba_gas_laws_game/screens/gas_law_selection_screen.dart';
import 'package:scuba_gas_laws_game/screens/settings_screen.dart';

/// Starting screen with title and start button.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
              // Settings button in top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title with icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.science,
                            color: Colors.lightBlue.shade200,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Boyle's Law Lab",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.settings_applications,
                            color: Colors.lightBlue.shade200,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      // Start button
                      _StartButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GasLawSelectionScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Lab scene decoration
                      _LabScene(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glowing start button.
class _StartButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
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
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: const Text(
              'START EXPERIMENT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Decorative lab scene at the bottom.
class _LabScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Lab bench
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          // Lab equipment
          Positioned(
            bottom: 20,
            left: 40,
            child: _LabFlask(color: Colors.pink.shade300),
          ),
          Positioned(
            bottom: 20,
            left: 120,
            child: _TestTube(color: Colors.orange.shade300),
          ),
          Positioned(
            bottom: 20,
            left: 200,
            child: _TestTube(color: Colors.green.shade300),
          ),
          Positioned(
            bottom: 20,
            right: 200,
            child: _TestTube(color: Colors.purple.shade300),
          ),
          Positioned(
            bottom: 20,
            right: 120,
            child: _LabFlask(color: Colors.purple.shade300),
          ),
          Positioned(
            bottom: 20,
            right: 40,
            child: _LabFlask(color: Colors.green.shade300),
          ),
        ],
      ),
    );
  }
}

class _LabFlask extends StatelessWidget {
  final Color color;

  const _LabFlask({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _TestTube extends StatelessWidget {
  final Color color;

  const _TestTube({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

