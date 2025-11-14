// lib/core/models/insect.dart
class Insect {
  final String id;
  final String commonName;
  final String scientificName;
  final String description;
  final String? imageUrl;
  final String category;
  final String habitat;
  final String damage;
  final List<String> symptoms;
  final DateTime createdAt;

  Insect({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.habitat,
    required this.damage,
    required this.symptoms,
    required this.createdAt,
  });

  factory Insect.fromJson(Map<String, dynamic> json) {
    return Insect(
      id: json['id'],
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      description: json['description'],
      imageUrl: json['image_url'],
      category: json['category'],
      habitat: json['habitat'],
      damage: json['damage'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'habitat': habitat,
      'damage': damage,
      'symptoms': symptoms,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
