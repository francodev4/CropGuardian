// lib/core/services/image_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  static final ImageService instance = ImageService._internal();
  factory ImageService() => instance;
  ImageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtenir l'URL publique complète d'une image
  /// Supporte plusieurs formats:
  /// - URL complète (https://...)
  /// - Chemin Supabase Storage (insects/image.jpg)
  /// - Nom de fichier simple (image.jpg)
  String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    // Si c'est déjà une URL complète, la retourner
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Si c'est un chemin Supabase Storage
    try {
      // Retirer le slash initial s'il existe
      final cleanPath =
          imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

      // Construire l'URL publique depuis le bucket 'insects'
  final dynamic result = _supabase.storage.from('insects').getPublicUrl(cleanPath);

      // Selon la version du client, getPublicUrl peut retourner une String
      // ou un objet Map contenant la clé 'publicUrl'.
      if (result is String) return result;

      if (result is Map<String, dynamic>) {
        if (result.containsKey('publicUrl') && result['publicUrl'] is String) {
          return result['publicUrl'] as String;
        }

        if (result.containsKey('data') && result['data'] is Map<String, dynamic>) {
          final data = result['data'] as Map<String, dynamic>;
          if (data.containsKey('publicUrl') && data['publicUrl'] is String) {
            return data['publicUrl'] as String;
          }
        }
      }

      // Fallback: toString() si rien d'autre
      return result.toString();
    } catch (e) {
      print('⚠️ Erreur génération URL image: $e');
      return null;
    }
  }

  /// Obtenir l'URL avec timestamp pour forcer le rechargement
  String? getImageUrlWithCache(String? imagePath) {
    final url = getImageUrl(imagePath);
    if (url == null) return null;

    // Ajouter timestamp pour éviter le cache
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Vérifier si l'URL d'image est valide
  bool isValidImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    return imagePath.startsWith('http://') ||
        imagePath.startsWith('https://') ||
        imagePath.contains('/') ||
        imagePath.endsWith('.jpg') ||
        imagePath.endsWith('.jpeg') ||
        imagePath.endsWith('.png') ||
        imagePath.endsWith('.webp');
  }
}
