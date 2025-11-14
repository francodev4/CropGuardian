// lib/features/detection_result/detection_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/database_service.dart';

class DetectionResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const DetectionResultScreen({super.key, required this.result});

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  final DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insectName = widget.result['insect'] ?? 'Inconnu';
    final confidence = widget.result['confidence'] ?? 0.0;
    final confidencePercentage = widget.result['confidence_percentage'] ?? '0.0%';
    final severity = widget.result['severity'] ?? 'Inconnu';
    final modelType = widget.result['model_type'] ?? 'Inconnu';
    final source = widget.result['source'] ?? 'Inconnu';
    final recommendations = widget.result['recommendations'];
    
    // Vérifier si c'est un échec
    final isFailure = confidence == 0.0 || insectName.contains('Échec');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de Détection'),
      ),
      body: isFailure
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun insecte détecté',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez de prendre une autre photo avec un meilleur éclairage',
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte principale de résultat
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.bug_report,
                                    color: theme.colorScheme.primary, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      insectName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getConfidenceColor(confidence)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Confiance: $confidencePercentage',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _getConfidenceColor(confidence),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          // Sévérité
                          _InfoRow(
                            icon: Icons.warning_amber,
                            label: 'Sévérité',
                            value: severity,
                            color: _getSeverityColor(severity),
                          ),
                          const SizedBox(height: 12),
                          // Source
                          _InfoRow(
                            icon: Icons.source,
                            label: 'Source',
                            value: source,
                          ),
                          const SizedBox(height: 12),
                          // Modèle
                          _InfoRow(
                            icon: Icons.model_training,
                            label: 'Modèle',
                            value: modelType,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recommandations
                  if (recommendations != null) ...[
                    Text(
                      'Recommandations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (recommendations is List)
                      ...recommendations.map((rec) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      rec.toString(),
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            recommendations.toString(),
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  // Bouton pour chercher dans la collection
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final insect = await _database.getInsects(search: insectName);
                        if (insect.isNotEmpty && mounted) {
                          context.push('/insect/${insect.first.id}', extra: insect.first);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Insecte non trouvé dans la collection'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Voir dans la Collection'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Autre Photo'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Terminé'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getSeverityColor(String severity) {
    if (severity.contains('Élevé')) return Colors.red;
    if (severity.contains('Moyen')) return Colors.orange;
    if (severity.contains('Faible')) return Colors.yellow;
    return Colors.grey;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? theme.textTheme.bodyLarge?.color,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
