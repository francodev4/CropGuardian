// lib/features/fields/edit_field_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/field.dart';
import '../../core/services/field_service.dart';
import '../../core/theme/app_colors.dart';

class EditFieldDialog extends StatefulWidget {
  final Field field;
  final VoidCallback onFieldUpdated;

  const EditFieldDialog({
    super.key,
    required this.field,
    required this.onFieldUpdated,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _areaController;
  late final TextEditingController _cropTypeController;
  
  late String _selectedCropType;
  bool _isLoading = false;

  final List<String> _cropTypes = [
    'Maïs',
    'Blé',
    'Riz',
    'Soja',
    'Tomate',
    'Pomme de terre',
    'Coton',
    'Café',
    'Cacao',
    'Banane',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs avec les données existantes
    _nameController = TextEditingController(text: widget.field.name);
    _locationController = TextEditingController(text: widget.field.description);
    _areaController = TextEditingController(text: widget.field.area.toString());
    _cropTypeController = TextEditingController();
    
    // Déterminer le type de culture sélectionné
    if (_cropTypes.contains(widget.field.cropType)) {
      _selectedCropType = widget.field.cropType;
    } else {
      _selectedCropType = 'Autre';
      _cropTypeController.text = widget.field.cropType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  Future<void> _updateField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedField = Field(
        id: widget.field.id,
        userId: widget.field.userId,
        name: _nameController.text.trim(),
        latitude: widget.field.latitude,
        longitude: widget.field.longitude,
        area: double.parse(_areaController.text),
        cropType: _selectedCropType == 'Autre' 
            ? _cropTypeController.text.trim() 
            : _selectedCropType,
        plantingDate: widget.field.plantingDate,
        description: _locationController.text.trim(),
        createdAt: widget.field.createdAt,
      );

      await FieldService.instance.updateField(updatedField);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onFieldUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Champ modifié avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
      title: Row(
        children: [
          const Icon(Icons.edit, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Modifier le Champ',
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom du champ
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Nom du champ *',
                  hintText: 'Ex: Champ Nord, Parcelle A',
                  prefixIcon: const Icon(Icons.label),
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Localisation
              TextFormField(
                controller: _locationController,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Localisation *',
                  hintText: 'Ex: Kinshasa, Lubumbashi',
                  prefixIcon: const Icon(Icons.location_on),
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La localisation est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Surface (hectares)
              TextFormField(
                controller: _areaController,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Surface (hectares) *',
                  hintText: 'Ex: 2.5',
                  prefixIcon: const Icon(Icons.square_foot),
                  suffixText: 'ha',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La surface est obligatoire';
                  }
                  final area = double.tryParse(value);
                  if (area == null || area <= 0) {
                    return 'Surface invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type de culture
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                dropdownColor: isDark ? AppColors.cardBackground : Colors.white,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Type de culture *',
                  prefixIcon: const Icon(Icons.grass),
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                items: _cropTypes.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCropType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Champ personnalisé si "Autre"
              if (_selectedCropType == 'Autre')
                TextFormField(
                  controller: _cropTypeController,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Précisez le type de culture *',
                    hintText: 'Ex: Manioc, Arachide',
                    prefixIcon: const Icon(Icons.edit),
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                    ),
                  ),
                  validator: (value) {
                    if (_selectedCropType == 'Autre' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Veuillez préciser le type de culture';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 8),
              Text(
                '* Champs obligatoires',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateField,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Modifier'),
        ),
      ],
    );
  }
}
