// lib/features/fields/field_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/field.dart';
import '../../core/models/infestation.dart';
import '../../core/services/field_service.dart';
import '../../core/theme/app_colors.dart';
import 'edit_field_dialog.dart';

class FieldDetailScreen extends StatefulWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FieldService _fieldService = FieldService.instance; // ✅ Corrigé: utiliser le singleton
  List<Infestation> infestations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFieldData();
  }

  Future<void> _loadFieldData() async {
    setState(() => isLoading = true);
    try {
      final fieldInfestations = await _fieldService.getFieldInfestations(widget.field.id);
      setState(() {
        infestations = fieldInfestations;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading field data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.field.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editField(),
          ),
          // ✅ Ajouté: bouton pour rafraîchir les données
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFieldData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Infestations'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildInfestationsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations du champ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(Icons.agriculture, 'Type de culture', widget.field.cropType),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.square_foot, 'Superficie', '${widget.field.area} hectares'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today, 
                    'Date de plantation', 
                    _formatDate(widget.field.plantingDate)
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on, 
                    'Location', 
                    '${widget.field.latitude.toStringAsFixed(4)}, ${widget.field.longitude.toStringAsFixed(4)}'
                  ),
                  // ✅ Ajouté: date de création
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.add_circle_outline, 
                    'Créé le', 
                    _formatDate(widget.field.createdAt)
                  ),
                  
                  if (widget.field.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.field.description,
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Stats - Version améliorée
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Infestations actives',
                  infestations.where((i) => i.status == 'active').length.toString(),
                  AppColors.error,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Traitées',
                  infestations.where((i) => i.status == 'treated').length.toString(),
                  AppColors.warning,
                  Icons.healing,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Résolues',
                  infestations.where((i) => i.status == 'resolved').length.toString(),
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Détections totales',
                  infestations.length.toString(),
                  AppColors.primary,
                  Icons.bug_report,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfestationsTab() {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeInfestations = infestations.where((i) => i.status == 'active').toList();

    if (activeInfestations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Aucune infestation active',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce champ est sain !',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour signaler une infestation, allez dans Collection → Sélectionnez un insecte → Signaler',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeInfestations.length,
      itemBuilder: (context, index) {
        return _InfestationCard(
          infestation: activeInfestations[index],
          onStatusUpdate: _updateInfestationStatus,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (infestations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les détections apparaîtront ici',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Scannez des insectes ou signalez des infestations pour voir l\'historique',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ✅ Tri par date (plus récent en premier)
    final sortedInfestations = List<Infestation>.from(infestations)
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedInfestations.length,
      itemBuilder: (context, index) {
        return _HistoryCard(infestation: sortedInfestations[index]);
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _updateInfestationStatus(String infestationId, String status) async {
    try {
      await _fieldService.updateInfestationStatus(infestationId, status);
      await _loadFieldData(); // Recharger les données
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Infestation marked as $status'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _editField() {
    showDialog(
      context: context,
      builder: (context) => EditFieldDialog(
        field: widget.field,
        onFieldUpdated: () {
          // Recharger les données du champ
          setState(() {
            // Le champ sera rechargé via le parent
          });
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ✅ Les classes _InfestationCard et _HistoryCard restent inchangées mais voici quelques améliorations :

class _InfestationCard extends StatelessWidget {
  final Infestation infestation;
  final Function(String, String) onStatusUpdate;

  const _InfestationCard({
    required this.infestation,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        infestation.insectName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sévérité: ${_getSeverityText(infestation.severity)}',
                        style: TextStyle(
                          color: _getSeverityColor(infestation.severity),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSeverityBadge(infestation.severity),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              'Affected area: ${infestation.affectedArea.toStringAsFixed(1)}%',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Detected: ${_formatDate(infestation.detectedAt)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            
            if (infestation.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${infestation.notes}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onStatusUpdate(infestation.id, 'treated'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                    child: const Text('Marquer comme traité'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate(infestation.id, 'resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Résoudre'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(int severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getSeverityText(severity),
        style: TextStyle(
          color: _getSeverityColor(severity),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1: return 'Très faible';
      case 2: return 'Faible';
      case 3: return 'Moyenne';
      case 4: return 'Élevée';
      case 5: return 'Critique';
      default: return 'Inconnue';
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1: case 2: return AppColors.success;
      case 3: return AppColors.warning;
      case 4: case 5: return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _HistoryCard extends StatelessWidget {
  final Infestation infestation;

  const _HistoryCard({required this.infestation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(infestation.status).withOpacity(0.2),
          child: Icon(
            _getStatusIcon(infestation.status),
            color: _getStatusColor(infestation.status),
          ),
        ),
        title: Text(infestation.insectName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(infestation.detectedAt)),
            Text(
              'Severity: ${_getSeverityText(infestation.severity)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(infestation.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            infestation.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(infestation.status),
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return AppColors.error;
      case 'treated': return AppColors.warning;
      case 'resolved': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active': return Icons.warning;
      case 'treated': return Icons.healing;
      case 'resolved': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1: return 'Très faible';
      case 2: return 'Faible';
      case 3: return 'Moyenne';
      case 4: return 'Élevée';
      case 5: return 'Critique';
      default: return 'Inconnue';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}