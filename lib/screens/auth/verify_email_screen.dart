import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/error_text.dart';
import '../../repositories/auth_repository.dart';
import '../../state/auth_provider.dart';
import '../../widgets/loading_button.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _sending = false;

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).resendConfirmation(widget.email);
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.safe,
        content: Text('A new confirmation email is on its way'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.unsafe,
        content: Text(friendlyError(e)),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

    // When the email link opens the app, a session appears: leave this screen.
    ref.listen<Session?>(sessionProvider, (_, next) {
      if (next != null) Navigator.of(context).popUntil((r) => r.isFirst);
    });

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration:
                          BoxDecoration(color: pal.tint, shape: BoxShape.circle),
                      child: Icon(CupertinoIcons.mail,
                          size: 38, color: pal.accent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Check your email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a confirmation link to',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: pal.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: pal.text)),
                  const SizedBox(height: 12),
                  Text(
                    'Open the link on this phone and Mi-Dine will sign you in. Links work once, so use the newest email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: pal.muted, height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  LoadingButton(
                    label: 'Resend email',
                    onPressed: _resend,
                    isLoading: _sending,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}