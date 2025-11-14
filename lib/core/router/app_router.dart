// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/collection/collection_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/insect_detail/insect_detail_screen.dart';
import '../../features/detection_result/detection_result_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/fields/fields_screen.dart';
import '../../features/fields/field_detail_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/weather/weather_screen.dart';
import '../../features/identification/description_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/main_scaffold.dart';
import '../models/insect.dart';
import '../models/field.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoginRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // Si pas connecté et pas sur une route d'auth, rediriger vers login
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        // Si connecté et sur une route d'auth, rediriger vers home
        if (isLoggedIn && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        // Routes d'authentification
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Routes principales avec navigation
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/collection',
              builder: (context, state) => const CollectionScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            // Routes ajoutées dans ShellRoute pour navigation
            GoRoute(
              path: '/fields',
              builder: (context, state) => const FieldsScreen(),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Routes sans navigation
        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: '/weather',
          builder: (context, state) => const WeatherScreen(),
        ),
        GoRoute(
          path: '/description-search',
          builder: (context, state) => const DescriptionSearchScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/insect/:id',
          builder: (context, state) {
            final insect = state.extra as Insect;
            return InsectDetailScreen(insect: insect);
          },
        ),
        GoRoute(
          path: '/detection-result',
          builder: (context, state) {
            final result = state.extra as Map<String, dynamic>;
            return DetectionResultScreen(result: result);
          },
        ),
        // Route field detail sans navigation
        GoRoute(
          path: '/field/:id',
          builder: (context, state) {
            final field = state.extra as Field;
            return FieldDetailScreen(field: field);
          },
        ),
      ],
    );
  }
}
