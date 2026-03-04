import 'package:hive_flutter/hive_flutter.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/models/scan_result.dart';

/// Central service wrapping all Hive local-storage operations.
///
/// Manages three boxes:
/// - `userBox` — cached user profile
/// - `scanBox` — cached scan results (including unsynced ones)
/// - `settingsBox` — app preferences (theme, language, onboarding, etc.)
class LocalStorageService {
  static const String _userBoxName = 'users';
  static const String _scanBoxName = 'scans';
  static const String _settingsBoxName = 'settings';

  late Box<AppUser> _userBox;
  late Box<ScanResult> _scanBox;
  late Box _settingsBox;

  /// Must be called once during app init (after Hive.initFlutter()).
  Future<void> init() async {
    // Register adapters (safe to call multiple times due to internal guard)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppUserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScanResultAdapter());
    }

    _userBox = await Hive.openBox<AppUser>(_userBoxName);
    _scanBox = await Hive.openBox<ScanResult>(_scanBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // ─── User Cache ───

  Future<void> cacheUser(AppUser user) async {
    await _userBox.put(user.uid, user);
  }

  AppUser? getCachedUser() {
    if (_userBox.isEmpty) return null;
    return _userBox.values.first;
  }

  Future<void> clearUserCache() async {
    await _userBox.clear();
  }

  // ─── Scan Results Cache ───

  Future<void> cacheScanResult(ScanResult result) async {
    await _scanBox.put(result.id, result);
  }

  List<ScanResult> getCachedScans() {
    return _scanBox.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  /// Returns scans that haven't been synced to Firestore yet.
  List<ScanResult> getPendingSyncs() {
    return _scanBox.values.where((s) => !s.synced).toList();
  }

  /// Marks a local scan as synced after successful upload.
  Future<void> markSynced(String scanId, {String? remoteImageUrl}) async {
    final scan = _scanBox.get(scanId);
    if (scan != null) {
      final updated = scan.copyWith(synced: true, imageUrl: remoteImageUrl);
      await _scanBox.put(scanId, updated);
    }
  }

  Future<void> deleteScan(String scanId) async {
    await _scanBox.delete(scanId);
  }

  Future<void> clearScanCache() async {
    await _scanBox.clear();
  }

  // ─── Settings (generic key-value) ───

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // ─── Full Wipe ───

  Future<void> clearAll() async {
    await _userBox.clear();
    await _scanBox.clear();
    await _settingsBox.clear();
  }
}
