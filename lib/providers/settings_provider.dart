import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/services/local_storage.dart';
import 'package:verd/providers/auth_provider.dart';

/// Manages app-level settings persisted via Hive.
class SettingsNotifier extends Notifier<Map<String, dynamic>> {
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyOnboardingComplete = 'onboarding_complete';

  LocalStorageService get _storage => ref.read(localStorageServiceProvider);

  @override
  Map<String, dynamic> build() {
    return {
      keyLanguage: _storage.getSetting<String>(keyLanguage, defaultValue: 'en') ?? 'en',
      keyNotificationsEnabled: _storage.getSetting<bool>(keyNotificationsEnabled, defaultValue: true) ?? true,
      keyOnboardingComplete: _storage.getSetting<bool>(keyOnboardingComplete, defaultValue: false) ?? false,
    };
  }

  Future<void> setLanguage(String languageCode) async {
    await _storage.setSetting(keyLanguage, languageCode);
    state = {...state, keyLanguage: languageCode};
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.setSetting(keyNotificationsEnabled, enabled);
    state = {...state, keyNotificationsEnabled: enabled};
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _storage.setSetting(keyOnboardingComplete, complete);
    state = {...state, keyOnboardingComplete: complete};
  }

  String get language => state[keyLanguage] as String;
  bool get notificationsEnabled => state[keyNotificationsEnabled] as bool;
  bool get onboardingComplete => state[keyOnboardingComplete] as bool;
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Map<String, dynamic>>(
        SettingsNotifier.new);
