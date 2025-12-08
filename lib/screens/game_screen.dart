import 'package:flutter/material.dart';

import '../logic/diving_physics.dart';
import '../widgets/info_panel.dart';
import '../widgets/control_buttons.dart';
import '../widgets/lungs_widget.dart';
import '../widgets/volume_pressure_chart.dart';

/// Main game screen with underwater background, diver, lungs, and controls.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late DivingState _state;

  // AnimationController drives smooth transitions for depth / lung size.
  late AnimationController _controller;
  late Animation<double> _depthAnimation;

  double _targetDepth = 10.0;

  // For the optional Volume vs Pressure chart.
  final List<VolumePressurePoint> _history = [];
  static const int _maxHistoryPoints = 20;

  @override
  void initState() {
    super.initState();
    _state = DivingState(
      depthMeters: 10.0,
      lungVolumeLiters: 6.0,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _depthAnimation = Tween<double>(
      begin: _state.depthMeters,
      end: _targetDepth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        // As depth animates, continuously update physics state.
        setState(() {
          _state.setDepth(_depthAnimation.value);
          _pushHistory();
          _state.consumeOxygen(amount: 0.02);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToDepth(double newDepth) {
    _targetDepth = newDepth;
    _depthAnimation = Tween<double>(
      begin: _state.depthMeters,
      end: _targetDepth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller
      ..reset()
      ..forward();
  }

  void _onAscendSlowly() {
    _animateToDepth(ascendDepthStep(_state.depthMeters));
  }

  void _onDescend() {
    _animateToDepth(descendDepthStep(_state.depthMeters));
  }

  void _onEmergencyAscent() {
    _animateToDepth(emergencyAscentDepth(_state.depthMeters));
  }

  void _onExhale() {
    setState(() {
      _state.exhale(liters: 0.7);
      _state.consumeOxygen(amount: 0.1);
      _pushHistory();
    });
  }

  void _pushHistory() {
    _history.add(
      VolumePressurePoint(
        pressure: _state.pressureAtm,
        volume: _state.lungVolumeLiters,
      ),
    );
    if (_history.length > _maxHistoryPoints) {
      _history.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalize lung volume into [0,1] for the lungs widget.
    final double normalizedLungVolume =
        ((_state.lungVolumeLiters - 1.0) / (10.0 - 1.0)).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/HomeScreen_Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InfoPanel(state: _state),
              ),
              if (_state.isLungVolumeUnsafe)
                const _WarningBanner(
                  message:
                      'Warning: Lungs over-expanded! Ascend slower or exhale!',
                ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Diver + lungs in the center.
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DiverPlaceholder(),
                        const SizedBox(height: 16),
                        LungsWidget(normalizedVolume: normalizedLungVolume),
                      ],
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: SizedBox(
                        width: 160,
                        child: VolumePressureChart(points: _history),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: ControlButtons(
                  onAscendSlowly: _onAscendSlowly,
                  onExhale: _onExhale,
                  onEmergencyAscent: _onEmergencyAscent,
                  onDescend: _onDescend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flashing warning banner when lung volume exceeds safe limit.
class _WarningBanner extends StatefulWidget {
  final String message;

  const _WarningBanner({required this.message});

  @override
  State<_WarningBanner> createState() => _WarningBannerState();
}

class _WarningBannerState extends State<_WarningBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder diver widget. Swap this with an Image.asset of your diver PNG.
class _DiverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 2),
      ),
      alignment: Alignment.center,
      child: const Text(
        'DIVER\nPNG',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


