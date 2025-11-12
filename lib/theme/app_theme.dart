import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF0B0B0C);
  static const Color surface = Color(0xFF121316);
  static const Color neonGreen = Color(0xFF9BFF3D);
  static const Color neonPurple = Color(0xFFB041FF);
  static const Color outline = Color(0xFF52FF00);

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: neonGreen,
      brightness: Brightness.dark,
      primary: neonGreen,
      secondary: neonPurple,
      background: black,
      surface: surface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.shareTechMonoTextTheme().apply(
      bodyColor: Colors.white, displayColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: outline, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: neonPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: neonGreen),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side:  const BorderSide(color: outline, width: 2),
      ),
      margin:  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}