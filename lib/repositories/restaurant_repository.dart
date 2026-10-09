import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dish.dart';
import '../models/restaurant.dart';
import '../models/review.dart';

class RestaurantRepository {
  RestaurantRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// GET all restaurants.
  Future<List<Restaurant>> fetchAll() async {
    final rows = await _client.from('restaurants').select().order('name');
    return rows.map<Restaurant>(Restaurant.fromJson).toList();
  }

  /// GET one restaurant by the code printed in its QR. Null if none matches.
  Future<Restaurant?> fetchByQr(String code) async {
    final row = await _client
        .from('restaurants')
        .select()
        .eq('qr_code', code.trim())
        .maybeSingle();
    return row == null ? null : Restaurant.fromJson(row);
  }

  /// GET the menu of one restaurant.
  Future<List<Dish>> fetchDishes(String restaurantId) async {
    final rows = await _client
        .from('dishes')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('name');
    return rows.map<Dish>(Dish.fromJson).toList();
  }

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

  /// DELETE one of your own reviews (also enforced by a database policy).
  Future<void> deleteReview(String reviewId) {
    return _client.from('reviews').delete().eq('id', reviewId);
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(Supabase.instance.client),
);