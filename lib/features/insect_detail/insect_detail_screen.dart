// lib/features/insect_detail/insect_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
// Use Theme-based colors for light/dark support
import '../../core/models/insect.dart';
import '../../core/models/treatment.dart';
import '../../core/models/infestation.dart';
import '../../core/models/field.dart';
import '../../core/services/treatment_service.dart';
import '../../core/services/field_service.dart';
import '../../core/widgets/insect_image.dart';

class InsectDetailScreen extends StatefulWidget {
  final Insect insect;

  const InsectDetailScreen({super.key, required this.insect});

  @override
  State<InsectDetailScreen> createState() => _InsectDetailScreenState();
}

class _InsectDetailScreenState extends State<InsectDetailScreen> {
  final TreatmentService _treatmentService = TreatmentService.instance;
  List<Treatment> treatments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() => isLoading = true);
    try {
      final result =
          await _treatmentService.getTreatmentSuggestions(widget.insect.id);
      setState(() {
        treatments = result;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement traitements: $e');
      setState(() => isLoading = false);

      // Utiliser les traitements de secours
      final fallbackTreatments =
          _treatmentService.getFallbackTreatments(widget.insect.commonName);
      setState(() {
        treatments = fallbackTreatments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareInsect(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  InsectImage(
                    imageUrl: widget.insect.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Insect Info
                    Text(
                      widget.insect.commonName.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.insect.scientificName,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Details Section
                    _buildDetailSection('DÉTAILS', [
                      _buildDetailRow('Habitat', widget.insect.habitat),
                      _buildDetailRow('Catégorie', widget.insect.category),
                      _buildDetailRow('Dégâts', widget.insect.damage),
                    ]),

                    const SizedBox(height: 24),

                    // Description
                    _buildDetailSection('DESCRIPTION', [
                      Text(
                        widget.insect.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.5,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Symptoms
                    if (widget.insect.symptoms.isNotEmpty)
                      _buildDetailSection('SYMPTÔMES', [
                        ...widget.insect.symptoms.map(
                          (symptom) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),

                    const SizedBox(height: 24),

                    // Treatments
                    _buildDetailSection('TRAITEMENTS RECOMMANDÉS', [
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (treatments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: (Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color ??
                                        Theme.of(context).dividerColor)
                                    .withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aucun traitement spécifique disponible. Consultez un spécialiste.',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...treatments
                            .map((treatment) => _buildTreatmentCard(treatment)),
                    ]),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saveToFavorites,
                            icon: const Icon(Icons.bookmark_border),
                            label: const Text('Sauvegarder'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _confirmInfestation,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Confirmer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(Treatment treatment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom et type
          Row(
            children: [
              Expanded(
                child: Text(
                  treatment.methode,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              _buildTypeBadge(treatment.type),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          if (treatment.description != null)
            Text(
              treatment.description!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 12),

          // Informations détaillées
          Row(
            children: [
              // Efficacité
              if (treatment.efficacite != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${treatment.efficacite}/5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],

              // Coût
              if (treatment.coutEstime != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.euro, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${treatment.coutEstime!.toStringAsFixed(0)}€',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Période d'application
          if (treatment.periodeApplication != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    treatment.periodeApplication!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (type.toLowerCase()) {
      case 'biological':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[700]!;
        displayText = 'Biologique';
        break;
      case 'organic':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[700]!;
        displayText = 'Organique';
        break;
      case 'chemical':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[700]!;
        displayText = 'Chimique';
        break;
      case 'cultural':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue[700]!;
        displayText = 'Cultural';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
        displayText = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // Fonction pour partager l'insecte
  void _shareInsect() async {
    final String text = '''
🐛 ${widget.insect.commonName}

Nom scientifique: ${widget.insect.scientificName}
Catégorie: ${widget.insect.category}

Description: ${widget.insect.description}

Dégâts: ${widget.insect.damage}

Découvert via CropGuardian - Votre assistant de protection des cultures 🌱
''';

    try {
      // Essayer de partager normalement (fonctionne sur mobile)
      await Share.share(
        text,
        subject: 'Insecte détecté: ${widget.insect.commonName}',
      );

      // Sur mobile, le partage fonctionne et on ne fait rien d'autre
      // Sur web, Share.share ne fait rien et on copie dans le presse-papier

      // Petit délai pour laisser Share.share tenter son action
      await Future.delayed(const Duration(milliseconds: 300));

      // Copier aussi dans le presse-papier comme fallback
      await Clipboard.setData(ClipboardData(text: text));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Texte copié! Vous pouvez le coller où vous voulez.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Si tout échoue, au moins on informe l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du partage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour sauvegarder l'insecte dans les favoris
  Future<void> _saveToFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorite_insects') ?? [];

      if (favorites.contains(widget.insect.id)) {
        // Déjà dans les favoris, on l'enlève
        favorites.remove(widget.insect.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Ajouter aux favoris
        favorites.add(widget.insect.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris ⭐'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      await prefs.setStringList('favorite_insects', favorites);
      setState(() {}); // Rafraîchir l'interface
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour confirmer et enregistrer une infestation
  Future<void> _confirmInfestation() async {
    // Récupérer l'utilisateur connecté
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Vous devez être connecté pour confirmer une infestation'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Afficher un dialog pour collecter plus d'informations
    final TextEditingController notesController = TextEditingController();
    int severity = 3; // Par défaut: modérée
    double affectedArea = 10.0; // Par défaut: 10%

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirmer l\'infestation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voulez-vous enregistrer une infestation de ${widget.insect.commonName}?',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Sévérité
                const Text(
                  'Sévérité:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => severity = index + 1),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: severity == index + 1
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: severity == index + 1
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionné: ${[
                    'Très faible',
                    'Faible',
                    'Modéré',
                    'Élevé',
                    'Très élevé'
                  ][severity - 1]}',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),

                const SizedBox(height: 16),

                // Zone affectée
                const Text(
                  'Zone affectée (%):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: affectedArea,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${affectedArea.round()}%',
                  onChanged: (value) => setState(() => affectedArea = value),
                ),

                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    hintText: 'Observations supplémentaires...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Obtenir la position GPS actuelle
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          print('Erreur position GPS: $e');
          // Position par défaut si GPS non disponible
          position = null;
        }

        // Obtenir ou créer le champ par défaut de l'utilisateur
        final fieldService = FieldService.instance;
        var fields = await fieldService.getUserFields(user.id);

        String fieldId;
        if (fields.isEmpty) {
          // Créer un champ par défaut
          final defaultField = Field(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: user.id,
            name: 'Champ principal',
            area: 1.0,
            latitude: position?.latitude ?? 0.0,
            longitude: position?.longitude ?? 0.0,
            cropType: 'Non spécifié',
            plantingDate: DateTime.now(),
            description:
                'Champ créé automatiquement lors de l\'enregistrement d\'une infestation',
            createdAt: DateTime.now(),
          );

          final createdField = await fieldService.createField(defaultField);
          fieldId = createdField.id;
        } else {
          fieldId = fields.first.id;
        }

        // Créer l'infestation
        final infestation = Infestation(
          id: '', // ✅ Laisser vide pour que Supabase génère l'UUID
          fieldId: fieldId,
          insectId: widget.insect.id,
          insectName: widget.insect.commonName,
          latitude: position?.latitude ?? 0.0,
          longitude: position?.longitude ?? 0.0,
          severity: severity,
          affectedArea: affectedArea,
          status: 'active',
          imagePath: widget.insect.imageUrl,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          detectedAt: DateTime.now(),
        );

        await fieldService.createInfestation(infestation);

        // Fermer l'indicateur de chargement
        if (mounted) Navigator.pop(context);

        // Afficher le succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Infestation de ${widget.insect.commonName} enregistrée'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Voir',
                textColor: Colors.white,
                onPressed: () {
                  context.go('/history');
                },
              ),
            ),
          );

          // Retourner à l'écran précédent
          context.pop();
        }
      } catch (e) {
        // Fermer l'indicateur de chargement
        if (mounted) Navigator.pop(context);

        // Afficher l'erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
