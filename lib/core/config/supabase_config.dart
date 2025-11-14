// lib/core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // 🔐 Configuration Supabase
  // Remplacez par vos vraies valeurs
  static const String url = 'https://jwvmdptqgojezyahayja.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp3dm1kcHRxZ29qZXp5YWhheWphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MzAzMzUsImV4cCI6MjA3MzUwNjMzNX0.dx1ShTKBFCeqUS0eWPXV0W4vZ1sge4QSl3wYKcLXAfY';

  // 🚀 Configuration de performance
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const bool enableLogging = true; // false en production

  // 📱 Configuration de l'app
  static const String appName = 'CropGuardian';
  static const String version = '1.0.0';

  // 🔧 Endpoints API (si vous en avez)
  static const String apiVersion = 'v1';

  // 📊 Configuration des tables
  static const String insectsTable = 'insects';
  static const String traitementsTable = 'traitements';
  static const String preventionsTable = 'preventions';
  static const String userProfilesTable = 'user_profiles';
  static const String infestationsTable = 'infestations';
  static const String traitementsAppliquesTable = 'traitements_appliques';
  static const String keywordsTable = 'keywords';

  // 🔍 Fonctions Supabase (RPC)
  static const String searchInsectsByDescriptionFunction =
      'search_insects_by_description';
  static const String getUserStatsFunction = 'get_user_stats';

  // 📋 Colonnes importantes (pour les requêtes)
  // See Columns class below

  // 📋 Valeurs par défaut et constantes
  // See Defaults class below

  // 🔍 Requêtes SQL communes
  // See Queries class below

  // ⚙️ Configuration IA/ML
  // See AI class below

  // 🎨 Configuration UI
  // See UI class below

  // 🔔 Configuration notifications
  // See Notifications class below

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
