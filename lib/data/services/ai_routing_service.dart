import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/data/services/firestore_service.dart';

/// Routes crop scan images intelligently to the correct AI engine.
/// 
/// If online, it stores the image to trigger the Firebase Gemini Extension.
/// If offline, it routes the image to the local TFLite model.
class AIRoutingService {
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final LocalMLService _localMLService;
  final Connectivity _connectivity = Connectivity();

  AIRoutingService({
    required StorageService storageService,
    required FirestoreService firestoreService,
    required LocalMLService localMLService,
  })  : _storageService = storageService,
        _firestoreService = firestoreService,
        _localMLService = localMLService;

  /// Determines device online status, routes the image, and returns the result.
  Future<Map<String, dynamic>> routeScan({
    required String userId,
    required String scanId,
    required File image,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      // --- ONLINE PATH (Gemini Extension) ---
      
      // 1. Upload to Storage (this will trigger the Gemini Extension)
      final imageUrl = await _storageService.uploadScanImage(
        userId: userId,
        scanId: scanId,
        imageFile: image,
      );

      // 2. The Gemini Extension runs asynchronously via a Cloud Function.
      // In a real implementation, we would listen to the corresponding Firestore Document
      // where the extension writes its output, waiting for the results to populate.
      // For now, we simulate waiting for the Gemini Cloud Function.

      await Future.delayed(const Duration(seconds: 4));

      return {
        'status': 'success',
        'engine': 'gemini_cloud',
        'timestamp': DateTime.now().toIso8601String(),
        'imageUrl': imageUrl,
        'analysis': {
          'cropType': 'Cassava (Online Cloud Analysis)',
          'healthStatus': 'Treated',
          'confidence': 0.98,
          'diseases': [
            {
              'name': 'Cassava Mosaic Disease (CMD)',
              'severity': 'Low',
              'treatment': 'Continue monitoring. Gemini Cloud has confirmed standard growth patterns.'
            }
          ]
        }
      };
    } else {
      // --- OFFLINE PATH (Local TFLite Model) ---
      return await _localMLService.analyzeCropOffline(image);
    }
  }
}
