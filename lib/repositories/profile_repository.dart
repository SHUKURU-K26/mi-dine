import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/allergen.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// GET standard allergens plus this user's own (the database filters).
  Future<List<Allergen>> fetchCatalog() async {
    final rows =
        await _client.from('allergens').select('id, name, created_by').order('name');
    return rows.map<Allergen>(Allergen.fromJson).toList();
  }

  /// GET the signed-in user's saved allergens.
  Future<List<UserAllergen>> fetchMine() async {
    final rows = await _client
        .from('user_allergens')
        .select('id, severity, allergens(id, name, created_by)')
        .eq('user_id', _uid);
    return rows.map<UserAllergen>(UserAllergen.fromJson).toList();
  }

  /// POST or PUT: create the link, or update its severity.
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

  /// DELETE the link (the allergen itself stays in the catalog).
  Future<void> remove(int allergenId) {
    return _client
        .from('user_allergens')
        .delete()
        .eq('user_id', _uid)
        .eq('allergen_id', allergenId);
  }

  /// POST a custom allergen, then link it to the user with a severity.
  Future<void> addCustom(String name, Severity severity) async {
    final row = await _client
        .from('allergens')
        .insert({'name': name.trim(), 'created_by': _uid})
        .select('id')
        .single();
    final id = row['id'] as int;
    try {
      await save(id, severity);
    } catch (_) {
      // Do not leave an orphan custom allergen behind.
      await _client.from('allergens').delete().eq('id', id);
      rethrow;
    }
  }

  /// PATCH the name of a custom allergen (RLS allows only the owner).
  Future<void> renameCustom(int id, String name) {
    return _client.from('allergens').update({'name': name.trim()}).eq('id', id);
  }

  /// DELETE a custom allergen. Links are removed by ON DELETE CASCADE.
  Future<void> deleteCustom(int id) {
    return _client.from('allergens').delete().eq('id', id);
  }

  /// GET the preferred ticket language.
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

    /// GET the personal ticket note (empty string if none).
  Future<String> fetchTicketNote() async {
    final row = await _client
        .from('profiles')
        .select('ticket_note')
        .eq('id', _uid)
        .maybeSingle();
    return (row?['ticket_note'] as String?) ?? '';
  }

  /// PATCH the personal ticket note. Empty clears it.
  Future<void> updateTicketNote(String note) {
    return _client
        .from('profiles')
        .update({'ticket_note': note.isEmpty ? null : note}).eq('id', _uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(Supabase.instance.client),
);