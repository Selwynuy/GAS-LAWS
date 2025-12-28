import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

/// Service for managing background music and sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _backgroundPlayer;
  AudioPlayer? _soundEffectsPlayer;
  final SettingsService _settingsService = SettingsService();

  bool _isInitialized = false;
  bool _isBackgroundMusicPlaying = false;

  /// Initialize the sound service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _settingsService.initialize();
      
      // Create audio players after plugins are registered
      // Use separate player instances with unique IDs to prevent interference
      _backgroundPlayer = AudioPlayer(playerId: 'background_music');
      _soundEffectsPlayer = AudioPlayer(playerId: 'sound_effects');
      
      // Configure player modes - mediaPlayer for background music, lowLatency for sound effects
      await _backgroundPlayer!.setPlayerMode(PlayerMode.mediaPlayer);
      await _soundEffectsPlayer!.setPlayerMode(PlayerMode.lowLatency);
      
      // Set background music to loop
      await _backgroundPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Add listener to detect if background music stops unexpectedly
      _backgroundPlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          // Music stopped unexpectedly, restart if enabled
          if (_settingsService.isMusicEnabled && _isBackgroundMusicPlaying) {
            debugPrint('Background music stopped unexpectedly, restarting...');
            Future.delayed(const Duration(milliseconds: 100), () {
              playBackgroundMusic();
            });
          } else {
            _isBackgroundMusicPlaying = false;
          }
        } else if (state == PlayerState.playing) {
          _isBackgroundMusicPlaying = true;
        }
      });
      
      // Set volume from settings
      await _updateVolumes();
      
      // Start background music if enabled
      if (_settingsService.isMusicEnabled) {
        await playBackgroundMusic();
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing sound service: $e');
      // Don't mark as initialized if there's an error
    }
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized || _backgroundPlayer == null) {
      debugPrint('Sound service not initialized or player is null');
      return;
    }
    
    if (!_settingsService.isMusicEnabled) {
      debugPrint('Music is disabled in settings');
      return;
    }

    // If already playing, don't restart
    if (_isBackgroundMusicPlaying) {
      debugPrint('Background music already playing');
      return;
    }

    try {
      // Ensure looping is enabled before playing
      await _backgroundPlayer!.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer!.play(AssetSource('sounds/background_music.wav'));
      _isBackgroundMusicPlaying = true;
      debugPrint('Background music started');
    } catch (e) {
      debugPrint('Error playing background music: $e');
      _isBackgroundMusicPlaying = false;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (_backgroundPlayer == null) return;
    try {
      await _backgroundPlayer!.stop();
      _isBackgroundMusicPlaying = false;
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (_backgroundPlayer == null) return;
    try {
      await _backgroundPlayer!.pause();
      _isBackgroundMusicPlaying = false;
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized || _backgroundPlayer == null) return;
    if (!_settingsService.isMusicEnabled) return;
    try {
      // Check current state - if not playing, start fresh instead of resume
      final state = _backgroundPlayer!.state;
      if (state == PlayerState.playing) {
        // Already playing, nothing to do
        _isBackgroundMusicPlaying = true;
        return;
      }
      
      // If paused, resume; otherwise start fresh
      if (state == PlayerState.paused) {
        await _backgroundPlayer!.setReleaseMode(ReleaseMode.loop);
        await _backgroundPlayer!.resume();
        _isBackgroundMusicPlaying = true;
      } else {
        // Not playing or paused, start fresh
        await playBackgroundMusic();
      }
    } catch (e) {
      debugPrint('Error resuming background music: $e');
      // Try to start fresh if resume fails
      await playBackgroundMusic();
    }
  }

  /// Play touch sound effect
  Future<void> playTouchSound() async {
    if (!_isInitialized || _soundEffectsPlayer == null) {
      return;
    }
    
    if (!_settingsService.isSoundEffectsEnabled) {
      return;
    }

    try {
      // Play touch sound without affecting background music
      // Using a separate player with lowLatency mode ensures it doesn't interfere
      await _soundEffectsPlayer!.play(
        AssetSource('sounds/touch_sound.wav'),
        volume: _settingsService.soundEffectsVolume,
      );
      
      // Ensure background music is still playing after touch sound
      // Check after a short delay to allow touch sound to start
      Future.delayed(const Duration(milliseconds: 50), () async {
        if (_backgroundPlayer != null && _settingsService.isMusicEnabled) {
          final bgState = _backgroundPlayer!.state;
          if (bgState != PlayerState.playing && _isBackgroundMusicPlaying) {
            debugPrint('Background music stopped after touch sound, restarting...');
            await playBackgroundMusic();
          }
        }
      });
    } catch (e) {
      debugPrint('Error playing touch sound: $e');
    }
  }

  /// Update volumes from settings
  Future<void> _updateVolumes() async {
    if (_backgroundPlayer != null) {
      await _backgroundPlayer!.setVolume(_settingsService.musicVolume);
    }
    if (_soundEffectsPlayer != null) {
      await _soundEffectsPlayer!.setVolume(_settingsService.soundEffectsVolume);
    }
  }

  /// Update music enabled state
  Future<void> setMusicEnabled(bool enabled) async {
    await _settingsService.setMusicEnabled(enabled);
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  /// Update music volume
  Future<void> setMusicVolume(double volume) async {
    await _settingsService.setMusicVolume(volume);
    if (_backgroundPlayer != null) {
      await _backgroundPlayer!.setVolume(volume);
    }
  }

  /// Update sound effects enabled state
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    await _settingsService.setSoundEffectsEnabled(enabled);
  }

  /// Update sound effects volume
  Future<void> setSoundEffectsVolume(double volume) async {
    await _settingsService.setSoundEffectsVolume(volume);
    if (_soundEffectsPlayer != null) {
      await _soundEffectsPlayer!.setVolume(volume);
    }
  }

  /// Get current music enabled state
  bool get isMusicEnabled => _settingsService.isMusicEnabled;

  /// Get current music volume
  double get musicVolume => _settingsService.musicVolume;

  /// Get current sound effects enabled state
  bool get isSoundEffectsEnabled => _settingsService.isSoundEffectsEnabled;

  /// Get current sound effects volume
  double get soundEffectsVolume => _settingsService.soundEffectsVolume;

  /// Check if background music is currently playing
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _backgroundPlayer?.dispose();
      await _soundEffectsPlayer?.dispose();
    } catch (e) {
      debugPrint('Error disposing sound service: $e');
    }
    _backgroundPlayer = null;
    _soundEffectsPlayer = null;
    _isInitialized = false;
  }
}

