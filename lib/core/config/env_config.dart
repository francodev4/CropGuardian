import 'package:flutter_dotenv/flutter_dotenv.dart';

/// EnvConfig centralise le chargement et l'accès aux variables d'environnement.
class EnvConfig {
  /// Charge le fichier `.env` si présent. Appeler dès le démarrage (main).
  static Future<void> load() async {
    try {
      await dotenv.load();
    } catch (_) {
      // ignore: avoid_print
      print('No .env file found or failed to load — proceeding with environment variables');
    }
  }

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static String get huggingFaceApiKey => dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isHuggingFaceConfigured => huggingFaceApiKey.isNotEmpty;

  static String get configInstructions => '''
Pour configurer vos tokens API localement:

1) Créez un fichier `.env` à la racine du projet avec des clés comme:
   GEMINI_API_KEY=your_gemini_key
   OPENWEATHER_API_KEY=your_openweather_key
   HUGGINGFACE_API_KEY=your_hf_token
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key

2) Ce fichier est ignoré par Git (vérifiez `.gitignore`).

3) Alternativement, exportez les variables d'environnement ou utilisez --dart-define.
''';
}
