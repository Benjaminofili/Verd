import 'package:firebase_auth/firebase_auth.dart';

import 'package:verd/data/models/user.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/local_storage.dart';

/// Orchestrates authentication flow across Firebase Auth,
/// Firestore (user profiles), and local Hive cache.
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorage;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required LocalStorageService localStorage,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _localStorage = localStorage;

  /// Stream of raw Firebase auth state changes.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Currently signed-in Firebase user.
  User? get currentFirebaseUser => _authService.currentUser;

  /// Login with email and password.
  Future<AppUser> login(String email, String password) async {
    final credential = await _authService.signInWithEmail(email, password);
    final uid = credential.user!.uid;

    AppUser? profile = await _firestoreService.getUserProfile(uid);
    profile ??= AppUser(
      uid: uid,
      email: email.trim(),
      displayName: credential.user!.displayName ?? '',
      createdAt: DateTime.now(),
    );

    await _localStorage.cacheUser(profile);
    return profile;
  }

  /// Register a new account.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.createAccount(email, password);
    final uid = credential.user!.uid;

    await _authService.updateDisplayName(name);

    final user = AppUser(
      uid: uid,
      email: email.trim(),
      displayName: name.trim(),
      createdAt: DateTime.now(),
    );
    await _firestoreService.createUserProfile(user);

    await _localStorage.cacheUser(user);
    return user;
  }

  /// Sign in with Google.
  /// Returns null if the user cancelled the Google sign-in flow.
  Future<AppUser?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null; // User cancelled

    final firebaseUser = credential.user!;
    final uid = firebaseUser.uid;

    // Check if user profile already exists in Firestore
    AppUser? profile = await _firestoreService.getUserProfile(uid);

    if (profile == null) {
      // First-time Google sign-in — create a Firestore profile
      profile = AppUser(
        uid: uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUserProfile(profile);
    }

    await _localStorage.cacheUser(profile);
    return profile;
  }

  /// Send a passwordless email link.
  Future<void> sendSignInLink(String email) async {
    await _authService.sendSignInLinkToEmail(email);
  }

  /// Complete passwordless email link sign-in.
  Future<AppUser> completeEmailLinkSignIn({
    required String email,
    required String emailLink,
  }) async {
    final credential = await _authService.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
    final uid = credential.user!.uid;

    AppUser? profile = await _firestoreService.getUserProfile(uid);
    profile ??= AppUser(
      uid: uid,
      email: email.trim(),
      displayName: credential.user!.displayName ?? '',
      createdAt: DateTime.now(),
    );

    // Create profile if new user
    if (await _firestoreService.getUserProfile(uid) == null) {
      await _firestoreService.createUserProfile(profile);
    }

    await _localStorage.cacheUser(profile);
    return profile;
  }

  /// Check if a link is an email sign-in link.
  bool isSignInWithEmailLink(String link) {
    return _authService.isSignInWithEmailLink(link);
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordReset(email);
  }

  /// Logout: sign out of Firebase + Google and clear local cache.
  Future<void> logout() async {
    await _authService.signOut();
    await _localStorage.clearAll();
  }

  /// Delete account: wipe Firestore data → delete Firebase Auth user → clear cache.
  Future<void> deleteAccount() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.deleteAllUserData(uid);
    }
    await _authService.deleteAccount();
    await _localStorage.clearAll();
  }

  /// Get cached user (for offline scenarios).
  AppUser? getCachedUser() => _localStorage.getCachedUser();

  /// Refresh profile from Firestore and update cache.
  Future<AppUser?> refreshProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    final profile = await _firestoreService.getUserProfile(uid);
    if (profile != null) {
      await _localStorage.cacheUser(profile);
    }
    return profile;
  }
}

