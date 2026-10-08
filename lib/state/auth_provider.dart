import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Emits every time the user signs in or out.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// The current session, or null if logged out.
final sessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentSession;
});

/// The signed-in user's id. Only notifies when the id actually changes.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Display name from sign-up or Google. Empty string if unknown.
final userNameProvider = Provider<String>((ref) {
  ref.watch(authStateProvider);
  final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
  return (meta?['full_name'] ?? meta?['name'] ?? '').toString().trim();
});