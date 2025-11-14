// lib/features/fields/add_field_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/models/field.dart';
import '../../core/services/field_service.dart';
import '../../core/theme/app_colors.dart';

class AddFieldDialog extends StatefulWidget {
  final String userId;
  final VoidCallback onFieldAdded;
  final Field? field; // ✅ Champ existant pour modification

  const AddFieldDialog({
    super.key,
    required this.userId,
    required this.onFieldAdded,
    this.field, // null = ajout, non-null = modification
  });

  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
  
  // ✅ Helper pour savoir si on est en mode édition
  bool get isEditing => field != null;
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _cropTypeController = TextEditingController();
  
  String _selectedCropType = 'Maïs';
  bool _isLoading = false;
  bool _isLoadingGPS = false;
  double? _latitude;
  double? _longitude;

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
    
    // ✅ Si on est en mode édition, pré-remplir les champs
    if (widget.field != null) {
      final field = widget.field!;
      _nameController.text = field.name;
      _areaController.text = field.area.toString();
      _selectedCropType = field.cropType;
      _latitude = field.latitude;
      _longitude = field.longitude;
      _locationController.text = '${field.latitude.toStringAsFixed(6)}, ${field.longitude.toStringAsFixed(6)}';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingGPS = true);

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée définitivement');
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingGPS = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Position GPS obtenue'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingGPS = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur GPS: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  Future<void> _saveField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final field = Field(
        id: widget.field?.id ?? '', // ✅ Garder l'ID existant si modification
        userId: widget.userId,
        name: _nameController.text.trim(),
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        area: double.parse(_areaController.text),
        cropType: _selectedCropType == 'Autre' 
            ? _cropTypeController.text.trim() 
            : _selectedCropType,
        plantingDate: widget.field?.plantingDate ?? DateTime.now(), // ✅ Garder la date existante
        description: _locationController.text.trim(),
        createdAt: widget.field?.createdAt ?? DateTime.now(), // ✅ Garder la date de création
      );

      // ✅ Appeler createField ou updateField selon le mode
      if (widget.field == null) {
        // Mode ajout
        await FieldService.instance.createField(field);
      } else {
        // Mode modification
        await FieldService.instance.updateField(field);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onFieldAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.field == null 
                ? '✅ Champ ajouté avec succès !' 
                : '✅ Champ modifié avec succès !'),
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
    final theme = Theme.of(context);
    
    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Row(
        children: [
          Icon(Icons.agriculture, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            widget.field == null ? 'Ajouter un Champ' : 'Modifier le Champ',
            style: theme.textTheme.titleLarge,
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
                decoration: const InputDecoration(
                  labelText: 'Nom du champ *',
                  hintText: 'Ex: Champ Nord, Parcelle A',
                  prefixIcon: Icon(Icons.label),
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
                decoration: const InputDecoration(
                  labelText: 'Localisation *',
                  hintText: 'Ex: Kinshasa, Lubumbashi',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La localisation est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bouton GPS et coordonnées
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingGPS ? null : _getCurrentLocation,
                      icon: _isLoadingGPS
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(_isLoadingGPS ? 'Chargement...' : 'Obtenir ma position'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Affichage des coordonnées si disponibles
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GPS: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Surface (hectares)
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares) *',
                  hintText: 'Ex: 2.5',
                  prefixIcon: Icon(Icons.square_foot),
                  suffixText: 'ha',
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
                decoration: const InputDecoration(
                  labelText: 'Type de culture *',
                  prefixIcon: Icon(Icons.grass),
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
                  decoration: const InputDecoration(
                    labelText: 'Précisez le type de culture *',
                    hintText: 'Ex: Manioc, Arachide',
                    prefixIcon: Icon(Icons.edit),
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
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
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
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveField,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}
