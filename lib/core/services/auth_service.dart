// lib/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Getter pour l'utilisateur actuel
  User? get currentUser => _supabase.auth.currentUser;

  // Stream pour écouter les changements d'état d'auth
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'avatar_url': '',
      },
    );

    // Créer le profil utilisateur
    if (response.user != null) {
      await _createUserProfile(response.user!);
    }

    return response;
  }

  // Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Mot de passe oublié
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.crop_guardian://reset-password',
    );
  }

  // Créer le profil utilisateur dans la table profiles
  Future<void> _createUserProfile(User user) async {
    try {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? '',
        'avatar_url': user.userMetadata?['avatar_url'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Le profil existe peut-être déjà
      print('Erreur création profil: $e');
    }
  }

  // Récupérer le profil utilisateur complet
  Future<AppUser?> getUserProfile() async {
    if (currentUser == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser!.id)
          .maybeSingle();

      if (response != null) {
        return AppUser.fromJson(response);
      }
    } catch (e) {
      print('Erreur récupération profil: $e');
    }

    return null;
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    if (currentUser == null) return;

    await _supabase.from('profiles').update({
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => currentUser != null;

  /// Connexion avec Google OAuth
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // The Supabase SDK may return different types depending on platform and flow.
      // On web it may trigger a redirect flow (returns bool/null). On native it
      // returns an AuthResponse. We handle both safely.
      final dynamic result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.externalApplication,
        redirectTo: 'com.example.crop_guardian://login-callback', // Deep link pour Android
      );

      // If the SDK returned an AuthResponse, use it
      if (result is AuthResponse) {
        if (result.user != null) await _createUserProfile(result.user!);
        return result;
      }

      // If the SDK returned a bool (often indicates a redirect was initiated),
      // return null to indicate the caller should not expect an immediate AuthResponse.
      return null;
    } catch (e) {
      print('Erreur connexion Google: $e');
      rethrow;
    }
  }
}
