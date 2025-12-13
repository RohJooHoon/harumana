import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // indigo-600 (+/-)
  static const Color secondary = Color(0xFF9333EA); // purple-600
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color surface = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500

  // Status Colors
  static const Color success = Color(0xFF22C55E); // green-500
  static const Color warning = Color(0xFFFACC15); // yellow-400
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Pretendard', // Assuming use of system font or adding Pretendard later.
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF3F4F6)), // gray-100
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
