import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password}) =>
      _client.auth.signInWithPassword(email: email.trim(), password: password);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );

  Future<void> signInWithGoogle() => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.midine://login-callback/',
      );

  Future<void> signOut() => _client.auth.signOut();
  
  
  /// Calls the delete_my_account() database function, then clears the session.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(Supabase.instance.client),
);