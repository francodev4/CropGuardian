// lib/features/favorites/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/insect.dart';
import '../../core/services/database_service.dart';
import '../../core/widgets/insect_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Insect> _favoriteInsects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_insects') ?? [];

      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteInsects = [];
          _isLoading = false;
        });
        return;
      }

      // Charger chaque insecte depuis la base de données
      final List<Insect> insects = [];
      for (final id in favoriteIds) {
        try {
          final insect = await _databaseService.getInsectById(id);
          if (insect != null) {
            insects.add(insect);
          }
        } catch (e) {
          print('Erreur chargement insecte $id: $e');
        }
      }

      setState(() {
        _favoriteInsects = insects;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement favoris: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(String insectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorite_insects') ?? [];
      favorites.remove(insectId);
      await prefs.setStringList('favorite_insects', favorites);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiré des favoris'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Recharger la liste
      _loadFavorites();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
      ),
    body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _favoriteInsects.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteInsects.length,
                    itemBuilder: (context, index) {
                      final insect = _favoriteInsects[index];
                      return _FavoriteInsectCard(
                        insect: insect,
                        onRemove: () => _removeFromFavorites(insect.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 100,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Les insectes que vous sauvegardez apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/collection'),
            icon: const Icon(Icons.collections),
            label: const Text('Explorer la collection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteInsectCard extends StatelessWidget {
  final Insect insect;
  final VoidCallback onRemove;

  const _FavoriteInsectCard({
    required this.insect,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          context.push('/insect/${insect.id}', extra: insect);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              InsectImage(
                imageUrl: insect.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insect.commonName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insect.scientificName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insect.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            insect.category.toLowerCase().contains('nuisible')
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton supprimer
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.amber),
                onPressed: onRemove,
                tooltip: 'Retirer des favoris',
              ),

              // Flèche
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
