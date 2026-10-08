import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/severity.dart';
import 'app_colors.dart';

extension SeverityStyle on Severity {
  Color get color => switch (this) {
        Severity.anaphylactic => AppColors.unsafe,
        Severity.severe => AppColors.risky,
        Severity.preference => AppColors.primary,
      };

  IconData get icon => switch (this) {
        Severity.anaphylactic => CupertinoIcons.exclamationmark_triangle_fill,
        Severity.severe => CupertinoIcons.exclamationmark_circle_fill,
        Severity.preference => CupertinoIcons.info_circle_fill,
      };
}