import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/allergen.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';
import '../repositories/profile_repository.dart';
import 'auth_provider.dart';

/// Standard allergens plus the user's own. Reloads when the user changes.
final allergenCatalogProvider = FutureProvider<List<Allergen>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(profileRepositoryProvider).fetchCatalog();
});

/// The user's saved allergens.
class MyAllergensNotifier extends AsyncNotifier<List<UserAllergen>> {
  @override
  Future<List<UserAllergen>> build() {
    ref.watch(currentUserIdProvider);
    return ref.read(profileRepositoryProvider).fetchMine();
  }

  Future<void> _reload() async {
    state = AsyncData(await ref.read(profileRepositoryProvider).fetchMine());
  }

  Future<void> setSeverity(int allergenId, Severity severity) async {
    await ref.read(profileRepositoryProvider).save(allergenId, severity);
    await _reload();
  }

  Future<void> remove(int allergenId) async {
    await ref.read(profileRepositoryProvider).remove(allergenId);
    await _reload();
  }

  Future<void> addCustom(String name, Severity severity) async {
    await ref.read(profileRepositoryProvider).addCustom(name, severity);
    ref.invalidate(allergenCatalogProvider);
    await _reload();
  }

  Future<void> renameCustom(int id, String name) async {
    await ref.read(profileRepositoryProvider).renameCustom(id, name);
    ref.invalidate(allergenCatalogProvider);
    await _reload();
  }

  Future<void> deleteCustom(int id) async {
    await ref.read(profileRepositoryProvider).deleteCustom(id);
    ref.invalidate(allergenCatalogProvider);
    await _reload();
  }
}

final myAllergensProvider =
    AsyncNotifierProvider<MyAllergensNotifier, List<UserAllergen>>(
  MyAllergensNotifier.new,
);