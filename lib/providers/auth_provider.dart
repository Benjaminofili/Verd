import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/repositories/auth_repository.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/local_storage.dart';
import 'package:verd/providers/notification_provider.dart';

// ─── Service-level providers ───

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  // This is correctly overridden in main.dart inside ProviderScope
  throw UnimplementedError('localStorageServiceProvider must be overridden');
});

// ─── Repository provider ───

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// ─── Auth State (reactive stream from Firebase) ───

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

// ─── Cached current user profile ───

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(localStorageServiceProvider).getCachedUser();
});

// ─── Auth Notifier (login / register / logout actions) ───

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // If the user is logged in, try to use the cached profile
    final authState = ref.watch(authStateProvider);
    return authState.whenData((user) {
      if (user == null) return null;
      return ref.read(localStorageServiceProvider).getCachedUser();
    }).value;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      await _handleFcmSetup(user.uid);
      return user;
    });
  }

  Future<void> _handleFcmSetup(String uid) async {
    try {
      final fcm = ref.read(fcmServiceProvider);
      final token = await fcm.init();
      if (token != null) {
        await ref.read(firestoreServiceProvider).saveFcmToken(uid, token);
      }
      // Re-sync topic subscriptions
      await ref.read(notificationSettingsProvider.notifier).syncSubscriptions();
    } catch (e) {
      debugPrint('[FCM] Setup failed: $e');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
          );
      await _handleFcmSetup(user.uid);
      return user;
    });
  }

  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).resetPassword(email);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);
