import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, outlined }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? icon; // mapped to leadingIcon for convenience
  final Color? customColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.icon,
    this.customColor,
  });

  /// Vertical padding scaled relative to screen height for responsiveness
  EdgeInsets _padding(BuildContext context) {
    final sh = MediaQuery.sizeOf(context).height;
    final vPad = switch (size) {
      AppButtonSize.small  => sh * 0.010,
      AppButtonSize.medium => sh * 0.013,
      AppButtonSize.large  => sh * 0.018,
    };
    final hPad = switch (size) {
      AppButtonSize.small  => AppSpacing.lg,
      AppButtonSize.medium => AppSpacing.xl,
      AppButtonSize.large  => AppSpacing.xxl,
    };
    return EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);
  }

  /// Text style capped at 1.3× so buttons don't overflow on large-text a11y
  TextStyle _textStyle(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final base = size == AppButtonSize.small
        ? AppTypography.buttonSmall
        : AppTypography.button;
    return base.copyWith(fontSize: (base.fontSize ?? 16) * scale);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = !isLoading && !isDisabled && onPressed != null;
    final Color baseColor = customColor ?? AppColors.primary;

    final loaderColor = variant == AppButtonVariant.primary
        ? AppColors.textWhite
        : baseColor;

    Widget label = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null || icon != null) ...[
          leadingIcon ?? icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            text,
            style: _textStyle(context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailingIcon!,
        ],
      ],
    );

    final ButtonStyle style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: baseColor,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
        padding: _padding(context),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.backgroundSecondary,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.gray100,
        disabledForegroundColor: AppColors.gray400,
        padding: _padding(context),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive ? AppColors.gray300 : AppColors.gray200,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      AppButtonVariant.ghost => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: baseColor,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.gray400,
        padding: _padding(context),
        elevation: 0,
        shadowColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      AppButtonVariant.outlined => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.gray400,
        padding: _padding(context),
        elevation: 0,
        shadowColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive ? AppColors.gray300 : AppColors.gray200,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    };

    return ConstrainedBox(
      // 44px minimum ensures iOS HIG / Material touch target compliance
      constraints: const BoxConstraints(minHeight: 44),
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: style,
          child: label,
        ),
      ),
    );
  }
}