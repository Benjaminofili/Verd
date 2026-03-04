import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// NOT FOUND / 404 SCREEN
// Shown when navigating to a deleted/invalid item or unknown route.
//
// Usage:
//   // Unknown route in GoRouter:
//   errorBuilder: (_, __) => const NotFoundScreen()
//
//   // Deleted item:
//   if (scan == null) return NotFoundScreen(itemName: 'Scan')
//
//   // With custom navigation:
//   NotFoundScreen(
//     itemName: 'Report',
//     onGoHome: () => context.go('/home'),
//     onGoBack: () => context.pop(),
//   )
// ═══════════════════════════════════════════════════════════════════════════

class NotFoundScreen extends StatefulWidget {
  final String? itemName;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoBack;

  const NotFoundScreen({
    super.key,
    this.itemName,
    this.onGoHome,
    this.onGoBack,
  });

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeSlide;
  late final AnimationController _floatCtrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeSlide =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    final scaleFactor =
    MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final illustrationSize = (sw * 0.6).clamp(200.0, 280.0);
    final label = widget.itemName ?? 'page';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: (widget.onGoBack != null || Navigator.canPop(context))
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: theme.colorScheme.onSurface),
          onPressed: widget.onGoBack ??
                  () => Navigator.of(context).pop(),
        )
            : null,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeSlide,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
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
                    // Floating illustration
                    AnimatedBuilder(
                      animation: _float,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _float.value),
                        child: child,
                      ),
                      child: _NotFoundIllustration(
                          size: illustrationSize),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 404 chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius:
                        BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '404',
                        style: AppTypography.buttonSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Title
                    Text(
                      'This $label doesn\'t exist',
                      style: AppTypography.h2.copyWith(
                        fontSize: AppTypography.xxl * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Subtitle
                    Text(
                      'The $label you\'re looking for may have been\ndeleted or the link may be incorrect.',
                      style: AppTypography.body.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.base * scaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.huge),

                    // Go Home
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onGoHome ??
                                () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: Text('Go to Home',
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

                    const SizedBox(height: AppSpacing.md),

                    // Go Back
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onGoBack ??
                                () => Navigator.of(context).pop(),
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
                          'Go Back',
                          style: AppTypography.button
                              .copyWith(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
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

// ─── Illustration ────────────────────────────────────────────────────────────

class _NotFoundIllustration extends StatelessWidget {
  final double size;
  const _NotFoundIllustration({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _NotFoundPainter()),
    );
  }
}

class _NotFoundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    canvas.drawCircle(
      Offset(w / 2, h * 0.47),
      w * 0.42,
      Paint()..color = AppColors.primary50,
    );

    // Leaf
    final leafPath = Path()
      ..moveTo(w * 0.5, h * 0.14)
      ..cubicTo(w * 0.74, h * 0.14, w * 0.80, h * 0.40, w * 0.5, h * 0.54)
      ..cubicTo(w * 0.20, h * 0.40, w * 0.26, h * 0.14, w * 0.5, h * 0.14);
    canvas.drawPath(leafPath, Paint()..color = AppColors.primary300);

    // Leaf midrib
    final midrib = Paint()
      ..color = AppColors.primary600
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.5, h * 0.20), Offset(w * 0.5, h * 0.52), midrib);

    // Stem
    canvas.drawLine(
      Offset(w * 0.5, h * 0.54),
      Offset(w * 0.5, h * 0.72),
      Paint()
        ..color = AppColors.primary700
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Question mark badge
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.28),
      w * 0.13,
      Paint()..color = AppColors.warning,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.15,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(w * 0.70 - tp.width / 2, h * 0.28 - tp.height / 2));

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w / 2, h * 0.88),
          width: w * 0.42,
          height: h * 0.055),
      Paint()..color = AppColors.gray300.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Skip Button ─────────────────────────────────────────────────────────────
// Kept here since it's used on onboarding/permission screens
// which redirect to utility screens when something goes wrong.

class SkipButton extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;
  final Color? color;

  const SkipButton({
    super.key,
    required this.onSkip,
    this.label = 'Skip',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Theme.of(context).colorScheme.onSurfaceVariant;
    return TextButton(
      onPressed: onSkip,
      style: TextButton.styleFrom(
        foregroundColor: color ?? fallback,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTypography.body.copyWith(
          color: color ?? fallback,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }
}