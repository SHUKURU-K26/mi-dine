import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .signUp(_name.text, _email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.unsafe,
          content: Text(friendlyError(next.error!)),
        ));
      } else if (prev?.isLoading == true && next.hasValue) {
        // Signed up and logged in: go back to the root so AuthGate shows Home.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create your account',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    const Text(
                      'Set up your medical dining profile in minutes',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Full name',
                      controller: _name,
                      icon: CupertinoIcons.person,
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      icon: CupertinoIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      icon: CupertinoIcons.lock,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Confirm password',
                      controller: _confirm,
                      icon: CupertinoIcons.lock_shield,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => Validators.confirm(v, _password.text),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                        label: 'Create account',
                        onPressed: _submit,
                        isLoading: loading),
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