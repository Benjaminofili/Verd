import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/repositories/scan_repository.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/providers/auth_provider.dart';

// ─── Service provider ───

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ─── Repository provider ───

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(storageServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// ─── Scan History Provider ───

class ScanHistoryNotifier extends AsyncNotifier<List<ScanResult>> {
  @override
  Future<List<ScanResult>> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    if (user == null) return [];

    return await ref.read(scanRepositoryProvider).getScanHistory(user.uid);
  }

  /// Refresh the scan history from Firestore.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      if (user == null) return [];
      return await ref.read(scanRepositoryProvider).getScanHistory(user.uid);
    });
  }
}

final scanHistoryProvider =
    AsyncNotifierProvider<ScanHistoryNotifier, List<ScanResult>>(
        ScanHistoryNotifier.new);

// ─── Sync status (pending count) ───

final syncStatusProvider = Provider<int>((ref) {
  return ref.watch(scanRepositoryProvider).pendingSyncCount;
});
