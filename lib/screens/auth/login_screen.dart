import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/loading_button.dart';
import 'signup_screen.dart';
import '../../widgets/brand_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.unsafe,
          content: Text(friendlyError(next.error!)),
        ));
      }
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: context.pal.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                          child: const BrandLogo(height: 110),
                    ),
                    SizedBox(height: 8),
                    FadeSlideIn(
                      delayMs: 100,
                      child: Column(children: [
                        Text('Welcome back',
                            style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 6),
                        Text(
                          'Sign in to your Mi-Dine account',
                          style: TextStyle(color: context.pal.muted),
                        ),
                      ]),
                    ),
                    SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 200,
                      child: Column(children: [
                        AppTextField(
                          label: 'Email',
                          controller: _email,
                          icon: CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        SizedBox(height: 14),
                        AppTextField(
                          label: 'Password',
                          controller: _password,
                          icon: CupertinoIcons.lock,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                        ),
                      ]),
                    ),
                    SizedBox(height: 22),
                    LoadingButton(
                        label: 'Sign in', onPressed: _submit, isLoading: loading),
                    SizedBox(height: 22),
                    const _OrDivider(),
                    SizedBox(height: 22),
                    OutlinedButton(
                      onPressed: loading
                          ? null
                          : () => ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: BorderSide(color: context.pal.tint, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('G',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: context.pal.accent)),
                          SizedBox(width: 12),
                          Text('Continue with Google',
                              style: TextStyle(
                                  color: context.pal.text,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New to Mi-Dine? ",
                            style: TextStyle(color: context.pal.muted)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: Text('Create account',
                              style: TextStyle(
                                  color: context.pal.accent,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: context.pal.tint, thickness: 1.5)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('or', style: TextStyle(color: context.pal.muted)),
      ),
      Expanded(child: Divider(color: context.pal.tint, thickness: 1.5)),
    ]);
  }
}