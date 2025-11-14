// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec bouton profil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CROP\nGUARDIAN',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                height: 1.1,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Identifiez les insectes nuisibles avec l\'IA',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/profile'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    tooltip: 'Profil',
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Actions rapides
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Scanner',
                      subtitle: 'Prendre une photo',
                      icon: Icons.camera_alt,
                      color: AppColors.primary,
                      onTap: () => context.push('/camera'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Collection',
                      subtitle: 'Parcourir insectes',
                      icon: Icons.collections,
                      color: AppColors.secondary,
                      onTap: () => context.go('/collection'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Historique',
                      subtitle: 'Détections passées',
                      icon: Icons.history,
                      color: AppColors.warning,
                      onTap: () => context.go('/history'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Météo',
                      subtitle: 'Alertes actuelles',
                      icon: Icons.wb_sunny,
                      color: AppColors.accent,
                      onTap: () => context.push('/weather'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Nouvelles cartes pour recherche et favoris
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Recherche',
                      subtitle: 'Par description',
                      icon: Icons.text_fields,
                      color: Colors.purple,
                      onTap: () => context.push('/description-search'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Favoris',
                      subtitle: 'Insectes sauvegardés',
                      icon: Icons.bookmark,
                      color: Colors.amber,
                      onTap: () => context.push('/favorites'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Carte Champs
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Mes Champs',
                      subtitle: 'Gérer vos cultures',
                      icon: Icons.agriculture,
                      color: Colors.green,
                      onTap: () => context.push('/fields'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Tableau de bord',
                      subtitle: 'Statistiques',
                      icon: Icons.dashboard,
                      color: Colors.blue,
                      onTap: () => context.push('/dashboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
