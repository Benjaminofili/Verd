import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Wraps [FirebaseStorage] for uploading and managing scan images.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a scan image and returns its download URL.
  ///
  /// Path: `scans/{userId}/{scanId}.jpg`
  Future<String> uploadScanImage({
    required String userId,
    required String scanId,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('scans/$userId/$scanId.jpg');

    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // Optional: listen for progress
    uploadTask.snapshotEvents.listen((event) {
      final progress =
          (event.bytesTransferred / event.totalBytes * 100).toStringAsFixed(0);
      debugPrint('[StorageService] Upload progress: $progress%');
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Uploads a profile picture and returns its download URL.
  ///
  /// Path: `profiles/{userId}/avatar.jpg`
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('profiles/$userId/avatar.jpg');

    final snapshot = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await snapshot.ref.getDownloadURL();
  }

  /// Deletes a file from storage by its full download URL.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('[StorageService] Error deleting file: $e');
    }
  }
}
