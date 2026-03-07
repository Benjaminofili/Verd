import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase App Check initialization and configuration.
/// 
/// App Check helps protect your backend resources from abuse by verifying that
/// requests come from legitimate apps and devices.
class AppCheckService {
  static bool _isInitialized = false;

  /// Initialize Firebase App Check with appropriate providers for different platforms.
  /// 
  /// In debug builds, uses debug provider for easier development.
  /// In release builds, uses appropriate safety providers for each platform.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        // Debug provider for development - only use in debug builds
        await FirebaseAppCheck.instance.activate(
          webProvider: ReCaptchaV3Provider('6Lc3x2MqAAAAAJ0E4v8J0lJ5V8J0J0J0J0J0J0J0'), // Replace with your reCAPTCHA site key
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        debugPrint('[AppCheck] Initialized with debug provider');
      } else {
        // Production providers
        await FirebaseAppCheck.instance.activate(
          webProvider: ReCaptchaV3Provider('6Lc3x2MqAAAAAJ0E4v8J0lJ5V8J0J0J0J0J0J0J0'), // Replace with your reCAPTCHA site key
          androidProvider: AndroidProvider.playIntegrity, // Use Play Integrity for Android
          appleProvider: AppleProvider.deviceCheck, // Use DeviceCheck for iOS
        );
        debugPrint('[AppCheck] Initialized with production providers');
      }
      
      _isInitialized = true;
      debugPrint('[AppCheck] Firebase App Check initialized successfully');
    } catch (e) {
      debugPrint('[AppCheck] Failed to initialize: $e');
      // Continue without App Check in case of initialization failure
      // This ensures the app remains functional even if App Check fails
    }
  }

  /// Get the current App Check token.
  /// 
  /// This token is automatically attached to Firebase requests.
  /// You can also manually include this token in custom backend requests.
  static Future<String?> getToken() async {
    try {
      if (!_isInitialized) {
        debugPrint('[AppCheck] Warning: App Check not initialized, initializing now...');
        await initialize();
      }
      
      final token = await FirebaseAppCheck.instance.getToken();
      debugPrint('[AppCheck] Token retrieved successfully');
      return token;
    } catch (e) {
      debugPrint('[AppCheck] Failed to get token: $e');
      return null;
    }
  }

  /// Force refresh the App Check token.
  /// 
  /// Use this when you suspect the current token might be expired
  /// or when you need a fresh token for critical operations.
  static Future<String?> refreshToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      debugPrint('[AppCheck] Token refreshed successfully');
      return token;
    } catch (e) {
      debugPrint('[AppCheck] Failed to refresh token: $e');
      return null;
    }
  }

  /// Check if App Check is initialized.
  static bool get isInitialized => _isInitialized;

  /// Set custom token auto-refresh settings.
  /// 
  /// This configures how often App Check should automatically refresh tokens.
  static void configureTokenRefresh() {
    // Configure token refresh to happen every 60 minutes
    FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    debugPrint('[AppCheck] Token auto-refresh enabled');
  }
}
