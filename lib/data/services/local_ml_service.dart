import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Simulates a local Machine Learning model for offline crop analysis.
/// 
/// Once the `.tflite` model is delivered by the ML team, this class 
/// will be updated to use `tflite_flutter` to run on-device inference.
class LocalMLService {
  /// Analyzes a crop image locally (offline).
  /// 
  /// Returns a JSON-like map containing the structured analysis results.
  Future<Map<String, dynamic>> analyzeCropOffline(File image) async {
    // Enforce API 26 minimum for TFLite offline inference
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 26) {
        throw Exception('Offline AI scanning requires Android 8.0+. Please connect to WiFi/Data to use Cloud AI instead.');
      }
    }

    // TODO: Implement actual TFLite inference here when the model is ready.
    
    // Simulate processing time 
    await Future.delayed(const Duration(seconds: 2));

    return {
      'status': 'success',
      'engine': 'local_tflite_mock',
      'timestamp': DateTime.now().toIso8601String(),
      'analysis': {
        'cropType': 'Unknown Crop (Offline Mode)',
        'healthStatus': 'Pending Verification',
        'confidence': 0.85,
        'diseases': [
          {
            'name': 'Possible Leaf Blight',
            'severity': 'Moderate',
            'treatment': 'Ensure proper watering and isolate affected leaves. Connect to internet for detailed Gemini analysis.'
          }
        ]
      }
    };
  }
}
