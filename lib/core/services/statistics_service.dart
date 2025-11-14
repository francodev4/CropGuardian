// lib/core/services/statistics_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStatistics {
  final int detectionsCount;
  final int fieldsCount;
  final int infestationsCount;
  final int treatedCount;
  final Map<String, int> weeklyDetections;
  final List<FieldStat> fieldStats;

  DashboardStatistics({
    required this.detectionsCount,
    required this.fieldsCount,
    required this.infestationsCount,
    required this.treatedCount,
    required this.weeklyDetections,
    required this.fieldStats,
  });
}

class FieldStat {
  final String id;
  final String name;
  final String status;
  final double health;

  FieldStat({
    required this.id,
    required this.name,
    required this.status,
    required this.health,
  });
}

class StatisticsService {
  static StatisticsService? _instance;
  static StatisticsService get instance => _instance ??= StatisticsService._();

  StatisticsService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardStatistics> getDashboardStatistics() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return _getEmptyStatistics();
      }

      // Obtenir le nombre de détections (toutes, car pas de user_id)
      final detectionsResponse = await _supabase
          .from('detections')
          .select('id');
      final detectionsCount = (detectionsResponse as List).length;

      // Obtenir le nombre de champs
      final fieldsResponse =
          await _supabase.from('fields').select('*').eq('user_id', user.id);
      final fieldsCount = (fieldsResponse as List).length;
      final fieldsList = fieldsResponse;

      // Obtenir le nombre d'infestations
      final infestationsResponse = await _supabase
          .from('infestations')
          .select('*')
          .eq('status', 'active');
      final allInfestations = infestationsResponse as List;

      // Filtrer les infestations de l'utilisateur
      final userFieldIds = fieldsList.map((f) => f['id']).toList();
      final userInfestations = allInfestations
          .where((inf) => userFieldIds.contains(inf['field_id']))
          .toList();
      final infestationsCount = userInfestations.length;

      // Obtenir le nombre d'infestations traitées
      final treatedResponse = await _supabase
          .from('infestations')
          .select('*')
          .or('status.eq.treated,status.eq.resolved');
      final allTreated = treatedResponse as List;
      final treatedCount = allTreated
          .where((inf) => userFieldIds.contains(inf['field_id']))
          .length;

      // Obtenir les détections par jour (dernière semaine)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final weeklyDetectionsResponse = await _supabase
          .from('detections')
          .select('created_at')
          .gte('created_at', weekAgo.toIso8601String())
          .order('created_at', ascending: true);

      final weeklyDetections = <String, int>{
        'Lun': 0,
        'Mar': 0,
        'Mer': 0,
        'Jeu': 0,
        'Ven': 0,
        'Sam': 0,
        'Dim': 0,
      };

      for (var detection in weeklyDetectionsResponse as List) {
        final date = DateTime.parse(detection['created_at']);
        final dayName = _getDayName(date.weekday);
        weeklyDetections[dayName] = (weeklyDetections[dayName] ?? 0) + 1;
      }

      // Calculer les statistiques des champs
      final fieldStats = <FieldStat>[];
      for (var field in fieldsList) {
        final fieldId = field['id'];

        // Compter les infestations actives pour ce champ
        final fieldInfestations = userInfestations
            .where((inf) => inf['field_id'] == fieldId)
            .toList();

        final activeCount = fieldInfestations.length;

        // Calculer le "health" en fonction des infestations
        double health;
        String status;
        if (activeCount == 0) {
          health = 1.0;
          status = 'Sain';
        } else if (activeCount <= 2) {
          health = 0.7;
          status = 'Attention';
        } else {
          health = 0.3;
          status = 'Critique';
        }

        fieldStats.add(FieldStat(
          id: fieldId,
          name: field['name'] ?? 'Champ sans nom',
          status: status,
          health: health,
        ));
      }

      return DashboardStatistics(
        detectionsCount: detectionsCount,
        fieldsCount: fieldsCount,
        infestationsCount: infestationsCount,
        treatedCount: treatedCount,
        weeklyDetections: weeklyDetections,
        fieldStats: fieldStats,
      );
    } catch (e) {
      print('Erreur getDashboardStatistics: $e');
      return _getEmptyStatistics();
    }
  }

  DashboardStatistics _getEmptyStatistics() {
    return DashboardStatistics(
      detectionsCount: 0,
      fieldsCount: 0,
      infestationsCount: 0,
      treatedCount: 0,
      weeklyDetections: {
        'Lun': 0,
        'Mar': 0,
        'Mer': 0,
        'Jeu': 0,
        'Ven': 0,
        'Sam': 0,
        'Dim': 0,
      },
      fieldStats: [],
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}
