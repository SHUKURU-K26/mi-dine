import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dish.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repositories/restaurant_repository.dart';
import 'auth_provider.dart';

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.read(restaurantRepositoryProvider).fetchAll();
});

class RestaurantSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final restaurantSearchProvider =
    NotifierProvider<RestaurantSearchNotifier, String>(
        RestaurantSearchNotifier.new);

class CuisineFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final cuisineFilterProvider =
    NotifierProvider<CuisineFilterNotifier, String?>(
        CuisineFilterNotifier.new);

/// Distinct cuisines, used for the filter chips.
final cuisinesProvider = Provider<List<String>>((ref) {
  final list = ref.watch(restaurantsProvider).value ?? const <Restaurant>[];
  final set = {for (final r in list) if (r.cuisine.isNotEmpty) r.cuisine};
  return set.toList()..sort();
});

/// Derived state: the list after search and cuisine filter are applied.
final filteredRestaurantsProvider =
    Provider<AsyncValue<List<Restaurant>>>((ref) {
  final all = ref.watch(restaurantsProvider);
  final query = ref.watch(restaurantSearchProvider).trim().toLowerCase();
  final cuisine = ref.watch(cuisineFilterProvider);

  return all.whenData((list) => list.where((r) {
        final matchesCuisine = cuisine == null || r.cuisine == cuisine;
        final matchesQuery = query.isEmpty ||
            r.name.toLowerCase().contains(query) ||
            r.cuisine.toLowerCase().contains(query);
        return matchesCuisine && matchesQuery;
      }).toList());
});

final dishesProvider = FutureProvider.family<List<Dish>, String>(
  (ref, restaurantId) =>
      ref.read(restaurantRepositoryProvider).fetchDishes(restaurantId),
);

final reviewsProvider = FutureProvider.family<List<Review>, String>(
  (ref, restaurantId) =>
      ref.read(restaurantRepositoryProvider).fetchReviews(restaurantId),
);