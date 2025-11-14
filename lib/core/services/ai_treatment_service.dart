// lib/core/services/ai_treatment_service.dart
import 'dart:math';
import '../models/treatment.dart';

class AITreatmentService {
  static AITreatmentService? _instance;
  static AITreatmentService get instance => _instance ??= AITreatmentService._();
  AITreatmentService._();

  final Random _random = Random();

  Future<List<Treatment>> generateTreatmentSuggestions({
    required String insectName,
    required String cropType,
    String? location,
    int? severity,
  }) async {
    try {
      // Simulation d'appel IA (remplacez par un vrai appel API)
      await Future.delayed(const Duration(seconds: 2));
      
      return _generateSmartTreatments(insectName, cropType, severity ?? 3);
    } catch (e) {
      print('Erreur AI treatment generation: $e');
      rethrow;
    }
  }

  List<Treatment> _generateSmartTreatments(String insectName, String cropType, int severity) {
    List<Treatment> treatments = [];
    
    // Logique intelligente basée sur l'insecte et la culture
    if (insectName.toLowerCase().contains('puceron')) {
      treatments.addAll(_generateAphidTreatments(cropType, severity));
    } else if (insectName.toLowerCase().contains('thrips')) {
      treatments.addAll(_generateThripsTreatments(cropType, severity));
    } else if (insectName.toLowerCase().contains('doryphore')) {
      treatments.addAll(_generateBeetleTreatments(cropType, severity));
    } else {
      treatments.addAll(_generateGenericTreatments(cropType, severity));
    }

    return treatments.take(3).toList();
  }

  List<Treatment> _generateAphidTreatments(String cropType, int severity) {
    List<Treatment> treatments = [
      Treatment(
        id: 'ai_aphid_1',
        methode: 'Huile de neem + savon noir',
        description: 'Mélange de 10ml d\'huile de neem et 15ml de savon noir par litre d\'eau. Très efficace contre les pucerons.',
        type: 'organic',
        efficacite: severity > 3 ? 5 : 4,
        periodeApplication: severity > 3 ? 'Tous les 2 jours pendant une semaine' : 'Tous les 3-4 jours',
        coutEstime: 12.0,
        createdAt: DateTime.now(),
      ),
      Treatment(
        id: 'ai_aphid_2',
        methode: 'Auxiliaires spécialisés',
        description: 'Lâchers de Chrysopes et Aphidius (parasitoïdes). Solution biologique durable.',
        type: 'biological',
        efficacite: 5,
        periodeApplication: 'Dès détection, renouveler si nécessaire',
        coutEstime: 35.0,
        createdAt: DateTime.now(),
      ),
    ];

    if (severity >= 4) {
      treatments.add(Treatment(
        id: 'ai_aphid_3',
        methode: 'Traitement systémique d\'urgence',
        description: 'Application d\'insecticide systémique en cas d\'infestation sévère. À utiliser en dernier recours.',
        type: 'chemical',
        efficacite: 5,
        periodeApplication: 'Une application, respecter les délais avant récolte',
        coutEstime: 45.0,
        createdAt: DateTime.now(),
      ));
    }

    return treatments;
  }

  List<Treatment> _generateThripsTreatments(String cropType, int severity) {
    return [
      Treatment(
        id: 'ai_thrips_1',
        methode: 'Pièges chromatiques + prédateurs',
        description: 'Combinaison de pièges bleus et introduction d\'Orius (punaises prédatrices).',
        type: 'biological',
        efficacite: 4,
        periodeApplication: 'Installation continue des pièges, lâchers mensuels',
        coutEstime: 28.0,
        createdAt: DateTime.now(),
      ),
      Treatment(
        id: 'ai_thrips_2',
        methode: 'Pulvérisation huile essentielle',
        description: 'Mélange d\'huiles essentielles de menthe et eucalyptus (répulsif naturel).',
        type: 'organic',
        efficacite: 3,
        periodeApplication: 'Bi-hebdomadaire en prévention',
        coutEstime: 15.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Treatment> _generateBeetleTreatments(String cropType, int severity) {
    return [
      Treatment(
        id: 'ai_beetle_1',
        methode: 'Ramassage manuel + Bacillus thuringiensis',
        description: 'Combinaison ramassage des adultes et traitement larvaire au BT.',
        type: 'biological',
        efficacite: 4,
        periodeApplication: 'Ramassage quotidien, BT tous les 7 jours',
        coutEstime: 18.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Treatment> _generateGenericTreatments(String cropType, int severity) {
    return [
      Treatment(
        id: 'ai_generic_1',
        methode: 'Observation et piégeage',
        description: 'Mise en place de pièges de monitoring et surveillance renforcée.',
        type: 'cultural',
        efficacite: 2,
        periodeApplication: 'Installation immédiate, suivi hebdomadaire',
        coutEstime: 10.0,
        createdAt: DateTime.now(),
      ),
      Treatment(
        id: 'ai_generic_2',
        methode: 'Traitement polyvalent bio',
        description: 'Application d\'un insecticide biologique à large spectre (pyrèthre naturel).',
        type: 'organic',
        efficacite: 3,
        periodeApplication: 'Selon besoin, maximum 2 fois par semaine',
        coutEstime: 22.0,
        createdAt: DateTime.now(),
      ),
    ];
  }
}