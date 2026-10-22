import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_ticket.dart';
import '../repositories/profile_repository.dart';
import '../services/ticket_builder.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

/// The ticket language, loaded from and saved to the user's profile.
class TicketLanguageNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() {
    ref.watch(currentUserIdProvider);
    return ref.read(profileRepositoryProvider).fetchPreferredLanguage();
  }

  /// Updates the UI immediately, then saves. Rolls back if saving fails.
  Future<void> select(String code) async {
    final previous = state;
    state = AsyncData(code);
    try {
      await ref.read(profileRepositoryProvider).updatePreferredLanguage(code);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final ticketLanguageProvider =
    AsyncNotifierProvider<TicketLanguageNotifier, String>(
  TicketLanguageNotifier.new,
);

/// The guest's personal note, saved on their profile.
class TicketNoteNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() {
    ref.watch(currentUserIdProvider);
    return ref.read(profileRepositoryProvider).fetchTicketNote();
  }

  Future<void> save(String note) async {
    final previous = state;
    final clean = note.trim();
    state = AsyncData(clean);
    try {
      await ref.read(profileRepositoryProvider).updateTicketNote(clean);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final ticketNoteProvider =
    AsyncNotifierProvider<TicketNoteNotifier, String>(TicketNoteNotifier.new);

/// Derived state: rebuilds only when allergens, language, name or note change.
/// Null means there is nothing to build a ticket from yet.
final kitchenTicketProvider = Provider<KitchenTicket?>((ref) {
  final allergens = ref.watch(myAllergensProvider).value;
  if (allergens == null || allergens.isEmpty) return null;

  final language = ref.watch(ticketLanguageProvider).value ?? 'en';
  final name = ref.watch(userNameProvider);
  final note = ref.watch(ticketNoteProvider).value ?? '';

  return const TicketBuilder().build(
    allergens: allergens,
    languageCode: language,
    guestName: name,
    note: note,
  );
});