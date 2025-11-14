// lib/features/fields/widgets/treatment_card.dart
import 'package:flutter/material.dart';
import '../../../core/models/treatment.dart';
import '../../../core/theme/app_colors.dart';

class TreatmentCard extends StatelessWidget {
  final Treatment treatment;
  final VoidCallback? onTap;

  const TreatmentCard({
    super.key,
    required this.treatment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      treatment.methode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypeBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              if (treatment.description != null)
                Text(
                  treatment.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Informations détaillées
              Row(
                children: [
                  _buildInfoChip(
                    Icons.star,
                    treatment.efficaciteText,
                    _getEfficaciteColor(),
                  ),
                  if (treatment.coutEstime != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.euro,
                      '${treatment.coutEstime!.toStringAsFixed(0)}€',
                      _getCostColor(),
                    ),
                  ],
                ],
              ),
              
              if (treatment.periodeApplication != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        treatment.periodeApplication!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    Color backgroundColor;
    Color textColor;
    
    switch (treatment.type.toLowerCase()) {
      case 'biological':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[700]!;
        break;
      case 'organic':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[700]!;
        break;
      case 'chemical':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[700]!;
        break;
      case 'cultural':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        treatment.typeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEfficaciteColor() {
    if (treatment.efficacite == null) return Colors.grey;
    if (treatment.efficacite! >= 4) return Colors.green;
    if (treatment.efficacite! >= 3) return Colors.orange;
    return Colors.red;
  }

  Color _getCostColor() {
    if (treatment.coutEstime == null) return Colors.grey;
    if (treatment.coutEstime! < 15) return Colors.green;
    if (treatment.coutEstime! < 35) return Colors.orange;
    return Colors.red;
  }
}