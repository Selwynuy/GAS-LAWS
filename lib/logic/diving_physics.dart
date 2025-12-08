/// Simple physics / game-logic helpers for the scuba gas-laws game.
///
/// We use a very simplified Boyle's Law model:
///   P1 * V1 = P2 * V2
///
/// - Pressure is approximated as:
///     P(depth) = 1 atm + depthMeters / 10
///   (every 10m adds ~1 atm of pressure).
///
/// - Lung volume is adjusted instantly to match current pressure,
///   unless the player uses "Exhale" which reduces volume manually.
library;

class DivingState {
  /// Current depth in meters.
  double depthMeters;

  /// Current ambient pressure in atmospheres (atm).
  double pressureAtm;

  /// Current lung volume in liters.
  double lungVolumeLiters;

  /// Initial reference volume at surface (1 atm).
  final double surfaceLungVolumeLiters;

  /// Oxygen tank percentage [0–100].
  double oxygenTankPercent;

  /// Safe upper limit for lung volume. Above this, we show a warning.
  final double safeLungVolumeMax;

  DivingState({
    required this.depthMeters,
    required this.lungVolumeLiters,
    this.surfaceLungVolumeLiters = 6.0,
    this.oxygenTankPercent = 100.0,
    this.safeLungVolumeMax = 5.5, // Safe limit below max 6L at surface
  }) : pressureAtm = _pressureForDepth(depthMeters);

  /// Recalculate ambient pressure based on depth.
  static double _pressureForDepth(double depthMeters) {
    // 1 atm at surface + 1 atm per 10m depth (rough approximation).
    return 1.0 + depthMeters / 10.0;
  }

  /// Update state when the diver's depth changes.
  ///
  /// This applies Boyle's Law to compute the new lung volume.
  void setDepth(double newDepthMeters) {
    depthMeters = newDepthMeters.clamp(0.0, 40.0); // clamp to some game range
    final oldPressure = pressureAtm;
    pressureAtm = _pressureForDepth(depthMeters);

    // Boyle's Law: P1 * V1 = P2 * V2  ->  V2 = (P1 * V1) / P2
    final newVolume = (oldPressure * lungVolumeLiters) / pressureAtm;
    // Clamp between 2L (deepest) and 6L (surface) for realistic values
    lungVolumeLiters = newVolume.clamp(2.0, 6.0);
  }

  /// Manually exhale some air. This reduces lung volume and saves a bit of oxygen.
  void exhale({double liters = 0.5}) {
    lungVolumeLiters = (lungVolumeLiters - liters).clamp(2.0, 6.0);
    // Exhaling conserves a tiny bit of tank usage in this toy model.
    oxygenTankPercent = (oxygenTankPercent + 0.1).clamp(0.0, 100.0);
  }

  /// Consume oxygen over time / actions.
  void consumeOxygen({double amount = 0.5}) {
    oxygenTankPercent = (oxygenTankPercent - amount).clamp(0.0, 100.0);
  }

  /// Returns true if lung volume is above safe threshold.
  bool get isLungVolumeUnsafe => lungVolumeLiters > safeLungVolumeMax;
}

/// Convenience functions for the control buttons.

double ascendDepthStep(double currentDepth) {
  // Ascend slowly ~1 m per tap.
  return (currentDepth - 1.0).clamp(0.0, 40.0);
}

double descendDepthStep(double currentDepth) {
  // Descend ~1.5 m per tap.
  return (currentDepth + 1.5).clamp(0.0, 40.0);
}

double emergencyAscentDepth(double currentDepth) {
  // Emergency ascent jumps quickly toward the surface.
  return (currentDepth - 5.0).clamp(0.0, 40.0);
}


