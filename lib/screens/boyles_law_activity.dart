import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Boyle's Law Activity: Syringe and Balloon demonstration.
class BoylesLawActivity extends StatefulWidget {
  const BoylesLawActivity({super.key});

  @override
  State<BoylesLawActivity> createState() => _BoylesLawActivityState();
}

class _BoylesLawActivityState extends State<BoylesLawActivity> {
  // Syringe state
  double _maxVolume = 60.0; // mL
  double _currentVolume = 30.0; // Current volume in mL
  double _plungerPosition = 0.5; // 0.0 (bottom) to 1.0 (top)

  // Balloon state
  bool _balloonInSyringe = false;
  Offset _balloonPosition = const Offset(250, 350); // Initial position for dragging
  double _balloonSize = 1.0; // Scale factor based on pressure
  bool _isAtMaxPressure = false; // Visual feedback flag

  // System state
  bool _isSealed = false; // Finger sealing the opening
  double _pressure = 1.0; // atm (atmospheric pressure)
  double _initialVolume = 30.0; // Volume when sealed
  double _minVolume = 1.0; // Minimum volume when balloon is at max pressure

  // Balloon physical limit
  static const double _maxBalloonPressure = 3.0; // atm - maximum pressure balloon can withstand
  static const double _balloonBaseHeight = 60.0; // pixels - base height of balloon widget

  // Graph data points
  final List<Offset> _graphPoints = [];

  @override
  void initState() {
    super.initState();
    _resetActivity();
  }

  void _onPlungerDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Vertical drag: dragging up pulls plunger out (increases volume)
      // dragging down pushes plunger in (decreases volume)
      final delta = -details.delta.dy / 300; // Normalize based on syringe height
      double newPlungerPosition = (_plungerPosition + delta).clamp(0.0, 1.0);

      // Calculate new volume
      double newVolume = newPlungerPosition * _maxVolume;
      if (newVolume < 1) newVolume = 1; // Min volume to avoid errors

      // If balloon is in syringe, enforce minimum volume limit
      if (_balloonInSyringe) {
        if (_isSealed) {
          // Sealed: prevent volume from going below minimum (balloon pressure limit)
          if (newVolume < _minVolume) {
            newVolume = _minVolume;
            newPlungerPosition = _minVolume / _maxVolume;
          }
        } else {
          // Unsealed: prevent plunger from touching balloon (physical size limit)
          // Calculate minimum volume based on balloon's physical size
          // Balloon takes up space, so plunger can't compress it beyond its size
          // When unsealed, balloon size is 1.0, so it's at base height
          // Estimate: balloon height (60px) relative to typical syringe usable height (~400px)
          // This gives us a minimum volume percentage
          final double balloonPhysicalHeight = _balloonBaseHeight * _balloonSize;
          // Convert balloon height to volume (linear relationship: height proportional to volume)
          // Typical syringe usable height is ~400px (after accounting for opening and plunger)
          const double typicalSyringeUsableHeight = 400.0;
          final double minVolumeUnsealed = (balloonPhysicalHeight / typicalSyringeUsableHeight) * _maxVolume;
          // Ensure minimum is at least 10% of max volume to be safe
          final double safeMinVolume = math.max(minVolumeUnsealed, _maxVolume * 0.1);
          if (newVolume < safeMinVolume) {
            newVolume = safeMinVolume;
            newPlungerPosition = safeMinVolume / _maxVolume;
          }
        }
      }

      _plungerPosition = newPlungerPosition;
      _currentVolume = newVolume;

