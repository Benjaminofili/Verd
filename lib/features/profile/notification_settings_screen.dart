import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/providers/notification_provider.dart';
import 'package:verd/providers/settings_provider.dart';

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
            AppLocalizations.of(context)!.back,
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.done,
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
              title: AppLocalizations.of(context)!.push_notifications,
              subtitle: AppLocalizations.of(context)!.push_notifications_desc,
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
                  AppLocalizations.of(context)!.topics,
                  style: AppTypography.h4.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            _buildToggleItem(
              context: context,
              title: AppLocalizations.of(context)!.scan_results,
              subtitle: AppLocalizations.of(context)!.scan_results_desc,
              value: topics[FcmTopics.scanResults] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.scanResults, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              title: AppLocalizations.of(context)!.learning_updates,
              subtitle: AppLocalizations.of(context)!.learning_updates_desc,
              value: topics[FcmTopics.learningUpdates] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.learningUpdates, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            _buildToggleItem(
              context: context,
              title: AppLocalizations.of(context)!.system_alerts,
              subtitle: AppLocalizations.of(context)!.system_alerts_desc,
              value: topics[FcmTopics.systemAlerts] ?? false,
              onChanged: (val) => notifier.toggleTopic(FcmTopics.systemAlerts, val),
              enabled: settingsNotifier.notificationsEnabled,
            ),
            const Divider(height: AppSpacing.xl),
            _buildToggleItem(
              context: context,
              title: AppLocalizations.of(context)!.email_notifications,
              subtitle: AppLocalizations.of(context)!.email_notifications_desc,
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
                    AppLocalizations.of(context)!.debug_tools,
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
                        SnackBar(content: Text(AppLocalizations.of(context)!.token_copied)),
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
                    AppLocalizations.of(context)!.copy_token,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: AppTypography.medium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.debug_token_desc,
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
