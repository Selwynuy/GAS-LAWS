# Sound System Setup Guide

## What's Been Implemented

✅ **Sound Service** - Manages background music and sound effects
✅ **Settings Service** - Persists audio preferences (music volume, sound effects, etc.)
✅ **Settings Screen** - Updated to control music and sound effects
✅ **Touch Sounds** - Automatic touch sounds on all taps
✅ **Background Music** - Looping background music support

## What You Need to Do

### 1. Install Dependencies

Run this command to install the new packages:
```bash
flutter pub get
```

### 2. Add Sound Files

Create the `assets/sounds/` directory if it doesn't exist, then add these two files:

- **`assets/sounds/background_music.wav`** - Your scientific background music (no vocals)
- **`assets/sounds/touch_sound.wav`** - Your touch/click sound effect

### 3. File Requirements

**Background Music:**
- Format: WAV (currently used) or MP3
- Will loop automatically (can be short, e.g., 16 seconds)
- Sample rate: 44.1kHz or 48kHz
- Bitrate: 128-192 kbps

**Touch Sound:**
- Format: WAV (currently used) or MP3
- Short duration: 50-200ms
- Should be subtle and not annoying when repeated
- Sample rate: 44.1kHz or 48kHz
- Bitrate: 64-128 kbps

### 4. Where to Get Free Assets

See `assets/sounds/README.md` for detailed information on where to find free sound assets.

**Quick Links:**
- **Freesound.org** - https://freesound.org (search "scientific ambient" or "ui click")
- **OpenGameArt.org** - https://opengameart.org
- **Zapsplat.com** - https://www.zapsplat.com (free account required)
- **Incompetech.com** - https://incompetech.com/music/ (Kevin MacLeod's music)
- **Pixabay.com** - https://pixabay.com/music/

### 5. Test the Implementation

Once you've added the sound files:

1. Run `flutter pub get` if you haven't already
2. Run the app: `flutter run`
3. Go to Settings and adjust music/sound effect volumes
4. Test touch sounds by tapping buttons throughout the app
5. Background music should start automatically when the app launches

## How It Works

- **Background Music**: Starts automatically when the app launches (if enabled in settings)
- **Touch Sounds**: Play automatically on every tap/click throughout the app
- **Settings**: All preferences are saved and persist between app sessions
- **Volume Control**: Independent volume controls for music and sound effects

## Troubleshooting

**No sound playing?**
- Make sure the sound files are in `assets/sounds/` directory
- Check that file names match exactly: `background_music.wav` and `touch_sound.wav`
- Verify the files are listed in `pubspec.yaml` under assets (already done)
- Check Settings to ensure music/sound effects are enabled

**Sound files not found?**
- Run `flutter clean` then `flutter pub get`
- Restart the app completely
- Check file paths are correct (case-sensitive on some platforms)

**Too many touch sounds?**
- The touch sound system detects taps vs drags (won't play during scrolling)
- You can disable sound effects in Settings
- Individual buttons can be updated to not play sounds if needed

