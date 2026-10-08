import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/severity_style.dart';
import '../../models/severity.dart';
import '../../models/user_allergen.dart';
import '../../state/auth_provider.dart';
import '../../state/navigation_provider.dart';
import '../../state/profile_provider.dart';
import '../../widgets/fade_slide_in.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    final first = name.isEmpty ? 'there' : name.split(' ').first;
    final nav = ref.read(navIndexProvider.notifier);

    return Scaffold(
      body: SafeArea(
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
                        const Text('Welcome back',
                            style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text('Hello, $first',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryTint,
                    child: Text(
                      first.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delayMs: 100,
              child: _ProfileSummaryCard(onEdit: () => nav.select(3)),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delayMs: 200,
              child: Text('Quick actions',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 250,
              child: Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: CupertinoIcons.doc_text_fill,
                      title: 'Kitchen Ticket',
                      subtitle: 'Show the chef',
                      onTap: () => nav.select(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      icon: CupertinoIcons.search,
                      title: 'Find restaurants',
                      subtitle: 'Check menus',
                      onTap: () => nav.select(1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const FadeSlideIn(delayMs: 300, child: _DisclaimerCard()),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends ConsumerWidget {
  const _ProfileSummaryCard({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myAllergensProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: mine.when(
        loading: () => const SizedBox(
          height: 110,
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
        data: (list) => list.isEmpty
            ? _emptyContent(onEdit)
            : _filledContent(list, onEdit),
      ),
    );
  }

  Widget _emptyContent(VoidCallback onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(CupertinoIcons.shield_lefthalf_fill,
            color: Colors.white, size: 28),
        const SizedBox(height: 12),
        const Text('Set up your medical profile',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        const SizedBox(height: 6),
        const Text(
          'Add your allergens so Mi-Dine can build your Kitchen Ticket and check menus for you.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: 16),
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

  Widget _filledContent(List<UserAllergen> list, VoidCallback onEdit) {
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
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in Severity.values)
              if (count(s) > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(s.icon, size: 14, color: s.color),
                    const SizedBox(width: 6),
                    Text('${count(s)} ${s.label}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text)),
                  ]),
                ),
          ],
        ),
        const SizedBox(height: 14),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryTint, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.info_circle, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mi-Dine is a communication aid. It does not replace medical advice or guarantee that a meal is safe. Always confirm with the kitchen.',
              style: TextStyle(
                  fontSize: 13, height: 1.45, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}