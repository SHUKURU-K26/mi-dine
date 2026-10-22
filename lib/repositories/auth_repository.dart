import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

    /// Web returns to the page; Android returns through the deep link.
  String? get _redirect => kIsWeb ? null : 'io.supabase.midine://login-callback/';

    /// Returns true when the person must verify their email before signing in.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
      emailRedirectTo: _redirect,
    );
    return res.session == null;
  }

  /// Sends a fresh confirmation email.
  Future<void> resendConfirmation(String email) {
    return _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: _redirect,
    );
  }

  Future<void> signIn({required String email, required String password}) =>
      _client.auth.signInWithPassword(email: email.trim(), password: password);

    Future<void> signInWithGoogle() => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Web returns to the page itself; Android returns through the deep link.
        redirectTo: kIsWeb ? null : 'io.supabase.midine://login-callback/',
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