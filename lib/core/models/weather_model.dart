// lib/core/models/weather_model.dart

class WeatherModel {
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int cloudiness;
  final double? rain; // mm dans les dernières heures
  final String cityName;
  final DateTime dateTime;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.cloudiness,
    this.rain,
    required this.cityName,
    required this.dateTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cloudiness: json['clouds']['all'] ?? 0,
      rain: json['rain'] != null
          ? (json['rain']['1h'] as num?)?.toDouble()
          : null,
      cityName: json['name'] ?? 'Inconnue',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }

  // Risque de pluie en pourcentage
  int get rainProbability {
    if (rain != null && rain! > 0) return 100;
    if (cloudiness > 80) return 60;
    if (cloudiness > 50) return 30;
    return 10;
  }

  // Conditions pour pulvérisation
  bool get isGoodForSpraying {
    return windSpeed < 15 && rainProbability < 30;
  }

  // Risque de mildiou
  String get mildewRisk {
    if (humidity > 80 && temperature > 15 && temperature < 25) {
      return 'Élevé';
    } else if (humidity > 70 && temperature > 10 && temperature < 30) {
      return 'Modéré';
    }
    return 'Faible';
  }

  // Risque de ravageurs
  String get pestRisk {
    if (temperature > 20 && temperature < 30 && humidity > 60) {
      return 'Élevé';
    } else if (temperature > 15 && temperature < 35 && humidity > 50) {
      return 'Modéré';
    }
    return 'Faible';
  }
}

class ForecastModel {
  final double temperature;
  final String iconCode;
  final DateTime dateTime;
  final String description;

  ForecastModel({
    required this.temperature,
    required this.iconCode,
    required this.dateTime,
    required this.description,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] ?? '01d',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      description: json['weather'][0]['description'] ?? '',
    );
  }

  String get dayName {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[dateTime.weekday - 1];
  }
}
