import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/safety_style.dart';
import '../../core/utils/error_text.dart';
import '../../models/dish.dart';
import '../../models/dish_assessment.dart';
import '../../models/inputs.dart';
import '../../models/restaurant.dart';
import '../../models/user_allergen.dart';
import '../../repositories/restaurant_repository.dart';
import '../../services/safety_checker.dart';
import '../../state/auth_provider.dart';
import '../../state/navigation_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/restaurant_avatar.dart';
import '../../widgets/safety_badge.dart';
import '../../widgets/skeleton_box.dart';
import '../reviews/reviews_section.dart';
import 'dish_form_sheet.dart';
import 'restaurant_form_sheet.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  late Restaurant _r = widget.restaurant;
  bool _safeOnly = false;

  bool get _isOwner =>
      _r.createdBy != null && _r.createdBy == ref.read(currentUserIdProvider);

  static const _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );

  void _goToTab(int index) {
    Navigator.of(context).pop();
    ref.read(navIndexProvider.notifier).select(index);
  }

  SnackBar _snack(String text, {bool error = false}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.unsafe : AppColors.primaryDark,
        content: Text(text),
      );

  Future<bool> _confirm(String title, String message) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  // ------------------------------------------------------- Restaurant actions

  Future<void> _editRestaurant() async {
    final messenger = ScaffoldMessenger.of(context);
    final input = await showModalBottomSheet<RestaurantInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: _sheetShape,
      builder: (_) => RestaurantFormSheet(initial: _r),
    );
    if (input == null) return;

    try {
      final updated =
          await ref.read(restaurantRepositoryProvider).updateRestaurant(_r.id, input);
      ref.invalidate(restaurantsProvider);
      if (!mounted) return;
      setState(() => _r = updated);
      messenger.showSnackBar(_snack('Restaurant updated'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  Future<void> _deleteRestaurant() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await _confirm('Delete ${_r.name}?',
        'Its menu and all reviews will be deleted too. This cannot be undone.');
    if (!ok) return;

    try {
      await ref.read(restaurantRepositoryProvider).deleteRestaurant(_r.id);
      ref.invalidate(restaurantsProvider);
      navigator.pop();
      messenger.showSnackBar(_snack('${_r.name} deleted'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  // ------------------------------------------------------------ Dish actions

  Future<DishInput?> _dishSheet({Dish? dish}) async {
    final catalog = await ref.read(allergenCatalogProvider.future);
    if (!mounted) return null;
    final names = [
      for (final a in catalog)
        if (!a.isCustom) a.name,
    ];
    return showModalBottomSheet<DishInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: _sheetShape,
      builder: (_) => DishFormSheet(allergenNames: names, initial: dish),
    );
  }

  Future<void> _addDish() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final input = await _dishSheet();
      if (input == null) return;
      await ref.read(restaurantRepositoryProvider).addDish(_r.id, input);
      ref.invalidate(dishesProvider(_r.id));
      messenger.showSnackBar(_snack('${input.name} added to the menu'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  Future<void> _editDish(Dish dish) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final input = await _dishSheet(dish: dish);
      if (input == null) return;
      await ref.read(restaurantRepositoryProvider).updateDish(dish.id, input);
      ref.invalidate(dishesProvider(_r.id));
      messenger.showSnackBar(_snack('${input.name} updated'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  Future<void> _deleteDish(Dish dish) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _confirm('Delete ${dish.name}?',
        'It will be removed from this menu.');
    if (!ok) return;

    try {
      await ref.read(restaurantRepositoryProvider).deleteDish(dish.id);
      ref.invalidate(dishesProvider(_r.id));
      messenger.showSnackBar(_snack('${dish.name} deleted'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  // ------------------------------------------------------------------- Build

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final dishes = ref.watch(dishesProvider(_r.id));
    final mine = ref.watch(myAllergensProvider).value ?? const <UserAllergen>[];
    final owner = _isOwner;

    return Scaffold(
      appBar: AppBar(
        title: Text(_r.name),
        actions: [
          if (owner)
            PopupMenuButton<String>(
              icon: const Icon(CupertinoIcons.ellipsis_circle),
              onSelected: (v) =>
                  v == 'edit' ? _editRestaurant() : _deleteRestaurant(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit restaurant')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete restaurant',
                      style: TextStyle(color: AppColors.unsafe)),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Hero(
                tag: 'restaurant-${_r.id}',
                child: RestaurantAvatar(name: _r.name, size: 68),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_r.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(_r.cuisine,
                        style: TextStyle(
                            color: pal.accent, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(CupertinoIcons.location, size: 14, color: pal.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(_r.address,
                            style: TextStyle(color: pal.muted, fontSize: 13)),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          if (_r.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(_r.description,
                style: TextStyle(color: pal.muted, height: 1.45)),
          ],
          if (_r.isUserAdded) ...[
            const SizedBox(height: 16),
            _InfoBanner(
              icon: CupertinoIcons.person_2,
              color: AppColors.risky,
              text: owner
                  ? 'You added this restaurant. Other members see it as unverified.'
                  : 'Member added and unverified. Ingredient details come from a member, not the restaurant. Always confirm with the kitchen.',
            ),
          ],
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
              onRetry: () => ref.invalidate(dishesProvider(_r.id)),
            ),
            data: (list) => _menu(
              const SafetyChecker().assessAll(list, mine),
              hasProfile: mine.isNotEmpty,
              owner: owner,
            ),
          ),
          const SizedBox(height: 32),
          ReviewsSection(restaurantId: _r.id),
        ],
      ),
    );
  }

  Widget _menu(List<DishAssessment> items,
      {required bool hasProfile, required bool owner}) {
    final pal = context.pal;
    final visible = _safeOnly
        ? items.where((a) => a.level == SafetyLevel.safe).toList()
        : items;
    int count(SafetyLevel l) => items.where((a) => a.level == l).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasProfile && items.isNotEmpty) ...[
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
              child:
                  Text('Menu', style: Theme.of(context).textTheme.titleMedium),
            ),
            if (owner)
              TextButton.icon(
                onPressed: _addDish,
                icon: const Icon(CupertinoIcons.add, size: 18),
                label: const Text('Add dish'),
              ),
            if (hasProfile && items.isNotEmpty) ...[
              Text('Safe only', style: TextStyle(color: pal.muted, fontSize: 13)),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: _safeOnly,
                activeTrackColor: pal.brand,
                onChanged: (v) => setState(() => _safeOnly = v),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                owner
                    ? 'No dishes yet. Tap Add dish to build the menu.'
                    : 'This restaurant has no dishes listed yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: pal.muted),
              ),
            ),
          )
        else if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No safe dishes on this menu for your profile.',
                style: TextStyle(color: pal.muted),
              ),
            ),
          )
        else
          for (final (i, a) in visible.indexed)
            FadeSlideIn(
              key: ValueKey(a.dish.id),
              delayMs: min(i * 40, 300),
              child: _DishCard(
                assessment: a,
                showStatus: hasProfile,
                onEdit: owner ? () => _editDish(a.dish) : null,
                onDelete: owner ? () => _deleteDish(a.dish) : null,
              ),
            ),
        const SizedBox(height: 8),
        Text(
          'Ingredient information is provided by the restaurant or a member. Always confirm with the kitchen.',
          style: TextStyle(color: pal.muted, fontSize: 12, height: 1.4),
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
              style: TextStyle(fontSize: 12, color: context.pal.muted)),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.assessment,
    required this.showStatus,
    this.onEdit,
    this.onDelete,
  });

  final DishAssessment assessment;
  final bool showStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final dish = assessment.dish;
    final color = assessment.level.color;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showStatus ? color.withValues(alpha: 0.5) : pal.tint,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: pal.text)),
                    if (dish.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(dish.description,
                          style: TextStyle(
                              color: pal.muted, fontSize: 13, height: 1.35)),
                    ],
                  ],
                ),
              ),
              if (dish.price != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text('\$${dish.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: pal.strong)),
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
                    style: TextStyle(fontSize: 12.5, color: pal.muted)),
              ),
          ],
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(CupertinoIcons.pencil, size: 16),
                    label: const Text('Edit'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(CupertinoIcons.delete,
                        size: 16, color: AppColors.unsafe),
                    label: const Text('Delete',
                        style: TextStyle(color: AppColors.unsafe)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, height: 1.4, color: context.pal.text)),
          ),
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
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.info_circle, size: 20, color: pal.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add your allergens to see which dishes are safe for you.',
              style: TextStyle(fontSize: 13, height: 1.4, color: pal.strong),
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Add')),
        ],
      ),
    );
  }
}