import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/router/app_router.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Wraps [FirebaseMessaging] for push notification management.
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Create a high importance channel for Android.
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important agricultural alerts.',
    importance: Importance.max,
  );

  /// Initialize FCM: request permission, setup local notifications/channels, and get token.
  Future<String?> init() async {
    // 1. Request permission (iOS + Android 13+)
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

    // 2. Setup Local Notifications (Android Channel creation)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(initSettings);
    }

    // 3. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Get device token
    final token = await _messaging.getToken();
    debugPrint('[FCM] Device token: $token');
    return token;
  }

  /// Listen for foreground messages and show a local notification.
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;

      // If we have a notification payload, show it via local notifications on Android
      if (notification != null && android != null && !kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon,
            ),
          ),
        );
      }
      
      handler(message);
    });
  }

  /// Listen for when the user taps a notification from background.
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message);
      handler(message);
    });
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final router = GoRouter.of(navigatorKey.currentContext!);

    switch (type) {
      case 'scan_result':
        final scanId = data['scan_id'] as String?;
        final userId = data['user_id'] as String?;
        if (scanId != null && userId != null) {
          // Navigate to scan result screen
          // In a real implementation, you'd fetch the scan result from Firestore
          router.pushNamed('scan_result', extra: {
            'scanId': scanId,
            'userId': userId,
            'fromNotification': true,
          });
        }
        break;
      case 'crop_alert':
        // Navigate to learning center for crop alerts
        router.pushNamed('learning_center');
        break;
      case 'profile_update':
        // Navigate to profile screen
        router.pushNamed('edit_profile');
        break;
      default:
        // Default navigation to home
        router.pushNamed('home');
    }
  }

  /// Check for initial message (when app is opened from terminated state)
  Future<void> checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Subscribe to a topic (e.g., 'crop_alerts').
  Future<void> subscribeTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Listen for token refreshes.
  void onTokenRefresh(void Function(String token) handler) {
    _messaging.onTokenRefresh.listen(handler);
  }
}
