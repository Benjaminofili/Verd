import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/data/services/local_storage.dart';

/// Orchestrates scan operations across Firebase Storage,
/// Firestore, and local Hive cache (offline-first).
class ScanRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final LocalStorageService _localStorage;
  final _uuid = const Uuid();

  ScanRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required LocalStorageService localStorage,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        _localStorage = localStorage;

  /// Save a new scan result.
  ///
  /// 1. Saves to Hive immediately (offline-first).
  /// 2. If online, uploads image + saves to Firestore.
  Future<ScanResult> saveScan({
    required String userId,
    required String plantName,
    required String diagnosis,
    required double confidence,
    required List<String> recommendations,
    File? imageFile,
  }) async {
    final scanId = _uuid.v4();
    
    // Create the local scan result
    var scan = ScanResult(
      id: scanId,
      userId: userId,
      localImagePath: imageFile?.path,
      plantName: plantName,
      diagnosis: diagnosis,
      confidence: confidence,
      recommendations: recommendations,
      scannedAt: DateTime.now(),
      synced: false,
    );

    // Save locally first (works offline)
    await _localStorage.cacheScanResult(scan);

    // Attempt remote sync
    try {
      String? remoteUrl;
      if (imageFile != null && await imageFile.exists()) {
        remoteUrl = await _storageService.uploadScanImage(
          userId: userId,
          scanId: scanId,
          imageFile: imageFile,
        );
      }

      final syncedScan = scan.copyWith(synced: true, imageUrl: remoteUrl);
      await _firestoreService.saveScanResult(userId, syncedScan);
      await _localStorage.markSynced(scanId, remoteImageUrl: remoteUrl);

      scan = syncedScan;
      debugPrint('[ScanRepository] Scan saved and synced: $scanId');
    } catch (e) {
      debugPrint('[ScanRepository] Saved locally, sync pending: $e');
      // Scan is still saved locally and will be synced later by SyncService
    }

    return scan;
  }

  /// Get the user's scan history.
  /// Merges local (Hive) and remote (Firestore) results.
  Future<List<ScanResult>> getScanHistory(String userId) async {
    // Start with local cache
    final localScans = _localStorage.getCachedScans();

    try {
      // Fetch remote and merge
      final remoteScans = await _firestoreService.getUserScans(userId);

      // Build a map by ID for deduplication
      final scanMap = <String, ScanResult>{};
      for (final scan in localScans) {
        scanMap[scan.id] = scan;
      }
      for (final scan in remoteScans) {
        // Remote takes precedence (it's the authoritative source)
        scanMap[scan.id] = scan;
      }

      final merged = scanMap.values.toList()
        ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return merged;
    } catch (e) {
      debugPrint('[ScanRepository] Using local cache only: $e');
      // Offline — return whatever we have locally
      return localScans;
    }
  }

  /// Delete a scan from both local and remote.
  Future<void> deleteScan(String userId, String scanId) async {
    await _localStorage.deleteScan(scanId);
    try {
      await _firestoreService.deleteScan(userId, scanId);
    } catch (e) {
      debugPrint('[ScanRepository] Remote delete failed: $e');
    }
  }

  /// Number of unsynced scans.
  int get pendingSyncCount => _localStorage.getPendingSyncs().length;
}
