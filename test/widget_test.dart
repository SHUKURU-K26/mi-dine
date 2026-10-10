import 'package:flutter_test/flutter_test.dart';
import 'package:mi_dine/models/allergen.dart';
import 'package:mi_dine/models/dish.dart';
import 'package:mi_dine/models/dish_assessment.dart';
import 'package:mi_dine/models/severity.dart';
import 'package:mi_dine/models/user_allergen.dart';
import 'package:mi_dine/services/safety_checker.dart';

UserAllergen _mine(String name, Severity severity) => UserAllergen(
      id: name,
      allergen: Allergen(id: 1, name: name),
      severity: severity,
    );

Dish _dish({List<String> contains = const [], List<String> mayContain = const []}) =>
    Dish(
      id: 'd1',
      name: 'Test dish',
      description: '',
      price: 5,
      contains: contains,
      mayContain: mayContain,
    );

void main() {
  const checker = SafetyChecker();

  test('dish containing an anaphylactic allergen is not safe', () {
    final result = checker.assess(
      _dish(contains: ['Peanuts']),
      [_mine('Peanuts', Severity.anaphylactic)],
    );
    expect(result.level, SafetyLevel.unsafe);
  });

  test('traces of an anaphylactic allergen are not safe', () {
    final result = checker.assess(
      _dish(mayContain: ['Soy']),
      [_mine('Soy', Severity.anaphylactic)],
    );
    expect(result.level, SafetyLevel.unsafe);
  });

  test('traces of a severe intolerance are a caution', () {
    final result = checker.assess(
      _dish(mayContain: ['Dairy']),
      [_mine('Dairy', Severity.severe)],
    );
    expect(result.level, SafetyLevel.caution);
  });

  test('a preference allergen in the dish is only a caution', () {
    final result = checker.assess(
      _dish(contains: ['Eggs']),
      [_mine('Eggs', Severity.preference)],
    );
    expect(result.level, SafetyLevel.caution);
  });

  test('traces of a preference allergen are ignored', () {
    final result = checker.assess(
      _dish(mayContain: ['Eggs']),
      [_mine('Eggs', Severity.preference)],
    );
    expect(result.level, SafetyLevel.safe);
  });

  test('a dish with no matching allergens is safe', () {
    final result = checker.assess(
      _dish(contains: ['Fish']),
      [_mine('Peanuts', Severity.anaphylactic)],
    );
    expect(result.level, SafetyLevel.safe);
    expect(result.reasons, isEmpty);
  });

  test('assessAll lists safe dishes before unsafe ones', () {
    final dishes = [
      _dish(contains: ['Peanuts']),
      _dish(),
    ];
    final list = checker.assessAll(dishes, [_mine('Peanuts', Severity.severe)]);
    expect(list.first.level, SafetyLevel.safe);
    expect(list.last.level, SafetyLevel.unsafe);
  });
}