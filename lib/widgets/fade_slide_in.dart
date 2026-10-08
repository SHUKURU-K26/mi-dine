import 'package:flutter/material.dart';

/// Fades and slides its child up on first build.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}