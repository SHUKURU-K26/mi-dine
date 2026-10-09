import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/severity_style.dart';
import '../../models/dish_assessment.dart';
import '../../models/severity.dart';
import '../../state/onboarding_provider.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/safety_badge.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _count = 3;
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => ref.read(onboardingProvider.notifier).complete();

  void _next() {
    if (_page == _count - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final last = _page == _count - 1;

    return Scaffold(
      backgroundColor: pal.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: last ? 0 : 1,
                      child: TextButton(
                        onPressed: last ? null : _finish,
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: const [
                      _Slide(
                        title: 'Tell us what you cannot eat',
                        body:
                            'Build a precise medical profile with each trigger and how serious it is. Not a diet label, your real needs.',
                        illustration: _ProfileIllustration(),
                      ),
                      _Slide(
                        title: 'Hand the chef a clear ticket',
                        body:
                            'Mi-Dine writes kitchen instructions in English, Spanish, French, Arabic or Mandarin. Show your screen or share it.',
                        illustration: _TicketIllustration(),
                      ),
                      _Slide(
                        title: 'See what is safe before you order',
                        body:
                            'Scan the code on a menu and every dish is marked Safe, Caution or Not safe, with the reason.',
                        illustration: _MenuIllustration(),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _count; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: i == _page ? 28 : 8,
                        decoration: BoxDecoration(
                          color: i == _page ? AppColors.primary : pal.tint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: FilledButton(
                    onPressed: _next,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(last ? 'Get started' : 'Continue',
                          key: ValueKey(last)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String title;
  final String body;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(child: SizedBox(height: 280, child: Center(child: illustration))),
          const SizedBox(height: 28),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(body,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.pal.muted, height: 1.5)),
        ],
      ),
    );
  }
}

class _ProfileIllustration extends StatelessWidget {
  const _ProfileIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.primary,
          child: Icon(CupertinoIcons.shield_lefthalf_fill,
              color: Colors.white, size: 52),
        ),
        SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _MiniChip('Peanuts', Severity.anaphylactic),
            _MiniChip('Gluten', Severity.severe),
            _MiniChip('Soy', Severity.preference),
          ],
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.label, this.severity);

  final String label;
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.pal.text)),
              Text(severity.label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketIllustration extends StatelessWidget {
  const _TicketIllustration();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    const languages = ['English', 'Español', 'Français', 'العربية', '中文'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 260,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: pal.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.tint, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.all(14),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.shield_lefthalf_fill,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('MEDICAL DIETARY ALERT',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.4)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.unsafe.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.unsafe.withValues(alpha: 0.6),
                        width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ANAPHYLACTIC ALLERGY',
                          style: TextStyle(
                              color: AppColors.unsafe,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                      const SizedBox(height: 6),
                      Text('Peanuts',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: pal.text)),
                      const SizedBox(height: 8),
                      const _Bar(0.9),
                      const SizedBox(height: 6),
                      const _Bar(0.65),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, l) in languages.indexed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: i == 1 ? AppColors.primary : pal.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: i == 1 ? AppColors.primary : pal.tint, width: 1.5),
                ),
                child: Text(l,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: i == 1 ? Colors.white : pal.text)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.factor);

  final double factor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: factor,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.unsafe.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _MenuIllustration extends StatelessWidget {
  const _MenuIllustration();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DishRow('Grilled Tilapia', SafetyLevel.safe),
        SizedBox(height: 10),
        _DishRow('Pesto Gnocchi', SafetyLevel.caution),
        SizedBox(height: 10),
        _DishRow('Peanut Stew', SafetyLevel.unsafe),
      ],
    );
  }
}

class _DishRow extends StatelessWidget {
  const _DishRow(this.name, this.level);

  final String name;
  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: 290,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pal.tint, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: pal.text)),
          ),
          SafetyBadge(level: level),
        ],
      ),
    );
  }
}