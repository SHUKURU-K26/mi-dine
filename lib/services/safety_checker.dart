import '../models/dish.dart';
import '../models/dish_assessment.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';

class SafetyChecker {
  const SafetyChecker();

  DishAssessment assess(Dish dish, List<UserAllergen> mine) {
    var level = SafetyLevel.safe;
    final reasons = <String>[];

    void raise(SafetyLevel next) {
      if (next.index > level.index) level = next;
    }

    final contains = dish.contains.map((e) => e.toLowerCase()).toSet();
    final mayContain = dish.mayContain.map((e) => e.toLowerCase()).toSet();
    final text = '${dish.name} ${dish.description}'.toLowerCase();

    for (final u in mine) {
      final name = u.allergen.name;
      final key = name.toLowerCase();

      if (contains.contains(key)) {
        if (u.severity == Severity.preference) {
          raise(SafetyLevel.caution);
          reasons.add('Contains $name, which you prefer to avoid');
        } else {
          raise(SafetyLevel.unsafe);
          reasons.add('Contains $name');
        }
      } else if (mayContain.contains(key)) {
        if (u.severity == Severity.anaphylactic) {
          raise(SafetyLevel.unsafe);
          reasons.add('May contain traces of $name');
        } else if (u.severity == Severity.severe) {
          raise(SafetyLevel.caution);
          reasons.add('May contain traces of $name');
        }
      } else if (u.allergen.isCustom) {
        // Custom ingredients are not tagged by restaurants, so match text.
        if (text.contains(key)) {
          if (u.severity == Severity.preference) {
            raise(SafetyLevel.caution);
          } else {
            raise(SafetyLevel.unsafe);
          }
          reasons.add('Mentions $name in its description');
        } else if (u.severity != Severity.preference) {
          raise(SafetyLevel.caution);
          reasons.add('Cannot verify $name on this menu. Ask the kitchen');
        }
      }
    }
    return DishAssessment(dish: dish, level: level, reasons: reasons);
  }

  /// Safe dishes first, then caution, then not safe.
  List<DishAssessment> assessAll(List<Dish> dishes, List<UserAllergen> mine) {
    final list = [for (final d in dishes) assess(d, mine)];
    list.sort((a, b) {
      final byLevel = a.level.index.compareTo(b.level.index);
      return byLevel != 0 ? byLevel : a.dish.name.compareTo(b.dish.name);
    });
    return list;
  }
}