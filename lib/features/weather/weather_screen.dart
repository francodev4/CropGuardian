// lib/features/weather/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Use Theme colors instead of AppColors to support light/dark modes
import '../../core/providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données météo au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes Météo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherProvider>().refresh();
            },
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des données météo...'),
                ],
              ),
            );
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      weatherProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<WeatherProvider>().refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Note: Assurez-vous d\'avoir configuré votre clé API OpenWeatherMap dans weather_service.dart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final weather = weatherProvider.currentWeather;
          if (weather == null) {
            return const Center(
              child: Text('Aucune donnée météo disponible'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Météo actuelle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _getWeatherIcon(weather.iconCode),
                      const SizedBox(height: 16),
                      Text(
                        '${weather.temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.description[0].toUpperCase() +
                            weather.description.substring(1),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.cityName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail('Humidité',
                              '${weather.humidity}%', Icons.water_drop),
                          _buildWeatherDetail('Vent',
                              '${weather.windSpeed.round()} km/h', Icons.air),
                          _buildWeatherDetail('Pluie',
                              '${weather.rainProbability}%', Icons.umbrella),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Alertes météo
                Text(
                  'Alertes pour vos cultures',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Alerte pulvérisation
                if (weather.isGoodForSpraying)
                  _buildAlertCard(
                    'Conditions idéales pour pulvérisation',
                    'Vent faible et temps sec - moment idéal pour traiter vos cultures',
                    Icons.check_circle,
                    Colors.green,
                  )
                else
                  _buildAlertCard(
                    'Conditions défavorables à la pulvérisation',
                    'Vent trop fort ou risque de pluie - attendez de meilleures conditions',
                    Icons.warning,
                    Colors.orange,
                  ),

                const SizedBox(height: 12),

                // Alerte mildiou
                if (weather.mildewRisk == 'Élevé')
                  _buildAlertCard(
                    'Risque de mildiou élevé',
                    'Humidité et température favorables au mildiou - surveillance accrue recommandée',
                    Icons.warning,
                    Colors.red,
                  )
                else if (weather.mildewRisk == 'Modéré')
                  _buildAlertCard(
                    'Risque de mildiou modéré',
                    'Humidité élevée prévue - surveillez vos cultures',
                    Icons.warning,
                    Colors.orange,
                  )
                else
                  _buildAlertCard(
                    'Risque de mildiou faible',
                    'Conditions actuelles peu favorables au développement du mildiou',
                    Icons.check_circle,
                    Colors.green,
                  ),

                const SizedBox(height: 12),

                // Alerte ravageurs
                if (weather.pestRisk == 'Élevé')
                  _buildAlertCard(
                    'Risque de ravageurs élevé',
                    'Températures et humidité favorables aux ravageurs - inspection recommandée',
                    Icons.bug_report,
                    Colors.red,
                  )
                else if (weather.pestRisk == 'Modéré')
                  _buildAlertCard(
                    'Risque de ravageurs modéré',
                    'Conditions propices à la prolifération - restez vigilant',
                    Icons.bug_report,
                    Colors.orange,
                  )
                else
                  _buildAlertCard(
                    'Risque de ravageurs faible',
                    'Conditions actuelles défavorables aux ravageurs',
                    Icons.check_circle,
                    Colors.green,
                  ),

                const SizedBox(height: 24),

                // Prévisions 7 jours
                Text(
                  'Prévisions 7 jours',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),

                if (weatherProvider.forecasts.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weatherProvider.forecasts.length,
                      itemBuilder: (context, index) {
                        final forecast = weatherProvider.forecasts[index];
                        return _buildForecastCard(
                          forecast.dayName,
                          '${forecast.temperature.round()}°',
                          forecast.iconCode,
                        );
                      },
                    ),
                  )
                else
                  const Center(
                    child: Text('Prévisions non disponibles'),
                  ),

                const SizedBox(height: 24),

                // Recommandations
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Recommandations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRecommendation(
                        'Inspectez vos cultures tôt le matin quand les insectes sont moins actifs',
                      ),
                      _buildRecommendation(
                        'Évitez la pulvérisation en période de vent fort (>15 km/h)',
                      ),
                      _buildRecommendation(
                        'Arrosez vos cultures le soir pour éviter l\'évaporation',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Retourne l'icône appropriée selon le code météo
  Widget _getWeatherIcon(String iconCode) {
    IconData icon;

    // Codes OpenWeatherMap: 01d/01n = soleil, 02-04 = nuages, 09-10 = pluie, 11 = orage, 13 = neige, 50 = brume
    if (iconCode.contains('01')) {
      icon = Icons.wb_sunny;
    } else if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04')) {
      icon = Icons.cloud;
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      icon = Icons.water_drop;
    } else if (iconCode.contains('11')) {
      icon = Icons.thunderstorm;
    } else if (iconCode.contains('13')) {
      icon = Icons.ac_unit;
    } else if (iconCode.contains('50')) {
      icon = Icons.foggy;
    } else {
      icon = Icons.wb_sunny;
    }

    return Icon(icon, size: 64, color: Colors.white);
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(String day, String temp, String iconCode) {
    // Convertir iconCode en IconData
    IconData icon;
    if (iconCode.contains('01')) {
      icon = Icons.wb_sunny;
    } else if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04')) {
      icon = Icons.cloud;
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      icon = Icons.water_drop;
    } else if (iconCode.contains('11')) {
      icon = Icons.thunderstorm;
    } else if (iconCode.contains('13')) {
      icon = Icons.ac_unit;
    } else if (iconCode.contains('50')) {
      icon = Icons.foggy;
    } else {
      icon = Icons.wb_sunny;
    }

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            temp,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
