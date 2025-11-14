// lib/core/models/detection.dart
class Detection {
  final String id;
  final String insectId;
  final String insectName;
  final String scientificName;
  final double confidence;
  final String? imagePath;
  final String? location;
  final DateTime createdAt;
  final bool isFavorite;

  Detection({
    required this.id,
    required this.insectId,
    required this.insectName,
    required this.scientificName,
    required this.confidence,
    this.imagePath,
    this.location,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'],
      insectId: json['insect_id'],
      insectName: json['insect_name'],
      scientificName: json['scientific_name'],
      confidence: json['confidence'].toDouble(),
      imagePath: json['image_path'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insect_id': insectId,
      'insect_name': insectName,
      'scientific_name': scientificName,
      'confidence': confidence,
      'image_path': imagePath,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }
}
