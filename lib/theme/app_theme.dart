import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const int _primaryValue = 0xFF5d708e;
  static const MaterialColor primary = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFF5F8FB),
      100: Color(0xFFE6EEF6),
      200: Color(0xFFD4E1F0),
      300: Color(0xFFAFCBE2),
      400: Color(0xFF81A9D4),
      500: Color(_primaryValue),
      600: Color(0xFF455773),
      700: Color(0xFF39485F),
      800: Color(0xFF2D384B),
      900: Color(0xFF1F2736),
    },
  );

  static const int _pointValue = 0xFFEDB0B8;
  static const MaterialColor point = MaterialColor(
    _pointValue,
    <int, Color>{
      50: Color(0xFFFCF6F7),
      100: Color(0xFFF8E7E9),
      200: Color(0xFFF4D8DC),
      300: Color(0xFFF0C9CE),
      400: Color(0xFFECB9C0),
      500: Color(_pointValue),
      600: Color(0xFFD99FA7), 
      700: Color(0xFFC58E95),
      800: Color(0xFFB17D84),
      900: Color(0xFF906066),
    },
  );

  static const Color background = Color(0xFFF9FAFB); 
  static const Color surface = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF455773)], // primary[600]
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pointGradient = LinearGradient(
    colors: [point, Color(0xFFC58E95)], // point[700]
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
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
        secondary: const Color(0xFFAFCBE2), // primary[300]
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
