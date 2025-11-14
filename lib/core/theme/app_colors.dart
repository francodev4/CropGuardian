// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales du design
  static const Color primary = Color(0xFF6B8E3D);
  static const Color primaryGreen = Color(0xFF6B8E3D);
  static const Color secondary = Color(0xFF8FBC8F);
  static const Color accent = Color(0xFFFFD700);

  // Fond sombre moderne
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2D2D2D);
  static const Color cardBackground = Color(0xFF3A3A3A);

  // Texte optimisé
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // Système
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Bordures et séparateurs
  static const Color border = Color(0xFF505050);

  // Gradients modernes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7CB342), Color(0xFF1B5E20)],
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF238636), Color(0xFF1B5E20)],
  );

  static const LinearGradient cardGradientOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFE65100)],
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F6FEB), Color(0xFF0969DA)],
  );

  static const LinearGradient cardGradientRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDA3633), Color(0xFFB91C1C)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF21262D), Color(0xFF30363D), Color(0xFF21262D)],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // Méthodes utilitaires
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.95) return success;
    if (confidence >= 0.90) return success;
    if (confidence >= 0.80) return const Color(0xFF7CB342);
    if (confidence >= 0.70) return warning;
    if (confidence >= 0.60) return const Color(0xFFFF9800);
    return error;
  }

  static Color getDangerLevel(int level) {
    switch (level) {
      case 5:
        return const Color(0xFFF85149);
      case 4:
        return error;
      case 3:
        return const Color(0xFFFFB300);
      case 2:
        return warning;
      case 1:
        return success;
      default:
        return textSecondary;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chenilles':
        return const Color(0xFF7CB342);
      case 'pucerons':
        return const Color(0xFFFF9800);
      case 'criquets':
        return const Color(0xFFE53935);
      case 'charançons':
        return const Color(0xFF2196F3);
      case 'coléoptères':
        return const Color(0xFF8BC34A);
      case 'papillons':
        return const Color(0xFF9C27B0);
      default:
        return textSecondary;
    }
  }
}
