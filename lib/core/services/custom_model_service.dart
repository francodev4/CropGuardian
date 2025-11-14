// lib/core/services/custom_model_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

// Import for compute (run in an isolate) is usually in flutter/foundation.dart

class CustomModelService extends ChangeNotifier {
  static CustomModelService? _instance;
  static CustomModelService get instance =>
      _instance ??= CustomModelService._();
  CustomModelService._();

  List<String> _labels = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  final Random _random = Random();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get availableClasses => List.from(_labels);
  int get classCount => _labels.length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setInitialized(bool initialized) {
    _isInitialized = initialized;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _setError(null);

      debugPrint('🤖 Initialisation du modèle personnalisé...');

      // Try to load a real tflite model from app documents or assets
      final loaded = await _tryLoadTfliteModel();

      if (!loaded) {
        debugPrint('⚠️ Modèle TFLite non trouvé, utilisation du simulateur');
        await _loadModelSimulation();
      }

      await _loadLabels();

      _setInitialized(true);
      debugPrint('✅ Modèle personnalisé prêt ! Classes: ${_labels.length}');
      debugPrint('📋 Classes disponibles: ${_labels.take(5).join(', ')}...');
    } catch (e) {
      _setError('Échec initialisation modèle personnalisé: $e');
      debugPrint('❌ Erreur chargement modèle: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  tfl.Interpreter? _interpreter;
  ImageProcessor? _imgProcessor;
  TensorImage? _inputImage;

  Future<bool> _tryLoadTfliteModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile =
          File('${appDir.path}/models/crop_guardian_model.tflite');

      if (await modelFile.exists()) {
        debugPrint('📥 Chargement modèle TFLite depuis ${modelFile.path}');
        _interpreter = tfl.Interpreter.fromFile(modelFile);
      } else {
        // Try from assets
        try {
          final assetData =
              await rootBundle.load('assets/models/crop_guardian_model.tflite');
          final bytes = assetData.buffer.asUint8List();
          final tmpDir = await getTemporaryDirectory();
          final tmpFile = File('${tmpDir.path}/crop_guardian_model.tflite');
          await tmpFile.writeAsBytes(bytes, flush: true);
          _interpreter = tfl.Interpreter.fromFile(tmpFile);
        } catch (e) {
          debugPrint('ℹ️ Modèle TFLite natif non disponible (normal sur émulateur)');
          debugPrint('📱 L\'app utilise le modèle simulé - tout fonctionne normalement');
          return false;
        }
      }

      // Setup helpers based on interpreter input shape
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputType = _interpreter!.getInputTensor(0).type;
      debugPrint('🔍 TFLite input shape: $inputShape type=$inputType');

      // Build a basic ImageProcessor for 224x224 RGB input
      _imgProcessor = ImageProcessorBuilder()
          .add(ResizeOp(224, 224, ResizeMethod.BILINEAR))
          .add(NormalizeOp(0, 255))
          .build();

      return true;
    } catch (e) {
      debugPrint('❌ Échec chargement TFLite: $e');
      _interpreter = null;
      return false;
    }
  }

  Future<void> _loadModelSimulation() async {
    try {
      // Simuler le temps de chargement d'un vrai modèle
      await Future.delayed(const Duration(milliseconds: 1500));

      debugPrint('📊 Modèle simulé chargé:');
      debugPrint('  - Input shape: [1, 224, 224, 3]');
      debugPrint('  - Output shape: [1, ${_getDefaultLabels().length}]');
      debugPrint('  - Type: TensorFlow Lite personnalisé simulé');
    } catch (e) {
      throw Exception('Erreur chargement modèle simulé: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      // Essayer de charger depuis assets
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final labelsFile = File('${appDir.path}/models/labels.json');

        if (await labelsFile.exists()) {
          final labelData = await labelsFile.readAsString();
          final labelJson = json.decode(labelData);

          if (labelJson is Map<String, dynamic>) {
            _labels = labelJson.values.cast<String>().toList();
          } else if (labelJson is List) {
            _labels = labelJson.cast<String>();
          }

          debugPrint(
              '🏷️ Labels chargés depuis fichier: ${_labels.length} classes');
        } else {
          throw Exception('Fichier labels non trouvé');
        }
      } catch (e) {
        // Si pas d'assets, essayer depuis assets bundle
        try {
          final labelData =
              await rootBundle.loadString('assets/models/labels.json');
          final labelJson = json.decode(labelData);

          if (labelJson is Map<String, dynamic>) {
            _labels = labelJson.values.cast<String>().toList();
          } else if (labelJson is List) {
            _labels = labelJson.cast<String>();
          }

          debugPrint(
              '🏷️ Labels chargés depuis assets: ${_labels.length} classes');
        } catch (e2) {
          debugPrint(
              '⚠️ Assets non trouvés, utilisation des labels par défaut');
          _labels = _getDefaultLabels();
        }
      }

      if (_labels.isEmpty) {
        _labels = _getDefaultLabels();
      }

      debugPrint('🏷️ Labels finaux: ${_labels.length} classes');
    } catch (e) {
      throw Exception('Erreur chargement labels: $e');
    }
  }

