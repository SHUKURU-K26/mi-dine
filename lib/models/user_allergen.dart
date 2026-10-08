import 'allergen.dart';
import 'severity.dart';

class UserAllergen {
  const UserAllergen({
    required this.id,
    required this.allergen,
    required this.severity,
  });

  final String id;
  final Allergen allergen;
  final Severity severity;

  /// Expects: { id, severity, allergens: { id, name } }
  factory UserAllergen.fromJson(Map<String, dynamic> json) => UserAllergen(
        id: json['id'] as String,
        severity: Severity.fromValue(json['severity'] as String),
        allergen: Allergen.fromJson(json['allergens'] as Map<String, dynamic>),
      );
}