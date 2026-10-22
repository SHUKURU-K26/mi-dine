class Allergen {
  const Allergen({required this.id, required this.name, this.createdBy});

  final int id;
  final String name;

  /// Null for the standard list, the owner's user id for custom allergens.
  final String? createdBy;

  bool get isCustom => createdBy != null;

  factory Allergen.fromJson(Map<String, dynamic> json) => Allergen(
        id: json['id'] as int,
        name: json['name'] as String,
        createdBy: json['created_by'] as String?,
      );
}