import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRMATION DIALOG
// Use for destructive or irreversible actions (delete, logout, etc.)
// and for general confirm/cancel prompts.
//
// Usage:
//   final confirmed = await ConfirmationDialog.show(context,
//     title: 'Delete Scan?',
//     message: 'This cannot be undone.',
//     isDangerous: true,
//   );
//   if (confirmed == true) doDelete();
// ═══════════════════════════════════════════════════════════════════════════

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;
  final Widget? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDangerous = false,
    this.icon,
  });

  // ── Static show helpers ────────────────────────────────────────────────

  /// Generic confirm/cancel dialog. Returns true if confirmed.
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDangerous = false,
        Widget? icon,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
        icon: icon,
      ),
    );
  }

  /// Shortcut for delete confirmations.
  static Future<bool?> delete(
      BuildContext context, {
        required String itemName,
        String? customMessage,
      }) {
    return show(
      context,
      title: 'Delete $itemName?',
      message: customMessage ??
          'This action cannot be undone. "$itemName" will be permanently deleted.',
      confirmLabel: AppLocalizations.of(context)!.delete,
      cancelLabel: AppLocalizations.of(context)!.cancel,
      isDangerous: true,
      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 32),
    );
  }

  /// Shortcut for logout confirmation.
  static Future<bool?> logout(BuildContext context) {
    return show(
      context,
      title: AppLocalizations.of(context)!.logout_q,
      message: AppLocalizations.of(context)!.logout_desc,
      confirmLabel: AppLocalizations.of(context)!.logout,
      cancelLabel: AppLocalizations.of(context)!.stay,
      isDangerous: false,
      icon: const Icon(Icons.logout_outlined,
          color: AppColors.textSecondary, size: 32),
    );
  }

  /// Shortcut for discard unsaved changes.
  static Future<bool?> discardChanges(BuildContext context) {
    return show(
      context,
      title: AppLocalizations.of(context)!.discard_changes_q,
      message: AppLocalizations.of(context)!.discard_changes_desc,
      confirmLabel: AppLocalizations.of(context)!.discard,
      cancelLabel: AppLocalizations.of(context)!.keep_editing,
      isDangerous: true,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    final confirmColor = isDangerous ? theme.colorScheme.error : theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl)),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      // Constrain width on tablets
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sw < 600 ? sw * 0.88 : 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              if (icon != null) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDangerous
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Title
              Text(
                title,
                style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Message
              Text(
                message,
                style: AppTypography.body
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Buttons
              Row(children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(
                          color: theme.colorScheme.outlineVariant, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(AppRadius.button)),
                    ),
                    child: Text(cancelLabel,
                        style: AppTypography.button
                            .copyWith(color: theme.colorScheme.onSurface)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(AppRadius.button)),
                    ),
                    child: Text(confirmLabel,
                        style: AppTypography.button.copyWith(color: theme.colorScheme.onPrimary)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}