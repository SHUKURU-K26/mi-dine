import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  late final Animation<double> _logoFade = CurvedAnimation(
      parent: _c, curve: const Interval(0, 0.5, curve: Curves.easeOut));

  late final Animation<double> _logoScale = Tween<double>(begin: 0.85, end: 1)
      .animate(CurvedAnimation(
          parent: _c, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)));

  late final Animation<double> _textFade = CurvedAnimation(
      parent: _c, curve: const Interval(0.45, 0.9, curve: Curves.easeOut));

  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _c,
              curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset('assets/icon/logo.jpg', height: 170),
                  ),
                ),
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'Mi-Dine',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 6),
                        const Text('Eat out with confidence',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: FadeTransition(
              opacity: _textFade,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}