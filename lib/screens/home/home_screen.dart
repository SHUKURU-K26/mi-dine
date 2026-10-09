import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/severity_style.dart';
import '../../models/restaurant.dart';
import '../../models/severity.dart';
import '../../models/user_allergen.dart';
import '../../state/auth_provider.dart';
import '../../state/navigation_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/restaurant_avatar.dart';
import '../../widgets/skeleton_box.dart';
import '../profile/settings_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../restaurants/scan_flow.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = context.pal;
    final name = ref.watch(userNameProvider);
    final first = name.isEmpty ? 'there' : name.split(' ').first;
    final nav = ref.read(navIndexProvider.notifier);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                FadeSlideIn(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting, style: TextStyle(color: pal.muted)),
                            const SizedBox(height: 2),
                            Text('Hello, $first',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                          ],
                        ),
                      ),
                      InkResponse(
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: pal.tint,
                          child: Text(
                            first.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  delayMs: 80,
                  child: _ProfileHero(onEdit: () => nav.select(3)),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  delayMs: 160,
                  child: SizedBox(
                    height: 232,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: _TicketTile(onTap: () => nav.select(2)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                child: _MiniTile(
                                  icon: CupertinoIcons.search,
                                  title: 'Explore',
                                  subtitle: 'Browse menus',
                                  onTap: () => nav.select(1),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _MiniTile(
                                  icon: CupertinoIcons.qrcode_viewfinder,
                                  title: 'Scan QR',
                                  subtitle: 'Open a menu',
                                  onTap: () => scanAndOpenRestaurant(context, ref),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(
                  delayMs: 240,
                  child: _SectionHeader(
                    title: 'Restaurants',
                    action: 'See all',
                    onAction: () => nav.select(1),
                  ),
                ),
                const SizedBox(height: 12),
                const FadeSlideIn(delayMs: 280, child: _RestaurantStrip()),
                const SizedBox(height: 26),
                const FadeSlideIn(delayMs: 320, child: _DisclaimerCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Hero card

class _ProfileHero extends ConsumerWidget {
  const _ProfileHero({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myAllergensProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(right: -36, top: -36, child: _Orb(size: 150, alpha: 0.07)),
            Positioned(right: 50, bottom: -56, child: _Orb(size: 120, alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.all(22),
              child: mine.when(
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(
                      child: CupertinoActivityIndicator(color: Colors.white)),
                ),
                error: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Could not load your profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(myAllergensProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
                data: (list) =>
                    list.isEmpty ? _empty() : _filled(list),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassIcon(CupertinoIcons.shield_lefthalf_fill),
        const SizedBox(height: 16),
        const Text('Set up your medical profile',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 19)),
        const SizedBox(height: 6),
        const Text(
          'Add your allergens so Mi-Dine can build your Kitchen Ticket and check menus for you.',
          style: TextStyle(color: Colors.white70, height: 1.45),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onEdit,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(160, 46),
          ),
          child: const Text('Get started'),
        ),
      ],
    );
  }

  Widget _filled(List<UserAllergen> list) {
    int count(Severity s) => list.where((u) => u.severity == s).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your medical profile',
            style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          '${list.length} ${list.length == 1 ? 'trigger' : 'triggers'} saved',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 26),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in Severity.values)
              if (count(s) > 0)
                _GlassPill(icon: s.icon, text: '${count(s)} ${s.label}'),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onEdit,
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Edit profile',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_right, color: Colors.white, size: 14),
          ]),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

/// Frosted, translucent surface used on top of the teal gradient.
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ]),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

// ---------------------------------------------------------------- Bento tiles

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(CupertinoIcons.doc_text_fill,
                  size: 130, color: Colors.white.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _GlassIcon(CupertinoIcons.doc_text_fill),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kitchen Ticket',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      const SizedBox(height: 4),
                      const Text('Show the chef in 5 languages',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12.5, height: 1.3)),
                      const SizedBox(height: 12),
                      const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Open',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(CupertinoIcons.chevron_right,
                            color: Colors.white, size: 14),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: pal.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: pal.tint, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: pal.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: pal.text)),
                  Text(subtitle,
                      style: TextStyle(color: pal.muted, fontSize: 12.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Restaurants

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        GestureDetector(
          onTap: onAction,
          child: Text(action,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _RestaurantStrip extends ConsumerWidget {
  const _RestaurantStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);

    return SizedBox(
      height: 128,
      child: restaurants.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonBox(width: 176, height: 128, radius: 20),
            SizedBox(width: 12),
            SkeletonBox(width: 176, height: 128, radius: 20),
            SizedBox(width: 12),
            SkeletonBox(width: 176, height: 128, radius: 20),
          ],
        ),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(restaurantsProvider),
            icon: const Icon(CupertinoIcons.refresh, size: 18),
            label: const Text('Could not load restaurants. Retry'),
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(
                child: Text('No restaurants yet',
                    style: TextStyle(color: context.pal.muted)),
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _RestaurantCard(
                  restaurant: items[i],
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) =>
                          RestaurantDetailScreen(restaurant: items[i]),
                    ),
                  ),
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
    final pal = context.pal;
    return SizedBox(
      width: 176,
      child: Material(
        color: pal.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pal.tint, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RestaurantAvatar(name: restaurant.name, size: 42),
                const Spacer(),
                Text(restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: pal.text)),
                const SizedBox(height: 2),
                Text(restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.info_circle,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mi-Dine is a communication aid. It does not replace medical advice or guarantee that a meal is safe. Always confirm with the kitchen.',
              style: TextStyle(fontSize: 13, height: 1.45, color: pal.strong),
            ),
          ),
        ],
      ),
    );
  }
}