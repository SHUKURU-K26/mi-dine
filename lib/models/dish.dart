class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.contains,
    required this.mayContain,
  });

  final String id;
  final String name;
  final String description;
  final double? price;
  final List<String> contains;
  final List<String> mayContain;

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as String,
        name: json['name'] as String,
        description: (json['description'] as String?) ?? '',
        price: (json['price'] as num?)?.toDouble(),
        contains: List<String>.from(json['contains'] as List? ?? const []),
        mayContain: List<String>.from(json['may_contain'] as List? ?? const []),
      );
}