import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'state/auth_provider.dart';
import 'state/onboarding_provider.dart';
import 'state/theme_provider.dart';

class MiDineApp extends ConsumerWidget {
  const MiDineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return MaterialApp(
      title: 'Mi-Dine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const AppRoot(),
    );
  }
}

/// Splash (at least 2.2s) -> onboarding (first launch only) -> AuthGate.
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _splashDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarded = ref.watch(onboardingProvider);

    final Widget child;
    if (!_splashDone || onboarded.isLoading) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (onboarded.value != true) {
      child = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      child = const AuthGate(key: ValueKey('gate'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}

/// Shows Login when logged out, the app when logged in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session == null ? const LoginScreen() : const MainShell();
  }
}