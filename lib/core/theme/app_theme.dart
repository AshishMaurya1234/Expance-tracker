import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF00C897);
  static const Color primaryDark = Color(0xFF00A878);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentGold = Color(0xFFFFD93D);
  static const Color background = Color(0xFF0D0F14);
  static const Color cardSurface = Color(0xFF161B26);
  static const Color cardElevated = Color(0xFF1E2535);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9BA3BC);
  static const Color textHint = Color(0xFF4A5270);
  static const Color border = Color(0xFF252D45);
  static const Color success = Color(0xFF00C897);
  static const Color error = Color(0xFFFF4F6B);
  static const Color gradientBlue = Color(0xFF0096FF);

  static TextTheme _textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark ? textPrimary : const Color(0xFF111827);

    return TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? textSecondary : const Color(0xFF4B5563),
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    textTheme: _textTheme(Brightness.dark),
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: gradientBlue,
      surface: cardSurface,
      error: error,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardElevated,
      hintStyle: GoogleFonts.dmSans(
        color: textHint,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: GoogleFonts.dmSans(
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F7FB),
    textTheme: _textTheme(Brightness.light),
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: gradientBlue,
      surface: Colors.white,
      error: error,
      onPrimary: Colors.white,
      onSurface: Color(0xFF111827),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111827),
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}