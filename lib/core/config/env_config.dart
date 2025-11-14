// lib/core/config/env_config.dart
class EnvConfig {
  // 🔑 Configuration des tokens d'API
  // IMPORTANT: Ne jamais committer les vraies valeurs !

  static const String _huggingFaceToken = String.fromEnvironment(
    'HUGGING_FACE_TOKEN',
    defaultValue: '', // Token vide par défaut
  );

  // 📖 Getters pour accéder aux tokens de manière sécurisée
  static String get huggingFaceToken {
    if (_huggingFaceToken.isEmpty) {
      throw Exception('Token Hugging Face manquant. '
          'Veuillez configurer HUGGING_FACE_TOKEN dans vos variables d\'environnement.');
    }
    return _huggingFaceToken;
  }

  // 🧪 Vérifier si les tokens sont configurés
  static bool get isHuggingFaceConfigured => _huggingFaceToken.isNotEmpty;

  // 📝 Instructions pour configurer les tokens
  static String get configInstructions => '''
Pour configurer vos tokens API:

1. Créez un fichier .env à la racine du projet:
   HUGGING_FACE_TOKEN=your_token_here

2. Ou définissez les variables d'environnement:
   export HUGGING_FACE_TOKEN=your_token_here

3. Ou utilisez --dart-define lors de la compilation:
   flutter run --dart-define=HUGGING_FACE_TOKEN=your_token_here
''';
}
