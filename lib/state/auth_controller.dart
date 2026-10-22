import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email: email, password: password),
    );
  }

    /// Returns true when the person must verify their email first.
  Future<bool> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    var needsConfirmation = false;
    state = await AsyncValue.guard(() async {
      needsConfirmation = await ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password);
    });
    return needsConfirmation && !state.hasError;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);