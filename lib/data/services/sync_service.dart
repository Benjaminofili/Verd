import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:verd/data/services/local_storage.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/storage_service.dart';

/// Offline-first sync engine.
///
/// Watches network connectivity and automatically uploads pending
/// (unsynced) scan results to Firestore + Firebase Storage
/// when the device comes back online.
class SyncService {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncing = false;

  SyncService({
    required LocalStorageService localStorage,
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _localStorage = localStorage,
        _firestoreService = firestoreService,
        _storageService = storageService;

  /// Start listening for connectivity changes.
  void startListening() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        syncPendingScans();
      }
    });
  }

  /// Stop listening.
  void stopListening() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Check current connectivity status.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Upload all pending (unsynced) scan results.
  Future<void> syncPendingScans() async {
    if (_isSyncing) return; // Prevent overlapping syncs
    _isSyncing = true;

    try {
      final pending = _localStorage.getPendingSyncs();
      if (pending.isEmpty) {
        debugPrint('[SyncService] No pending scans to sync.');
        _isSyncing = false;
        return;
      }

      debugPrint('[SyncService] Syncing ${pending.length} pending scans...');

      for (final scan in pending) {
        try {
          String? remoteUrl;

          // Upload image to Firebase Storage if we have a local path
          if (scan.localImagePath != null) {
            final file = File(scan.localImagePath!);
            if (await file.exists()) {
              remoteUrl = await _storageService.uploadScanImage(
                userId: scan.userId,
                scanId: scan.id,
                imageFile: file,
              );
            }
          }

          // Save the scan result to Firestore
          final syncedScan = scan.copyWith(
            synced: true,
            imageUrl: remoteUrl ?? scan.imageUrl,
          );
          await _firestoreService.saveScanResult(scan.userId, syncedScan);

          // Mark local copy as synced
          await _localStorage.markSynced(scan.id, remoteImageUrl: remoteUrl);

          debugPrint('[SyncService] Synced scan: ${scan.id}');
        } catch (e) {
          debugPrint('[SyncService] Failed to sync scan ${scan.id}: $e');
          // Continue with next scan — don't block the entire batch
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Number of scans waiting to be synced (for UI badge).
  int get pendingCount => _localStorage.getPendingSyncs().length;
}
