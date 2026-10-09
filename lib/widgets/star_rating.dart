import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
            size: size,
            color: AppColors.risky,
          ),
      ],
    );
  }
}