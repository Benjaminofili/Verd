import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// INFO DIALOG
// Alert (single OK), Success, and Bottom Sheet variants.
//
// Usage:
//   // Alert
//   await InfoDialog.alert(context, title: 'Session Expired', message: '...');
//
//   // Success (auto-dismisses)
//   await InfoDialog.success(context, title: 'Profile Updated!');
//
//   // Bottom sheet
//   await InfoDialog.bottomSheet(context, title: 'Options', child: ...);
//
//   // Options list
//   final result = await InfoDialog.options(context, options: [...]);
// ═══════════════════════════════════════════════════════════════════════════

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String okLabel;
  final Widget? icon;

  const InfoDialog._({
    required this.title,
    required this.message,
    required this.okLabel,
    required _InfoDialogVariant variant,
    this.icon,
  });

  // ── Static show helpers ────────────────────────────────────────────────

  /// Single "OK" acknowledgement dialog.
  static Future<void> alert(
      BuildContext context, {
        required String title,
        required String message,
        String okLabel = 'OK',
        Widget? icon,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InfoDialog._(
        title: title,
        message: message,
        okLabel: okLabel,
        icon: icon,
        variant: _InfoDialogVariant.alert,
      ),
    );
  }

  /// Animated success dialog — auto-dismisses by default.
  static Future<void> success(
      BuildContext context, {
        required String title,
        String? message,
        String? actionLabel,
        VoidCallback? onAction,
        bool autoDismiss = true,
        Duration autoDismissDuration = const Duration(seconds: 2),
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialogContent(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        autoDismiss: autoDismiss,
        autoDismissDuration: autoDismissDuration,
      ),
    );
  }

  /// Modal bottom sheet with arbitrary content.
  static Future<T?> bottomSheet<T>(
      BuildContext context, {
        required Widget child,
        String? title,
        bool isDismissible = true,
        bool showDragHandle = true,
        double? maxHeightFraction,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        maxHeightFraction: maxHeightFraction ?? 0.85,
        child: child,
      ),
    );
  }

  /// Bottom sheet with a list of tappable options.
  static Future<T?> options<T>(
      BuildContext context, {
        String? title,
        required List<SheetOption<T>> options,
      }) {
    return bottomSheet<T>(
      context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((o) => _SheetOptionTile<T>(option: o))
            .toList(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl)),
      backgroundColor: AppColors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sw < 600 ? sw * 0.88 : 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(title,
                  style: AppTypography.h3, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(AppRadius.button)),
                  ),
                  child: Text(okLabel, style: AppTypography.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _InfoDialogVariant { alert }

// ─── Success Dialog Content ─────────────────────────────────────────────────

class _SuccessDialogContent extends StatefulWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool autoDismiss;
  final Duration autoDismissDuration;

  const _SuccessDialogContent({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    required this.autoDismiss,
    required this.autoDismissDuration,
  });

  @override
  State<_SuccessDialogContent> createState() => _SuccessDialogContentState();
}

class _SuccessDialogContentState extends State<_SuccessDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkDraw;
  late final Animation<double> _bgFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _circleScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _checkDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve:
          const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );
    _ctrl.forward();

    if (widget.autoDismiss) {
      Future.delayed(widget.autoDismissDuration, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    const s = 88.0;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl)),
      backgroundColor: AppColors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sw < 600 ? sw * 0.88 : 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated checkmark
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => SizedBox(
                  width: s,
                  height: s,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FadeTransition(
                        opacity: _bgFade,
                        child: Transform.scale(
                          scale: _circleScale.value,
                          child: Container(
                            width: s,
                            height: s,
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: _circleScale.value,
                        child: Container(
                          width: s * 0.82,
                          height: s * 0.82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.success, width: 2.5),
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: Size(s * 0.42, s * 0.42),
                        painter: _CheckPainter(
                          progress: _checkDraw.value,
                          color: AppColors.success,
                          strokeWidth: s * 0.055,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(widget.title,
                  style: AppTypography.h3, textAlign: TextAlign.center),
              if (widget.message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.message!,
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onAction?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppRadius.button)),
                    ),
                    child: Text(widget.actionLabel!,
                        style: AppTypography.button),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Checkmark Painter ──────────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(0, size.height * 0.55);
    final p2 = Offset(size.width * 0.38, size.height);
    final p3 = Offset(size.width, 0);

    final seg1 = (p2 - p1).distance;
    final seg2 = (p3 - p2).distance;
    final total = seg1 + seg2;
    final drawn = progress * total;

    final path = Path()..moveTo(p1.dx, p1.dy);

    if (drawn <= seg1) {
      final t = drawn / seg1;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (drawn - seg1) / seg2;
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─── Bottom Sheet ────────────────────────────────────────────────────────────

class _AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final double maxHeightFraction;

  const _AppBottomSheet({
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.maxHeightFraction = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.sizeOf(context).height;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sh * maxHeightFraction),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius:
                    BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),

            // Title row
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, 0),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(title!, style: AppTypography.h4)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 44, minHeight: 44),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: AppSpacing.sm),

            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  bottomPad + AppSpacing.lg,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet Option model ──────────────────────────────────────────────────────

class SheetOption<T> {
  final String label;
  final IconData? icon;
  final Color? color;
  final T value;
  final bool isDangerous;

  const SheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.isDangerous = false,
  });
}

class _SheetOptionTile<T> extends StatelessWidget {
  final SheetOption<T> option;
  const _SheetOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final color = option.isDangerous
        ? AppColors.error
        : (option.color ?? AppColors.textPrimary);

    return ListTile(
      leading: option.icon != null
          ? Icon(option.icon, color: color, size: 22)
          : null,
      title: Text(option.label,
          style: AppTypography.body.copyWith(color: color)),
      onTap: () => Navigator.of(context).pop(option.value),
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
    );
  }
}