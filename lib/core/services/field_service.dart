// lib/core/services/field_service.dart
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/field.dart';
import '../models/infestation.dart';

class FieldService {
  static FieldService? _instance;
  static FieldService get instance => _instance ??= FieldService._();
  
  FieldService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Gestion des champs
  Future<List<Field>> getUserFields(String userId) async {
    try {
      final response = await _supabase
          .from('fields')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Field.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur getUserFields: $e');
      return [];
    }
  }

  Future<Field> createField(Field field) async {
    try {
      final response = await _supabase
          .from('fields')
          .insert(field.toJson())
          .select()
          .single();

      return Field.fromJson(response);
    } catch (e) {
      print('Erreur createField: $e');
      rethrow;
    }
  }

  Future<void> updateField(Field field) async {
    try {
      await _supabase
          .from('fields')
          .update(field.toJson())
          .eq('id', field.id);
    } catch (e) {
      print('Erreur updateField: $e');
      rethrow;
    }
  }

  Future<void> deleteField(String fieldId) async {
    try {
      await _supabase
          .from('fields')
          .delete()
          .eq('id', fieldId);
    } catch (e) {
      print('Erreur deleteField: $e');
      rethrow;
    }
  }

  // Gestion des infestations
  Future<List<Infestation>> getFieldInfestations(String fieldId) async {
    try {
      final response = await _supabase
          .from('infestations')
          .select()
          .eq('field_id', fieldId)
          .order('detected_at', ascending: false);

      return (response as List)
          .map((json) => Infestation.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur getFieldInfestations: $e');
      return [];
    }
  }

  Future<List<Infestation>> getActiveInfestations(String userId) async {
    try {
      final response = await _supabase
          .from('infestations')
          .select('''
            *,
            fields!inner (
              user_id
            )
          ''')
          .eq('fields.user_id', userId)
          .eq('status', 'active')
          .order('detected_at', ascending: false);

      return (response as List)
          .map((json) => Infestation.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur getActiveInfestations: $e');
      return [];
    }
  }

  Future<Infestation> createInfestation(Infestation infestation) async {
    try {
      final response = await _supabase
          .from('infestations')
          .insert(infestation.toJson())
          .select()
          .single();

      return Infestation.fromJson(response);
    } catch (e) {
      print('Erreur createInfestation: $e');
      rethrow;
    }
  }

  Future<void> updateInfestationStatus(String infestationId, String status, {String? notes}) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        if (notes != null) 'notes': notes,
      };

      if (status == 'treated') {
        updateData['treated_at'] = DateTime.now().toIso8601String();
      } else if (status == 'resolved') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('infestations')
          .update(updateData)
          .eq('id', infestationId);
    } catch (e) {
      print('Erreur updateInfestationStatus: $e');
      rethrow;
    }
  }

  // ✅ CORRIGÉ: Statistiques d'infestation sans FetchOptions
  Future<Map<String, dynamic>> getInfestationStats(String userId) async {
    try {
      // Obtenir tous les champs de l'utilisateur
      final fields = await getUserFields(userId);
      final fieldIds = fields.map((f) => f.id).toList();

      if (fieldIds.isEmpty) {
        return {
          'active_count': 0,
          'treated_count': 0,
          'resolved_count': 0,
          'total_fields': 0,
        };
      }

      // ✅ CORRIGÉ: Compter manuellement au lieu d'utiliser FetchOptions
      final activeInfestations = await _supabase
          .from('infestations')
          .select('id')
          .inFilter('field_id', fieldIds)
          .eq('status', 'active');

      final treatedInfestations = await _supabase
          .from('infestations')
          .select('id')
          .inFilter('field_id', fieldIds)
          .eq('status', 'treated');

      final resolvedInfestations = await _supabase
          .from('infestations')
          .select('id')
          .inFilter('field_id', fieldIds)
          .eq('status', 'resolved');

      return {
        'active_count': (activeInfestations as List).length,
        'treated_count': (treatedInfestations as List).length,
        'resolved_count': (resolvedInfestations as List).length,
        'total_fields': fields.length,
      };
    } catch (e) {
      print('Erreur getInfestationStats: $e');
      return {
        'active_count': 0,
        'treated_count': 0,
        'resolved_count': 0,
        'total_fields': 0,
      };
    }
  }

  // Géolocalisation - Obtenir la position actuelle
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Les services de localisation sont désactivés');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permissions de localisation refusées');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permissions de localisation refusées définitivement');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erreur géolocalisation: $e');
      return null;
    }
  }

  // Calculer la distance entre deux points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Trouver le champ le plus proche
  Future<Field?> findNearestField(String userId, double latitude, double longitude) async {
    try {
      final fields = await getUserFields(userId);
      if (fields.isEmpty) return null;

      Field? nearestField;
      double minDistance = double.infinity;

      for (final field in fields) {
        final distance = calculateDistance(
          latitude, longitude, 
          field.latitude, field.longitude
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestField = field;
        }
      }

      return minDistance <= 1000 ? nearestField : null;
    } catch (e) {
      print('Erreur findNearestField: $e');
      return null;
    }
  }

  // Méthodes utilitaires
  double calculateDistanceGeolocator(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  List<String> getAvailableCropTypes() {
    return [
      'Tomates',
      'Maïs',
      'Blé',
      'Pommes de terre',
      'Carottes',
      'Salade',
      'Concombres',
      'Poivrons',
      'Aubergines',
      'Courgettes',
      'Haricots',
      'Petits pois',
      'Radis',
      'Épinards',
      'Autres',
    ];
  }

  bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  String generateUniqueId() {
    // ✅ Retourner une chaîne vide pour laisser Supabase générer l'UUID
    // Supabase utilise gen_random_uuid() automatiquement
    return '';
  }

  // ✅ AJOUTÉ: Méthode manquante pour la compatibilité avec les anciens tests
  void addTestData(String userId) {
    print('⚠️ addTestData() appelée mais ignorée - utilisez les données de la base de données');
  }
}