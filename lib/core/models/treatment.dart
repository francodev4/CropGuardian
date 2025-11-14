// lib/core/models/treatment.dart
class Treatment {
  final String id;
  final String? insectId;
  final String methode;
  final String? description;
  final String type;
  final int? efficacite;
  final String? periodeApplication;
  final double? coutEstime;
  final DateTime createdAt;

  Treatment({
    required this.id,
    this.insectId,
    required this.methode,
    this.description,
    required this.type,
    this.efficacite,
    this.periodeApplication,
    this.coutEstime,
    required this.createdAt,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) => Treatment(
    id: json['id'],
    insectId: json['insect_id'],
    methode: json['methode'],
    description: json['description'],
    type: json['type'] ?? 'biological',
    efficacite: json['efficacite'],
    periodeApplication: json['periode_application'],
    coutEstime: json['cout_estime']?.toDouble(),
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'insect_id': insectId,
    'methode': methode,
    'description': description,
    'type': type,
    'efficacite': efficacite,
    'periode_application': periodeApplication,
    'cout_estime': coutEstime,
    'created_at': createdAt.toIso8601String(),
  };

  String get efficaciteText {
    switch (efficacite) {
      case 5: return 'Très efficace';
      case 4: return 'Efficace';
      case 3: return 'Modérément efficace';
      case 2: return 'Peu efficace';
      case 1: return 'Faiblement efficace';
      default: return 'Efficacité inconnue';
    }
  }

  String get typeText {
    switch (type.toLowerCase()) {
      case 'biological': return 'Biologique';
      case 'chemical': return 'Chimique';
      case 'organic': return 'Organique';
      case 'cultural': return 'Cultural';
      case 'mechanical': return 'Mécanique';
      default: return type;
    }
  }

  String get costText {
    if (coutEstime == null) return 'Coût non estimé';
    if (coutEstime! < 10) return 'Économique';
    if (coutEstime! < 50) return 'Coût modéré';
    return 'Coût élevé';
  }
}
