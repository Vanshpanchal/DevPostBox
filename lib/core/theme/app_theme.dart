/// App theme configuration for DevPostBox
/// Black and white monochrome Material 3 theme
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Light theme - White background, black text
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black, // Yellow needs black text
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerLight),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      inputDecorationTheme: _buildInputTheme(Brightness.light),
      elevatedButtonTheme: _buildButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryLight),
    );
  }

  /// Dark theme - Black background, white text
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryDark,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerDark),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      inputDecorationTheme: _buildInputTheme(Brightness.dark),
      elevatedButtonTheme: _buildButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryDark),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color primaryColor = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final Color secondaryColor = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primaryColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primaryColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color fillColor = isLight
        ? AppColors.surfaceLight
        : AppColors.cardDark;
    final Color borderColor = isLight
        ? AppColors.dividerLight
        : AppColors.dividerDark;
    final Color focusColor = isLight
        ? AppColors.primaryLight
        : AppColors.primaryDark;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLight
            ? AppColors.primaryLight
            : AppColors.primaryDark,
        foregroundColor: isLight ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    Brightness brightness,
  ) {
    final bool isLight = brightness == Brightness.light;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isLight
            ? AppColors.primaryLight
            : AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(
          color: isLight ? AppColors.primaryLight : AppColors.primaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
