import 'dish.dart';

enum SafetyLevel { safe, caution, unsafe }

class DishAssessment {
  const DishAssessment({
    required this.dish,
    required this.level,
    required this.reasons,
  });

  final Dish dish;
  final SafetyLevel level;
  final List<String> reasons;
}