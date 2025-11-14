// lib/core/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.isLoggedIn;
  
  // ✅ Getter pour l'ID utilisateur (fallback sur Supabase Auth si AppUser est null)
  String? get userId {
    if (_currentUser != null && _currentUser!.id.isNotEmpty) {
      return _currentUser!.id;
    }
    return _authService.currentUser?.id;
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    try {
      // Écouter les changements d'état d'authentification
      _authService.authStateChanges.listen(
        (AuthState state) {
          if (state.event == AuthChangeEvent.signedIn) {
            _loadUserProfile();
          } else if (state.event == AuthChangeEvent.signedOut) {
            _currentUser = null;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('⚠️ Erreur auth state: $error');
          // Ne pas crasher, juste logger l'erreur
        },
      );

      // Charger le profil si déjà connecté
      if (isLoggedIn) {
        _loadUserProfile();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur initialisation AuthProvider: $e');
      // L'app continue même si l'auth échoue
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _currentUser = await _authService.getUserProfile().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⚠️ Timeout chargement profil utilisateur - continuons sans profil');
          return null; // Retourner null au lieu de lancer une exception
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Erreur chargement profil: $e');
      _errorMessage = e.toString();
      _currentUser = null;
      notifyListeners();
      // Ne pas crasher, l'app continue
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de l\'inscription');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError('Email ou mot de passe incorrect');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Connexion avec Google OAuth
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signInWithGoogle();

      if (response != null && response.user != null) {
        // Connexion réussie immédiatement (rare sur mobile)
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        // Redirect flow initié - l'utilisateur sera redirigé vers Google
        // Le callback sera géré par authStateChanges listener
        debugPrint('🔄 Google Sign-In redirect initié...');
        _setLoading(false);
        // Retourner true car le flow est en cours
        return true;
      }
    } catch (e) {
      debugPrint('❌ Erreur Google Sign-In: $e');
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou mot de passe incorrect';
        case 'User already registered':
          return 'Cet email est déjà utilisé';
        case 'Password should be at least 6 characters':
          return 'Le mot de passe doit contenir au moins 6 caractères';
        case 'Unable to validate email address: invalid format':
          return 'Format d\'email invalide';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}
