import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neutral colours that change between light and dark mode.
/// Safety colours (safe, risky, unsafe) stay in AppColors because they never change.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.tint,
    required this.text,
    required this.muted,
    required this.strong,
    required this.accent,
    required this.brand,
  });

  final Color background;
  final Color surface;
  final Color tint;
  final Color text;
  final Color muted;

  /// Headings and text that sit on a tinted surface.
  final Color strong;

  /// Teal used for icons and text links.
  final Color accent;

  /// Teal used as a filled background behind white text.
  final Color brand;

  static const light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    tint: AppColors.primaryTint,
    text: AppColors.text,
    muted: AppColors.textMuted,
    strong: AppColors.primaryDark,
    accent: AppColors.primary,
    brand: AppColors.primary,
  );

  static const dark = AppPalette(
    background: Color(0xFF0B1517),
    surface: Color(0xFF132226),
    tint: Color(0xFF1E383D),
    text: Color(0xFFE8F1F2),
    muted: Color(0xFF8FA6AA),
    strong: Color(0xFFBFE3E7),
    accent: Color(0xFF5FC0CC),
    brand: Color(0xFF1A7885),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? tint,
    Color? text,
    Color? muted,
    Color? strong,
    Color? accent,
    Color? brand,
  }) =>
      AppPalette(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        tint: tint ?? this.tint,
        text: text ?? this.text,
        muted: muted ?? this.muted,
        strong: strong ?? this.strong,
        accent: accent ?? this.accent,
        brand: brand ?? this.brand,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      strong: Color.lerp(strong, other.strong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get pal =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}