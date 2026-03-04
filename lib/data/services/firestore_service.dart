import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/models/scan_result.dart';

/// Wraps [FirebaseFirestore] with typed methods for Verd's collections.
///
/// Collections:
/// - `users/{uid}` — user profiles
/// - `users/{uid}/scans/{scanId}` — per-user scan results
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence (Firestore caches data locally by default
    // on mobile, but this ensures it's explicitly active).
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  // ─── Users ───

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Create or overwrite a user profile document.
  Future<void> createUserProfile(AppUser user) async {
    await _usersCol.doc(user.uid).set(user.toFirestore());
  }

  /// Get a user profile by UID.
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Update specific fields on the user profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersCol.doc(uid).update(data);
  }

  /// Store the FCM token on the user document.
  Future<void> saveFcmToken(String uid, String token) async {
    await _usersCol.doc(uid).update({'fcmToken': token});
  }

  // ─── Scans (sub-collection under user) ───

  CollectionReference<Map<String, dynamic>> _scansCol(String uid) =>
      _usersCol.doc(uid).collection('scans');

  /// Save a scan result to Firestore.
  Future<void> saveScanResult(String uid, ScanResult scan) async {
    await _scansCol(uid).doc(scan.id).set(scan.toFirestore());
  }

  /// Get all scans for a user, ordered by most recent.
  Future<List<ScanResult>> getUserScans(String uid) async {
    final snapshot = await _scansCol(uid)
        .orderBy('scannedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ScanResult.fromFirestore(doc)).toList();
  }

  /// Delete a single scan.
  Future<void> deleteScan(String uid, String scanId) async {
    await _scansCol(uid).doc(scanId).delete();
  }

  /// Delete all user data — called when user deletes their account.
  Future<void> deleteAllUserData(String uid) async {
    // Delete scans sub-collection
    final scans = await _scansCol(uid).get();
    for (final doc in scans.docs) {
      await doc.reference.delete();
    }
    // Delete user document
    await _usersCol.doc(uid).delete();
  }
}
