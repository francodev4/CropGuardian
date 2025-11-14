import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SupabaseService extends ChangeNotifier {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  final SupabaseClient _client = Supabase.instance.client;
  bool _isInitialized = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  SupabaseClient get client => _client;

  Future<void> initialize() async {
    try {
      _error = null;
      // Vérifier la connexion
      await _client.from('profiles').select('id').limit(1);
      _isInitialized = true;
      debugPrint('✅ Supabase initialisé avec succès');
      notifyListeners();
    } catch (e) {
      _error = 'Erreur connexion Supabase: $e';
      debugPrint('❌ $_error');
      notifyListeners();
    }
  }

  // Upload d'image avec gestion d'erreurs robuste
  Future<String?> uploadImage(
      File imageFile, String bucket, String path) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Fichier image introuvable');
      }

      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB max
        throw Exception('Fichier trop volumineux (max 10MB)');
      }

      final bytes = await imageFile.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$path';

      await _client.storage.from(bucket).uploadBinary(fileName, bytes);

      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);

      debugPrint('✅ Image uploadée: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Erreur upload image: $e');
      return null;
    }
  }

  // Sauvegarder une prédiction
  Future<bool> savePrediction(Map<String, dynamic> predictionData) async {
    try {
      await _client.from('predictions').insert(predictionData);

      debugPrint('✅ Prédiction sauvegardée');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde prédiction: $e');
      return false;
    }
  }

  // Récupérer l'historique des prédictions
  Future<List<Map<String, dynamic>>> getPredictionHistory(
      {int limit = 50}) async {
    try {
      final response = await _client
          .from('predictions')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Erreur récupération historique: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    debugPrint('🗑️ Supabase Service libéré');
    super.dispose();
  }
}
