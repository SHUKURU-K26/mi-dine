class Allergen {
  const Allergen({required this.id, required this.name});

  final int id;
  final String name;

  factory Allergen.fromJson(Map<String, dynamic> json) =>
      Allergen(id: json['id'] as int, name: json['name'] as String);
}