import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/dish_assessment.dart';
import 'app_colors.dart';

extension SafetyStyle on SafetyLevel {
  Color get color => switch (this) {
        SafetyLevel.safe => AppColors.safe,
        SafetyLevel.caution => AppColors.risky,
        SafetyLevel.unsafe => AppColors.unsafe,
      };

  IconData get icon => switch (this) {
        SafetyLevel.safe => CupertinoIcons.checkmark_circle_fill,
        SafetyLevel.caution => CupertinoIcons.exclamationmark_triangle_fill,
        SafetyLevel.unsafe => CupertinoIcons.xmark_circle_fill,
      };

  String get label => switch (this) {
        SafetyLevel.safe => 'Safe',
        SafetyLevel.caution => 'Caution',
        SafetyLevel.unsafe => 'Not safe',
      };
}