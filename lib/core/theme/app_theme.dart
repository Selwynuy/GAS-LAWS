import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF99CAE8),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }
  
  // Color constants
  static const Color primaryBlue = Color(0xFF99CAE8);
  static const Color oceanDark = Color(0xFF003366);
  static const Color oceanMid = Color(0xFF006699);
  static const Color oceanDeep = Color(0xFF001122);
  
  // Scuba diving specific colors
  static const Color warningRed = Color(0xFFD32F2F);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color safeGreen = Color(0xFF4CAF50);
}

