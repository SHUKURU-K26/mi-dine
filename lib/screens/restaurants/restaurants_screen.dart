import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../models/restaurant.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/restaurant_avatar.dart';
import '../../widgets/skeleton_box.dart';
import 'restaurant_detail_screen.dart';
import 'scan_flow.dart';

class RestaurantsScreen extends ConsumerStatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  ConsumerState<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends ConsumerState<RestaurantsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Restaurant r) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r)),
    );
  }

  Future<void> _scan() => scanAndOpenRestaurant(context, ref);

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(filteredRestaurantsProvider);
    final cuisines = ref.watch(cuisinesProvider);
    final selected = ref.watch(cuisineFilterProvider);
    final query = ref.watch(restaurantSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        actions: [
          IconButton(
            tooltip: 'Scan QR code',
            icon: Icon(CupertinoIcons.qrcode_viewfinder),
            onPressed: _scan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: ref.read(restaurantSearchProvider.notifier).set,
              decoration: InputDecoration(
                hintText: 'Search restaurants or cuisines',
                prefixIcon: Icon(CupertinoIcons.search,
                    size: 20, color: context.pal.accent),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(CupertinoIcons.clear_circled_solid,
                            size: 20, color: context.pal.muted),
                        onPressed: () {
                          _search.clear();
                          ref.read(restaurantSearchProvider.notifier).set('');
                        },
                      ),
              ),
            ),
          ),
          if (cuisines.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterPill(
                    label: 'All',
                    active: selected == null,
                    onTap: () =>
                        ref.read(cuisineFilterProvider.notifier).set(null),
                  ),
                  for (final c in cuisines) ...[
                    SizedBox(width: 8),
                    _FilterPill(
                      label: c,
                      active: selected == c,
                      onTap: () =>
                          ref.read(cuisineFilterProvider.notifier).set(c),
                    ),
                  ],
                ],
              ),
            ),
          SizedBox(height: 12),
          Expanded(
            child: restaurants.when(
              loading: () => const _SkeletonList(),
              error: (e, _) => ErrorState(
                message: friendlyError(e),
                onRetry: () => ref.invalidate(restaurantsProvider),
              ),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: CupertinoIcons.search,
                      title: 'No restaurants found',
                      message: 'Try a different search or clear the cuisine filter.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(restaurantsProvider.future),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12),
                        itemBuilder: (context, i) => FadeSlideIn(
                          key: ValueKey(list[i].id),
                          delayMs: (i * 50).clamp(0, 300),
                          child: _RestaurantCard(
                            restaurant: list[i],
                            onTap: () => _open(list[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : context.pal.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : context.pal.tint,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : context.pal.text,
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.pal.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.pal.tint, width: 1.5),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'restaurant-${restaurant.id}',
                child: RestaurantAvatar(name: restaurant.name),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 3),
                    Text(restaurant.cuisine,
                        style: TextStyle(
                            color: context.pal.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    SizedBox(height: 3),
                    Text(restaurant.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.pal.muted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  size: 16, color: context.pal.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: 12),
      itemBuilder: (_, _) => const SkeletonBox(height: 90, radius: 18),
    );
  }
}