import '../../../../../../core/constants/app_constants.dart';

/// Service for calculating diving physics operations.
class DivingPhysicsService {
  /// Calculate new depth after ascending slowly.
  static double ascendDepthStep(double currentDepth) {
    return (currentDepth - AppConstants.ascendStepMeters).clamp(
      AppConstants.minDepthMeters,
      AppConstants.maxDepthMeters,
    );
  }

  /// Calculate new depth after descending.
  static double descendDepthStep(double currentDepth) {
    return (currentDepth + AppConstants.descendStepMeters).clamp(
      AppConstants.minDepthMeters,
      AppConstants.maxDepthMeters,
    );
  }

  /// Calculate new depth after emergency ascent.
  static double emergencyAscentDepth(double currentDepth) {
    return (currentDepth - AppConstants.emergencyAscentStepMeters).clamp(
      AppConstants.minDepthMeters,
      AppConstants.maxDepthMeters,
    );
  }
}

