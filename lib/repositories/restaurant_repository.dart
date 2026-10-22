import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dish.dart';
import '../models/inputs.dart';
import '../models/restaurant.dart';
import '../models/review.dart';

class RestaurantRepository {
  RestaurantRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  // ---------------------------------------------------------- Restaurants

  /// GET all restaurants.
  Future<List<Restaurant>> fetchAll() async {
    final rows = await _client.from('restaurants').select().order('name');
    return rows.map<Restaurant>(Restaurant.fromJson).toList();
  }

  /// GET one restaurant by its QR code. Null if none matches.
  Future<Restaurant?> fetchByQr(String code) async {
    final row = await _client
        .from('restaurants')
        .select()
        .eq('qr_code', code.trim())
        .maybeSingle();
    return row == null ? null : Restaurant.fromJson(row);
  }

  /// POST a restaurant owned by the signed-in user.
  Future<Restaurant> addRestaurant(RestaurantInput input) async {
    final row = await _client
        .from('restaurants')
        .insert({...input.toJson(), 'created_by': _uid})
        .select()
        .single();
    return Restaurant.fromJson(row);
  }

  /// PATCH a restaurant (RLS allows only its creator).
  Future<Restaurant> updateRestaurant(String id, RestaurantInput input) async {
    final row = await _client
        .from('restaurants')
        .update(input.toJson())
        .eq('id', id)
        .select()
        .single();
    return Restaurant.fromJson(row);
  }

  /// DELETE a restaurant. Its dishes and reviews go with it (cascade).
  Future<void> deleteRestaurant(String id) {
    return _client.from('restaurants').delete().eq('id', id);
  }

  // ---------------------------------------------------------------- Dishes

  /// GET the menu of one restaurant.
  Future<List<Dish>> fetchDishes(String restaurantId) async {
    final rows = await _client
        .from('dishes')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('name');
    return rows.map<Dish>(Dish.fromJson).toList();
  }

  /// POST a dish.
  Future<void> addDish(String restaurantId, DishInput input) {
    return _client
        .from('dishes')
        .insert({...input.toJson(), 'restaurant_id': restaurantId});
  }

  /// PATCH a dish.
  Future<void> updateDish(String id, DishInput input) {
    return _client.from('dishes').update(input.toJson()).eq('id', id);
  }

  /// DELETE a dish.
  Future<void> deleteDish(String id) {
    return _client.from('dishes').delete().eq('id', id);
  }

  // --------------------------------------------------------------- Reviews

  /// GET reviews with the author's name (joined from profiles).
  Future<List<Review>> fetchReviews(String restaurantId) async {
    final rows = await _client
        .from('reviews')
        .select('*, profiles(full_name)')
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false);
    return rows.map<Review>(Review.fromJson).toList();
  }

  /// POST a new review.
  Future<void> addReview({
    required String restaurantId,
    required int rating,
    required String comment,
    required bool dedicatedFryer,
    required bool staffKnowledgeable,
  }) {
    return _client.from('reviews').insert({
      'restaurant_id': restaurantId,
      'user_id': _uid,
      'rating': rating,
      'comment': comment.trim(),
      'dedicated_fryer': dedicatedFryer,
      'staff_knowledgeable': staffKnowledgeable,
    });
  }

    /// PATCH one of your own reviews (also enforced by a database policy).
  Future<void> updateReview(
    String reviewId, {
    required int rating,
    required String comment,
    required bool dedicatedFryer,
    required bool staffKnowledgeable,
  }) {
    return _client.from('reviews').update({
      'rating': rating,
      'comment': comment.trim(),
      'dedicated_fryer': dedicatedFryer,
      'staff_knowledgeable': staffKnowledgeable,
    }).eq('id', reviewId);
  }

  /// DELETE one of your own reviews (also enforced by a database policy).
  Future<void> deleteReview(String reviewId) {
    return _client.from('reviews').delete().eq('id', reviewId);
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(Supabase.instance.client),
);