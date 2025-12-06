import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Base palette (kept private; consumed via ColorScheme)
  static const Color _black = Color(0xFF050507);
  static const Color _surface = Color(0xFF121317);
  static const Color _neonGreen = Color(0xFF9BFF3D);
  static const Color _neonPurple = Color(0xFFB041FF);
  static const Color _magentaPink = Color(0xFFFF00FF);
  static const Color _cyan = Color(0xFF00E5CC);
  static const Color _danger = Color(0xFFFF0040);
  static const Color _darkBg = Color(0xFF0A0A0A);

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _black,
    colorScheme: ColorScheme.dark(
      primary: _neonPurple,
      onPrimary: Colors.black,
      secondary: _neonGreen,
      onSecondary: Colors.black,
      tertiary: _magentaPink,
      onTertiary: Colors.black,
      surface: _surface,
      onSurface: Colors.white,
      error: _danger,
      onError: Colors.white,
      outline: _neonGreen,
      surfaceContainerLowest: _darkBg,
    ),
    textTheme: GoogleFonts.shareTechMonoTextTheme().apply(
      bodyColor: Colors.white.withValues(alpha: 0.9),
      displayColor: _neonGreen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      hintStyle: TextStyle(color: _neonGreen.withValues(alpha: 0.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _neonGreen.withValues(alpha:0.6), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _neonPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _danger.withValues(alpha:0.9), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _danger.withValues(alpha:0.9), width: 2),
      ),
      labelStyle: const TextStyle(color: _neonGreen),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _neonPurple,
        foregroundColor: Colors.white,
        shadowColor: _neonPurple.withValues(alpha:0.7),
        elevation: 8,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _neonPurple,
      foregroundColor: Colors.white,
      elevation: 8,
      splashColor: _cyan.withValues(alpha:0.3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.shareTechMono(
        color: _neonGreen,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: _surface,
      shadowColor: _neonPurple.withValues(alpha:0.4),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: _neonGreen.withValues(alpha:0.7), width: 1.4),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}