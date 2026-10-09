import 'package:flutter/material.dart';

import '../core/theme/safety_style.dart';
import '../models/dish_assessment.dart';

class SafetyBadge extends StatelessWidget {
  const SafetyBadge({super.key, required this.level});

  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: 14, color: level.color),
          const SizedBox(width: 6),
          Text(level.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: level.color)),
        ],
      ),
    );
  }
}