import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/services/sound_service.dart';

/// Balloon and Bottle Experiment for Charles Law.
/// Demonstrates: V₁/T₁ = V₂/T₂ (at constant pressure)
/// Step-by-step interactive experiment with drag-and-drop materials.
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
  bool _coldWaterPoured = false;
  bool _bottleTransferred = false;
  bool _experimentComplete = false;

  // Positions (using relative positioning)
  Offset? _cupPosition;
  Offset? _bottlePosition;
  Offset? _containerPosition;

  // Dragging state
  String? _draggingItem;

  // Physics - using proper Charles Law calculations
  double _temperatureCelsius = 20.0; // Room temperature
  static const double _roomTempC = 20.0;
  static const double _hotTempC = 80.0;
  static const double _coldTempC = 5.0;
  
  // Reference values for Charles Law calculation
  static const double _referenceTempK = 293.15; // 20°C in Kelvin
  static const double _referenceVolume = 1.0; // Normalized reference volume
  
  // Current volume (calculated from Charles Law)
  double _currentVolume = _referenceVolume;


  // Animation controller for smooth balloon size changes
  AnimationController? _animationController;
  Animation<double>? _volumeAnimation;
  AnimationController? _steamAnimationController;

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
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _steamAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _volumeAnimation = Tween<double>(
      begin: _referenceVolume,
      end: _referenceVolume,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    
    _volumeAnimation!.addListener(_onVolumeAnimationUpdate);
  }
  
  void _onVolumeAnimationUpdate() {
    if (mounted && _volumeAnimation != null) {
      setState(() {
        _currentVolume = _volumeAnimation!.value;
      });
    }
  }

  @override
  void dispose() {
    _volumeAnimation?.removeListener(_onVolumeAnimationUpdate);
    _animationController?.dispose();
    _steamAnimationController?.dispose();
    super.dispose();
  }

  /// Convert Celsius to Kelvin
  double _celsiusToKelvin(double celsius) => celsius + 273.15;

  /// Calculate volume using Charles Law: V₁/T₁ = V₂/T₂
  /// Therefore: V₂ = V₁ × (T₂/T₁)
  double _calculateVolume(double temperatureCelsius) {
    final temperatureK = _celsiusToKelvin(temperatureCelsius);
    final newVolume = _referenceVolume * (temperatureK / _referenceTempK);
    return newVolume.clamp(0.3, 2.0); // Clamp to reasonable visual range
  }

  /// Update temperature based on experiment state and animate volume change
  void _updateTemperatureFromState() {
    if (!mounted || _animationController == null) return;
    
    double targetTemp = _roomTempC;
    
    if (_bottleInCup && _hotWaterPoured && _balloonOnBottle) {
      targetTemp = _hotTempC;
    } else if (_bottleTransferred && _coldWaterPoured) {
      targetTemp = _coldTempC;
    }

    if ((_temperatureCelsius - targetTemp).abs() > 0.1) {
      setState(() {
        _temperatureCelsius = _temperatureCelsius + (targetTemp - _temperatureCelsius) * 0.1;
      });
      
      final targetVolume = _calculateVolume(_temperatureCelsius);
      
      // Remove old listener before recreating animation
      _volumeAnimation?.removeListener(_onVolumeAnimationUpdate);
      
      _volumeAnimation = Tween<double>(
        begin: _currentVolume,
        end: targetVolume,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ));
      
      // Reattach listener
      _volumeAnimation!.addListener(_onVolumeAnimationUpdate);
      
      _animationController!.forward(from: 0.0);
    }
  }


  void _onItemAccepted(String itemId, Offset dropPosition) {
    bool dropped = false;

    switch (itemId) {
      case 'cup':
        if (_currentStep == 0) {
          final screenSize = MediaQuery.of(context).size;
          // Center the cup on the table
          final centerX = screenSize.width / 2;
          final centerY = screenSize.height * 0.4; // Center of table area
          setState(() {
            _cupPosition = Offset(centerX, centerY);
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
        if (_currentStep == 2 && _hotWaterPoured && _cupPosition != null) {
          // Keep bottle position aligned with cup (which is already centered)
          setState(() {
            _bottlePosition = Offset(_cupPosition!.dx, _cupPosition!.dy);
            _bottleInCup = true;
            _currentStep = 3;
            _items.firstWhere((i) => i.id == 'bottle').used = true;
            dropped = true;
          });
          // Start temperature update after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            _updateTemperatureFromState();
          });
        } else if (_currentStep == 6 && _containerPlaced && _bottleInCup && _containerPosition != null) {
          setState(() {
            _bottlePosition = Offset(_containerPosition!.dx, _containerPosition!.dy - 60);
            _bottleInCup = false;
            _bottleTransferred = true;
            _currentStep = 7;
            dropped = true;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            _updateTemperatureFromState();
          });
        }
        break;

      case 'balloon':
        if (_currentStep == 3 && _bottleInCup && _cupPosition != null) {
          setState(() {
            _balloonOnBottle = true;
            _currentStep = 4;
            _items.firstWhere((i) => i.id == 'balloon').used = true;
            dropped = true;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            _updateTemperatureFromState();
          });
        }
        break;

      case 'container':
        if (_currentStep == 4 && _balloonOnBottle) {
          setState(() {
            _containerPosition = dropPosition;
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
            _coldWaterPoured = true;
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
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _showCompletionDialog();
          }
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
      _coldWaterPoured = false;
      _bottleTransferred = false;
      _experimentComplete = false;
      _temperatureCelsius = _roomTempC;
      _currentVolume = _referenceVolume;
      _cupPosition = null;
      _bottlePosition = null;
      _containerPosition = null;
      
      for (var item in _items) {
        item.used = false;
      }
    });
    _animationController?.reset();
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

  /// Get color based on temperature
  Color _getTemperatureColor() {
    if (_temperatureCelsius < _roomTempC) {
      return Colors.blue.shade700;
    } else if (_temperatureCelsius > _roomTempC) {
      return Colors.red.shade700;
    }
    return Colors.grey.shade700;
  }

  /// Get temperature icon
  IconData _getTemperatureIcon() {
    if (_temperatureCelsius < _roomTempC) {
      return Icons.ac_unit;
    } else if (_temperatureCelsius > _roomTempC) {
      return Icons.whatshot;
    }
    return Icons.thermostat;
  }
  

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tableCenterX = screenSize.width * 0.4;
    final tableCenterY = screenSize.height * 0.35;

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
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.grey.shade100,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Table surface
                        Positioned.fill(
                          child: Container(
                            margin: EdgeInsets.only(top: constraints.maxHeight * 0.1),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.brown.shade400,
                                  Colors.brown.shade600,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Cup (or combined cup with hot water and bottle)
                        if (_cupPlaced && _cupPosition != null)
                          Positioned(
                            left: _cupPosition!.dx - (_bottleInCup && _hotWaterPoured ? 100 : 60), // Center horizontally
                            top: _cupPosition!.dy - (_bottleInCup && _hotWaterPoured ? 130 : 60), // Moved slightly up when combined
                            child: _SvgImageWidget(
                              svgPath: _bottleInCup && _hotWaterPoured
                                  ? 'assets/charles_law/cup_hot_water_bottle.png'
                                  : _hotWaterPoured 
                                      ? 'assets/charles_law/cup_hot_water.png'
                                      : 'assets/charles_law/cup.png',
                              icon: Icons.local_drink,
                              size: _bottleInCup && _hotWaterPoured ? 200 : 120, // Bigger when combined
                            ),
                          ),

                        // Hot water steam
                        if (_hotWaterPoured && 
                            _bottleInCup && 
                            _cupPosition != null &&
                            _steamAnimationController != null)
                          Positioned(
                            left: _cupPosition!.dx - 20,
                            top: _cupPosition!.dy - (_bottleInCup ? 160 : 90), // Adjusted for moved-up combined image
                            child: _SteamWidget(controller: _steamAnimationController!),
                          ),

                        // Container
                        if (_containerPlaced && _containerPosition != null)
                          Positioned(
                            left: _containerPosition!.dx - 40,
                            top: _containerPosition!.dy - 40,
                            child: _SvgImageWidget(
                              svgPath: _coldWaterPoured
                                  ? 'assets/charles_law/container_cold_water.svg'
                                  : 'assets/charles_law/container.png',
                              icon: Icons.square,
                              size: 80,
                            ),
                          ),

                        // Bottle (only show when transferred to container, not when in cup)
                        if (_bottleTransferred && _bottlePosition != null)
                          Positioned(
                            left: _bottlePosition!.dx - 20,
                            top: _bottlePosition!.dy - 50,
                            child: _SvgImageWidget(
                              svgPath: 'assets/charles_law/bottle.png',
                              icon: Icons.water_drop,
                              size: 40,
                            ),
                          ),

                        // Balloon on bottle (use cup position since bottle is in cup)
                        if (_balloonOnBottle && _cupPosition != null)
                          Positioned(
                            left: _cupPosition!.dx - (_currentVolume * 50), // Center based on balloon size
                            top: _cupPosition!.dy - (_currentVolume * 100 + 30), // Position above cup/bottle
                            child: _BalloonPlaceholder(size: _currentVolume),
                          ),

                        // Drop zones (only visible when dragging)
                        // Cup drop zone (centered on table)
                        if (_currentStep == 0 && _draggingItem != null)
                          Positioned(
                            left: screenSize.width / 2 - 100,
                            top: screenSize.height * 0.4 - 100,
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
                        if (_currentStep == 1 && _cupPlaced && _cupPosition != null && _draggingItem != null)
                          Positioned(
                            left: _cupPosition!.dx - 60,
                            top: _cupPosition!.dy - 60,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Pour Hot Water',
                              onAccept: (itemId, position) {
                                if (itemId == 'hotWater') {
                                  _onItemAccepted(itemId, _cupPosition!);
                                }
                              },
                            ),
                          ),

                        // Bottle drop zone (in cup) - centered on cup
                        if (_currentStep == 2 && _hotWaterPoured && _cupPosition != null && _draggingItem != null)
                          Positioned(
                            left: _cupPosition!.dx - 60, // Same as cup position (centered)
                            top: _cupPosition!.dy - 60, // Same as cup position (centered)
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Place Bottle',
                              onAccept: (itemId, position) {
                                if (itemId == 'bottle') {
                                  _onItemAccepted(itemId, _cupPosition!);
                                }
                              },
                            ),
                          ),

                        // Balloon drop zone (on bottle)
                        if (_currentStep == 3 && _bottleInCup && _cupPosition != null && _draggingItem != null)
                          Positioned(
                            left: _cupPosition!.dx - 50, // Use cup position since bottle is in cup
                            top: _cupPosition!.dy - 150, // Above the cup/bottle
                            child: _DropZone(
                              width: 100,
                              height: 100,
                              label: 'Place Balloon',
                              onAccept: (itemId, position) {
                                if (itemId == 'balloon') {
                                  _onItemAccepted(itemId, _cupPosition!);
                                }
                              },
                            ),
                          ),

                        // Container drop zone
                        if (_currentStep == 4 && _balloonOnBottle && _draggingItem != null)
                          Positioned(
                            left: tableCenterX + 100,
                            top: tableCenterY - 100,
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
                        if (_currentStep == 5 && _containerPlaced && _containerPosition != null && _draggingItem != null)
                          Positioned(
                            left: _containerPosition!.dx - 60,
                            top: _containerPosition!.dy - 60,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Pour Cold Water',
                              onAccept: (itemId, position) {
                                if (itemId == 'coldWater') {
                                  _onItemAccepted(itemId, _containerPosition!);
                                }
                              },
                            ),
                          ),

                        // Bottle transfer drop zone
                        if (_currentStep == 6 && _containerPlaced && _containerPosition != null && _draggingItem != null)
                          Positioned(
                            left: _containerPosition!.dx - 60,
                            top: _containerPosition!.dy - 60,
                            child: _DropZone(
                              width: 120,
                              height: 120,
                              label: 'Transfer Bottle',
                              onAccept: (itemId, position) {
                                if (itemId == 'bottle') {
                                  _onItemAccepted(itemId, _containerPosition!);
                                }
                              },
                            ),
                          ),

                        // Item showcase panel (right side)
                        Positioned(
                          right: 10,
                          top: 80,
                          bottom: 200,
                          width: 60,
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
                color: Colors.white.withOpacity(0.95),
                child: Column(
                  children: [
                    Text(
                      _getStepInstruction(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _currentStep == 7 ? Colors.green.shade700 : Colors.blue.shade900,
                        letterSpacing: 0.5,
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
                            color: _getTemperatureColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getTemperatureColor(),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getTemperatureIcon(),
                                size: 16,
                                color: _getTemperatureColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_temperatureCelsius.toStringAsFixed(0)}°C',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getTemperatureColor(),
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
                            'Volume: ${(_currentVolume * 100).toStringAsFixed(0)}%',
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
  
  /// Get SVG asset path for an item (returns null if SVG doesn't exist)
  static String? _getSvgPathForItem(String itemId) {
    final svgPaths = {
      'cup': 'assets/charles_law/cup.png',
      'bottle': 'assets/charles_law/bottle.png',
      'balloon': 'assets/charles_law/balloon.svg',
      'container': 'assets/charles_law/container.png',
      'hotWater': 'assets/charles_law/hot_water.svg',
      'coldWater': 'assets/charles_law/cold_water.svg',
    };
    return svgPaths[itemId];
  }

  @override
  Widget build(BuildContext context) {
    // Filter out used items (unless currently being dragged)
    final visibleItems = items.where((item) => 
      !item.used || draggingItem == item.id
    ).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate item size based on available space
                final itemCount = visibleItems.length;
                final availableHeight = constraints.maxHeight;
                final headerHeight = 24.0;
                final totalPadding = (itemCount - 1) * 4.0; // vertical padding between items
                final itemHeight = ((availableHeight - headerHeight - totalPadding) / itemCount).clamp(40.0, 48.0);
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: visibleItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: Draggable<String>(
                        data: item.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade400, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: _SvgOrIconWidget(
                              svgPath: _getSvgPathForItem(item.id),
                              icon: item.icon,
                              size: 24,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        childWhenDragging: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _SvgOrIconWidget(
                            svgPath: _getSvgPathForItem(item.id),
                            icon: item.icon,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        onDragStarted: () {
                          onDragStart(item.id);
                          SoundService().playTouchSound();
                        },
                        onDragEnd: (_) {
                          onDragEnd();
                        },
                        child: SizedBox(
                          width: 48,
                          height: itemHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade300, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SvgOrIconWidget(
                                  svgPath: _getSvgPathForItem(item.id),
                                  icon: item.icon,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(height: 1),
                                Flexible(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget that uses SVG if available, otherwise falls back to Material Icon
class _SvgOrIconWidget extends StatelessWidget {
  final String? svgPath;
  final IconData icon;
  final double size;
  final Color? color;

  const _SvgOrIconWidget({
    this.svgPath,
    required this.icon,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Try to use image if path is provided, otherwise use icon
    if (svgPath != null) {
      try {
        // Check if it's PNG or SVG
        if (svgPath!.toLowerCase().endsWith('.png') || 
            svgPath!.toLowerCase().endsWith('.jpg') ||
            svgPath!.toLowerCase().endsWith('.jpeg')) {
          return Image.asset(
            svgPath!,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Failed to load image: $svgPath');
              debugPrint('Error: $error');
              return Icon(
                icon,
                size: size,
                color: color ?? Colors.grey.shade700,
              );
            },
          );
        } else {
          // SVG image
          return SvgPicture.asset(
            svgPath!,
            width: size,
            height: size,
            colorFilter: color != null 
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            placeholderBuilder: (context) => Icon(
              icon,
              size: size,
              color: color ?? Colors.grey.shade700,
            ),
          );
        }
      } catch (e) {
        // If image fails to load, fall back to icon
        return Icon(
          icon,
          size: size,
          color: color ?? Colors.grey.shade700,
        );
      }
    }
    
    return Icon(
      icon,
      size: size,
      color: color ?? Colors.grey.shade700,
    );
  }
}

/// Widget to display SVG images for dropped items
class _SvgImageWidget extends StatelessWidget {
  final String svgPath;
  final IconData icon;
  final double size;

  const _SvgImageWidget({
    required this.svgPath,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: _SvgOrIconWidget(
          svgPath: svgPath,
          icon: icon,
          size: size,
          color: null,
        ),
      ),
    );
  }
}

/// Balloon placeholder widget
class _BalloonPlaceholder extends StatelessWidget {
  final double size;

  const _BalloonPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    final balloonSize = 40.0 + (size * 80.0);
    return CustomPaint(
      size: Size(balloonSize, balloonSize),
      painter: _BalloonPainter(volume: size),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final double volume;
  
  _BalloonPainter({required this.volume});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Oblong/elliptical balloon shape - elongated vertically (taller than wide)
    final balloonPath = Path();
    
    // Create oblong shape - taller vertically than wide horizontally
    final radiusX = size.width * 0.35; // Horizontal radius (narrower)
    final radiusY = size.height * 0.45; // Vertical radius (taller)
    
    // Main oblong body (ellipse) - vertically elongated
    balloonPath.addOval(Rect.fromCenter(
      center: Offset(centerX, centerY - 5),
      width: radiusX * 2, // Narrower width
      height: radiusY * 2, // Taller height
    ));
    
    // Narrow neck at bottom connecting to bottle
    balloonPath.lineTo(centerX, size.height - 8);
    balloonPath.close();

    // Base gradient fill
    final colorSwatch = Colors.red;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorSwatch.shade200,
        colorSwatch.shade300,
        colorSwatch.shade400,
        colorSwatch.shade600,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.style = PaintingStyle.fill;
    canvas.drawPath(balloonPath, paint);

    // Highlight on upper left side (lighter)
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.4);
    paint.style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.addOval(Rect.fromCenter(
      center: Offset(centerX - radiusX * 0.2, centerY - radiusY * 0.3),
      width: size.width * 0.4,
      height: size.height * 0.3,
    ));
    canvas.drawPath(highlightPath, paint);

    // Border/stroke
    paint.color = colorSwatch.shade800;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawPath(balloonPath, paint);

    // Darker rolled rim at bottom (darker pink/red)
    paint.color = colorSwatch.shade900;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, size.height - 5),
          width: size.width * 0.12,
          height: 8,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
    
    // Small circle at the very bottom (opening)
    paint.color = colorSwatch.shade900;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, size.height - 1), 2.5, paint);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = Colors.black.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(centerX, size.height - 1), 2.5, paint);
  }
  
  @override
  bool shouldRepaint(_BalloonPainter oldDelegate) => oldDelegate.volume != volume;
}

/// Steam animation widget
class _SteamWidget extends StatelessWidget {
  final AnimationController controller;

  const _SteamWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(40, 60),
          painter: _SteamPainter(progress: controller.value),
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
    final offsetY = progress * size.height;
    final opacity = (0.8 - progress * 0.5).clamp(0.3, 0.8);

    // Draw multiple steam particles with varying sizes
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.15 + i * 0.175);
      final y = size.height - offsetY + (i * 8.0);
      final particleSize = 4.0 + i * 1.5;
      final particleOpacity = opacity * (1.0 - i * 0.15);
      
      // Outer glow
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(particleOpacity * 0.3);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize + 2,
        glowPaint,
      );
      
      // Main particle
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(particleOpacity);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
      
      // Inner highlight
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(particleOpacity * 0.6);
      
      canvas.drawCircle(
        Offset(x - particleSize * 0.3, y - particleSize * 0.3),
        particleSize * 0.4,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter oldDelegate) => oldDelegate.progress != progress;
}

class _DropZone extends StatefulWidget {
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
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          widget.onAccept(details.data, position);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.green.shade100.withOpacity(0.7)
                    : Colors.blue.shade50.withOpacity(_pulseAnimation.value),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighlighted
                      ? Colors.green.shade500
                      : Colors.blue.shade300.withOpacity(0.5),
                  width: isHighlighted ? 3 : 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                          color: Colors.green.shade300.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted
                        ? Colors.green.shade800
                        : Colors.blue.shade700.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
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
              'WHAT HAPPENED TO THE BALLOON AS THE BOTTLE IS PLACED IN HOT WATER?',
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
