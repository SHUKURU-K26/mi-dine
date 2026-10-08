import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/allergen.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// GET all allergens available to choose from.
  Future<List<Allergen>> fetchCatalog() async {
    final rows = await _client.from('allergens').select().order('name');
    return rows.map<Allergen>(Allergen.fromJson).toList();
  }

  /// GET the signed-in user's saved allergens (joined with allergen name).
  Future<List<UserAllergen>> fetchMine() async {
    final rows = await _client
        .from('user_allergens')
        .select('id, severity, allergens(id, name)')
        .eq('user_id', _uid);
    return rows.map<UserAllergen>(UserAllergen.fromJson).toList();
  }

  /// POST or PUT: create the row, or update its severity if it exists.
  Future<void> save(int allergenId, Severity severity) {
    return _client.from('user_allergens').upsert(
      {
        'user_id': _uid,
        'allergen_id': allergenId,
        'severity': severity.value,
      },
      onConflict: 'user_id,allergen_id',
    );
  }

  /// DELETE the row.
  Future<void> remove(int allergenId) {
    return _client
        .from('user_allergens')
        .delete()
        .eq('user_id', _uid)
        .eq('allergen_id', allergenId);
  }

    /// GET the preferred ticket language from the profiles table.
  Future<String> fetchPreferredLanguage() async {
    final row = await _client
        .from('profiles')
        .select('preferred_language')
        .eq('id', _uid)
        .maybeSingle();
    return (row?['preferred_language'] as String?) ?? 'en';
  }

  /// PATCH the preferred ticket language.
  Future<void> updatePreferredLanguage(String code) {
    return _client
        .from('profiles')
        .update({'preferred_language': code}).eq('id', _uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(Supabase.instance.client),
);