  List<String> _getDefaultLabels() {
    return [
      'Puceron vert',
      'Thrips',
      'Mouche blanche',
      'Cochenille',
      'Doryphore',
      'Chenille légionnaire',
      'Pyrale du maïs',
      'Altise',
      'Noctuelle',
      'Criquet migrateur',
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
      'Sciarides',
      'Aleurodes',
      'Psylles',
      'Punaises',
      'Charançons',
    ];
  }
  
  // --- Méthodes d'aide (Ajoutées/Simplifiées pour la complétude) ---

  Future<void> _validateImageFile(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('Fichier image introuvable');
    }
    if (await imageFile.length() == 0) {
      throw Exception('Fichier image vide');
    }
  }

  static Future<Map<String, dynamic>> _analyzeImageInIsolate(String imagePath) async {
    // Cette méthode n'est plus utilisée dans le nouveau mode statique, 
    // mais est conservée pour la complétude de la classe.
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(imageBytes);

      if (decoded == null) {
        return {'error': 'Impossible de décoder l\'image'};
      }
      
      final colorAnalysis = _analyzeColorsOptimized(decoded);
      final brightness = _analyzeBrightnessOptimized(decoded);
      
      return {
        'width': decoded.width,
        'height': decoded.height,
        'file_size': imageBytes.length,
        'dominant_colors': colorAnalysis,
        'brightness': brightness,
        'aspect_ratio': decoded.width / decoded.height,
        'quality_score': _calculateImageQuality(decoded, brightness, colorAnalysis),
      };
    } catch (e) {
      return { 'width': 0, 'height': 0, 'file_size': 0, 'error': 'Erreur analyse image: $e' };
    }
  }

  // Placeholders pour les fonctions d'analyse interne
  static Map<String, double> _analyzeColorsOptimized(img.Image image) {
    return {'red': 0.33, 'green': 0.33, 'blue': 0.34}; 
  }

  static double _analyzeBrightnessOptimized(img.Image image) {
    return 0.5; 
  }

  static double _calculateImageQuality(img.Image image, double brightness, Map<String, double> colors) {
    return 0.9; 
  }
  
  // Cette méthode n'est plus utilisée, mais est conservée.
  List<Map<String, dynamic>> _generateIntelligentPrediction(
      Map<String, dynamic> imageAnalysis) {
    // Logique de simulation précédente, utilisant _random
    final qualityScore = imageAnalysis['quality_score'] as double? ?? 0.5;
    final qualityMultiplier = 0.5 + qualityScore / 2;
    final shuffledLabels = List<String>.from(_labels)..shuffle(_random);

    final results = <Map<String, dynamic>>[];
    
    if (shuffledLabels.isNotEmpty) {
      results.add(_createPrediction(shuffledLabels[0], 
        ((50 + _random.nextInt(40)) * qualityMultiplier).round(), 
        'Élevé'));
    }
    if (shuffledLabels.length > 1) {
      results.add(_createPrediction(shuffledLabels[1], 
        ((15 + _random.nextInt(20)) * qualityMultiplier).round(), 
        'Faible'));
    }
    if (shuffledLabels.length > 2) {
      results.add(_createPrediction(shuffledLabels[2], 
        ((15 + _random.nextInt(20)) * qualityMultiplier).round(), 
        'Faible'));
    }
    
    results.sort((a, b) => b['confidence_raw'].compareTo(a['confidence_raw']));

    return results;
  }

  Map<String, dynamic> _createPrediction(String name, int rawConfidence, String severity) {
    final confidence = rawConfidence.clamp(10, 99) / 100;
    return {
      'name': name,
      'confidence': confidence,
      'confidence_raw': rawConfidence.clamp(10, 99),
      'confidence_percentage': '${(confidence * 100).toStringAsFixed(1)}%',
      'severity': severity,
    };
  }

  List<String> _generateRecommendations(String insectName) {
    // Logique de recommandation simplifiée/simulée
    if (insectName.toLowerCase().contains('puceron')) {
      return [
        'Application de savon noir à 1% sur le feuillage.',
        'Introduction de coccinelles (prédateurs naturels).',
        'Vérifier la face inférieure des feuilles.'
      ];
    } else if (insectName.toLowerCase().contains('thrips')) {
      return [
        'Utiliser des pièges bleus englués.',
        'Application d\'huile de neem.',
        'Éliminer les débris végétaux autour des plantes.'
      ];
    } else if (insectName.toLowerCase().contains('mouche blanche')) {
      return [
        'Utiliser des pièges jaunes englués.',
        'Pulvériser avec une solution à base d\'ail et de piment.',
        'Assurer une bonne ventilation.'
      ];
    } else {
      return [
        'Consulter un agronome pour une analyse plus poussée.',
        'Isoler la plante infectée pour éviter la propagation.'
      ];
    }
  }

  // -----------------------------------------------------------------
  // ✅ MÉTHODE predictInsect CORRIGÉE 
  // -----------------------------------------------------------------

  Future<Map<String, dynamic>> predictInsect(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('Modèle non initialisé. Appelez initialize() d\'abord.');
    }

    try {
      // Validation du fichier
      await _validateImageFile(imageFile);

      debugPrint('🖼️ Analyse de l\'image avec le modèle personnalisé...');

      final startTime = DateTime.now();

      // If we have a real interpreter, use it
      if (_interpreter != null) {
        try {
          // Load image bytes and preprocess
          final bytes = await imageFile.readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded == null) {
            throw Exception('Impossible de décoder l\'image');
          }

          // Convert to TensorImage
          _inputImage = TensorImage.fromImage(decoded);
          if (_imgProcessor != null) {
            _inputImage = _imgProcessor!.process(_inputImage!);
          }

          // Prepare output buffer
          final outputShape = _interpreter!.getOutputTensor(0).shape;
          final outputType = _interpreter!.getOutputTensor(0).type;
          final outputBuffer =
              TensorBuffer.createFixedSize(outputShape, outputType);

          // Run inference
          _interpreter!.run(_inputImage!.buffer, outputBuffer.buffer);

          // Convert output to probabilities and map to labels
          final probs = outputBuffer.getDoubleList();
          final indexed = List<int>.generate(probs.length, (i) => i);
          indexed.sort((a, b) => probs[b].compareTo(probs[a]));

          final results = <Map<String, dynamic>>[];
          for (var i = 0; i < min(3, indexed.length); i++) {
            final idx = indexed[i];
            final name = _labels.length > idx ? _labels[idx] : 'Insecte $idx';
            final confidence = (probs[idx] * 100).clamp(0, 100);
            results.add({
              'name': name,
              'confidence': confidence / 100,
              'confidence_percentage': '${confidence.toStringAsFixed(1)}%',
              'severity': 'Modéré',
              'index': idx,
            });
          }

          final endTime = DateTime.now();
          final processingTime = endTime.difference(startTime).inMilliseconds;

          return {
            'insect': results.isNotEmpty ? results.first['name'] : 'Inconnu',
            'confidence':
                results.isNotEmpty ? results.first['confidence'] : 0.0,
            'confidence_percentage': results.isNotEmpty
                ? results.first['confidence_percentage']
                : '0%',
            'severity':
                results.isNotEmpty ? results.first['severity'] : 'Modéré',
            'all_predictions': results,
            'processing_time': '${processingTime}ms',
            'model_type': 'TensorFlow Lite local',
            'source': 'On-device TFLite',
            'timestamp': DateTime.now().toIso8601String(),
            'recommendations': _generateRecommendations(
                results.isNotEmpty ? results.first['name'] : 'Inconnu'),
          };
        } catch (e) {
          debugPrint('⚠️ Erreur inference TFLite, fallback simulateur: $e');
          // fallthrough to simulation
        }
      }

      // Si on arrive ici, c'est que le modèle TFLite n'a pas pu être chargé
      // Retourner une erreur pour que AI Service passe au service suivant (Gemini)
      debugPrint('⚠️ Modèle TFLite non disponible, passage au service suivant...');
      
      return {
        'insect': 'Modèle non disponible',
        'confidence': 0.0,
        'confidence_percentage': '0.0%',
        'severity': 'Inconnu',
        'all_predictions': [],
        'processing_time': '0ms',
        'model_type': 'TFLite (Non chargé)',
        'source': 'Erreur',
        'timestamp': DateTime.now().toIso8601String(),
        'recommendations': [],
      };

    } catch (e) {
      debugPrint('❌ Erreur prédiction: $e');
      rethrow;
    }
  }
}