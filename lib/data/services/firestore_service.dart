import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  /// Directly updates a scan document with raw data.
  Future<void> updateScanRaw(String uid, String scanId, Map<String, dynamic> data) async {
    await _scansCol(uid).doc(scanId).update(data);
  }

  /// Sets (creates or overwrites) a scan document with raw data.
  Future<void> saveScanRaw(String uid, String scanId, Map<String, dynamic> data) async {
    await _scansCol(uid).doc(scanId).set(data);
  }

  /// Get all scans for a user, ordered by most recent.
  Future<List<ScanResult>> getUserScans(String uid, {int? limit}) async {
    var query = _scansCol(uid).orderBy('scannedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ScanResult.fromFirestore(doc)).toList();
  }

  /// Listens to a scan document and waits for the Gemini Extension to populate the 'output' field.
  Future<Map<String, dynamic>?> waitForScanAnalysis({
    required String userId,
    required String scanId,
    required Duration timeout,
  }) async {
    try {
      final docRef = _scansCol(userId).doc(scanId);

      // Listen to the document stream
      return await docRef.snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        final data = snapshot.data();
        if (data == null) return null;

        // 1. Check for success field (matches Extension config)
        if (data.containsKey('output')) {
          final output = data['output'];
          
          // Check if the output itself is a structured error from the extension
          if (output is Map && 
              (output['cropType'] == 'Error' || 
               output['healthStatus']?.toString().contains('Error') == true)) {
            return {
              'analysis': {
                'cropType': 'Error',
                'healthStatus': 'Configuration Error',
                'confidence': 0.0,
                'diseases': [
                  {
                    'name': 'Extension Error',
                    'severity': 'Critical',
                    'treatment': output['diseases']?.first['treatment']?.toString() ?? 'Model configuration invalid.'
                  }
                ]
              }
            };
          }
          return data;
        }

        // 2. Check for explicit error fields
        if (data.containsKey('error') || data.containsKey('errorMessage')) {
          return {
            'status': 'error',
            'error': data['error'] ?? data['errorMessage'],
            'analysis': {
              'cropType': 'Error',
              'healthStatus': 'Analysis Failed',
              'confidence': 0.0,
              'diseases': [
                {
                  'name': 'System Error',
                  'severity': 'High',
                  'treatment': data['error']?.toString() ?? data['errorMessage']?.toString() ?? 'Check Cloud Function logs.'
                }
              ]
            }
          };
        }

        // 3. Check for 'status' field (some versions use this for progress/error)
        final status = data['status'];
        if (status is Map && status.containsKey('error')) {
           return {
            'analysis': {
              'cropType': 'Error',
              'healthStatus': 'Extension Config Error',
              'diseases': [{'name': 'Status Error', 'severity': 'Critical', 'treatment': status['error'].toString()}]
            }
          };
        }

        return null; // Keep waiting
      }).firstWhere(
        (data) => data != null,
      ).timeout(timeout);
    } catch (e) {
      debugPrint('[FirestoreService] Timeout or Error waiting for analysis: $e');
      return null;
    }
  }

  /// Get scans for a user by crop type.
  Future<List<ScanResult>> getCropScans(String uid, String cropType) async {
    final snapshot = await _scansCol(uid)
        .where('plantName', isEqualTo: cropType)
        .orderBy('scannedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ScanResult.fromFirestore(doc)).toList();
  }

  /// Update user's crop stats.
  Future<void> updateCropStats({
    required String userId,
    required String cropType,
    required String healthStatus,
  }) async {
    // Basic implementation for stats tracking
    final statsRef = _usersCol.doc(userId).collection('stats').doc(cropType);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(statsRef);
      if (!doc.exists) {
        transaction.set(statsRef, {
          'cropType': cropType,
          'totalScans': 1,
          'healthyScans': healthStatus == 'healthy' ? 1 : 0,
        });
      } else {
        final currentTotal = doc.data()?['totalScans'] ?? 0;
        final currentHealthy = doc.data()?['healthyScans'] ?? 0;
        transaction.update(statsRef, {
          'totalScans': currentTotal + 1,
          'healthyScans': healthStatus == 'healthy' ? currentHealthy + 1 : currentHealthy,
        });
      }
    });
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
