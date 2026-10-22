class RestaurantInput {
  const RestaurantInput({
    required this.name,
    required this.cuisine,
    required this.address,
    required this.description,
  });

  final String name;
  final String cuisine;
  final String address;
  final String description;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'cuisine': cuisine.trim(),
        'address': address.trim(),
        'description': description.trim(),
      };
}

class DishInput {
  const DishInput({
    required this.name,
    required this.description,
    required this.price,
    required this.contains,
    required this.mayContain,
  });

  final String name;
  final String description;
  final double? price;
  final List<String> contains;
  final List<String> mayContain;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'contains': contains,
        'may_contain': mayContain,
      };
}