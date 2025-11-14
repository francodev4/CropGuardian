import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Simple coordinate class for field boundaries
class FieldCoordinate {
  final double latitude;
  final double longitude;

  FieldCoordinate({
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  // 📍 Obtenir la position actuelle
  Future<Position?> getCurrentLocation() async {
    try {
      // Vérifier les permissions
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw LocationException('Permission de localisation refusée');
      }

      // Vérifier si la localisation est activée
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        throw LocationException('Service de localisation désactivé');
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('❌ Erreur lors de l\'obtention de la localisation: $e');
      return null;
    }
  }

  // 🔄 Écouter les changements de position
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mise à jour tous les 10 mètres
      ),
    );
  }

  // 📏 Calculer la distance entre deux points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // 🎯 Vérifier si un point est dans un rayon donné
  bool isWithinRadius(
    Position center,
    Position target,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      center.latitude,
      center.longitude,
      target.latitude,
      target.longitude,
    );
    return distance <= radiusInMeters;
  }

  // 🗺️ Vérifier si un point est dans un polygone (champ)
  bool isPointInField(
    double latitude,
    double longitude,
    List<FieldCoordinate> fieldCoordinates,
  ) {
    if (fieldCoordinates.length < 3) return false;

    // Algorithme ray-casting pour déterminer si le point est dans le polygone
    int intersections = 0;
    int vertexCount = fieldCoordinates.length;

    for (int i = 0; i < vertexCount; i++) {
      int j = (i + 1) % vertexCount;

      double xi = fieldCoordinates[i].latitude;
      double yi = fieldCoordinates[i].longitude;
      double xj = fieldCoordinates[j].latitude;
      double yj = fieldCoordinates[j].longitude;

      if (((yi > longitude) != (yj > longitude)) &&
          (latitude < (xj - xi) * (longitude - yi) / (yj - yi) + xi)) {
        intersections++;
      }
    }

    return intersections % 2 == 1;
  }

  // 🔒 Vérifier et demander les permissions
  Future<bool> _checkLocationPermission() async {
    var permission = await Permission.location.status;

    if (permission.isDenied) {
      permission = await Permission.location.request();
    }

    if (permission.isPermanentlyDenied) {
      throw LocationException(
        'Permission de localisation définitivement refusée. '
        'Veuillez l\'activer dans les paramètres.',
      );
    }

    return permission.isGranted;
  }

  // 🧭 Obtenir l'adresse approximative (nécessite un service de geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Pour une implémentation simple, on retourne les coordonnées formatées
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('❌ Erreur lors de l\'obtention de l\'adresse: $e');
      return null;
    }
  }

  // 📊 Statistiques de localisation
  Future<LocationStats> getLocationStats(List<Position> positions) async {
    if (positions.isEmpty) {
      return LocationStats(
        totalDistance: 0,
        averageAccuracy: 0,
        centerPoint: null,
      );
    }

    double totalDistance = 0;
    double totalAccuracy = 0;

    // Calculer la distance totale parcourue
    for (int i = 1; i < positions.length; i++) {
      totalDistance += calculateDistance(
        positions[i - 1].latitude,
        positions[i - 1].longitude,
        positions[i].latitude,
        positions[i].longitude,
      );
    }

    // Calculer la précision moyenne
    for (var position in positions) {
      totalAccuracy += position.accuracy;
    }

    // Calculer le point central
    double avgLat = positions.map((p) => p.latitude).reduce((a, b) => a + b) /
        positions.length;
    double avgLon = positions.map((p) => p.longitude).reduce((a, b) => a + b) /
        positions.length;

    return LocationStats(
      totalDistance: totalDistance,
      averageAccuracy: totalAccuracy / positions.length,
      centerPoint: Position(
        latitude: avgLat,
        longitude: avgLon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );
  }
}

// 📊 Classe pour les statistiques de localisation
class LocationStats {
  final double totalDistance;
  final double averageAccuracy;
  final Position? centerPoint;

  LocationStats({
    required this.totalDistance,
    required this.averageAccuracy,
    this.centerPoint,
  });
}

// ⚠️ Exception personnalisée pour la localisation
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}
