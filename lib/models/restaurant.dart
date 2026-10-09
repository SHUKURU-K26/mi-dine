class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.description,
    required this.qrCode,
  });

  final String id;
  final String name;
  final String cuisine;
  final String address;
  final String description;
  final String qrCode;

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        cuisine: (json['cuisine'] as String?) ?? '',
        address: (json['address'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        qrCode: json['qr_code'] as String,
      );
}