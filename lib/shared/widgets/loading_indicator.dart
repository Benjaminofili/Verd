import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

enum LoadingIndicatorVariant { spinner, dots, linear }
enum LoadingIndicatorSize { small, medium, large }

/// Inline loading indicator — spinner, bouncing dots, or linear bar.
class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorVariant variant;
  final LoadingIndicatorSize size;
  final Color? color;
  final String? label;

  const LoadingIndicator({
    super.key,
    this.variant = LoadingIndicatorVariant.spinner,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.label,
  });

  double get _spinnerSize => switch (size) {
    LoadingIndicatorSize.small  => 16,
    LoadingIndicatorSize.medium => 24,
    LoadingIndicatorSize.large  => 40,
  };

  double get _strokeWidth => switch (size) {
    LoadingIndicatorSize.small  => 1.5,
    LoadingIndicatorSize.medium => 2.5,
    LoadingIndicatorSize.large  => 3.5,
  };

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    Widget indicator = switch (variant) {
      LoadingIndicatorVariant.spinner => SizedBox(
        width: _spinnerSize,
        height: _spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: _strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      ),
      LoadingIndicatorVariant.dots => _DotsIndicator(color: effectiveColor),
      LoadingIndicatorVariant.linear => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          backgroundColor: effectiveColor.withValues(alpha: 0.15),
          minHeight: 3,
        ),
      ),
    };

    if (label != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: AppSpacing.md),
          Text(
            label!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: AppTypography.sm * scaleFactor,
            ),
          ),
        ],
      );
    }

    return indicator;
  }
}

/// Full-screen blocking overlay — wraps any widget tree.
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isVisible = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
        // Absorb all touches while loading
          AbsorbPointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [AppShadows.lg],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicator(size: LoadingIndicatorSize.large),
                        if (message != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            message!,
                            style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Animated bouncing dots ─────────────────────────────────────────────────

class _DotsIndicator extends StatefulWidget {
  final Color color;
  const _DotsIndicator({required this.color});

  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<_DotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            // Simple sine-wave bounce
            final bounce = (1 - (t * 2 - 1).abs()).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * bounce;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}