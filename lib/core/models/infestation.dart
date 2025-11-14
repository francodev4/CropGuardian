// lib/core/models/infestation.dart
class Infestation {
  final String id;
  final String fieldId;
  final String insectId;
  final String insectName;
  final double latitude;
  final double longitude;
  final int severity; // 1-5 scale
  final double affectedArea; // percentage of field affected
  final String status; // active, treated, resolved
  final String? imagePath;
  final String? notes;
  final DateTime detectedAt;
  final DateTime? treatedAt;
  final DateTime? resolvedAt;

  Infestation({
    required this.id,
    required this.fieldId,
    required this.insectId,
    required this.insectName,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.affectedArea,
    required this.status,
    this.imagePath,
    this.notes,
    required this.detectedAt,
    this.treatedAt,
    this.resolvedAt,
  });

  factory Infestation.fromJson(Map<String, dynamic> json) {
    return Infestation(
      id: json['id'] ?? '',
      fieldId: json['field_id'] ?? '',
      insectId: json['insect_id'] ?? '',
      insectName: json['insect_name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 1,
      affectedArea: (json['affected_area'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'active',
      imagePath: json['image_path'],
      notes: json['notes'],
      detectedAt: json['detected_at'] != null 
          ? DateTime.parse(json['detected_at']) 
          : DateTime.now(),
      treatedAt: json['treated_at'] != null 
          ? DateTime.parse(json['treated_at']) 
          : null,
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'field_id': fieldId,
      'insect_id': insectId,
      'insect_name': insectName,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'affected_area': affectedArea,
      'status': status,
      'image_path': imagePath,
      'notes': notes,
      'treated_at': treatedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
    
    // ✅ N'inclure id et detected_at que pour les modifications
    // Lors de la création, Supabase les génère automatiquement
    if (id.isNotEmpty) {
      json['id'] = id;
      json['detected_at'] = detectedAt.toIso8601String();
    }
    
    return json;
  }

  Infestation copyWith({
    String? status,
    DateTime? treatedAt,
    DateTime? resolvedAt,
    String? notes,
  }) {
    return Infestation(
      id: id,
      fieldId: fieldId,
      insectId: insectId,
      insectName: insectName,
      latitude: latitude,
      longitude: longitude,
      severity: severity,
      affectedArea: affectedArea,
      status: status ?? this.status,
      imagePath: imagePath,
      notes: notes ?? this.notes,
      detectedAt: detectedAt,
      treatedAt: treatedAt ?? this.treatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}