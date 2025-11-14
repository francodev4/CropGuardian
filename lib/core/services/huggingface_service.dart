// lib/core/services/huggingface_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

class HuggingFaceService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _apiKey =
      ''; // ⚠️ Remplacer par votre vrai token

  final Dio _dio = Dio();

  // 🤖 Classification d'images d'insectes
  Future<Map<String, dynamic>> classifyInsectImage(File imageFile) async {
    try {
      print('🔍 Analyse d\'image avec Hugging Face...');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Modèle spécialisé pour la classification d'insectes
      final response = await _dio.post(
        '$_baseUrl/microsoft/resnet-50',
        data: {'inputs': base64Image},
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final results = response.data as List;
        if (results.isNotEmpty) {
          final topResult = results.first;
          return {
            'insect': _mapToInsectName(topResult['label']),
            'confidence': (topResult['score'] * 100).toStringAsFixed(1),
            'raw_label': topResult['label'],
            'source': 'Hugging Face AI',
          };
        }
      }

      throw Exception('Aucun résultat de classification');
    } catch (e) {
      print('❌ Erreur Hugging Face: $e');
      throw Exception('Erreur classification Hugging Face: $e');
    }
  }

  // 🗂️ Mapper les labels IA vers des noms d'insectes agricoles
  String _mapToInsectName(String label) {
    final lowercaseLabel = label.toLowerCase();

    // Mapping spécialisé pour l'agriculture
    final insectMapping = {
      'beetle': 'Doryphore (coléoptère)',
      'ladybug': 'Coccinelle',
      'aphid': 'Puceron',
      'caterpillar': 'Chenille défoliatrice',
      'butterfly': 'Papillon (chenille potentielle)',
      'moth': 'Papillon de nuit (pyrale possible)',
      'fly': 'Mouche (possiblement nuisible)',
      'ant': 'Fourmi',
      'bee': 'Abeille (bénéfique)',
      'wasp': 'Guêpe',
      'spider': 'Araignée (prédateur utile)',
      'grasshopper': 'Criquet/Sauterelle',
      'cricket': 'Grillon',
      'tick': 'Tique',
      'mite': 'Acarien',
      'thrips': 'Thrips',
      'whitefly': 'Mouche blanche',
      'scale': 'Cochenille',
    };

    // Recherche du mapping le plus proche
    for (final entry in insectMapping.entries) {
      if (lowercaseLabel.contains(entry.key)) {
        return entry.value;
      }
    }

    // Si pas de match, retourner le label original nettoyé
    return 'Insecte: ${_cleanLabel(label)}';
  }

  // 🧹 Nettoyer les labels de l'IA
  String _cleanLabel(String label) {
    return label
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }

  // 🧪 Tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        'https://api-inference.huggingface.co/',
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Test connexion Hugging Face échoué: $e');
      return false;
    }
  }

  void dispose() {
    _dio.close();
  }
}

// Extension pour capitaliser les mots
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
