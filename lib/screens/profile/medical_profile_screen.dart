import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/severity_style.dart';
import '../../core/utils/error_text.dart';
import '../../models/allergen.dart';
import '../../models/severity.dart';
import '../../models/user_allergen.dart';
import '../../state/profile_provider.dart';
import '../../widgets/error_state.dart';
import 'settings_screen.dart';

class MedicalProfileScreen extends ConsumerWidget {
  const MedicalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(allergenCatalogProvider);
    final mine = ref.watch(myAllergensProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(CupertinoIcons.gear),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => Center(child: CupertinoActivityIndicator()),
        error: (e, _) => ErrorState(
          message: friendlyError(e),
          onRetry: () => ref.invalidate(allergenCatalogProvider),
        ),
        data: (allergens) {
          if (mine.hasError && mine.value == null) {
            return ErrorState(
              message: friendlyError(mine.error!),
              onRetry: () => ref.invalidate(myAllergensProvider),
            );
          }
          if (mine.value == null) {
            return Center(child: CupertinoActivityIndicator());
          }
          final selected = {for (final u in mine.value!) u.allergen.id: u};
          return _Body(allergens: allergens, selected: selected);
        },
      ),
    );
  }

}

class _Body extends ConsumerWidget {
  const _Body({required this.allergens, required this.selected});

  final List<Allergen> allergens;
  final Map<int, UserAllergen> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'Select every ingredient you must avoid, then set how serious it is. Your Kitchen Ticket is built from this list.',
          style: TextStyle(color: context.pal.muted, height: 1.45),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final a in allergens)
              _AllergenTile(
                allergen: a,
                current: selected[a.id],
                onTap: () => _openSheet(context, ref, a, selected[a.id]),
              ),
          ],
        ),
        SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.pal.tint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.lock_shield,
                  size: 20, color: context.pal.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your profile is private. Only you can read or change it.',
                  style: TextStyle(
                      fontSize: 13, height: 1.45, color: context.pal.strong),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref,
      Allergen allergen, UserAllergen? current) async {
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.pal.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SeveritySheet(allergen: allergen, current: current?.severity),
    );
    if (result == null || !context.mounted) return;

    final notifier = ref.read(myAllergensProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (result.remove) {
        await notifier.remove(allergen.id);
        messenger.showSnackBar(_snack('${allergen.name} removed'));
      } else {
        await notifier.setSeverity(allergen.id, result.severity!);
        messenger.showSnackBar(
            _snack('${allergen.name} saved as ${result.severity!.label}'));
      }
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  SnackBar _snack(String text, {bool error = false}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.unsafe : AppColors.primaryDark,
        content: Text(text),
      );
}

class _SheetResult {
  const _SheetResult.save(this.severity) : remove = false;
  const _SheetResult.remove()
      : severity = null,
        remove = true;

  final Severity? severity;
  final bool remove;
}

/// Animated chip: changes colour and border when a severity is set.
class _AllergenTile extends StatelessWidget {
  const _AllergenTile({
    required this.allergen,
    required this.current,
    required this.onTap,
  });

  final Allergen allergen;
  final UserAllergen? current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sev = current?.severity;
    final color = sev?.color ?? context.pal.muted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sev == null ? context.pal.surface : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sev == null ? context.pal.tint : color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                sev?.icon ?? CupertinoIcons.add,
                key: ValueKey(sev),
                size: 16,
                color: color,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(allergen.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (sev != null)
                  Text(sev.label, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeveritySheet extends StatelessWidget {
  const _SeveritySheet({required this.allergen, required this.current});

  final Allergen allergen;
  final Severity? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(allergen.name,
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 4),
            Text('How serious is this for you?',
                style: TextStyle(color: context.pal.muted)),
            SizedBox(height: 16),
            for (final s in Severity.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context, _SheetResult.save(s)),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: current == s
                          ? s.color.withValues(alpha: 0.10)
                          : context.pal.surface,
                      border: Border.all(
                        color: current == s ? s.color : context.pal.tint,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(s.icon, color: s.color, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.label,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 2),
                              Text(s.description,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: context.pal.muted)),
                            ],
                          ),
                        ),
                        if (current == s)
                          Icon(CupertinoIcons.checkmark_alt, color: s.color),
                      ],
                    ),
                  ),
                ),
              ),
            if (current != null)
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, const _SheetResult.remove()),
                  icon: Icon(CupertinoIcons.delete,
                      size: 18, color: AppColors.unsafe),
                  label: Text('Remove from my profile',
                      style: TextStyle(color: AppColors.unsafe)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}