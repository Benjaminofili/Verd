import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/services/fcm_service.dart';
import 'package:verd/data/services/local_storage.dart';
import 'package:verd/providers/auth_provider.dart';

/// Provider for the FCM service instance.
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

/// Topic constants for FCM.
class FcmTopics {
  static const String scanResults = 'scan_results';
  static const String learningUpdates = 'learning_updates';
  static const String systemAlerts = 'system_alerts';
  
  static List<String> get all => [scanResults, learningUpdates, systemAlerts];
}

/// Manages specific notification category subscriptions.
class NotificationSettingsNotifier extends Notifier<Map<String, bool>> {
  LocalStorageService get _storage => ref.read(localStorageServiceProvider);
  FCMService get _fcm => ref.read(fcmServiceProvider);

  @override
  Map<String, bool> build() {
    // Load persisted topic preferences from Hive
    return {
      FcmTopics.scanResults: _storage.getSetting<bool>('notif_${FcmTopics.scanResults}', defaultValue: true) ?? true,
      FcmTopics.learningUpdates: _storage.getSetting<bool>('notif_${FcmTopics.learningUpdates}', defaultValue: true) ?? true,
      FcmTopics.systemAlerts: _storage.getSetting<bool>('notif_${FcmTopics.systemAlerts}', defaultValue: true) ?? true,
    };
  }

  /// Toggle a specific topic subscription.
  Future<void> toggleTopic(String topic, bool enabled) async {
    state = {...state, topic: enabled};
    await _storage.setSetting('notif_$topic', enabled);
    
    if (enabled) {
      await _fcm.subscribeTopic(topic);
      debugPrint('[FCM] Subscribed to $topic');
    } else {
      await _fcm.unsubscribeTopic(topic);
      debugPrint('[FCM] Unsubscribed from $topic');
    }
  }

  /// Re-sync all topic subscriptions (useful on login).
  Future<void> syncSubscriptions() async {
    for (final entry in state.entries) {
      if (entry.value) {
        await _fcm.subscribeTopic(entry.key);
      } else {
        await _fcm.unsubscribeTopic(entry.key);
      }
    }
    debugPrint('[FCM] Synced all subscriptions');
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, Map<String, bool>>(
        NotificationSettingsNotifier.new);
