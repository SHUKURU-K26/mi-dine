import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextStyle _inter(double size, FontWeight weight) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.text,
      );

  static TextStyle _poppins(double size, FontWeight weight) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.text,
      );

  static ThemeData get light {
    final textTheme = TextTheme(
      headlineLarge: _poppins(32, FontWeight.w700),
      headlineMedium: _poppins(26, FontWeight.w600),
      headlineSmall: _poppins(22, FontWeight.w600),
      titleLarge: _poppins(20, FontWeight.w600),
      titleMedium: _inter(16, FontWeight.w600),
      titleSmall: _inter(14, FontWeight.w600),
      bodyLarge: _inter(16, FontWeight.w400),
      bodyMedium: _inter(14, FontWeight.w400),
      bodySmall: _inter(12, FontWeight.w400),
      labelLarge: _inter(14, FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.unsafe,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: AppColors.primaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryTint),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryTint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}