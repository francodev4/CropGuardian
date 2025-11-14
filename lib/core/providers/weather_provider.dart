// lib/core/providers/weather_provider.dart

import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;

  WeatherProvider({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecasts = [];
  bool _isLoading = false;
  String? _error;

  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecasts => _forecasts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge la météo actuelle et les prévisions
  Future<void> loadWeatherData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charger en parallèle la météo actuelle et les prévisions
      final results = await Future.wait([
        _weatherService.getCurrentWeatherForCurrentLocation(),
        _weatherService.getForecastForCurrentLocation(),
      ]);

      _currentWeather = results[0] as WeatherModel;
      _forecasts = results[1] as List<ForecastModel>;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentWeather = null;
      _forecasts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchit les données météo
  Future<void> refresh() async {
    await loadWeatherData();
  }
}
