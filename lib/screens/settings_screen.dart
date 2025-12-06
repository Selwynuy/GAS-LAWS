import 'package:flutter/material.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  double _musicVolume = 0.7;
  bool _soundEffectsEnabled = true;
  double _soundEffectsVolume = 0.8;
  bool _animationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF003366),
              Color(0xFF006699),
              Color(0xFF001122),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Music section
                _buildSection(
                  title: 'Music',
                  icon: Icons.music_note,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Enable Music',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _musicEnabled,
                      onChanged: (value) {
                        setState(() {
                          _musicEnabled = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                    if (_musicEnabled) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume: ${(_musicVolume * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: _musicVolume,
                              onChanged: (value) {
                                setState(() {
                                  _musicVolume = value;
                                });
                              },
                              activeColor: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                // Sound Effects section
                _buildSection(
                  title: 'Sound Effects',
                  icon: Icons.volume_up,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Enable Sound Effects',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _soundEffectsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEffectsEnabled = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                    if (_soundEffectsEnabled) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume: ${(_soundEffectsVolume * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: _soundEffectsVolume,
                              onChanged: (value) {
                                setState(() {
                                  _soundEffectsVolume = value;
                                });
                              },
                              activeColor: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                // Other settings
                _buildSection(
                  title: 'Display',
                  icon: Icons.palette,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Enable Animations',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _animationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _animationsEnabled = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // About section
                _buildSection(
                  title: 'About',
                  icon: Icons.info,
                  children: [
                    ListTile(
                      title: const Text(
                        'Boyle\'s Law Lab',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'An educational simulation of scuba diving gas laws',
                        style: TextStyle(color: Colors.white70),
                      ),
                      leading: const Icon(Icons.science, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

