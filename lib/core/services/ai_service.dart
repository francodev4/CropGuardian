// lib/core/services/ai_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model_zoo_service.dart';
import 'huggingface_service.dart';
import 'local_ai_service.dart'; // LocalAIService est pour la recherche texte locale
import 'custom_model_service.dart';
import 'gemini_service.dart'; // Importez le nouveau service Gemini

class AIService {
  final HuggingFaceService _huggingFaceService = HuggingFaceService();
  final LocalAIService _localAIService = LocalAIService.instance;
  final ModelZooService _modelZooService = ModelZooService.instance;
  final CustomModelService _customModelService = CustomModelService.instance;
  final GeminiService _geminiService = GeminiService.instance; // Ajoutez Gemini
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isHuggingFaceReady = false;
  bool _isLocalReady = false;
  bool _isModelZooReady = false;
  bool _isCustomModelReady = false;
  bool _isGeminiReady = false; // Nouvelle variable pour Gemini

  // Initialiser tous les services IA
  Future<void> initialize() async {
    print('🚀 Initialisation des services IA...');

    // 1. 🎯 PRIORITÉ MAX: Votre modèle personnalisé (15 classes)
    try {
      await _customModelService.initialize();
      _isCustomModelReady = true;
      print(
          '✅ 🎯 VOTRE MODÈLE personnalisé prêt ! (${_customModelService.classCount} classes)');
      print('📋 Classes: ${_customModelService.availableClasses}');
    } catch (e) {
      print('❌ Erreur CustomModelService: $e');
    }

    // 2. 🤖 Gemini AI (Texte et Vision)
    try {
      await _geminiService.initialize();
      _isGeminiReady = _geminiService.isInitialized;
      print('✅ 🤖 Service Gemini prêt !');
    } catch (e) {
      print('❌ Erreur GeminiService: $e');
    }

    // 3. 🌐 HuggingFace
    // NOTE: L'initialisation de HuggingFace est souvent implicite lors du premier appel ou non nécessaire.
    _isHuggingFaceReady = true; // Considéré prêt si la clé API est configurée
    print('🌐 Service HuggingFace: ${_isHuggingFaceReady ? 'Prêt' : 'Clé manquante/Non initialisé'}');

    // 4. 🧠 Model Zoo (Simulé)
    try {
      await _modelZooService.initialize();
      _isModelZooReady = _modelZooService.isReady;
      print('🧠 Service Model Zoo: ${_isModelZooReady ? 'Prêt (Simulé)' : 'Inactif'}');
    } catch (e) {
      print('❌ Erreur ModelZooService: $e');
    }

    // 5. 📱 Service IA local (pour la recherche texte locale)
    try {
      await _localAIService.initialize();
      _isLocalReady = true;
      print('✅ 📱 Service IA local prêt !');
    } catch (e) {
      print('❌ Erreur LocalAIService: $e');
    }
  }

  // ***************************************************************
  // 📸 FONCTION PRINCIPALE: Analyse d'image avec logique de repli
  // ***************************************************************
  Future<Map<String, dynamic>> identifyInfestation(File imageFile) async {
    // 1. 🎯 TENTATIVE 1: Votre modèle personnalisé (TFLite/Local)
    if (_isCustomModelReady) {
      try {
        print('🎯 Tentative 1: Custom Model (Local TFLite)...');
        final result = await _customModelService.predictInsect(imageFile);
        
        // La logique de CustomModelService est censée retourner un résultat même en simulation
        final confidence = _getConfidenceValue(result['confidence']);
        if (confidence > 0.0) {
          print('✅ Résultat local trouvé: ${result['insect']} (${result['confidence_percentage']})');
          return result;
        }
      } catch (e) {
        print('❌ Échec Custom Model (TFLite/Simul.): $e. Repli...');
      }
    }

    // 2. 🤖 TENTATIVE 2: Gemini Vision (Cloud)
    if (_isGeminiReady) {
      try {
        print('🤖 Tentative 2: Gemini Vision (Cloud)...');
        final result = await _geminiService.identifyImage(imageFile);
        
        final confidence = _getConfidenceValue(result['confidence']);
        if (confidence > 0.0) {
          print('✅ Résultat Gemini Vision trouvé: ${result['insect']} (${result['confidence_percentage']})');
          return result;
        }
      } catch (e) {
        print('❌ Échec Gemini Vision: $e. Repli...');
      }
    }

    // 3. 🌐 TENTATIVE 3: HuggingFace (Cloud)
    if (_isHuggingFaceReady) {
      try {
        print('🌐 Tentative 3: HuggingFace (Cloud)...');
        final result = await _huggingFaceService.classifyInsectImage(imageFile);
        
        // HuggingFace utilise un format légèrement différent pour le confidence
        final confidenceStr = result['confidence']?.toString() ?? '0.0';
        final confidenceValue = double.tryParse(confidenceStr) ?? 0.0;
        
        if (confidenceValue > 50.0) { 
          print('✅ Résultat HuggingFace trouvé: ${result['insect']} ($confidenceStr%)');
          return {
            'insect': result['insect'],
            'confidence': confidenceValue / 100, // Conversion en 0.0-1.0
            'confidence_percentage': '$confidenceStr%',
            'severity': _getSeverity(confidenceValue / 100),
            'recommendations': 'Veuillez consulter un expert pour confirmer.',
            'model_type': 'HuggingFace ResNet',
            'source': 'HuggingFace API',
          };
        }
      } catch (e) {
        print('❌ Échec HuggingFace: $e. Repli...');
      }
    }

    // 4. 🧠 TENTATIVE 4: Model Zoo (Simulé/Cloud)
    if (_isModelZooReady) {
      try {
        print('🧠 Tentative 4: Model Zoo (Simulé)...');
        final results = await _modelZooService.predictInsect(imageFile);
        
        // Model Zoo retourne List<Map>, prendre le premier résultat
        if (results.isNotEmpty) {
          final bestResult = results.first;
          final confidence = _getConfidenceValue(bestResult['confidence']);
          
          if (confidence > 0.0) {
            print('✅ Résultat Model Zoo trouvé: ${bestResult['name']} ($confidence)');
            // Convertir au format standard
            return {
              'insect': bestResult['name'],
              'confidence': confidence,
              'confidence_percentage': '${(confidence * 100).toStringAsFixed(1)}%',
              'severity': _getSeverity(confidence),
              'recommendations': 'Veuillez consulter un expert pour confirmer.',
              'model_type': 'Model Zoo (Simulé)',
              'source': 'Model Zoo Local',
            };
          }
        }
      } catch (e) {
        print('❌ Échec Model Zoo (Simulé): $e. Repli...');
      }
    }

    // 5. ❌ ÉCHEC FINAL
    print('🚨 Échec de toutes les tentatives d\'analyse d\'image.');
    return {
      'insect': 'Échec de l\'analyse (Aucun modèle IA n\'a répondu)',
      'confidence': 0.0,
      'confidence_percentage': '0.0%',
      'severity': 'Très faible',
      'recommendations': 'Veuillez vérifier les connexions Internet ou réessayer avec une meilleure image.',
      'model_type': 'Échec Global',
      'source': 'Logiciel',
    };
  }

