import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/ticket_templates.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../models/kitchen_ticket.dart';
import '../../state/navigation_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/ticket_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/kitchen_ticket_view.dart';
import 'chef_mode_screen.dart';
import '../../core/theme/app_theme.dart';

class TicketScreen extends ConsumerWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myAllergensProvider);
    final ticket = ref.watch(kitchenTicketProvider);

    Widget body;
    if (mine.hasError && mine.value == null) {
      body = ErrorState(
        message: friendlyError(mine.error!),
        onRetry: () => ref.invalidate(myAllergensProvider),
      );
    } else if (mine.value == null) {
      body = Center(child: CupertinoActivityIndicator());
    } else if (ticket == null) {
      body = EmptyState(
        icon: CupertinoIcons.doc_text,
        title: 'No ticket yet',
        message:
            'Add at least one allergen to your medical profile and your Kitchen Ticket will be built for you.',
        actionLabel: 'Build my profile',
        onAction: () => ref.read(navIndexProvider.notifier).select(3),
      );
    } else {
      body = _TicketBody(ticket: ticket);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Kitchen Ticket')),
      body: body,
    );
  }
}

class _TicketBody extends ConsumerWidget {
  const _TicketBody({required this.ticket});

  final KitchenTicket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        FadeSlideIn(
          child: Text(
            'Choose the language of the kitchen. Your ticket updates instantly.',
            style: TextStyle(color: context.pal.muted, height: 1.45),
          ),
        ),
        SizedBox(height: 16),
        FadeSlideIn(
          delayMs: 80,
          child: _LanguagePicker(
            selected: ticket.language,
            onSelect: (code) => _selectLanguage(context, ref, code),
          ),
        ),
        SizedBox(height: 20),
        FadeSlideIn(
          delayMs: 160,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ValueKey(ticket.language),
              child: KitchenTicketView(ticket: ticket),
            ),
          ),
        ),
        SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _openChefMode(context),
          icon: Icon(CupertinoIcons.eye),
          label: Text('Show to chef'),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copy(context),
                icon: Icon(CupertinoIcons.doc_on_doc, size: 18),
                label: Text('Copy'),
                style: _outlined(context),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: Icon(CupertinoIcons.share, size: 18),
                label: Text('Share'),
                style: _outlined(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

ButtonStyle _outlined(BuildContext context) => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(50),
    foregroundColor: context.pal.accent,
    side: BorderSide(color: context.pal.tint, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  Future<void> _selectLanguage(
      BuildContext context, WidgetRef ref, String code) async {
    final messenger = ScaffoldMessenger.of(context);
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

  void _openChefMode(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondary) => Theme(
        data: AppTheme.light,
        child: ChefModeScreen(ticket: ticket),
      ),
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: ticket.toPlainText()));
    messenger.showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.safe,
      content: Text('Ticket copied to clipboard'),
    ));
  }

  Future<void> _share() {
    return SharePlus.instance.share(
      ShareParams(text: ticket.toPlainText(), subject: ticket.title),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TicketTemplates.languages.length,
        separatorBuilder: (_, _) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final lang = TicketTemplates.languages[i];
          final active = lang.code == selected;
          return GestureDetector(
            onTap: () => onSelect(lang.code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : context.pal.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active ? AppColors.primary : context.pal.tint,
                  width: 1.5,
                ),
              ),
              child: Text(
                lang.nativeName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : context.pal.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}