import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_theme_model.dart';

class AppTheme {
  // Default static colors (Uzay Boşluğu — fallback)
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceBright = Color(0xFF31394D);
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color primary = Color(0xFFD0BCFF);
  static const Color secondary = Color(0xFFADC6FF);
  static const Color tertiary = Color(0xFFFFAFD3);
  static const Color outline = Color(0xFF958EA0);
  static const Color glassFill = Color(0x1F31394D);
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Build ThemeData from a dynamic AppThemeModel
  static ThemeData fromModel(AppThemeModel model) {
    final glassFillDynamic = model.surfaceBright.withOpacity(0.12);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: model.surface,
      colorScheme: ColorScheme.dark(
        surface: model.surface,
        onSurface: model.onSurface,
        primary: model.primary,
        secondary: model.secondary,
        tertiary: model.tertiary,
        outline: model.outline,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 80,
          fontWeight: FontWeight.w700,
          letterSpacing: -3.2,
          color: model.onSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          color: model.onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: model.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: model.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: model.onSurface,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: model.onSurface.withOpacity(0.7),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassFillDynamic,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: model.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
        ),
      ),
    );
  }

  /// Static getter for backward-compatibility
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        outline: outline,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 80,
          fontWeight: FontWeight.w700,
          letterSpacing: -3.2,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: onSurface.withOpacity(0.7),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: glassBorder, width: 1),
          ),
        ),
      ),
    );
  }
}
