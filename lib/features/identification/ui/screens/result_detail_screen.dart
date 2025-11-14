// lib/features/identification/ui/screens/result_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/detection.dart';
import '../../../../core/models/insect.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ResultDetailScreen extends StatefulWidget {
  final Detection detection;

  const ResultDetailScreen({super.key, required this.detection});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  Future<void> _saveIdentification() async {
    if (_isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Déjà sauvegardé'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        throw Exception('Vous devez être connecté pour sauvegarder');
      }

      await DatabaseService().saveDetection(widget.detection);

      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Identification sauvegardée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareResult() async {
    try {
      final text = '''
🐛 Identification CropGuardian

Insecte: ${widget.detection.insectName}
Nom scientifique: ${widget.detection.scientificName}
Confiance: ${(widget.detection.confidence * 100).toStringAsFixed(1)}%

Date: ${_formatDate(widget.detection.createdAt)}
${widget.detection.location != null ? 'Localisation: ${widget.detection.location}' : ''}

📱 Partagé depuis CropGuardian
      ''';

      await Share.share(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur de partage: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewInsectDetail() {
    // Créer un objet Insect à partir de la détection
    final insect = Insect(
      id: widget.detection.insectId,
      commonName: widget.detection.insectName,
      scientificName: widget.detection.scientificName,
      description: 'Insecte identifié par l\'IA avec ${(widget.detection.confidence * 100).toStringAsFixed(1)}% de confiance',
      imageUrl: widget.detection.imagePath,
      category: 'Identifié',
      habitat: 'Information non disponible',
      damage: 'Consultez la base de données pour plus d\'informations',
      symptoms: const ['Identification automatique'],
      createdAt: widget.detection.createdAt,
    );

    context.push('/insect/${insect.id}', extra: insect);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Détails de l'identification",
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResult,
            tooltip: 'Partager',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec image et informations principales
            _buildHeader(context, isDark),

            const SizedBox(height: 24),

            // Informations détaillées
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(context, isDark),

                  const SizedBox(height: 24),

                  // Suggestions de traitement simples
                  _buildTreatmentSection(isDark),

                  const SizedBox(height: 32),

                  // Actions
                  _buildActionButtons(context, isDark),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.primary.withOpacity(0.8), AppColors.primary.withOpacity(0.6)]
              : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Image de l'insecte
          if (widget.detection.imagePath != null)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(widget.detection.imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Nom de l'insecte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  widget.detection.insectName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),
                Text(
                  widget.detection.scientificName,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Badge de confiance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(widget.detection.confidence).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getConfidenceColor(widget.detection.confidence),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: _getConfidenceColor(widget.detection.confidence),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Confiance: ${(widget.detection.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getConfidenceColor(widget.detection.confidence),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              _formatDate(widget.detection.createdAt),
              isDark,
            ),

            if (widget.detection.location != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on,
                'Localisation',
                widget.detection.location!,
                isDark,
              ),
            ],

            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Catégorie',
              'Insecte identifié',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.textSecondary : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentSection(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommandations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pour obtenir des recommandations de traitement détaillées, consultez la fiche complète de l\'insecte.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Voir plus de détails
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _viewInsectDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Voir la fiche complète',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Actions secondaires
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? AppColors.textSecondary : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Nouvelle photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveIdentification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved 
                      ? AppColors.success 
                      : (isDark ? AppColors.surface : Colors.grey[600]),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSaved ? Icons.check : Icons.save,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSaved ? 'Sauvegardé' : 'Sauvegarder',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
