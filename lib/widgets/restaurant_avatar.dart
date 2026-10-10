import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';

class RestaurantAvatar extends StatelessWidget {
  const RestaurantAvatar({super.key, required this.name, this.size = 56});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.pal.tint,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            color: context.pal.accent,
          ),
        ),
      ),
    );
  }
}