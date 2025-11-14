// lib/features/fields/screens/treatment_suggestions_screen.dart
import 'package:flutter/material.dart';
import '../../core/models/treatment.dart';
import '../../core/services/hybrid_treatment_service.dart';
import '../../core/theme/app_colors.dart';
import 'treatment_card.dart'; // ✅ CORRIGÉ: Chemin relatif correct

class TreatmentSuggestionsScreen extends StatefulWidget {
  final String insectId;
  final String insectName;
  final String cropType;
  final int? severity;
  final String? location;

  const TreatmentSuggestionsScreen({
    super.key,
    required this.insectId,
    required this.insectName,
    required this.cropType,
    this.severity,
    this.location,
  });

  @override
  State<TreatmentSuggestionsScreen> createState() => _TreatmentSuggestionsScreenState();
}

class _TreatmentSuggestionsScreenState extends State<TreatmentSuggestionsScreen> {
  final HybridTreatmentService _treatmentService = HybridTreatmentService.instance;
  List<Treatment> treatments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final suggestions = await _treatmentService.getSmartTreatmentSuggestions(
        insectId: widget.insectId,
        insectName: widget.insectName,
        cropType: widget.cropType,
        location: widget.location,
        severity: widget.severity,
      );

      setState(() {
        treatments = suggestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement des traitements: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suggestions de traitement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTreatments,
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec informations sur l'insecte
          _buildHeader(),
          
          // Liste des traitements
          Expanded(
            child: _buildTreatmentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.insectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoItem(Icons.agriculture, 'Culture', widget.cropType),
              if (widget.severity != null) ...[
                const SizedBox(width: 16),
                _buildInfoItem(
                  Icons.warning,
                  'Sévérité',
                  '${widget.severity}/5',
                  color: _getSeverityColor(widget.severity!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentsList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Recherche de traitements...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTreatments,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (treatments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            SizedBox(height: 16),
            Text(
              'Aucun traitement trouvé',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            Text(
              'Contactez un spécialiste pour des conseils personnalisés',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        return TreatmentCard(
          treatment: treatments[index],
          onTap: () => _showTreatmentDetail(treatments[index]),
        );
      },
    );
  }

  void _showTreatmentDetail(Treatment treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TreatmentDetailModal(treatment: treatment),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 4) return AppColors.error;
    if (severity >= 3) return AppColors.warning;
    return AppColors.success;
  }
}

class _TreatmentDetailModal extends StatelessWidget {
  final Treatment treatment;

  const _TreatmentDetailModal({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Titre
          Text(
            treatment.methode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description complète
          if (treatment.description != null)
            Text(
              treatment.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Détails
          _buildDetailRow('Type', treatment.typeText),
          _buildDetailRow('Efficacité', treatment.efficaciteText),
          if (treatment.periodeApplication != null)
            _buildDetailRow('Application', treatment.periodeApplication!),
          if (treatment.coutEstime != null)
            _buildDetailRow('Coût estimé', '${treatment.coutEstime!.toStringAsFixed(0)}€'),
          
          const SizedBox(height: 24),
          
          // Bouton fermer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ),
          
          // Espace pour le clavier
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}