import 'package:flutter/material.dart';
import '../../../core/services/sound_service.dart';
import 'gas_law_selection_screen.dart';

/// Starting screen with title and start button.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure music is playing when on home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soundService = SoundService();
      if (soundService.isMusicEnabled && !soundService.isBackgroundMusicPlaying) {
        soundService.playBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/HomeScreen_Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _StartButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GasLawSelectionScreen()),
                );
              },
            ),
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

