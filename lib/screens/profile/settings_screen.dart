import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/ticket_templates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/error_text.dart';
import '../../repositories/auth_repository.dart';
import '../../state/auth_provider.dart';
import '../../state/navigation_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/ticket_provider.dart';
import '../../widgets/fade_slide_in.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _modeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    final email = ref.watch(userEmailProvider);
    final langCode = ref.watch(ticketLanguageProvider).value ?? 'en';
    final language = TicketTemplates.languageOf(langCode);
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              FadeSlideIn(child: _AccountCard(name: name, email: email)),
              const SizedBox(height: 24),
              const _Label('Preferences'),
              _Group(children: [
                _SettingsRow(
                  icon: CupertinoIcons.globe,
                  title: 'Ticket language',
                  value: language.nativeName,
                  onTap: () => _pickLanguage(context, ref, langCode),
                ),
                _SettingsRow(
                  icon: CupertinoIcons.moon,
                  title: 'Appearance',
                  value: _modeLabel(mode),
                  onTap: () => _pickTheme(context, ref, mode),
                ),
              ]),
              const SizedBox(height: 24),
              const _Label('About'),
              _Group(children: [
                _SettingsRow(
                  icon: CupertinoIcons.info_circle,
                  title: 'Medical disclaimer',
                  onTap: () => _info(
                    context,
                    'Medical disclaimer',
                    'Mi-Dine is a communication aid. It does not replace medical advice and cannot guarantee that a meal is safe. Always confirm ingredients and preparation with the kitchen.',
                  ),
                ),
                _SettingsRow(
                  icon: CupertinoIcons.lock_shield,
                  title: 'Privacy',
                  onTap: () => _info(
                    context,
                    'Privacy',
                    'Your allergen profile is stored in your account and protected by database security rules. Only you can read or change it.',
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              const _Label('Account'),
              _Group(children: [
                _SettingsRow(
                  icon: CupertinoIcons.arrow_right_square,
                  title: 'Sign out',
                  onTap: () => _signOut(context, ref),
                ),
                _SettingsRow(
                  icon: CupertinoIcons.delete,
                  title: 'Delete account',
                  danger: true,
                  onTap: () => _delete(context, ref),
                ),
              ]),
              const SizedBox(height: 28),
              Center(
                child: Text('Mi-Dine 1.0.0',
                    style: TextStyle(color: context.pal.muted, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- actions

  Future<void> _pickLanguage(
      BuildContext context, WidgetRef ref, String current) async {
    final messenger = ScaffoldMessenger.of(context);
    final code = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ticket language',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('The language your Kitchen Ticket is written in.',
                  style: TextStyle(color: ctx.pal.muted)),
              const SizedBox(height: 12),
              for (final l in TicketTemplates.languages)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.nativeName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: l.code == current
                      ? Icon(CupertinoIcons.checkmark_alt,
                          color: ctx.pal.accent)
                      : null,
                  onTap: () => Navigator.pop(ctx, l.code),
                ),
            ],
          ),
        ),
      ),
    );
    if (code == null || code == current) return;

    try {
      await ref.read(ticketLanguageProvider.notifier).select(code);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.unsafe,
        content: Text(friendlyError(e)),
      ));
    }
  }

  Future<void> _pickTheme(
      BuildContext context, WidgetRef ref, ThemeMode current) async {
    final mode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 12),
              for (final m in ThemeMode.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(switch (m) {
                    ThemeMode.system => CupertinoIcons.device_phone_portrait,
                    ThemeMode.light => CupertinoIcons.sun_max,
                    ThemeMode.dark => CupertinoIcons.moon,
                  }),
                  title: Text(_modeLabel(m),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: m == current
                      ? Icon(CupertinoIcons.checkmark_alt,
                          color: ctx.pal.accent)
                      : null,
                  onTap: () => Navigator.pop(ctx, m),
                ),
            ],
          ),
        ),
      ),
    );
    if (mode != null) ref.read(themeModeProvider.notifier).select(mode);
  }

  Future<void> _info(BuildContext context, String title, String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) {
    return showCupertinoDialog<bool>(
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
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to see your profile.',
      action: 'Sign out',
    );
    if (ok != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final repo = ref.read(authRepositoryProvider);
    ref.invalidate(navIndexProvider);
    // Close Settings first, otherwise it stays on top of the login screen.
    navigator.popUntil((r) => r.isFirst);
    await repo.signOut();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Delete account?',
      message:
          'This permanently deletes your profile, allergens and reviews. This cannot be undone.',
      action: 'Delete',
    );
    if (ok != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.deleteAccount();
      ref.invalidate(navIndexProvider);
      navigator.popUntil((r) => r.isFirst);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.unsafe,
        content: Text(friendlyError(e)),
      ));
    }
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final source = name.isNotEmpty ? name : email;
    final initial = source.isEmpty ? 'M' : source.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pal.tint, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: pal.brand,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Mi-Dine member' : name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: pal.text)),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: pal.muted, fontSize: 13.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: context.pal.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: pal.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: pal.tint, width: 1.5),
      ),
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) Divider(height: 1, indent: 64, color: pal.tint),
            c,
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: danger
                    ? AppColors.unsafe.withValues(alpha: 0.10)
                    : pal.tint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: danger ? AppColors.unsafe : pal.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: danger ? AppColors.unsafe : pal.text)),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(value!,
                    style: TextStyle(color: pal.muted, fontSize: 13.5)),
              ),
            if (onTap != null && !danger)
              Icon(CupertinoIcons.chevron_right, size: 15, color: pal.muted),
          ],
        ),
      ),
    );
  }
}