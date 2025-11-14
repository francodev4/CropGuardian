// lib/core/services/weather_service.dart

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio;

  // Clé API OpenWeatherMap
  // IMPORTANT: Ne laissez PAS la clé en dur dans le code. Mettez votre clé dans `.env`.
  // Exemple `.env`:
  // OPENWEATHER_API_KEY=your-real-key
  // Ici on utilise un placeholder vide pour éviter d'exposer la clé dans le repo.
  static const String _apiKey = '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  /// Récupère la météo actuelle pour une position géographique
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric', // Celsius
          'lang': 'fr', // Descriptions en français
        },
      );

      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les prévisions sur 5 jours (toutes les 3 heures)
  Future<List<ForecastModel>> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'fr',
        },
      );

      final List<dynamic> list = response.data['list'];

      // Filtrer pour obtenir une prévision par jour (midi)
      final Map<String, ForecastModel> dailyForecasts = {};

      for (var item in list) {
        final forecast = ForecastModel.fromJson(item);
        final dateKey =
            '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';

        // Garder la prévision de midi (12h) pour chaque jour
        if (forecast.dateTime.hour >= 11 && forecast.dateTime.hour <= 13) {
          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = forecast;
          }
        }
      }

      return dailyForecasts.values.take(7).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la position actuelle de l'utilisateur
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé');
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation refusée définitivement');
    }

    // Obtenir la position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Récupère la météo actuelle en utilisant la localisation de l'appareil
  Future<WeatherModel> getCurrentWeatherForCurrentLocation() async {
    final position = await getCurrentLocation();
    return getCurrentWeather(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Récupère les prévisions en utilisant la localisation de l'appareil
  Future<List<ForecastModel>> getForecastForCurrentLocation() async {
    final position = await getCurrentLocation();
    return getForecast(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          return 'Clé API invalide. Veuillez configurer votre clé OpenWeatherMap.';
        case 404:
          return 'Données météo non disponibles pour cette localisation.';
        case 429:
          return 'Limite d\'appels API dépassée. Réessayez plus tard.';
        default:
          return 'Erreur lors de la récupération des données météo.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Délai de réception dépassé. Réessayez.';
    } else {
      return 'Erreur réseau. Vérifiez votre connexion internet.';
    }
  }
}
