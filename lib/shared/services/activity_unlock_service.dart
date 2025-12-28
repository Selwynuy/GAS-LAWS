import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage activity unlock status
class ActivityUnlockService {
  static const String _prefix = 'activity_unlocked_';

  /// Check if an activity is unlocked
  static Future<bool> isActivityUnlocked(String activityKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$activityKey') ?? false;
  }

  /// Unlock an activity
  static Future<void> unlockActivity(String activityKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$activityKey', true);
  }

  /// Reset all unlocks (for testing/debugging)
  static Future<void> resetAllUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

