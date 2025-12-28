import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app settings
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  // Default values
  static const bool _defaultMusicEnabled = true;
  static const double _defaultMusicVolume = 0.7;
  static const bool _defaultSoundEffectsEnabled = true;
  static const double _defaultSoundEffectsVolume = 0.8;
  static const bool _defaultAnimationsEnabled = true;

  /// Initialize the settings service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Music settings
  bool get isMusicEnabled =>
      _prefs?.getBool('music_enabled') ?? _defaultMusicEnabled;

  Future<void> setMusicEnabled(bool value) async {
    await _prefs?.setBool('music_enabled', value);
  }

  double get musicVolume =>
      _prefs?.getDouble('music_volume') ?? _defaultMusicVolume;

  Future<void> setMusicVolume(double value) async {
    await _prefs?.setDouble('music_volume', value);
  }

  // Sound effects settings
  bool get isSoundEffectsEnabled =>
      _prefs?.getBool('sound_effects_enabled') ?? _defaultSoundEffectsEnabled;

  Future<void> setSoundEffectsEnabled(bool value) async {
    await _prefs?.setBool('sound_effects_enabled', value);
  }

  double get soundEffectsVolume =>
      _prefs?.getDouble('sound_effects_volume') ?? _defaultSoundEffectsVolume;

  Future<void> setSoundEffectsVolume(double value) async {
    await _prefs?.setDouble('sound_effects_volume', value);
  }

  // Animation settings
  bool get isAnimationsEnabled =>
      _prefs?.getBool('animations_enabled') ?? _defaultAnimationsEnabled;

  Future<void> setAnimationsEnabled(bool value) async {
    await _prefs?.setBool('animations_enabled', value);
  }
}