      if (_isSealed && _balloonInSyringe) {
        // Apply Boyle's Law
        if (_currentVolume > 0.1 && _initialVolume > 0) {
          double calculatedPressure = (1.0 * _initialVolume) / _currentVolume;
          
          // Cap pressure at balloon's maximum
          if (calculatedPressure > _maxBalloonPressure) {
            _pressure = _maxBalloonPressure;
            _isAtMaxPressure = true;
            // Recalculate volume to match capped pressure
            _currentVolume = (1.0 * _initialVolume) / _maxBalloonPressure;
            _plungerPosition = _currentVolume / _maxVolume;
          } else {
            _pressure = calculatedPressure;
            _isAtMaxPressure = false;
          }
          
          _pressure = _pressure.clamp(0.1, _maxBalloonPressure);
          _balloonSize = (1.0 / _pressure).clamp(0.2, 1.5);
          _addGraphPoint();
        }
      }
    });
  }

  void _addGraphPoint() {
    _graphPoints.add(Offset(_currentVolume, _pressure));
    if (_graphPoints.length > 50) {
      _graphPoints.removeAt(0);
    }
  }

  void _onBalloonDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_balloonInSyringe) return;
    setState(() {
      _balloonPosition = Offset(
        (_balloonPosition.dx + details.delta.dx).clamp(0, constraints.maxWidth - 50),
        (_balloonPosition.dy + details.delta.dy).clamp(0, constraints.maxHeight - 60),
      );
    });
  }

  void _onBalloonDragEnd(DragEndDetails details) {
    // Check if balloon is dropped near syringe opening (bottom of syringe)
    // Syringe is on the left, let's say its center X is around 100
    final syringeOpeningX = 100.0;
    final syringeOpeningY = 450.0; // Approximate bottom of the screen

    if ((_balloonPosition.dx - syringeOpeningX).abs() < 100 &&
        (_balloonPosition.dy - syringeOpeningY).abs() < 100) {
      setState(() {
        _balloonInSyringe = true;
      });
    }
  }

  void _toggleSeal() {
    setState(() {
      _isSealed = !_isSealed;
      if (_isSealed && _balloonInSyringe) {
        _initialVolume = _currentVolume;
        _pressure = 1.0;
        // Calculate minimum volume based on max balloon pressure
        // P1 * V1 = P2 * V2 => V2 = (P1 * V1) / P2
        _minVolume = (1.0 * _initialVolume) / _maxBalloonPressure;
        _isAtMaxPressure = false;
        _graphPoints.clear();
        _addGraphPoint();
      } else {
        _pressure = 1.0;
        _balloonSize = 1.0;
        _isAtMaxPressure = false;
        _minVolume = 1.0;
      }
    });
  }

  void _resetActivity() {
    setState(() {
      _balloonInSyringe = false;
      _balloonPosition = const Offset(250, 350);
      _balloonSize = 1.0;
      _isSealed = false;
      _pressure = 1.0;
      _plungerPosition = 0.5;
      _currentVolume = _maxVolume / 2;
      _initialVolume = _maxVolume / 2;
      _minVolume = 1.0;
      _isAtMaxPressure = false;
      _graphPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Boyle's Law: Vertical Syringe"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.orange.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main interactive area
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Left side: Syringe
                      Positioned(
                        left: 20,
                        top: 20,
                        bottom: 20,
                        width: 120,
                        child: _VerticalSyringeWidget(
                          plungerPosition: _plungerPosition,
                          isSealed: _isSealed,
                          balloonInSyringe: _balloonInSyringe,
                          balloonSize: _balloonSize,
                          isAtMaxPressure: _isAtMaxPressure,
                          onPlungerDrag: _onPlungerDragUpdate,
                        ),
                      ),
                      // Graph on top right
                      Positioned(
                        top: 20,
                        right: 20,
                        width: constraints.maxWidth - 180,
                        height: 250,
                        child: _PressureVolumeGraph(
                          points: _graphPoints,
                          currentVolume: _currentVolume,
                          currentPressure: _pressure,
                        ),
                      ),
                      // Draggable balloon if not in syringe
                      if (!_balloonInSyringe)
                        Positioned(
                          left: _balloonPosition.dx,
                          top: _balloonPosition.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) => _onBalloonDragUpdate(details, constraints),
                            onPanEnd: _onBalloonDragEnd,
                            child: const _BalloonWidget(),
                          ),
                        ),
                    ],
                  );
                }),
              ),
              // Info and controls
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  children: [
                    Text(
                      !_balloonInSyringe
                          ? 'STEP 1: Drag the balloon into the syringe'
                          : !_isSealed
                              ? 'STEP 2: Adjust volume, then SEAL OPENING'
                              : _isAtMaxPressure
                                  ? 'STEP 3: Balloon at MAX PRESSURE! Cannot compress further.'
                                  : 'STEP 3: Change volume to see Boyle\'s Law',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isAtMaxPressure ? Colors.red.shade700 : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('VOLUME: ${_currentVolume.toStringAsFixed(0)} ml', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('PRESSURE: ${_pressure.toStringAsFixed(2)} atm', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: const Text('RELEASE'),
                          onPressed: _isSealed ? _toggleSeal : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock),
                          label: const Text('SEAL'),
                          onPressed: !_isSealed && _balloonInSyringe ? _toggleSeal : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('RESET'),
                          onPressed: _resetActivity,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                        ),
                      ],
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

/// Vertical syringe widget.
class _VerticalSyringeWidget extends StatelessWidget {
  final double plungerPosition; // 0.0 (bottom) to 1.0 (top)
  final bool isSealed;
  final bool balloonInSyringe;
  final double balloonSize;
  final bool isAtMaxPressure;
  final Function(DragUpdateDetails) onPlungerDrag;

  const _VerticalSyringeWidget({
    required this.plungerPosition,
    required this.isSealed,
    required this.balloonInSyringe,
    required this.balloonSize,
    required this.isAtMaxPressure,
    required this.onPlungerDrag,
  });

  @override
  Widget build(BuildContext context) {
    const syringeWidth = 100.0;
    const plungerHandleHeight = 20.0;
    const plungerHeadHeight = 15.0;
    const openingHeight = 20.0;

    return LayoutBuilder(builder: (context, constraints) {
      final syringeHeight = constraints.maxHeight;
      final double airVolumeMaxHeight = syringeHeight - openingHeight - plungerHeadHeight;
      final double plungerHeadBottom = openingHeight + (plungerPosition * airVolumeMaxHeight);

      return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Syringe barrel
          Positioned(
            bottom: 0,
            left: (constraints.maxWidth - syringeWidth) / 2,
            child: Container(
              width: syringeWidth,
              height: syringeHeight,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade600, width: 4),
              ),
            ),
          ),
          // Balloon
          if (balloonInSyringe)
            Positioned(
              bottom: openingHeight,
              height: plungerHeadBottom > openingHeight ? plungerHeadBottom - openingHeight : 0,
              left: (constraints.maxWidth - syringeWidth) / 2,
              width: syringeWidth,
              child: Align(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: balloonSize,
                  child: _BalloonWidget(isAtMaxPressure: isAtMaxPressure),
                ),
              ),
            ),
          
          // Plunger Assembly
          Positioned(
            bottom: plungerHeadBottom,
            left: (constraints.maxWidth - (syringeWidth + 20)) / 2,
            child: GestureDetector(
              onVerticalDragUpdate: onPlungerDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: syringeWidth + 20,
                    height: plungerHandleHeight,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black54, width: 2),
                    ),
                    child: const Icon(Icons.drag_handle, color: Colors.white),
                  ),
                  // Shaft
                  Container(
                    width: 10,
                    height: syringeHeight - plungerHeadBottom,
                    color: Colors.grey.shade500,
                  ),
                  // Head
                  Container(
                    width: syringeWidth - 10,
                    height: plungerHeadHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Opening
          Positioned(
            bottom: 0,
            left: (constraints.maxWidth - 40) / 2,
            child: Container(
              width: 40,
              height: openingHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
            ),
          ),
          if (isSealed)
            Positioned(
              bottom: -15,
              child: Icon(Icons.pan_tool, color: Colors.pink.shade300, size: 30),
            ),
        ],
      );
    });
  }
}

