import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF050507);
  static const Color surface = Color(0xFF121317);
  static const Color neonGreen = Color(0xFF9BFF3D);
  static const Color neonPurple = Color(0xFFB041FF);
  static const Color cyanGlow = Color(0xFF00FFF0);
  static const Color outline = Color(0xFF52FF00);

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: neonPurple,
      brightness: Brightness.dark,
      primary: neonPurple,
      secondary: neonGreen,
      background: black,
      surface: surface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.shareTechMonoTextTheme().apply(
      bodyColor: Colors.white.withOpacity(0.9),
      displayColor: neonGreen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: neonGreen.withOpacity(0.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: neonGreen.withOpacity(0.6), width: 1.4),
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
        shadowColor: neonPurple.withOpacity(0.7),
        elevation: 8,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: neonPurple,
      foregroundColor: Colors.white,
      elevation: 8,
      splashColor: cyanGlow.withOpacity(0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.shareTechMono(
        color: neonGreen,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      shadowColor: neonPurple.withOpacity(0.4),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: outline.withOpacity(0.7), width: 1.4),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}
