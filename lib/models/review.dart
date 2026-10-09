class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.dedicatedFryer,
    required this.staffKnowledgeable,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String authorName;
  final int rating;
  final String comment;
  final bool dedicatedFryer;
  final bool staffKnowledgeable;
  final DateTime createdAt;

  /// Expects: { ..., profiles: { full_name } }
  factory Review.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final name = (profile?['full_name'] as String?)?.trim() ?? '';
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: name.isEmpty ? 'Mi-Dine member' : name,
      rating: json['rating'] as int,
      comment: (json['comment'] as String?) ?? '',
      dedicatedFryer: json['dedicated_fryer'] as bool? ?? false,
      staffKnowledgeable: json['staff_knowledgeable'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}