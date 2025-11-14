// lib/core/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Theme-aware scaffold; AppColors removed in favor of Theme

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        currentIndex: _getCurrentIndex(currentLocation),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_rounded),
            label: 'Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Tableau',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String location) {
    // Utiliser startsWith pour gérer les routes avec paramètres
    if (location == '/' || location == '/home') {
      return 0;
    } else if (location.startsWith('/collection')) {
      return 1;
    } else if (location.startsWith('/history')) {
      return 3;
    } else if (location.startsWith('/dashboard')) {
      return 4;
    } else if (location.startsWith('/fields')) {
      return 0; // Retour à l'accueil pour fields
    }
    return 0; // Par défaut, accueil
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/collection');
        break;
      case 2:
        context.push('/camera');
        break;
      case 3:
        context.go('/history');
        break;
      case 4: // Nouvel index pour Dashboard
        context.go('/dashboard');
        break;
    }
  }
}
