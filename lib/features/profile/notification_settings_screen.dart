import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/providers/notification_provider.dart';
import 'package:verd/providers/settings_provider.dart';
import 'package:df_localization/df_localization.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topics = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'back'.tr(),
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          'notifications'.tr(),
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'done'.tr(),
              style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            _buildToggleItem(
              context: context,
              title: 'push_notifications'.tr(),
              subtitle: 'push_notifications_desc'.tr(),
              value: settingsNotifier.notificationsEnabled,
              onChanged: (val) async {
                if (val) {
                  // Initialize FCM service if turning on
                  await ref.read(fcmServiceProvider).init();
                }
                await settingsNotifier.setNotificationsEnabled(val);
              },
            ),
            const Divider(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'topics'.tr(),
                  style: AppTypography.h4.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            _buildToggleItem(
              context: context,
              title: 'scan_results'.tr(),
              subtitle: 'scan_results_desc'.tr(),
              value: topics[FcmTopics.scanResults] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.scanResults, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              title: 'learning_updates'.tr(),
              subtitle: 'learning_updates_desc'.tr(),
              value: topics[FcmTopics.learningUpdates] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.learningUpdates, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              title: 'system_alerts'.tr(),
              subtitle: 'system_alerts_desc'.tr(),
              value: topics[FcmTopics.systemAlerts] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.systemAlerts, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            const Divider(height: AppSpacing.xl),
            _buildToggleItem(
              context: context,
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: true, // Mocked for now
              onChanged: (val) {},
              enabled: true,
            ),
            if (kDebugMode) ...[
              const Divider(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'debug_tools'.tr(),
                    style: AppTypography.h4.copyWith(
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              AppCard(
                variant: AppCardVariant.outlined,
                onTap: () async {
                  final token = await ref.read(fcmServiceProvider).init();
                  if (token != null) {
                    await Clipboard.setData(ClipboardData(text: token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('token_copied'.tr())),
                      );
                    }
                  }
                },
                child: ListTile(
                  leading: Icon(
                    Icons.copy_outlined,
                    color: theme.brightness == Brightness.dark ? AppColors.errorLight : AppColors.error,
                  ),
                  title: Text(
                    'copy_token'.tr(),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: AppTypography.medium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Use this to send test messages from Firebase Console',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: theme.brightness == Brightness.dark 
                  ? theme.colorScheme.surfaceContainerHighest 
                  : AppColors.gray300,
            ),
          ],
        ),
      ),
    );
  }
}
