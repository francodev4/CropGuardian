// lib/core/models/field.dart
class Field {
  final String id;
  final String name;
  final String userId;
  final double latitude;
  final double longitude;
  final double area; // en hectares
  final String cropType;
  final DateTime plantingDate;
  final String description;
  final DateTime createdAt;

  Field({
    required this.id,
    required this.name,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.cropType,
    required this.plantingDate,
    required this.description,
    required this.createdAt,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? '550e8400-e29b-41d4-a716-446655440000', // ✅ Fallback UUID
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      area: (json['area'] ?? 0.0).toDouble(),
      cropType: json['crop_type'] ?? '',
      plantingDate: json['planting_date'] != null 
          ? DateTime.parse(json['planting_date']) 
          : DateTime.now(),
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'crop_type': cropType,
      'planting_date': plantingDate.toIso8601String(),
      'description': description,
    };
    
    // ✅ N'inclure id et created_at que pour les modifications
    // Lors de la création, Supabase les génère automatiquement
    if (id.isNotEmpty) {
      json['id'] = id;
      json['created_at'] = createdAt.toIso8601String();
    }
    
    return json;
  }
}