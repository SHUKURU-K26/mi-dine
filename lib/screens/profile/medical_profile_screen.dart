import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/severity_style.dart';
import '../../core/utils/error_text.dart';
import '../../models/allergen.dart';
import '../../models/severity.dart';
import '../../models/user_allergen.dart';
import '../../state/profile_provider.dart';
import '../../widgets/error_state.dart';
import 'custom_allergen_sheet.dart';
import 'settings_screen.dart';

class MedicalProfileScreen extends ConsumerWidget {
  const MedicalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(allergenCatalogProvider);
    final mine = ref.watch(myAllergensProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(CupertinoIcons.gear),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
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
            return const Center(child: CupertinoActivityIndicator());
          }
          final selected = {for (final u in mine.value!) u.allergen.id: u};
          return _Body(allergens: allergens, selected: selected);
        },
      ),
    );
  }
}

enum _Action { save, remove, edit, delete }

class _SheetResult {
  const _SheetResult(this.action, [this.severity]);

  final _Action action;
  final Severity? severity;
}

class _Body extends ConsumerWidget {
  const _Body({required this.allergens, required this.selected});

  final List<Allergen> allergens;
  final Map<int, UserAllergen> selected;

  Set<String> get _takenNames =>
      {for (final a in allergens) a.name.toLowerCase()};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = context.pal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'Select every ingredient you must avoid, then set how serious it is. Can\'t find yours? Add it. Your Kitchen Ticket is built from this list.',
          style: TextStyle(color: pal.muted, height: 1.45),
        ),
        const SizedBox(height: 20),
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
            _AddChip(onTap: () => _add(context, ref)),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pal.tint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.lock_shield, size: 20, color: pal.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your profile is private. Only you can read or change it, including the ingredients you add.',
                  style:
                      TextStyle(fontSize: 13, height: 1.45, color: pal.strong),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SnackBar _snack(String text, {bool error = false}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.unsafe : AppColors.primaryDark,
        content: Text(text),
      );

  Future<CustomAllergenResult?> _customSheet(
    BuildContext context, {
    String? name,
    Severity? severity,
  }) {
    return showModalBottomSheet<CustomAllergenResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CustomAllergenSheet(
        takenNames: _takenNames,
        initialName: name,
        initialSeverity: severity,
      ),
    );
  }

  // ---- Create
  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await _customSheet(context);
    if (result == null) return;

    try {
      await ref
          .read(myAllergensProvider.notifier)
          .addCustom(result.name, result.severity);
      messenger.showSnackBar(_snack('${result.name} added to your profile'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  // ---- Update
  Future<void> _edit(BuildContext context, WidgetRef ref, Allergen allergen,
      UserAllergen current) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await _customSheet(context,
        name: allergen.name, severity: current.severity);
    if (result == null) return;

    final notifier = ref.read(myAllergensProvider.notifier);
    try {
      if (result.name != allergen.name) {
        await notifier.renameCustom(allergen.id, result.name);
      }
      if (result.severity != current.severity) {
        await notifier.setSeverity(allergen.id, result.severity);
      }
      messenger.showSnackBar(_snack('${result.name} updated'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  // ---- Delete (custom only), with confirmation
  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Allergen allergen) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete ${allergen.name}?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
              'It will be removed from your profile and your Kitchen Ticket.'),
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
    if (ok != true) return;

    try {
      await ref.read(myAllergensProvider.notifier).deleteCustom(allergen.id);
      messenger.showSnackBar(_snack('${allergen.name} deleted'));
    } catch (e) {
      messenger.showSnackBar(_snack(friendlyError(e), error: true));
    }
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref,
      Allergen allergen, UserAllergen? current) async {
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SeveritySheet(
        allergen: allergen,
        current: current?.severity,
      ),
    );
    if (result == null || !context.mounted) return;

    switch (result.action) {
      case _Action.edit:
        await _edit(context, ref, allergen, current!);
      case _Action.delete:
        await _confirmDelete(context, ref, allergen);
      case _Action.save:
      case _Action.remove:
        final notifier = ref.read(myAllergensProvider.notifier);
        final messenger = ScaffoldMessenger.of(context);
        try {
          if (result.action == _Action.remove) {
            await notifier.remove(allergen.id);
            messenger.showSnackBar(_snack('${allergen.name} removed'));
          } else {
            await notifier.setSeverity(allergen.id, result.severity!);
            messenger.showSnackBar(_snack(
                '${allergen.name} saved as ${result.severity!.label}'));
          }
        } catch (e) {
          messenger.showSnackBar(_snack(friendlyError(e), error: true));
        }
    }
  }
}

/// Dashed-looking chip that opens the "add your own" sheet.
class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pal.accent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.add_circled, size: 18, color: pal.accent),
            const SizedBox(width: 8),
            Text('Add your own',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: pal.accent)),
          ],
        ),
      ),
    );
  }
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
    final pal = context.pal;
    final sev = current?.severity;
    final color = sev?.color ?? pal.muted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sev == null ? pal.surface : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sev == null ? pal.tint : color,
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(allergen.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: pal.text)),
                if (sev != null)
                  Text(sev.label, style: TextStyle(fontSize: 11, color: color))
                else if (allergen.isCustom)
                  Text('Your own',
                      style: TextStyle(fontSize: 11, color: pal.muted)),
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
    final pal = context.pal;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(allergen.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
                allergen.isCustom
                    ? 'Your own ingredient. How serious is this for you?'
                    : 'How serious is this for you?',
                style: TextStyle(color: pal.muted)),
            const SizedBox(height: 16),
            for (final s in Severity.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () =>
                      Navigator.pop(context, _SheetResult(_Action.save, s)),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: current == s
                          ? s.color.withValues(alpha: 0.10)
                          : pal.surface,
                      border: Border.all(
                        color: current == s ? s.color : pal.tint,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(s.icon, color: s.color, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.label,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: pal.text)),
                              const SizedBox(height: 2),
                              Text(s.description,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: pal.muted)),
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
            if (allergen.isCustom)
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, const _SheetResult(_Action.edit)),
                      icon: Icon(CupertinoIcons.pencil,
                          size: 18, color: pal.accent),
                      label:
                          Text('Rename', style: TextStyle(color: pal.accent)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(
                          context, const _SheetResult(_Action.delete)),
                      icon: const Icon(CupertinoIcons.delete,
                          size: 18, color: AppColors.unsafe),
                      label: const Text('Delete',
                          style: TextStyle(color: AppColors.unsafe)),
                    ),
                  ),
                ],
              )
            else if (current != null)
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(
                      context, const _SheetResult(_Action.remove)),
                  icon: const Icon(CupertinoIcons.delete,
                      size: 18, color: AppColors.unsafe),
                  label: const Text('Remove from my profile',
                      style: TextStyle(color: AppColors.unsafe)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}