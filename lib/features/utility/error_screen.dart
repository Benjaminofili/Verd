import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ERROR SCREEN
// Full-page error screen for unrecoverable errors.
// Variants: generic, network, server, permission denied
//
// Usage:
//   // In GoRouter errorBuilder:
//   errorBuilder: (_, state) => ErrorScreen.generic(onRetry: () => context.go('/'))
//
//   // Directly:
//   ErrorScreen.network(onRetry: _reload)
//   ErrorScreen.server(onRetry: _reload)
// ═══════════════════════════════════════════════════════════════════════════

enum _ErrorType { generic, network, server, permission }

class ErrorScreen extends StatefulWidget {
  final String title;
  final String message;
  final String retryLabel;
  final String? secondaryLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondary;
  final _ErrorType _type;

  const ErrorScreen._({
    required this.title,
    required this.message,
    required this.retryLabel,
    required _ErrorType type,
    this.secondaryLabel,
    this.onRetry,
    this.onSecondary,
  }) : _type = type;

  // ── Named constructors ─────────────────────────────────────────────────

  factory ErrorScreen.generic({
    String title = 'Something Went Wrong',
    String message = 'An unexpected error occurred.\nPlease try again.',
    String retryLabel = 'Try Again',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen._(
        title: title,
        message: message,
        retryLabel: retryLabel,
        type: _ErrorType.generic,
        secondaryLabel: onGoHome != null ? 'Go to Home' : null,
        onRetry: onRetry,
        onSecondary: onGoHome,
      );

  factory ErrorScreen.network({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen._(
        title: 'No Internet Connection',
        message:
        'Please check your network settings\nand try again.',
        retryLabel: 'Retry',
        type: _ErrorType.network,
        secondaryLabel: onGoHome != null ? 'Go to Home' : null,
        onRetry: onRetry,
        onSecondary: onGoHome,
      );

  factory ErrorScreen.server({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen._(
        title: 'Server Error',
        message:
        'Our servers are experiencing issues.\nPlease try again in a moment.',
        retryLabel: 'Try Again',
        type: _ErrorType.server,
        secondaryLabel: onGoHome != null ? 'Go to Home' : null,
        onRetry: onRetry,
        onSecondary: onGoHome,
      );

  factory ErrorScreen.permission({
    String? featureName,
    VoidCallback? onOpenSettings,
    VoidCallback? onGoBack,
  }) =>
      ErrorScreen._(
        title: 'Permission Required',
        message:
        '${featureName ?? 'This feature'} requires a permission\nthat has been denied. Please enable it\nin your device settings.',
        retryLabel: 'Open Settings',
        type: _ErrorType.permission,
        secondaryLabel: 'Go Back',
        onRetry: onOpenSettings,
        onSecondary: onGoBack,
      );

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeSlide =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _iconBg => switch (widget._type) {
    _ErrorType.network    => AppColors.info.withValues(alpha: 0.1),
    _ErrorType.server     => AppColors.warning.withValues(alpha: 0.1),
    _ErrorType.permission => AppColors.warning.withValues(alpha: 0.1),
    _ErrorType.generic    => AppColors.error.withValues(alpha: 0.1),
  };

  Color get _iconColor => switch (widget._type) {
    _ErrorType.network    => AppColors.info,
    _ErrorType.server     => AppColors.warning,
    _ErrorType.permission => AppColors.warning,
    _ErrorType.generic    => AppColors.error,
  };

  IconData get _icon => switch (widget._type) {
    _ErrorType.network    => Icons.wifi_off_outlined,
    _ErrorType.server     => Icons.cloud_off_outlined,
    _ErrorType.permission => Icons.lock_outline,
    _ErrorType.generic    => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    final scaleFactor =
    MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final iconSize = (sw * 0.25).clamp(80.0, 110.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeSlide,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(_fadeSlide),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.1,
                  vertical: AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: _iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_icon,
                          size: iconSize * 0.44, color: _iconColor),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Title
                    Text(
                      widget.title,
                      style: AppTypography.h2.copyWith(
                        fontSize: AppTypography.xxl * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Message
                    Text(
                      widget.message,
                      style: AppTypography.body.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.base * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.huge),

                    // Primary CTA
                    if (widget.onRetry != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onRetry,
                          icon: Icon(
                            widget._type == _ErrorType.network
                                ? Icons.refresh
                                : widget._type == _ErrorType.permission
                                ? Icons.settings_outlined
                                : Icons.refresh,
                            size: 18,
                          ),
                          label: Text(widget.retryLabel,
                              style: AppTypography.button),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.button)),
                          ),
                        ),
                      ),

                    // Secondary CTA
                    if (widget.secondaryLabel != null &&
                        widget.onSecondary != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onSecondary,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                                color: AppColors.gray300, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.button)),
                          ),
                          child: Text(
                            widget.secondaryLabel!,
                            style: AppTypography.button
                                .copyWith(color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}