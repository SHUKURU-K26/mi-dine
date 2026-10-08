import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/allergen.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';
import '../repositories/profile_repository.dart';
import 'auth_provider.dart';

/// Shared, read-only list of every allergen. Fetched once and cached.
final allergenCatalogProvider = FutureProvider<List<Allergen>>(
  (ref) => ref.read(profileRepositoryProvider).fetchCatalog(),
);

/// The user's saved allergens. Reloads automatically if the user changes.
class MyAllergensNotifier extends AsyncNotifier<List<UserAllergen>> {
  @override
  Future<List<UserAllergen>> build() {
    ref.watch(currentUserIdProvider);
    return ref.read(profileRepositoryProvider).fetchMine();
  }

  Future<void> setSeverity(int allergenId, Severity severity) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.save(allergenId, severity);
    state = AsyncData(await repo.fetchMine());
  }

  Future<void> remove(int allergenId) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.remove(allergenId);
    state = AsyncData(await repo.fetchMine());
  }
}

final myAllergensProvider =
    AsyncNotifierProvider<MyAllergensNotifier, List<UserAllergen>>(
  MyAllergensNotifier.new,
);