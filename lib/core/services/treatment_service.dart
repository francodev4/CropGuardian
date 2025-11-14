// lib/core/services/treatment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/treatment.dart';

class TreatmentService {
  static TreatmentService? _instance;
  static TreatmentService get instance => _instance ??= TreatmentService._();
  TreatmentService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtenir traitements pour un insecte spécifique
  Future<List<Treatment>> getTreatmentSuggestions(String insectId) async {
    try {
      final response = await _supabase
          .from('traitements')
          .select()
          .eq('insect_id', insectId)
          .order('efficacite', ascending: false);

      return (response as List)
          .map((json) => Treatment.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur getTreatmentSuggestions: $e');
      return [];
    }
  }

  // Obtenir tous les traitements
  Future<List<Treatment>> getAllTreatments() async {
    try {
      final response = await _supabase
          .from('traitements')
          .select()
          .order('efficacite', ascending: false);

      return (response as List)
          .map((json) => Treatment.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur getAllTreatments: $e');
      return [];
    }
  }

  // Créer un nouveau traitement
  Future<Treatment> createTreatment(Treatment treatment) async {
    try {
      final response = await _supabase
          .from('traitements')
          .insert(treatment.toJson())
          .select()
          .single();

      return Treatment.fromJson(response);
    } catch (e) {
      print('Erreur createTreatment: $e');
      rethrow;
    }
  }

  // Rechercher traitements par méthode
  Future<List<Treatment>> searchTreatments(String query) async {
    try {
      final response = await _supabase
          .from('traitements')
          .select()
          .or('methode.ilike.%$query%,description.ilike.%$query%')
          .order('efficacite', ascending: false);

      return (response as List)
          .map((json) => Treatment.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur searchTreatments: $e');
      return [];
    }
  }

  // Traitements de secours locaux
  List<Treatment> getFallbackTreatments(String insectName) {
    final fallbackData = {
      'puceron': [
        Treatment(
          id: 'fallback_1',
          methode: 'Savon noir',
          description: 'Diluer 15ml de savon noir dans 1L d\'eau. Pulvériser tôt le matin ou en soirée.',
          type: 'organic',
          efficacite: 4,
          periodeApplication: 'Répéter tous les 3-5 jours',
          coutEstime: 5.0,
          createdAt: DateTime.now(),
        ),
        Treatment(
          id: 'fallback_2',
          methode: 'Coccinelles',
          description: 'Introduction de coccinelles prédatrices naturelles des pucerons.',
          type: 'biological',
          efficacite: 5,
          periodeApplication: 'Au début de l\'infestation',
          coutEstime: 25.0,
          createdAt: DateTime.now(),
        ),
      ],
      'thrips': [
        Treatment(
          id: 'fallback_3',
          methode: 'Pièges chromatiques bleus',
          description: 'Installation de pièges collants bleus pour capturer les thrips adultes.',
          type: 'cultural',
          efficacite: 3,
          periodeApplication: 'Installation permanente',
          coutEstime: 8.0,
          createdAt: DateTime.now(),
        ),
      ],
    };

    // Recherche par nom d'insecte
    for (String key in fallbackData.keys) {
      if (insectName.toLowerCase().contains(key)) {
        return fallbackData[key]!;
      }
    }

    // Traitement générique
    return [
      Treatment(
        id: 'generic',
        methode: 'Consultation spécialisée',
        description: 'Contactez un agronome ou un conseiller agricole pour un diagnostic personnalisé.',
        type: 'advice',
        efficacite: 3,
        periodeApplication: 'Immédiatement',
        coutEstime: 0.0,
        createdAt: DateTime.now(),
      )
    ];
  }
}