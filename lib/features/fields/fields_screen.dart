// lib/features/fields/fields_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/field.dart';
import '../../core/services/field_service.dart';
import '../../core/providers/auth_provider.dart';
import 'add_field_dialog.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final FieldService _fieldService = FieldService.instance;
  List<Field> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String userId;
      
      // ✅ Utiliser le getter userId qui gère le fallback automatiquement
      if (authProvider.isLoggedIn && authProvider.userId != null) {
        userId = authProvider.userId!;
        print('✅ Utilisation de l\'ID utilisateur: $userId');
      } else {
        // UUID de test qui correspond à celui dans la base de données
        userId = '550e8400-e29b-41d4-a716-446655440000';
        print('⚠️ Utilisateur non connecté, utilisation de l\'UUID de test');
      }
      
      print('📱 Chargement des champs pour l\'utilisateur UUID: $userId');
      final userFields = await _fieldService.getUserFields(userId);
      
      if (mounted) {
        setState(() {
          fields = userFields;
          isLoading = false;
        });
      }
      
      print('✅ ${userFields.length} champs chargés');
    } catch (e) {
      print('❌ Erreur lors du chargement des champs: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading fields: $e'),
            backgroundColor: AppColors.error,
          ),
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
        title: const Text('Mes Champs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFieldDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showUserInfo(),
            tooltip: 'User Info',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fields.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFields,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final field = fields[index];
                      return _FieldCard(
                        field: field,
                        onTap: () => context.push('/field/${field.id}', extra: field),
                        onEdit: () => _showEditFieldDialog(field),
                        onDelete: () => _showDeleteConfirmation(field),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFieldDialog(),
        tooltip: 'Ajouter un champ',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No fields yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to see your fields or check your database',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddFieldDialog,
            child: const Text('Add Field'),
          ),
        ],
      ),
    );
  }

  void _showUserInfo() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    String userInfo;
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      final user = authProvider.currentUser!;
      userInfo = '''
Connected User:
• Email: ${user.email}
• ID: ${user.id}
• Name: ${user.fullName}
• Status: Authenticated
• Fields: ${fields.length}
      ''';
    } else {
      userInfo = '''
No User Connected:
• Using test UUID: 550e8400-e29b-41d4-a716-446655440000
• Status: Not authenticated
• Fields: ${fields.length}

Note: Login to see your real data
      ''';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Information'),
        content: Text(userInfo),
        actions: [
          if (!authProvider.isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/login');
              },
              child: const Text('Login'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddFieldDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Obtenir l'ID utilisateur (connecté ou UUID de test)
    String userId;
    if (authProvider.isLoggedIn && authProvider.userId != null) {
      userId = authProvider.userId!;
    } else {
      // Utiliser l'UUID de test pour permettre l'ajout même sans connexion
      userId = '550e8400-e29b-41d4-a716-446655440000';
      print('⚠️ Ajout de champ avec UUID de test');
    }

    // Afficher le formulaire d'ajout
    showDialog(
      context: context,
      builder: (context) => AddFieldDialog(
        userId: userId,
        onFieldAdded: _loadFields,
      ),
    );
  }

  // ✅ Modifier un champ
  void _showEditFieldDialog(Field field) {
    showDialog(
      context: context,
      builder: (context) => AddFieldDialog(
        userId: field.userId,
        field: field, // Passer le champ existant pour modification
        onFieldAdded: _loadFields,
      ),
    );
  }

  // ✅ Supprimer un champ avec confirmation
  void _showDeleteConfirmation(Field field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le champ'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${field.name}" ?\n\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteField(field);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ✅ Supprimer le champ
  Future<void> _deleteField(Field field) async {
    try {
      await _fieldService.deleteField(field.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Champ "${field.name}" supprimé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      
      // Recharger la liste
      await _loadFields();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ✅ _FieldCard et _InfoChip restent identiques
class _FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _FieldCard({
    required this.field,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          field.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          field.cropType,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFieldStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getFieldStatusText(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getFieldStatusColor(),
                      ),
                    ),
                  ),
                  // ✅ Menu pour modifier/supprimer
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: theme.textTheme.bodyMedium?.color),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.square_foot,
                    label: '${field.area.toStringAsFixed(1)} ha',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.location_on,
                    label: '${field.latitude.toStringAsFixed(2)}, ${field.longitude.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: 'Planté le ${_formatDate(field.plantingDate)}',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: '${_getDaysOld(field.plantingDate)} jours',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFieldStatusColor() {
    final daysOld = _getDaysOld(field.plantingDate);
    if (daysOld < 30) return AppColors.primary;
    if (daysOld < 90) return AppColors.success;
    return AppColors.warning;
  }

  String _getFieldStatusText() {
    final daysOld = _getDaysOld(field.plantingDate);
    if (daysOld < 30) return 'New';
    if (daysOld < 90) return 'Active';
    return 'Mature';
  }

  int _getDaysOld(DateTime plantingDate) {
    return DateTime.now().difference(plantingDate).inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.textTheme.bodyMedium?.color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}