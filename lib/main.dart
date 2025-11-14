import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/weather_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/ai_service.dart';

// Variable globale pour les caméras
List<CameraDescription> globalCameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis `.env` si présent
  await EnvConfig.load();

  // Configuration de l'orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Configuration de la status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 🚀 Initialisation Supabase avec timeout et gestion d'erreur robuste
  try {
    await SupabaseConfig.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ Timeout Supabase - L\'app continuera sans backend');
        throw Exception('Supabase timeout');
      },
    );
    debugPrint('✅ Supabase initialisé');
  } catch (e) {
    debugPrint(
        '⚠️ Erreur Supabase (l\'app fonctionnera en mode hors ligne): $e');
    // L'app continue même si Supabase échoue
  }

  // 📸 Initialisation des caméras (non-bloquant)
  try {
    globalCameras = await availableCameras().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('⚠️ Timeout caméra');
        return [];
      },
    );
    debugPrint('✅ ${globalCameras.length} caméra(s) détectée(s)');
  } catch (e) {
    globalCameras = [];
    debugPrint('⚠️ Erreur initialisation caméras: $e');
  }

  // 🤖 Initialisation de l'IA en arrière-plan (NON-BLOQUANT)
  // L'app démarre immédiatement, l'IA se charge en parallèle
  _initializeAIInBackground();

  // 🚀 Lancer l'app immédiatement
  runApp(const CropGuardianApp());
}

// 🤖 Initialisation IA en arrière-plan pour ne pas bloquer le démarrage
void _initializeAIInBackground() async {
  final aiService = AIService();
  try {
    debugPrint('🔄 Initialisation IA en arrière-plan...');
    await aiService.initialize().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('⚠️ Timeout IA - Continuera en mode basique');
        throw Exception('AI initialization timeout');
      },
    );
    debugPrint('✅ IA initialisée avec succès !');
  } catch (e) {
    debugPrint(
        '⚠️ Erreur initialisation IA (l\'app fonctionnera sans IA avancée): $e');
    // L'app continue même si l'IA échoue
  }
}

class CropGuardianApp extends StatelessWidget {
  const CropGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return MaterialApp.router(
            title: 'Crop Guardian',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
