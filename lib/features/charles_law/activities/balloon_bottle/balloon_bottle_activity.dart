import 'package:flutter/material.dart';
import '../../../../core/services/sound_service.dart';

/// Balloon and Bottle Experiment for Charles Law.
class BalloonBottleActivity extends StatefulWidget {
  const BalloonBottleActivity({super.key});

  @override
  State<BalloonBottleActivity> createState() => _BalloonBottleActivityState();
}

class _BalloonBottleActivityState extends State<BalloonBottleActivity>
    with TickerProviderStateMixin {
  // Experiment state
  int _currentStep = 0;
  bool _cupPlaced = false;
  bool _hotWaterPoured = false;
  bool _bottleInCup = false;
  bool _balloonOnBottle = false;
  bool _containerPlaced = false;
  bool _bottleTransferred = false;
  bool _experimentComplete = false;

  // Positions
  Offset _cupPosition = const Offset(300, 400);
  Offset _bottlePosition = const Offset(300, 300);
  Offset _containerPosition = const Offset(500, 400);

  // Dragging state
  String? _draggingItem;

  // Physics
  double _temperature = 20.0; // Celsius
  double _balloonSize = 0.3; // Normalized size (0.3 = deflated, 1.0 = fully inflated)
  static const double _roomTemp = 20.0;
  static const double _hotTemp = 80.0;
  static const double _coldTemp = 5.0;

  // Animation controllers
  late AnimationController _balloonAnimationController;
  late AnimationController _steamAnimationController;
  late Animation<double> _balloonSizeAnimation;
  late Animation<double> _steamAnimation;

  // Item showcase positions (right side)
  final List<_ItemData> _items = [
    _ItemData(id: 'cup', label: 'Cup', icon: Icons.local_drink, used: false),
    _ItemData(id: 'bottle', label: 'Bottle', icon: Icons.water_drop, used: false),
    _ItemData(id: 'balloon', label: 'Balloon', icon: Icons.circle, used: false),
    _ItemData(id: 'container', label: 'Container', icon: Icons.square, used: false),
    _ItemData(id: 'hotWater', label: 'Hot Water', icon: Icons.whatshot, used: false),
    _ItemData(id: 'coldWater', label: 'Cold Water', icon: Icons.ac_unit, used: false),
  ];

  @override
  void initState() {
    super.initState();
    
    _balloonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _steamAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _balloonSizeAnimation = Tween<double>(begin: 0.3, end: 0.3).animate(
      CurvedAnimation(parent: _balloonAnimationController, curve: Curves.easeInOut),
    );

    _steamAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _steamAnimationController, curve: Curves.easeInOut),
    );

    _balloonSizeAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _balloonSize = _balloonSizeAnimation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _balloonAnimationController.dispose();
    _steamAnimationController.dispose();
    super.dispose();
  }

  void _updateTemperature() {
    double targetTemp = _roomTemp;
    
    if (_bottleInCup && _hotWaterPoured) {
      targetTemp = _hotTemp;
    } else if (_bottleTransferred && _containerPlaced) {
      targetTemp = _coldTemp;
    }

    if ((_temperature - targetTemp).abs() > 0.1) {
      setState(() {
        _temperature = _temperature + (targetTemp - _temperature) * 0.1;
      });
    } else {
      _temperature = targetTemp;
    }

    // Update balloon size based on temperature (Charles Law: V/T = constant)
    // Assuming room temp (20°C = 293K) gives size 0.3, hot (80°C = 353K) gives 1.0
    double targetSize;
    if (_temperature <= _roomTemp) {
      targetSize = 0.3;
    } else if (_temperature >= _hotTemp) {
      targetSize = 1.0;
    } else {
      // Linear interpolation between room temp and hot temp
      double ratio = (_temperature - _roomTemp) / (_hotTemp - _roomTemp);
      targetSize = 0.3 + (1.0 - 0.3) * ratio;
    }

    // For cold water, deflate further
    if (_bottleTransferred && _temperature < _roomTemp) {
      double coldRatio = (_temperature - _coldTemp) / (_roomTemp - _coldTemp);
      targetSize = 0.2 + (0.3 - 0.2) * coldRatio;
    }

    if ((_balloonSize - targetSize).abs() > 0.01) {
      _balloonSizeAnimation = Tween<double>(
        begin: _balloonSize,
        end: targetSize,
      ).animate(CurvedAnimation(
        parent: _balloonAnimationController,
        curve: Curves.easeInOut,
      ));
      _balloonAnimationController.forward(from: 0.0);
    }
  }

  void _onItemAccepted(String itemId, Offset dropPosition) {
    bool dropped = false;

    switch (itemId) {
      case 'cup':
        if (_currentStep == 0) {
          setState(() {
            _cupPosition = Offset(dropPosition.dx - 40, dropPosition.dy - 40);
            _cupPlaced = true;
            _currentStep = 1;
            _items.firstWhere((i) => i.id == 'cup').used = true;
            dropped = true;
          });
        }
        break;

      case 'hotWater':
        if (_currentStep == 1 && _cupPlaced) {
          setState(() {
            _hotWaterPoured = true;
            _currentStep = 2;
            _items.firstWhere((i) => i.id == 'hotWater').used = true;
            dropped = true;
          });
        }
        break;

      case 'bottle':
        if (_currentStep == 2 && _hotWaterPoured) {
          setState(() {
            _bottlePosition = Offset(_cupPosition.dx, _cupPosition.dy - 60);
            _bottleInCup = true;
            _currentStep = 3;
            _items.firstWhere((i) => i.id == 'bottle').used = true;
            dropped = true;
          });
        } else if (_currentStep == 6 && _containerPlaced && _bottleInCup) {
          setState(() {
            _bottlePosition = Offset(_containerPosition.dx, _containerPosition.dy - 60);
            _bottleInCup = false;
            _bottleTransferred = true;
            _currentStep = 7;
            dropped = true;
          });
          _updateTemperature();
        }
        break;

      case 'balloon':
        if (_currentStep == 3 && _bottleInCup) {
          setState(() {
            _balloonOnBottle = true;
            _currentStep = 4;
            _items.firstWhere((i) => i.id == 'balloon').used = true;
            dropped = true;
          });
          _updateTemperature();
        }
        break;

      case 'container':
        if (_currentStep == 4 && _balloonOnBottle) {
          setState(() {
            _containerPosition = Offset(dropPosition.dx - 40, dropPosition.dy - 40);
            _containerPlaced = true;
            _currentStep = 5;
            _items.firstWhere((i) => i.id == 'container').used = true;
            dropped = true;
          });
        }
        break;

      case 'coldWater':
        if (_currentStep == 5 && _containerPlaced) {
          setState(() {
            _currentStep = 6;
            _items.firstWhere((i) => i.id == 'coldWater').used = true;
            dropped = true;
          });
        }
        break;
    }

    if (dropped) {
      setState(() {
        _draggingItem = null;
      });
      SoundService().playTouchSound();
      
      // Check if experiment is complete
      if (_currentStep == 7 && !_experimentComplete) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionDialog();
        });
      }
    }
  }

  void _showCompletionDialog() {
    setState(() {
      _experimentComplete = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CompletionDialog(),
    );
  }

  void _resetExperiment() {
    setState(() {
      _currentStep = 0;
      _cupPlaced = false;
      _hotWaterPoured = false;
      _bottleInCup = false;
      _balloonOnBottle = false;
      _containerPlaced = false;
      _bottleTransferred = false;
      _experimentComplete = false;
      _temperature = _roomTemp;
      _balloonSize = 0.3;
      _cupPosition = const Offset(300, 400);
      _bottlePosition = const Offset(300, 300);
      _containerPosition = const Offset(500, 400);
      
      for (var item in _items) {
        item.used = false;
      }
    });
    _balloonAnimationController.reset();
  }

  String _getStepInstruction() {
    switch (_currentStep) {
      case 0:
        return 'STEP 1: Place the cup in the center of the table';
      case 1:
        return 'STEP 2: Pour hot water into the cup';
      case 2:
        return 'STEP 3: Put the empty transparent bottle inside the cup';
      case 3:
        return 'STEP 4: Place the balloon at the opening of the bottle';
      case 4:
        return 'STEP 5: Place a container beside the cup';
      case 5:
        return 'STEP 6: Pour cold water into the container';
      case 6:
        return 'STEP 7: Transfer the bottle from the hot cup to the cold container';
      case 7:
        return 'Experiment Complete! Observe the balloon behavior.';
      default:
        return 'Follow the steps to complete the experiment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Charles Law: Balloon & Bottle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.grey.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _updateTemperature();
                    return Stack(
                      children: [
                        // Table surface
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.only(top: 100),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        
                        // Cup
                        if (_cupPlaced)
                          Positioned(
                            left: _cupPosition.dx,
                            top: _cupPosition.dy,
                            child: _CupWidget(hasHotWater: _hotWaterPoured),
                          ),

                        // Hot water steam
                        if (_hotWaterPoured && _bottleInCup)
                          Positioned(
                            left: _cupPosition.dx + 20,
                            top: _cupPosition.dy - 30,
                            child: _SteamWidget(animation: _steamAnimation),
                          ),

                        // Container
                        if (_containerPlaced)
                          Positioned(
                            left: _containerPosition.dx,
                            top: _containerPosition.dy,
                            child: _ContainerWidget(hasColdWater: _currentStep >= 6),
                          ),

                        // Bottle
                        if (_bottleInCup || _bottleTransferred)
                          Positioned(
                            left: _bottlePosition.dx,
                            top: _bottlePosition.dy,
                            child: const _BottleWidget(),
                          ),

                        // Balloon on bottle
                        if (_balloonOnBottle)
                          Positioned(
                            left: _bottlePosition.dx + 10,
                            top: _bottlePosition.dy - 60,
                            child: _BalloonWidget(size: _balloonSize),
                          ),

                        // Drop zones
                        // Cup drop zone
                        if (_currentStep == 0)
                          Positioned(
                            left: 200,
                            top: 300,
                            child: _DropZone(
                              width: 200,
                              height: 200,
                              label: 'Place Cup Here',
                              onAccept: (itemId, position) {
                                if (itemId == 'cup') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Hot water drop zone
                        if (_currentStep == 1 && _cupPlaced)
                          Positioned(
                            left: _cupPosition.dx - 20,
                            top: _cupPosition.dy - 20,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Pour Hot Water',
                              onAccept: (itemId, position) {
                                if (itemId == 'hotWater') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Bottle drop zone (in cup)
                        if (_currentStep == 2 && _hotWaterPoured)
                          Positioned(
                            left: _cupPosition.dx - 20,
                            top: _cupPosition.dy - 20,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Place Bottle',
                              onAccept: (itemId, position) {
                                if (itemId == 'bottle') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Balloon drop zone (on bottle)
                        if (_currentStep == 3 && _bottleInCup)
                          Positioned(
                            left: _bottlePosition.dx - 30,
                            top: _bottlePosition.dy - 80,
                            child: _DropZone(
                              width: 100,
                              height: 100,
                              label: 'Place Balloon',
                              onAccept: (itemId, position) {
                                if (itemId == 'balloon') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Container drop zone
                        if (_currentStep == 4 && _balloonOnBottle)
                          Positioned(
                            left: 400,
                            top: 300,
                            child: _DropZone(
                              width: 200,
                              height: 200,
                              label: 'Place Container',
                              onAccept: (itemId, position) {
                                if (itemId == 'container') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Cold water drop zone
                        if (_currentStep == 5 && _containerPlaced)
                          Positioned(
                            left: _containerPosition.dx - 20,
                            top: _containerPosition.dy - 20,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Pour Cold Water',
                              onAccept: (itemId, position) {
                                if (itemId == 'coldWater') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Bottle transfer drop zone
                        if (_currentStep == 6 && _containerPlaced)
                          Positioned(
                            left: _containerPosition.dx - 20,
                            top: _containerPosition.dy - 20,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Transfer Bottle',
                              onAccept: (itemId, position) {
                                if (itemId == 'bottle') {
                                  _onItemAccepted(itemId, position);
                                }
                              },
                            ),
                          ),

                        // Item showcase panel (right side)
                        Positioned(
                          right: 10,
                          top: 80,
                          bottom: 100,
                          width: 120,
                          child: _ItemShowcasePanel(
                            items: _items,
                            draggingItem: _draggingItem,
                            onDragStart: (itemId) {
                              setState(() {
                                _draggingItem = itemId;
                              });
                            },
                            onDragEnd: () {
                              setState(() {
                                _draggingItem = null;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Instructions and info panel
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.white.withValues(alpha: 0.95),
                child: Column(
                  children: [
                    Text(
                      _getStepInstruction(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentStep == 7 ? Colors.green.shade700 : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _temperature > _roomTemp 
                                ? Colors.red.shade100 
                                : _temperature < _roomTemp 
                                    ? Colors.blue.shade100 
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _temperature > _roomTemp 
                                  ? Colors.red.shade300 
                                  : _temperature < _roomTemp 
                                      ? Colors.blue.shade300 
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _temperature > _roomTemp 
                                    ? Icons.whatshot 
                                    : _temperature < _roomTemp 
                                        ? Icons.ac_unit 
                                        : Icons.thermostat,
                                size: 16,
                                color: _temperature > _roomTemp 
                                    ? Colors.red.shade700 
                                    : _temperature < _roomTemp 
                                        ? Colors.blue.shade700 
                                        : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_temperature.toStringAsFixed(0)}°C',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _temperature > _roomTemp 
                                      ? Colors.red.shade700 
                                      : _temperature < _roomTemp 
                                          ? Colors.blue.shade700 
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade300),
                          ),
                          child: Text(
                            'Balloon: ${(_balloonSize * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('RESET'),
                      onPressed: _resetExperiment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
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

class _ItemData {
  final String id;
  final String label;
  final IconData icon;
  bool used;

  _ItemData({
    required this.id,
    required this.label,
    required this.icon,
    this.used = false,
  });
}

class _ItemShowcasePanel extends StatelessWidget {
  final List<_ItemData> items;
  final String? draggingItem;
  final Function(String) onDragStart;
  final VoidCallback onDragEnd;

  const _ItemShowcasePanel({
    required this.items,
    required this.draggingItem,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Materials',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.used && draggingItem != item.id) {
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Draggable<String>(
                    data: item.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade400, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Icon(item.icon, size: 30, color: Colors.blue.shade700),
                      ),
                    ),
                    childWhenDragging: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 30, color: Colors.grey.shade600),
                    ),
                    onDragStarted: () {
                      onDragStart(item.id);
                      SoundService().playTouchSound();
                    },
                    onDragEnd: (_) {
                      onDragEnd();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 24, color: Colors.blue.shade700),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CupWidget extends StatelessWidget {
  final bool hasHotWater;

  const _CupWidget({required this.hasHotWater});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _CupPainter(hasHotWater: hasHotWater),
    );
  }
}

class _CupPainter extends CustomPainter {
  final bool hasHotWater;

  _CupPainter({required this.hasHotWater});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey.shade700;

    // Cup body
    final cupPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..close();

    canvas.drawPath(cupPath, paint);
    canvas.drawPath(cupPath, strokePaint);

    // Handle
    final handlePath = Path()
      ..moveTo(size.width * 0.8, size.height * 0.4)
      ..quadraticBezierTo(size.width * 1.1, size.height * 0.35, size.width * 1.1, size.height * 0.5)
      ..quadraticBezierTo(size.width * 1.1, size.height * 0.65, size.width * 0.8, size.height * 0.6);

    canvas.drawPath(handlePath, strokePaint);

    // Hot water
    if (hasHotWater) {
      final waterPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.orange.shade200.withValues(alpha: 0.7);

      final waterPath = Path()
        ..moveTo(size.width * 0.25, size.height * 0.5)
        ..lineTo(size.width * 0.75, size.height * 0.5)
        ..lineTo(size.width * 0.75, size.height * 0.8)
        ..lineTo(size.width * 0.25, size.height * 0.8)
        ..close();

      canvas.drawPath(waterPath, waterPaint);
    }
  }

  @override
  bool shouldRepaint(_CupPainter oldDelegate) => oldDelegate.hasHotWater != hasHotWater;
}

class _BottleWidget extends StatelessWidget {
  const _BottleWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 100),
      painter: _BottlePainter(),
    );
  }
}

class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.blue.shade300;

    // Bottle outline (transparent)
    final bottlePath = Path()
      ..moveTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.3, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.5, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width * 0.7, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height)
      ..close();

    canvas.drawPath(bottlePath, paint);

    // Glass reflection
    final reflectionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.3);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.3, size.width * 0.2, size.height * 0.4),
      reflectionPaint,
    );
  }

  @override
  bool shouldRepaint(_BottlePainter oldDelegate) => false;
}

class _BalloonWidget extends StatelessWidget {
  final double size;

  const _BalloonWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    final balloonSize = 40.0 + (size * 60.0);
    return CustomPaint(
      size: Size(balloonSize, balloonSize),
      painter: _BalloonPainter(size: size),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final double size;

  _BalloonPainter({required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red.shade300;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.red.shade700;

    // Balloon shape (ellipse)
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
      strokePaint,
    );

    // Highlight
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radiusX * 0.3, center.dy - radiusY * 0.3),
        width: radiusX * 0.6,
        height: radiusY * 0.6,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_BalloonPainter oldDelegate) => oldDelegate.size != size;
}

class _ContainerWidget extends StatelessWidget {
  final bool hasColdWater;

  const _ContainerWidget({required this.hasColdWater});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 80),
      painter: _ContainerPainter(hasColdWater: hasColdWater),
    );
  }
}

class _ContainerPainter extends CustomPainter {
  final bool hasColdWater;

  _ContainerPainter({required this.hasColdWater});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.shade200;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey.shade700;

    // Container (rectangular)
    final containerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(containerRect, paint);
    canvas.drawRect(containerRect, strokePaint);

    // Cold water
    if (hasColdWater) {
      final waterPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.blue.shade200.withValues(alpha: 0.7);

      final waterRect = Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.4,
      );
      canvas.drawRect(waterRect, waterPaint);
    }
  }

  @override
  bool shouldRepaint(_ContainerPainter oldDelegate) => oldDelegate.hasColdWater != hasColdWater;
}

class _SteamWidget extends StatelessWidget {
  final Animation<double> animation;

  const _SteamWidget({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(40, 60),
          painter: _SteamPainter(progress: animation.value),
        );
      },
    );
  }
}

class _SteamPainter extends CustomPainter {
  final double progress;

  _SteamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.6 - progress * 0.4);

    final offsetY = progress * size.height;

    // Steam particles
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height - offsetY + (i * 5.0);
      
      canvas.drawCircle(
        Offset(x, y),
        3 + i * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter oldDelegate) => oldDelegate.progress != progress;
}

class _DropZone extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final Function(String, Offset) onAccept;

  const _DropZone({
    required this.width,
    required this.height,
    required this.label,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (itemId) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          onAccept(itemId.data, position);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? Colors.green.shade100.withValues(alpha: 0.5)
                : Colors.blue.shade50.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted
                  ? Colors.green.shade400
                  : Colors.blue.shade300,
              width: isHighlighted ? 3 : 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHighlighted
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WHAT DO YOU OBSERVE IN YOUR EXPERIMENT?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'WHAT HAPPENED TO THE BALLOON AS THE BOTTLE IS PLACED IN A HOT WATER?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'The balloon inflated because the air inside the bottle expanded due to increased temperature (Charles Law: Volume increases with temperature at constant pressure).',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'WHAT ABOUT IN THE COLD WATER?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'The balloon deflated because the air inside the bottle contracted due to decreased temperature (Charles Law: Volume decreases with temperature at constant pressure).',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
