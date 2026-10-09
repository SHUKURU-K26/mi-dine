import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static TextStyle _inter(double size, FontWeight weight, Color color) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle _poppins(double size, FontWeight weight, Color color) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

  static ThemeData _build(AppPalette pal, Brightness brightness) {
    final c = pal.text;
    final textTheme = TextTheme(
      headlineLarge: _poppins(32, FontWeight.w700, c),
      headlineMedium: _poppins(26, FontWeight.w600, c),
      headlineSmall: _poppins(22, FontWeight.w600, c),
      titleLarge: _poppins(20, FontWeight.w600, c),
      titleMedium: _inter(16, FontWeight.w600, c),
      titleSmall: _inter(14, FontWeight.w600, c),
      bodyLarge: _inter(16, FontWeight.w400, c),
      bodyMedium: _inter(14, FontWeight.w400, c),
      bodySmall: _inter(12, FontWeight.w400, c),
      labelLarge: _inter(14, FontWeight.w600, c),
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: pal.accent,
      surface: pal.surface,
      onSurface: pal.text,
      error: AppColors.unsafe,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [pal],
      scaffoldBackgroundColor: pal.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: pal.background,
        foregroundColor: pal.strong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: pal.strong),
      ),
      cardTheme: CardThemeData(
        color: pal.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: pal.tint),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pal.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pal.tint,
        hintStyle: TextStyle(color: pal.muted),
        labelStyle: TextStyle(color: pal.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: pal.accent, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: pal.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: pal.tint,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? pal.accent
                  : pal.muted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? pal.accent
                  : pal.muted,
            )),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: pal.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: pal.tint,
      ),
      dividerTheme: DividerThemeData(color: pal.tint),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}