  // ***************************************************************
  // 🔎 FONCTION SECONDAIRE: Recherche par mots-clés (pour le log)
  // ***************************************************************
  Future<Map<String, dynamic>> searchByDescription(String description) async {
    // 1. 📱 TENTATIVE 1: Local AI (pour la recherche locale)
    try {
      print('🔍 Tentative 1: Recherche locale (Local AI)...');
      final localResult = _localAIService.searchByDescription(description);
      
      if (localResult.isNotEmpty && !localResult.contains('Aucune correspondance exacte trouvée')) {
        print('✅ Résultat local trouvé pour la description: ${localResult.join(', ')}');
        return {
          'result': 'Correspondances locales: ${localResult.join(', ')}',
          'source': 'IA Locale',
        };
      }
    } catch (e) {
      print('❌ Échec recherche locale: $e. Repli...');
    }
    
    // 2. 🤖 TENTATIVE 2: Gemini AI (Cloud)
    if (_isGeminiReady) {
      try {
        print('🤖 Tentative 2: Gemini AI (Texte)...');
        final geminiResponse = await _geminiService.askQuestion(description);

        if (geminiResponse != 'Erreur lors du traitement de votre question') {
          print('✅ Résultat Gemini trouvé.');
          return {
            'result': geminiResponse,
            'source': 'Google Gemini AI',
          };
        }
      } catch (e) {
        print('❌ Échec Gemini Texte: $e. Repli...');
      }
    }

    // 3. ❌ ÉCHEC FINAL
    return {
      'result': 'Échec de la recherche par description. Veuillez réessayer ou utiliser l\'analyse d\'image.',
      'source': 'Échec Global',
    };
  }
  
  // ***************************************************************
  // 🛠️ FONCTIONS UTILITAIRES
  // ***************************************************************
  
  /// Convertir confidence en double (gère String, double, int, null)
  double _getConfidenceValue(dynamic confidence) {
    if (confidence == null) return 0.0;
    if (confidence is double) return confidence;
    if (confidence is int) return confidence.toDouble();
    if (confidence is String) return double.tryParse(confidence) ?? 0.0;
    return 0.0;
  }
  
  /// Déterminer la sévérité basée sur la confiance
  String _getSeverity(double confidence) {
    if (confidence >= 0.9) return 'Élevé';
    if (confidence >= 0.7) return 'Moyen';
    if (confidence >= 0.5) return 'Faible';
    return 'Très faible';
  }
  
  /// Obtenir le statut des services
  Map<String, bool> getServicesStatus() {
    return {
      '🎯 Votre Modèle (TFLite)': _isCustomModelReady,
      '🤖 Gemini AI': _isGeminiReady,
      '🌐 HuggingFace': _isHuggingFaceReady,
      '🧠 Model Zoo': _isModelZooReady,
      '📱 Service Local': _isLocalReady,
    };
  }
  
  /// Obtenir les détails du modèle personnalisé
  Map<String, dynamic> getCustomModelInfo() {
    if (_isCustomModelReady) {
      return {
        'initialized': _customModelService.isInitialized,
        'loading': _customModelService.isLoading,
        'error': _customModelService.error,
        'classes_count': _customModelService.classCount,
        'classes': _customModelService.availableClasses,
        'model_type': 'TensorFlow Lite personnalisé',
        'version': '2.0',
      };
    }
    return {'status': 'Model not ready'};
  }
  
  /// Libérer les ressources
  void dispose() {
    try {
      if (_isCustomModelReady) {
        _customModelService.dispose();
      }
      _huggingFaceService.dispose();
      _modelZooService.dispose();
    } catch (e) {
      print('Erreur lors de la libération des ressources: $e');
    }
  }
}