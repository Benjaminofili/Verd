import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/data/services/firestore_service.dart';

/// Routes crop scan images intelligently to the correct AI engine.
/// 
/// If online, it stores the image to trigger the Firebase Gemini Extension.
/// If offline, it routes the image to the local TFLite model.
class AIRoutingService {
  final StorageService _storageService;
  final LocalMLService _localMLService;
  final FirestoreService _firestoreService;
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
    final isOnline = !connectivityResult.contains(ConnectivityResult.none) && connectivityResult.isNotEmpty;

    if (isOnline) {
      // --- ONLINE PATH (Gemini Extension) ---
      
      // 1. Upload to Storage
      final imageUrl = await _storageService.uploadScanImage(
        userId: userId,
        scanId: scanId,
        imageFile: image,
      );

      debugPrint('[AIRoutingService] Creating trigger document at: users/$userId/scans/$scanId');
      
      // 2. Create the Firestore document to trigger the Gemini Extension
      final initialScan = ScanResult(
        id: scanId,
        userId: userId,
        imageUrl: imageUrl, 
        plantName: 'Analyzing...', 
        diagnosis: 'Pending analysis', 
        confidence: 0.0,
        recommendations: [],
        scannedAt: DateTime.now(),
        synced: true,
      );
      
      final docData = initialScan.toFirestore();
      // Explicitly add 'prompt' and 'image' fields just in case the Extension
      // is configured to look for those specifically.
      docData['prompt'] = 'Analyze this crop image. Identify the cropType, healthStatus (Healthy/Warning/Critical), confidence score, and specific diseases with treatments. Return result in JSON format.';
      docData['image'] = imageUrl; 
      
      debugPrint('[AIRoutingService] Sending trigger to Firestore...');
      await _firestoreService.saveScanRaw(userId, scanId, docData);
      debugPrint('[AIRoutingService] Trigger sent. Waiting for AI result...');

      // 3. Listen to Firestore for the Gemini Extension result
      final result = await _firestoreService.waitForScanAnalysis(
        userId: userId,
        scanId: scanId,
        timeout: const Duration(seconds: 45),
      );

      if (result == null) {
        throw Exception('Analysis timed out. Please try again or check your connection.');
      }

      // 3. Format result to match our app's structure
      // The extension returns stringified JSON in the 'output' field
      Map<String, dynamic> analysisData;
      
      // Handle the case where FirestoreService caught an error
      if (result['analysis'] != null) {
        debugPrint('[AIRoutingService] AI Extension reported an error: ${result['analysis']}');
        return {
          'status': 'error',
          'engine': 'gemini_cloud_extension',
          'analysis': result['analysis']
        };
      }

      final dynamic output = result['output'];
      if (output == null) {
        debugPrint('[AIRoutingService] Result arrived but "output" field is null!');
        throw Exception('AI analysis failed (empty response).');
      }

      debugPrint('[AIRoutingService] AI Result received. Parsing output...');
      if (output is String) {
        // Sometimes Gemini returns markdown blocks, so we strip them
        String rawJson = output;
        rawJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();
        try {
          analysisData = jsonDecode(rawJson) as Map<String, dynamic>;
        } catch (e) {
          analysisData = {
            'cropType': 'Unknown (Parse Error)',
            'healthStatus': 'Error',
            'confidence': 0.0,
            'diseases': [
              {
                'name': 'Analysis Formatting Error',
                'severity': 'Critical',
                'treatment': 'The AI returned invalid format. Raw output: $rawJson'
              }
            ]
          };
        }
      } else if (result['output'] is Map) {
        analysisData = Map<String, dynamic>.from(result['output'] as Map);
      } else {
         throw Exception('Analysis failed or returned unexpected format.');
      }

      return {
        'status': 'success',
        'engine': 'gemini_cloud_extension',
        'timestamp': DateTime.now().toIso8601String(),
        'imageUrl': imageUrl,
        'analysis': analysisData
      };
    } else {
      // --- OFFLINE PATH (Local TFLite Model) ---
      return await _localMLService.analyzeCropOffline(image);
    }
  }
}
