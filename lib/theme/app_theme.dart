import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFFD2691E);
  static const Color lightSecondary = Color(0xFFE74C3C);
  static const Color lightAccent = Color(0xFF27AE60);
  static const Color lightBackground = Color(0xFFFDF6F0);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2C3E50);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFFF8C42);
  static const Color darkSecondary = Color(0xFFFF6B6B);
  static const Color darkAccent = Color(0xFF4ECDC4);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE8E8E8);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: lightPrimary),
      titleTextStyle: TextStyle(
        color: lightPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: darkPrimary),
      titleTextStyle: TextStyle(
        color: darkPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );
}
