import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Wraps [FirebaseMessaging] for push notification management.
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM: request permission and get the device token.
  /// Returns the FCM token (or null if permission denied).
  Future<String?> init() async {
    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notification permission denied');
      return null;
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get device token
    final token = await _messaging.getToken();
    debugPrint('[FCM] Device token: $token');
    return token;
  }

  /// Listen for foreground messages.
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Listen for when the user taps a notification from background.
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Subscribe to a topic (e.g., 'crop_alerts').
  Future<void> subscribeTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Listen for token refreshes — important for keeping Firestore in sync.
  void onTokenRefresh(void Function(String token) handler) {
    _messaging.onTokenRefresh.listen(handler);
  }
}
