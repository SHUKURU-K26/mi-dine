import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/safety_style.dart';
import '../../core/utils/error_text.dart';
import '../../models/dish_assessment.dart';
import '../../models/restaurant.dart';
import '../../models/user_allergen.dart';
import '../../services/safety_checker.dart';
import '../../state/navigation_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/restaurant_avatar.dart';
import '../../widgets/safety_badge.dart';
import '../../widgets/skeleton_box.dart';
import '../reviews/reviews_section.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  bool _safeOnly = false;

  void _goToTab(int index) {
    Navigator.of(context).pop();
    ref.read(navIndexProvider.notifier).select(index);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final dishes = ref.watch(dishesProvider(r.id));
    final mine = ref.watch(myAllergensProvider).value ?? const <UserAllergen>[];

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Hero(
                tag: 'restaurant-${r.id}',
                child: RestaurantAvatar(name: r.name, size: 68),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(r.cuisine,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(CupertinoIcons.location,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(r.address,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13)),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(r.description,
              style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
          const SizedBox(height: 24),
          if (mine.isEmpty) ...[
            _NoProfileBanner(onTap: () => _goToTab(3)),
            const SizedBox(height: 24),
          ],
          dishes.when(
            loading: () => const Column(children: [
              SkeletonBox(height: 80),
              SizedBox(height: 10),
              SkeletonBox(height: 80),
              SizedBox(height: 10),
              SkeletonBox(height: 80),
            ]),
            error: (e, _) => ErrorState(
              message: friendlyError(e),
              onRetry: () => ref.invalidate(dishesProvider(r.id)),
            ),
            data: (list) => _menu(
              const SafetyChecker().assessAll(list, mine),
              hasProfile: mine.isNotEmpty,
            ),
          ),
          const SizedBox(height: 32),
          ReviewsSection(restaurantId: r.id),
        ],
      ),
    );
  }

  Widget _menu(List<DishAssessment> items, {required bool hasProfile}) {
    final visible = _safeOnly
        ? items.where((a) => a.level == SafetyLevel.safe).toList()
        : items;
    int count(SafetyLevel l) => items.where((a) => a.level == l).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasProfile) ...[
          Row(
            children: [
              for (final level in SafetyLevel.values) ...[
                Expanded(child: _CountTile(level: level, count: count(level))),
                if (level != SafetyLevel.unsafe) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Expanded(
              child: Text('Menu',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (hasProfile) ...[
              const Text('Safe only',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: _safeOnly,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => setState(() => _safeOnly = v),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No safe dishes on this menu for your profile.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          for (final (i, a) in visible.indexed)
            FadeSlideIn(
              key: ValueKey(a.dish.id),
              delayMs: min(i * 40, 300),
              child: _DishCard(assessment: a, showStatus: hasProfile),
            ),
        const SizedBox(height: 8),
        const Text(
          'Ingredient information is provided by the restaurant. Always confirm with the kitchen.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
        ),
        if (hasProfile) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _goToTab(2),
            icon: const Icon(CupertinoIcons.doc_text_fill),
            label: const Text('Open my Kitchen Ticket'),
          ),
        ],
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.level, required this.count});

  final SafetyLevel level;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(level.icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text('$count',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(level.label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.assessment, required this.showStatus});

  final DishAssessment assessment;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final dish = assessment.dish;
    final color = assessment.level.color;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showStatus
              ? color.withValues(alpha: 0.5)
              : AppColors.primaryTint,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    if (dish.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(dish.description,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.35)),
                    ],
                  ],
                ),
              ),
              if (dish.price != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text('\$${dish.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ),
            ],
          ),
          if (showStatus) ...[
            const SizedBox(height: 10),
            SafetyBadge(level: assessment.level),
            for (final reason in assessment.reasons)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(reason,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted)),
              ),
          ],
        ],
      ),
    );
  }
}

class _NoProfileBanner extends StatelessWidget {
  const _NoProfileBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.info_circle,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add your allergens to see which dishes are safe for you.',
              style: TextStyle(
                  fontSize: 13, height: 1.4, color: AppColors.primaryDark),
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Add')),
        ],
      ),
    );
  }
}