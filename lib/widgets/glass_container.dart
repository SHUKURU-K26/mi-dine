import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_palette.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: pal.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: pal.tint.withValues(alpha: 0.9)),
          ),
          child: child,
        ),
      ),
    );
  }
}