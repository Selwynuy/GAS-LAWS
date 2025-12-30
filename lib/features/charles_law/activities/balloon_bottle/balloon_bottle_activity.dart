import 'dart:async';
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
  Offset? _fixedNeckPosition; // Fixed neck position when balloon is first placed

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
  
  // Initial inflation animation (when balloon is first placed)
  AnimationController? _initialInflationController;
  Animation<double>? _initialInflationAnimation;
  bool _isInitialInflating = false;
  
  // Timer for continuous temperature updates
  Timer? _temperatureUpdateTimer;

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
    
    _initialInflationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), // 6 seconds for initial inflation
    );
    
    _initialInflationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _initialInflationController!,
      curve: Curves.easeOut,
    ));
    
    _volumeAnimation = Tween<double>(
      begin: _referenceVolume,
      end: _referenceVolume,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    
    _volumeAnimation!.addListener(_onVolumeAnimationUpdate);
    _initialInflationAnimation!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
    _initialInflationAnimation?.removeListener(() {});
    _temperatureUpdateTimer?.cancel();
    _animationController?.dispose();
    _steamAnimationController?.dispose();
    _initialInflationController?.dispose();
    super.dispose();
  }

  /// Convert Celsius to Kelvin
  double _celsiusToKelvin(double celsius) => celsius + 273.15;

  /// Calculate volume using Charles Law: V₁/T₁ = V₂/T₂
  /// Therefore: V₂ = V₁ × (T₂/T₁)
  double _calculateVolume(double temperatureCelsius) {
    final temperatureK = _celsiusToKelvin(temperatureCelsius);
    final newVolume = _referenceVolume * (temperatureK / _referenceTempK);
    return newVolume.clamp(0.3, 1.1); // Clamp to max 10% above reference size
  }

  /// Update temperature based on experiment state and animate volume change
  void _updateTemperatureFromState() {
    if (!mounted || _animationController == null) return;
    
    // Cancel any existing timer
    _temperatureUpdateTimer?.cancel();
    
    double targetTemp = _roomTempC;
    
    if (_bottleInCup && _hotWaterPoured) {
      targetTemp = 73.0; // Bottle reaches 73°C when placed in hot water
    } else if (_bottleTransferred && _coldWaterPoured) {
      targetTemp = _coldTempC;
    }

    // Start continuous temperature updates
    _temperatureUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
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
      } else {
        // Reached target temperature, stop timer
        timer.cancel();
        // Final update to ensure we're exactly at target
        setState(() {
          _temperatureCelsius = targetTemp;
        });
        final targetVolume = _calculateVolume(_temperatureCelsius);
        _volumeAnimation?.removeListener(_onVolumeAnimationUpdate);
        _volumeAnimation = Tween<double>(
          begin: _currentVolume,
          end: targetVolume,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeInOut,
        ));
        _volumeAnimation!.addListener(_onVolumeAnimationUpdate);
        _animationController!.forward(from: 0.0);
      }
    });
  }


  void _onItemAccepted(String itemId, Offset dropPosition) {
    bool dropped = false;

    switch (itemId) {
      case 'cup':
        if (_currentStep == 0) {
          final screenSize = MediaQuery.of(context).size;
          // Position cup to the left to make room for container on the right
          final centerX = screenSize.width * 0.35; // Moved left from center
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
        }
        // Note: Transfer is now handled by the "Transfer Bottle" button, not drag-and-drop
        break;

      case 'balloon':
        if (_currentStep == 3 && _bottleInCup && _cupPosition != null) {
          // Calculate and store fixed neck position (where balloon attaches to bottle)
          // Bottle opening is at the top of the combined cup/bottle image
          // Combined image top: _cupPosition!.dy - 130, size: 200
          // Bottle opening is approximately 30px from top of image
          final fixedNeckBottomY = _cupPosition!.dy - 130 + 30;
          // Store fixed neck position (center X, bottom Y)
          final fixedNeckX = _cupPosition!.dx; // Center of bottle opening
          setState(() {
            _balloonOnBottle = true;
            _fixedNeckPosition = Offset(fixedNeckX, fixedNeckBottomY); // Store fixed position
            _currentStep = 4;
            _items.firstWhere((i) => i.id == 'balloon').used = true;
            dropped = true;
            _isInitialInflating = true;
          });
          // Start initial inflation animation
          _initialInflationController?.forward(from: 0.0);
          // After initial inflation completes, start temperature-based updates
          Future.delayed(const Duration(milliseconds: 6100), () {
            if (mounted) {
              setState(() {
                _isInitialInflating = false;
              });
              _updateTemperatureFromState();
            }
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
      _fixedNeckPosition = null;
      _containerPlaced = false;
      _coldWaterPoured = false;
      _bottleTransferred = false;
      _experimentComplete = false;
      _temperatureCelsius = _roomTempC;
      _currentVolume = _referenceVolume;
      _cupPosition = null;
      _bottlePosition = null;
      _containerPosition = null;
      _isInitialInflating = false;
      
      for (var item in _items) {
        item.used = false;
      }
    });
    _animationController?.reset();
    _initialInflationController?.reset();
  }
  
  /// Get effective balloon size (accounts for initial inflation animation)
  double _getEffectiveBalloonSize() {
    if (!_balloonOnBottle) return _currentVolume;
    
    if (_isInitialInflating && _initialInflationAnimation != null) {
      // Start from 10% of volume and grow to current volume
      final startSize = _currentVolume * 0.1;
      final endSize = _currentVolume;
      return startSize + (endSize - startSize) * _initialInflationAnimation!.value;
    }
    
    return _currentVolume;
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
                          child: Transform.translate(
                            offset: Offset(0, constraints.maxHeight * 0.4),
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/charles_law/table.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
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
                            left: _containerPosition!.dx - 80,
                            top: _containerPosition!.dy - 80,
                            child: _SvgImageWidget(
                              svgPath: _bottleTransferred && _coldWaterPoured
                                  ? 'assets/charles_law/container_cold_water_bottle.png'
                                  : _coldWaterPoured
                                      ? 'assets/charles_law/container_cold_water.png'
                                      : 'assets/charles_law/container.png',
                              icon: Icons.square,
                              size: 160,
                            ),
                          ),

                        // Balloon on bottle (use fixed neck position stored when placed)
                        if (_balloonOnBottle && _fixedNeckPosition != null)
                          Builder(
                            builder: (context) {
                              // Use stored fixed neck position (updated when bottle is transferred)
                              final fixedNeckBottomY = _fixedNeckPosition!.dy;
                              final fixedNeckX = _fixedNeckPosition!.dx;
                              
                              // Calculate current widget size
                              final effectiveSize = _getEffectiveBalloonSize();
                              // Widget size should match actual balloon size
                              // Max radius is 33px (diameter 66px) + neck 15px + padding
                              final baseSize = 50.0; // Base size for neck
                              // Scale body diameter: volume 1.0 → 60px, volume 1.1 → 66px (10% more)
                              final bodySize = 60.0 + (effectiveSize - 1.0) * 60.0; // Diameter scales from 60px to 66px
                              final balloonSize = (baseSize + bodySize).clamp(50.0, 120.0); // Cap appropriately
                              
                              // Position widget so its bottom (neck) stays fixed
                              // Neck is drawn at size.height - 2 in the painter
                              // So: top + (balloonSize - 2) = fixedNeckBottomY
                              // Therefore: top = fixedNeckBottomY - balloonSize + 2
                              // Adjust offset based on whether bottle is transferred (moved up)
                              final offsetAdjustment = _bottleTransferred ? -15 : 35;
                              final top = fixedNeckBottomY - balloonSize + offsetAdjustment;
                              
                              // Horizontal position: centered on bottle opening (use current size so neck stays centered)
                              // Neck is always at centerX of widget, so center widget on fixedNeckX
                              final left = fixedNeckX - (balloonSize / 2); // Center horizontally based on current size
                              
                              return Positioned(
                                left: left,
                                top: top,
                                child: _BalloonPlaceholder(size: effectiveSize),
                              );
                            },
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

                        // Container drop zone (beside the cup)
                        if (_currentStep == 4 && _balloonOnBottle && _cupPosition != null && _draggingItem != null)
                          Positioned(
                            left: _cupPosition!.dx + 80, // Position to the right of the cup (moved 100px left)
                            top: _cupPosition!.dy - 100, // Align vertically with cup
                            child: _DropZone(
                              width: 100,
                              height: 100,
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

                        // Transfer bottle button
                        if (_currentStep == 6 && _containerPlaced && _bottleInCup && _containerPosition != null)
                          Positioned(
                            left: _containerPosition!.dx - 80,
                            top: _containerPosition!.dy + 60,
                            child: ElevatedButton(
                              onPressed: () {
                                // Transfer bottle from cup to container
                                setState(() {
                                  _bottlePosition = Offset(_containerPosition!.dx, _containerPosition!.dy - 60);
                                  _bottleInCup = false;
                                  _bottleTransferred = true;
                                  _currentStep = 7;
                                  // Update balloon's fixed neck position to align with bottle opening in container
                                  if (_balloonOnBottle && _fixedNeckPosition != null) {
                                    // Bottle opening in container is at the top of the container image
                                    // Container image top: _containerPosition!.dy - 80, size: 160
                                    // Bottle opening is approximately 40px from top of container image
                                    // Move balloon upward by reducing Y value significantly
                                    final newNeckBottomY = _containerPosition!.dy - 80 + 40; // Moved up 50px
                                    final newNeckX = _containerPosition!.dx; // Center of container (bottle opening)
                                    _fixedNeckPosition = Offset(newNeckX, newNeckBottomY);
                                  }
                                });
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  _updateTemperatureFromState();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Transfer Bottle',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                    SizedBox(
                      height: 60, // Fixed height to prevent layout shifts
                      child: Center(
                        child: Text(
                          _getStepInstruction(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _currentStep == 7 ? Colors.green.shade700 : Colors.blue.shade900,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
    // Base size accounts for neck, main body scales with volume
    // Keep minimum size for neck visibility, body scales from there
    // Widget size should match actual balloon size
    final baseSize = 50.0; // Base size for neck
    // Scale body diameter: volume 1.0 → 60px, volume 1.1 → 66px (10% more)
    final bodySize = 60.0 + (size - 1.0) * 60.0; // Diameter scales from 60px to 66px
    final balloonSize = (baseSize + bodySize).clamp(50.0, 120.0); // Cap appropriately
    return CustomPaint(
      size: Size(balloonSize, balloonSize),
      painter: _BalloonPainter(volume: size, widgetSize: balloonSize),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final double volume;
  final double widgetSize;
  
  _BalloonPainter({required this.volume, required this.widgetSize});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final centerX = size.width / 2;

    // Spherical balloon shape - use perfect oval/circle for main body
    final balloonPath = Path();
    
    // Neck stays fixed size (attached to bottle), only body scales with volume
    // Fixed neck dimensions
    final neckWidth = 8.0; // Fixed neck width
    final neckHeight = 15.0; // Fixed neck height
    
    // Main body radius scales with volume (only the body inflates)
    // Cap maximum inflation to 10% above initial size
    // Volume 1.0 (reference) → radius 30px
    // Volume 1.1 (max) → radius 33px (10% more)
    final baseRadius = 10.0; // Minimum radius when volume is small
    final initialRadius = 30.0; // Radius at volume 1.0 (reference)
    // Linear scaling: radius = initialRadius + (volume - 1.0) * scaleFactor
    // At volume 1.1, we want radius = 33, so: 33 = 30 + (1.1 - 1.0) * scaleFactor
    // scaleFactor = 3 / 0.1 = 30
    final radiusX = (initialRadius + (volume - 1.0) * 30.0).clamp(baseRadius, initialRadius * 1.1);
    final radiusY = radiusX; // Keep spherical
    
    // Calculate body center position (body sits above fixed neck)
    // Neck is fixed at bottom, body center moves up as it grows
    final neckBottomY = size.height - 2; // Bottom of neck (fixed)
    final neckTopY = neckBottomY - neckHeight; // Top of neck (fixed)
    
    // Body center Y position - starts low when small, moves up as it grows
    final bodyCenterY = neckTopY - radiusY - 5; // Body sits above neck
    
    // Main spherical body - perfect oval/circle (ensures round top, no triangle)
    balloonPath.addOval(Rect.fromCenter(
      center: Offset(centerX, bodyCenterY),
      width: radiusX * 2,
      height: radiusY * 2,
    ));
    
    // Smoothly connect body to fixed neck at bottom
    final ovalBottom = bodyCenterY + radiusY;
    
    // Create smooth transition from oval body to fixed neck
    balloonPath.moveTo(centerX - radiusX * 0.15, ovalBottom);
    balloonPath.quadraticBezierTo(
      centerX - radiusX * 0.1,
      neckTopY + 3,
      centerX - neckWidth * 0.5,
      neckTopY + 2,
    );
    // Fixed neck that extends down (doesn't scale)
    balloonPath.lineTo(centerX - neckWidth * 0.5, neckBottomY);
    balloonPath.lineTo(centerX + neckWidth * 0.5, neckBottomY);
    balloonPath.lineTo(centerX + neckWidth * 0.5, neckTopY + 2);
    balloonPath.quadraticBezierTo(
      centerX + radiusX * 0.1,
      neckTopY + 3,
      centerX + radiusX * 0.15,
      ovalBottom,
    );
    balloonPath.close();

    // Base gradient fill - vertical (top to bottom) instead of diagonal
    final colorSwatch = Colors.red;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
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

    // Highlight on upper left side (lighter) - use bodyCenterY
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.4);
    paint.style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.addOval(Rect.fromCenter(
      center: Offset(centerX - radiusX * 0.2, bodyCenterY - radiusY * 0.3),
      width: radiusX * 0.8,
      height: radiusY * 0.6,
    ));
    canvas.drawPath(highlightPath, paint);

    // Border/stroke
    paint.color = colorSwatch.shade800;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawPath(balloonPath, paint);

    // Neck outline (fixed size, attached to bottle)
    paint.color = colorSwatch.shade900;
    paint.strokeWidth = 2.5;
    // Draw fixed neck outline
    final neckPath = Path();
    neckPath.moveTo(centerX - neckWidth * 0.5, neckTopY + 2);
    neckPath.lineTo(centerX - neckWidth * 0.5, neckBottomY);
    neckPath.lineTo(centerX + neckWidth * 0.5, neckBottomY);
    neckPath.lineTo(centerX + neckWidth * 0.5, neckTopY + 2);
    canvas.drawPath(neckPath, paint);
    
    // Open oval/opening - at the lowest part of the neck (bottom)
    // Draw opening at the bottom where it attaches to bottle (fixed size)
    paint.color = colorSwatch.shade700;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, neckBottomY - 1), // At the lowest part of neck
        width: neckWidth * 1.5, // Fixed opening size relative to neck
        height: 5,
      ),
      paint,
    );
    
    // Inner edge of opening (shows it's open/hollow)
    paint.color = colorSwatch.shade600;
    paint.strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, neckBottomY - 1),
        width: neckWidth * 1.1, // Fixed inner opening size
        height: 3.5,
      ),
      paint,
    );
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
