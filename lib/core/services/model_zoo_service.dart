// lib/core/services/model_zoo_service.dart
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ModelZooService extends ChangeNotifier {
  static ModelZooService? _instance;
  static ModelZooService get instance => _instance ??= ModelZooService._();
  ModelZooService._();

  static const String _mobileNetUrl =
      'https://storage.googleapis.com/download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_224.tflite';

  static const String _labelsUrl =
      'https://storage.googleapis.com/download.tensorflow.org/models/mobilenet_v1_1.0_224_frozen.tgz';

  List<String> _labels = [];
  bool _isModelReady = false;
  bool _isLoading = false;
  String? _error;
  final Random _random = Random();
  late Dio _dio;

  // Getters
  bool get isReady => _isModelReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get availableLabels => List.from(_labels);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setReady(bool ready) {
    _isModelReady = ready;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isModelReady) return;

    try {
      _setLoading(true);
      _setError(null);

      // Configuration Dio
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'User-Agent': 'CropGuardian/1.0'},
      ));

      // Vérifier la connectivité
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw Exception('Pas de connexion internet');
      }

      await loadModel();
      _setReady(true);
    } catch (e) {
      _setError('Erreur initialisation: $e');
      debugPrint('❌ Erreur ModelZooService: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> downloadModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/models/mobilenet_model.tflite';
      final modelFile = File(modelPath);

      // Créer le dossier si nécessaire
      await modelFile.parent.create(recursive: true);

      if (await modelFile.exists()) {
        debugPrint('✅ Modèle déjà téléchargé');
        return;
      }

      debugPrint('📥 Téléchargement du modèle gratuit...');

      await _dio.download(
        _mobileNetUrl,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toInt();
            debugPrint('Progression: $progress%');
          }
        },
      );

      debugPrint('✅ Modèle téléchargé avec succès !');
    } catch (e) {
      throw Exception('Erreur téléchargement: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/models/mobilenet_model.tflite';
      final modelFile = File(modelPath);

      if (!await modelFile.exists()) {
        await downloadModel();
      }

      // Simuler le chargement du modèle
      await Future.delayed(const Duration(seconds: 2));
      _labels = await _loadLabels();

      debugPrint('🤖 Modèle IA simulé chargé et prêt !');
    } catch (e) {
      throw Exception('Erreur chargement modèle: $e');
    }
  }

  Future<List<Map<String, dynamic>>> predictInsect(File imageFile) async {
    if (!_isModelReady) {
      throw Exception('Modèle non chargé. Appelez initialize() d\'abord.');
    }

    try {
      // Validation du fichier
      if (!await imageFile.exists()) {
        throw Exception('Fichier image introuvable');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Fichier image vide');
      }

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB max
        throw Exception('Fichier trop volumineux (max 10MB)');
      }

      debugPrint('🔍 Analyse de l\'image avec Model Zoo...');

      // Simuler le processing
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(800)));

      return _simulateModelResults(imageFile);
    } catch (e) {
      throw Exception('Erreur prédiction: $e');
    }
  }

  List<Map<String, dynamic>> _simulateModelResults(File imageFile) {
    try {
      final fileName = imageFile.path.toLowerCase();
      final fileSize = imageFile.lengthSync();

      final baseResults = [
        {'name': 'Puceron vert', 'confidence': 0.75, 'severity': 'Modéré'},
        {'name': 'Thrips', 'confidence': 0.68, 'severity': 'Faible'},
        {'name': 'Mouche blanche', 'confidence': 0.45, 'severity': 'Élevé'},
        {'name': 'Cochenille', 'confidence': 0.32, 'severity': 'Modéré'},
        {'name': 'Doryphore', 'confidence': 0.28, 'severity': 'Élevé'},
      ];

      // Logique basée sur le nom du fichier
      if (fileName.contains('green') || fileName.contains('vert')) {
        baseResults[0]['confidence'] = 0.92;
        baseResults[0]['name'] = 'Puceron vert';
      } else if (fileName.contains('white') || fileName.contains('blanc')) {
        baseResults[0]['confidence'] = 0.88;
        baseResults[0]['name'] = 'Mouche blanche';
      } else if (fileSize > 2000000) {
        baseResults[0]['confidence'] = 0.85;
        baseResults[0]['name'] = 'Chenille légionnaire';
        baseResults[0]['severity'] = 'Critique';
      }

      // Ajouter metadata
      for (var result in baseResults) {
        result['timestamp'] = DateTime.now().toIso8601String();
        result['model_version'] = 'MobileNet v1.0 (Simulé)';
        result['processing_time'] = '${500 + _random.nextInt(800)}ms';
      }

      return baseResults
          .where((r) =>
              (r['confidence'] as double?) != null &&
              (r['confidence'] as double) > 0.1)
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur simulation: $e');
      return [];
    }
  }

  Future<List<String>> _loadLabels() async {
    try {
      // Simuler le chargement depuis assets ou API
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        'Puceron vert',
        'Chenille légionnaire',
        'Doryphore',
        'Thrips',
        'Mouche blanche',
        'Cochenille',
        'Criquet migrateur',
        'Pyrale du maïs',
        'Altise',
        'Noctuelle',
        'Cicadelle',
        'Hanneton',
        'Taupin',
        'Courtilière',
        'Tipule',
        'Pucerons noirs',
        'Acariens',
        'Mineuses',
        'Chenilles processionnaires',
        'Carpocapse',
      ];
    } catch (e) {
      debugPrint('❌ Erreur chargement labels: $e');
      return ['Insecte non identifié'];
    }
  }

  // Méthode pour nettoyer le cache
  Future<void> clearCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/models');

      if (await modelsDir.exists()) {
        await modelsDir.delete(recursive: true);
        debugPrint('🗑️ Cache modèles nettoyé');
      }
    } catch (e) {
      debugPrint('❌ Erreur nettoyage cache: $e');
    }
  }

  // Informations sur le modèle
  Map<String, dynamic> getModelInfo() {
    return {
      'name': 'MobileNet v1.0 (Model Zoo)',
      'version': '1.0',
      'type': 'Classification',
      'classes': _labels.length,
      'ready': _isModelReady,
      'loading': _isLoading,
      'error': _error,
      'source': 'TensorFlow Model Zoo (Simulé)',
      'input_size': [224, 224, 3],
      'output_size': _labels.length,
    };
  }

  @override
  void dispose() {
    _dio.close();
    _isModelReady = false;
    _isLoading = false;
    _error = null;
    debugPrint('🗑️ Model Zoo Service libéré');
    super.dispose();
  }
}
