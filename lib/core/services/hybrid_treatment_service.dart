// lib/core/services/hybrid_treatment_service.dart
import '../models/treatment.dart';
import 'treatment_service.dart';
import 'ai_treatment_service.dart';

class HybridTreatmentService {
  static HybridTreatmentService? _instance;
  static HybridTreatmentService get instance => _instance ??= HybridTreatmentService._();
  HybridTreatmentService._();

  final TreatmentService _dbService = TreatmentService.instance;
  final AITreatmentService _aiService = AITreatmentService.instance;

  Future<List<Treatment>> getSmartTreatmentSuggestions({
    required String insectId,
    required String insectName,
    required String cropType,
    String? location,
    int? severity,
  }) async {
    print('🔍 Recherche de traitements pour: $insectName');

    try {
      // 1. Essayer d'abord la base de données (rapide et fiable)
      List<Treatment> dbTreatments = await _dbService.getTreatmentSuggestions(insectId);
      
      if (dbTreatments.isNotEmpty) {
        print('✅ ${dbTreatments.length} traitements trouvés en BD');
        return _customizeTreatments(dbTreatments, cropType, severity);
      }

      print('⚠️ Aucun traitement en BD, génération IA...');
      
      // 2. Si pas de données en BD, utiliser l'IA
      List<Treatment> aiTreatments = await _aiService.generateTreatmentSuggestions(
        insectName: insectName,
        cropType: cropType,
        location: location ?? 'unknown',
        severity: severity ?? 3,
      );

      if (aiTreatments.isNotEmpty) {
        print('🤖 ${aiTreatments.length} traitements générés par IA');
        
        // 3. Sauvegarder les nouveaux traitements en BD pour la prochaine fois
        await _saveTreatmentsToDatabase(aiTreatments, insectId);
        
        return aiTreatments;
      }

    } catch (e) {
      print('❌ Erreur lors de la génération de traitements: $e');
    }

    // 4. Fallback final : traitements génériques locaux
    print('🔄 Utilisation des traitements de secours');
    return _dbService.getFallbackTreatments(insectName);
  }

  // Personnaliser les traitements selon le contexte
  List<Treatment> _customizeTreatments(List<Treatment> treatments, String cropType, int? severity) {
    return treatments.map((treatment) {
      // Ajuster selon la sévérité
      if (severity != null && severity >= 4) {
        // Prioriser les traitements les plus efficaces pour infestations sévères
        return treatment;
      }
      return treatment;
    }).toList();
  }

  // Sauvegarder les traitements IA en base pour réutilisation
  Future<void> _saveTreatmentsToDatabase(List<Treatment> treatments, String insectId) async {
    try {
      for (Treatment treatment in treatments) {
        // Créer une version persistante du traitement généré par IA
        final persistentTreatment = Treatment(
          id: treatment.id,
          insectId: insectId,
          methode: treatment.methode,
          description: treatment.description,
          type: treatment.type,
          efficacite: treatment.efficacite,
          periodeApplication: treatment.periodeApplication,
          coutEstime: treatment.coutEstime,
          createdAt: DateTime.now(),
        );

        await _dbService.createTreatment(persistentTreatment);
      }
      print('💾 Traitements IA sauvegardés en base de données');
    } catch (e) {
      print('⚠️ Erreur sauvegarde traitements: $e');
      // Ce n'est pas critique, on continue sans sauvegarder
    }
  }

  // Rechercher des traitements par description
  Future<List<Treatment>> searchTreatmentsByDescription(String description) async {
    try {
      // Recherche en base d'abord
      List<Treatment> dbResults = await _dbService.searchTreatments(description);
      
      if (dbResults.isNotEmpty) {
        return dbResults;
      }

      // Fallback avec traitements génériques
      return _dbService.getFallbackTreatments(description);
    } catch (e) {
      print('Erreur recherche par description: $e');
      return [];
    }
  }

  // Obtenir des statistiques sur les traitements
  Future<Map<String, dynamic>> getTreatmentStats() async {
    try {
      final allTreatments = await _dbService.getAllTreatments();
      
      Map<String, int> typeCount = {};
      double avgEfficacite = 0;
      double avgCost = 0;
      int validEfficacite = 0;
      int validCost = 0;

      for (Treatment treatment in allTreatments) {
        // Compter par type
        typeCount[treatment.type] = (typeCount[treatment.type] ?? 0) + 1;
        
        // Moyenne efficacité
        if (treatment.efficacite != null) {
          avgEfficacite += treatment.efficacite!;
          validEfficacite++;
        }
        
        // Moyenne coût
        if (treatment.coutEstime != null) {
          avgCost += treatment.coutEstime!;
          validCost++;
        }
      }

      return {
        'total_treatments': allTreatments.length,
        'by_type': typeCount,
        'avg_efficacite': validEfficacite > 0 ? avgEfficacite / validEfficacite : 0,
        'avg_cost': validCost > 0 ? avgCost / validCost : 0,
      };
    } catch (e) {
      print('Erreur statistiques traitements: $e');
      return {'total_treatments': 0, 'by_type': {}, 'avg_efficacite': 0, 'avg_cost': 0};
    }
  }
}