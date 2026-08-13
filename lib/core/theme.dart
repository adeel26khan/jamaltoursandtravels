import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      primaryColor: AppConstants.deepGreen,
      scaffoldBackgroundColor: AppConstants.softCream,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.deepGreen,
        secondary: AppConstants.primaryGold,
        surface: AppConstants.warmWhite,
        onPrimary: AppConstants.warmWhite,
        onSecondary: AppConstants.charcoal,
        onSurface: AppConstants.charcoal,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: AppConstants.deepGreen,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppConstants.deepGreen,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppConstants.deepGreen,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConstants.charcoal,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppConstants.deepGreen,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppConstants.charcoal,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppConstants.charcoal.withValues(alpha: 0.85),
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppConstants.warmWhite,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.deepGreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppConstants.primaryGold),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.warmWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGold,
          foregroundColor: AppConstants.charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.deepGreen,
          side: const BorderSide(color: AppConstants.primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.warmWhite,
        elevation: 2,
        shadowColor: AppConstants.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppConstants.borderGold, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.warmWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppConstants.primaryGold.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppConstants.primaryGold.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppConstants.deepGreen, width: 2),
        ),
        labelStyle: TextStyle(color: AppConstants.charcoal.withValues(alpha: 0.7)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.deepGreen,
        selectedItemColor: AppConstants.primaryGold,
        unselectedItemColor: AppConstants.warmWhite.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Islamic typography helper style (using Amiri font)
  static TextStyle islamicAccentStyle({double fontSize = 24, Color? color}) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? AppConstants.primaryGold,
      height: 1.4,
    );
  }

  // Glassmorphic Card decoration helper
  static BoxDecoration glassCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? AppConstants.warmWhite).withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppConstants.primaryGold.withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppConstants.deepGreen.withValues(alpha: 0.08),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