/// Balloon widget.
class _BalloonWidget extends StatelessWidget {
  final bool isAtMaxPressure;

  const _BalloonWidget({this.isAtMaxPressure = false});

  @override
  Widget build(BuildContext context) {
    final color = isAtMaxPressure ? Colors.orange.shade700 : Colors.red.shade300;
    final innerColor = isAtMaxPressure ? Colors.orange.shade500 : Colors.red.shade200;
    
    return SizedBox(
      width: 50,
      height: 60,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: isAtMaxPressure ? 6.0 : 4.0,
        child: Center(
          child: Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: innerColor.withOpacity(0.8),
              shape: BoxShape.circle,
              border: isAtMaxPressure
                  ? Border.all(color: Colors.red.shade900, width: 2)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}


/// Pressure vs Volume graph.
class _PressureVolumeGraph extends StatelessWidget {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  const _PressureVolumeGraph({
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pressure-Volume Graph',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'Pressure (atm)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomPaint(
                    painter: _GraphPainter(
                      points: points,
                      currentVolume: currentVolume,
                      currentPressure: currentPressure,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Volume (ml)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double currentVolume;
  final double currentPressure;

  _GraphPainter({
    required this.points,
    required this.currentVolume,
    required this.currentPressure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double leftPadding = 30;
    final double bottomPadding = 20;
    final double rightPadding = 10;
    final double topPadding = 10;

    final double graphWidth = size.width - leftPadding - rightPadding;
    final double graphHeight = size.height - topPadding - bottomPadding;

    final Offset origin = Offset(leftPadding, size.height - bottomPadding);

    final paint = Paint()
      ..color = Colors.orange.shade600
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.5;

    canvas.drawLine(origin, Offset(origin.dx + graphWidth, origin.dy), axisPaint); // X-axis
    canvas.drawLine(origin, Offset(origin.dx, origin.dy - graphHeight), axisPaint); // Y-axis

    // Draw grid lines and labels
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    
    final textStyle = TextStyle(
      color: Colors.grey.shade800,
      fontSize: 9,
    );

    const int numGridLines = 5;
    const maxVolume = 60.0;
    const maxPressure = 6.0;

    // Y-axis grid lines and labels
    for (int i = 0; i <= numGridLines; i++) {
      final y = origin.dy - (i * graphHeight / numGridLines);
      if (i > 0) { // Don't draw grid line on the axis itself
        canvas.drawLine(Offset(origin.dx, y), Offset(origin.dx + graphWidth, y), gridPaint);
      }

      final pressure = (i * maxPressure / numGridLines);
      final textSpan = TextSpan(text: pressure.toStringAsFixed(1), style: textStyle);
      final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.right, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(origin.dx - textPainter.width - 6, y - textPainter.height / 2));
    }

    // X-axis grid lines and labels
    for (int i = 0; i <= numGridLines; i++) {
      final x = origin.dx + (i * graphWidth / numGridLines);
      if (i > 0) { // Don't draw grid line on the axis itself
        canvas.drawLine(Offset(x, origin.dy), Offset(x, origin.dy - graphHeight), gridPaint);
      }

      final volume = (i * maxVolume / numGridLines);
      final textSpan = TextSpan(text: volume.toStringAsFixed(0), style: textStyle);
      final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, origin.dy + 6));
    }

    // Draw curve
    if (points.length > 1) {
      final path = Path();
      
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final x = origin.dx + (point.dx / maxVolume) * graphWidth;
        final y = origin.dy - (point.dy / maxPressure) * graphHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw current point
    if (currentVolume > 0 && currentPressure > 0) {
      final x = origin.dx + (currentVolume / maxVolume) * graphWidth;
      final y = origin.dy - (currentPressure / maxPressure) * graphHeight;

      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      canvas.drawCircle(Offset(x, y), 5, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

