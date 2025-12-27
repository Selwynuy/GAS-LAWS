import '../../../../../../core/constants/app_constants.dart';

/// Diving state model representing the current state of a scuba diver.
///
/// Uses a simplified Boyle's Law model: P1 * V1 = P2 * V2
/// - Pressure is approximated as: P(depth) = 1 atm + depthMeters / 10
/// - Lung volume is adjusted instantly to match current pressure,
///   unless the player uses "Exhale" which reduces volume manually.
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
    this.surfaceLungVolumeLiters = AppConstants.surfaceLungVolumeLiters,
    this.oxygenTankPercent = AppConstants.initialOxygenTankPercent,
    this.safeLungVolumeMax = AppConstants.safeLungVolumeMax,
  }) : pressureAtm = _pressureForDepth(depthMeters);

  /// Recalculate ambient pressure based on depth.
  static double _pressureForDepth(double depthMeters) {
    return AppConstants.surfacePressureAtm + 
           (depthMeters * AppConstants.pressurePerMeter);
  }

  /// Update state when the diver's depth changes.
  ///
  /// This applies Boyle's Law to compute the new lung volume.
  void setDepth(double newDepthMeters) {
    depthMeters = newDepthMeters.clamp(
      AppConstants.minDepthMeters, 
      AppConstants.maxDepthMeters,
    );
    final oldPressure = pressureAtm;
    pressureAtm = _pressureForDepth(depthMeters);

    // Boyle's Law: P1 * V1 = P2 * V2  ->  V2 = (P1 * V1) / P2
    final newVolume = (oldPressure * lungVolumeLiters) / pressureAtm;
    lungVolumeLiters = newVolume.clamp(
      AppConstants.minLungVolumeLiters,
      AppConstants.maxLungVolumeLiters,
    );
  }

  /// Manually exhale some air. This reduces lung volume and saves a bit of oxygen.
  void exhale({double liters = 0.5}) {
    lungVolumeLiters = (lungVolumeLiters - liters).clamp(
      AppConstants.minLungVolumeLiters,
      AppConstants.maxLungVolumeLiters,
    );
    // Exhaling conserves a tiny bit of tank usage in this toy model.
    oxygenTankPercent = (oxygenTankPercent + 0.1).clamp(
      AppConstants.minOxygenTankPercent,
      AppConstants.maxOxygenTankPercent,
    );
  }

  /// Consume oxygen over time / actions.
  void consumeOxygen({double amount = 0.5}) {
    oxygenTankPercent = (oxygenTankPercent - amount).clamp(
      AppConstants.minOxygenTankPercent,
      AppConstants.maxOxygenTankPercent,
    );
  }

  /// Returns true if lung volume is above safe threshold.
  bool get isLungVolumeUnsafe => lungVolumeLiters > safeLungVolumeMax;
}


