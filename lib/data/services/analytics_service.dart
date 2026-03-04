import 'package:firebase_analytics/firebase_analytics.dart';

/// Wraps [FirebaseAnalytics] for tracking events and user properties.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// The navigator observer — attach this to GoRouter for automatic
  /// screen view tracking.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a screen view.
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Log a login event.
  Future<void> logLogin({String method = 'email'}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log a sign-up event.
  Future<void> logSignUp({String method = 'email'}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log a plant scan event.
  Future<void> logScan({
    required String plantName,
    required String diagnosis,
    required double confidence,
  }) async {
    await _analytics.logEvent(
      name: 'plant_scan',
      parameters: {
        'plant_name': plantName,
        'diagnosis': diagnosis,
        'confidence': confidence,
      },
    );
  }

  /// Set user properties for segmentation.
  Future<void> setUserProperties({
    required String userId,
    String? farmLocation,
  }) async {
    await _analytics.setUserId(id: userId);
    if (farmLocation != null) {
      await _analytics.setUserProperty(
        name: 'farm_location',
        value: farmLocation,
      );
    }
  }

  /// Log a custom event.
  Future<void> logCustomEvent(String name, Map<String, Object>? params) async {
    await _analytics.logEvent(name: name, parameters: params);
  }
}
