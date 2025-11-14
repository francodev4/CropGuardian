// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Charger le thème sauvegardé
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print('Erreur chargement thème: $e');
    }
  }

  /// Changer le thème (toggle)
  Future<void> toggleTheme() async {
    try {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);

      notifyListeners();
    } catch (e) {
      print('Erreur changement thème: $e');
    }
  }

  /// Définir un thème spécifique
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);

      notifyListeners();
    } catch (e) {
      print('Erreur définition thème: $e');
    }
  }

  /// Suivre le thème système
  Future<void> useSystemTheme() async {
    try {
      _themeMode = ThemeMode.system;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isDarkMode'); // Supprimer la préférence

      notifyListeners();
    } catch (e) {
      print('Erreur thème système: $e');
    }
  }
}
