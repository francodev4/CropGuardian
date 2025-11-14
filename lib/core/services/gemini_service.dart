// lib/core/services/gemini_service.dart

import 'dart:io';
// Ajout nécessaire
// Ajout nécessaire pour kIsWeb
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  factory GeminiService() => instance;
  GeminiService._internal();

  // ⚠️ REMPLACEZ PAR VOTRE CLÉ API GEMINI!
  // IMPORTANT: Ne laissez PAS la clé en dur dans le code. Mettez votre clé dans `.env`
  // Exemple `.env`:
  // GEMINI_API_KEY=your-real-key
  // Ici on utilise un placeholder vide pour éviter d'exposer la clé dans le repo.
  static const String _apiKey = '';

  GenerativeModel? _model;
  GenerativeModel? _visionModel; // Nouveau modèle pour l'analyse d'image
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialiser le service Gemini
  Future<void> initialize() async {
    if (_apiKey == 'VOTRE_CLE_API_GEMINI_ICI' || _apiKey.isEmpty) {
      print('⚠️ Gemini: Clé API non configurée');
      print(
          '📝 Obtenez votre clé gratuite sur: https://makersuite.google.com/app/apikey');
      _isInitialized = false;
      return;
    }

    try {
      await Future.delayed(Duration.zero);

      // Modèle pour le TEXTE pur (question/réponse)
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
        ),
      );

      // Modèle pour la VISION/Multimodal (analyse d'image)
      // On utilise le même modèle mais on sépare la variable pour la clarté
      _visionModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      _isInitialized = true;
      print('✅ Gemini 2.5 Flash initialisé avec succès pour Texte et Vision!');
    } catch (e) {
      print('❌ Erreur initialisation Gemini: $e');
      _isInitialized = false;
    }
  }

  /// Poser une question textuelle à Gemini (pour la recherche par description)
  Future<String> askQuestion(String question) async {
    if (!_isInitialized || _model == null) {
      return 'Erreur: Service Gemini non initialisé.';
    }

    try {
      final enhancedPrompt = '''
Vous êtes un expert en protection des cultures. Répondez à la question suivante en vous concentrant sur l'identification d'insectes, de maladies, ou de problèmes agricoles, et donnez un conseil simple.
Question: "$question"
Réponse concise (max 150 mots).
''';

      // ✅ CORRECTION DU FORMAT ICI : S'assurer que seul du Content.text est envoyé.
      final content = [Content.text(enhancedPrompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Pas de réponse disponible';
    } catch (e) {
      // L'erreur FormatException devrait être corrigée.
      print('❌ Erreur question Gemini: $e');
      return 'Erreur lors du traitement de votre question (Gemini API: ${e.runtimeType})';
    }
  }

  /// 📸 Analyser une image avec Gemini (pour le repli de scan)
  Future<Map<String, dynamic>> identifyImage(File imageFile) async {
    if (!_isInitialized || _visionModel == null) {
      return {
        'insect': 'Erreur Gemini Vision',
        'confidence': 0.0,
        'confidence_percentage': '0.0%',
        'severity': 'Très faible',
        'recommendations': 'Veuillez vérifier la clé API de Gemini.',
      };
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes); // Type MIME correct

      const String prompt =
          'Analysez cette image. Quel est l\'insecte, la maladie ou le problème agricole le plus probable? Donnez le nom en français, la confiance (sur 100%), la gravité du problème (Faible/Moyen/Élevé) et une recommandation très courte.';

      final response = await _visionModel!.generateContent([
        Content.multi([
          TextPart(prompt),
          imagePart,
        ]),
      ]);

      final String? responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return _createErrorResult('Gemini n\'a pas pu identifier l\'élément.');
      }

      // Simplification: Tenter de parser le résultat textuel
      final parsedResult = _parseGeminiVisionResult(responseText);

      return {
        'insect': parsedResult['name'],
        'confidence': parsedResult['confidence'],
        'confidence_percentage':
            '${(parsedResult['confidence'] * 100).toStringAsFixed(1)}%',
        'severity': parsedResult['severity'],
        'recommendations': parsedResult['recommendations'],
        'model_type': 'Gemini 2.5 Flash (Vision)',
        'source': 'Google Gemini API',
      };
    } catch (e) {
      print('❌ Erreur analyse image Gemini: $e');
      return _createErrorResult('Erreur interne de l\'API Gemini Vision: $e');
    }
  }

  // Fonctions utilitaires pour le parsing
  Map<String, dynamic> _createErrorResult(String error) {
    return {
      'insect': 'Échec de l\'analyse',
      'confidence': 0.0,
      'confidence_percentage': '0.0%',
      'severity': 'Inconnu',
      'recommendations': 'Erreur: $error',
      'model_type': 'Gemini Vision',
      'source': 'Google Gemini API',
    };
  }

  // Fonction de parsing simple (à améliorer si nécessaire)
  Map<String, dynamic> _parseGeminiVisionResult(String text) {
    // Simuler l'extraction des données clés à partir d'une réponse formatée
    final lines = text.split('\n');
    String name = 'Résultat non formaté';
    double confidence = 0.5;
    String severity = 'Moyen';
    String recommendations = text; // Par défaut, toute la réponse

    // Logique de parsing très simple et fragile, basée sur des mots-clés
    for (final line in lines) {
      if (line.toLowerCase().contains('nom:'))
        name = line.split(':').last.trim();
      if (line.toLowerCase().contains('confiance:')) {
        try {
          String confStr = line
              .split(':')
              .last
              .trim()
              .replaceAll('%', '')
              .replaceAll(',', '.');
          confidence = double.tryParse(confStr) != null
              ? double.parse(confStr) / 100.0
              : 0.5;
        } catch (_) {}
      }
      if (line.toLowerCase().contains('gravité:'))
        severity = line.split(':').last.trim();
      if (line.toLowerCase().contains('recommandation:'))
        recommendations = line.split(':').last.trim();
    }

    return {
      'name': name,
      'confidence': confidence.clamp(0.0, 1.0),
      'severity': severity,
      'recommendations': recommendations
    };
  }

  // ... (Le reste de la classe GeminiService: testConnection, getServiceInfo)
}
