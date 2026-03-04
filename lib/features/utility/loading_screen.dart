import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LOADING SCREEN
// Full-page loading screen shown during:
//   - App initialisation / splash
//   - Auth state check
//   - Heavy data fetch before navigation
//
// Variants:
//   LoadingScreen.splash()   — branded logo + animated dots (app startup)
//   LoadingScreen.simple()   — minimal spinner + optional message
//   LoadingScreen.progress() — step-by-step progress (e.g. uploading scan)
//
// Usage:
//   // In GoRouter redirect while checking auth:
//   redirect: (_, state) {
//     if (authState == AuthState.loading) return '/loading';
//     return null;
//   }
//   GoRoute(path: '/loading', builder: (_, __) => const LoadingScreen.splash())
// ═══════════════════════════════════════════════════════════════════════════

enum _LoadingType { splash, simple, progress }

class LoadingScreen extends StatefulWidget {
  final String? message;
  final _LoadingType _type;

  // Progress variant fields
  final List<String>? steps;
  final int currentStep;

  const LoadingScreen.splash({super.key})
      : message = null,
        _type = _LoadingType.splash,
        steps = null,
        currentStep = 0;

  const LoadingScreen.simple({
    super.key,
    this.message,
  })  : _type = _LoadingType.simple,
        steps = null,
        currentStep = 0;

  const LoadingScreen.progress({
    super.key,
    required List<String> this.steps,
    this.currentStep = 0,
    this.message,
  }) : _type = _LoadingType.progress;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  // Shared
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;

  // Splash only
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: switch (widget._type) {
        _LoadingType.splash => AppColors.primary,
        _LoadingType.simple || _LoadingType.progress =>
        theme.scaffoldBackgroundColor,
      },
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: switch (widget._type) {
            _LoadingType.splash  => _SplashBody(
              pulseAnim: _pulse,
              dotsCtrl: _dotsCtrl,
            ),
            _LoadingType.simple  => _SimpleBody(message: widget.message),
            _LoadingType.progress => _ProgressBody(
              steps: widget.steps!,
              currentStep: widget.currentStep,
              message: widget.message,
            ),
          },
        ),
      ),
    );
  }
}

// ─── Splash body ────────────────────────────────────────────────────────────

class _SplashBody extends StatelessWidget {
  final Animation<double> pulseAnim;
  final AnimationController dotsCtrl;

  const _SplashBody({
    required this.pulseAnim,
    required this.dotsCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing logo mark
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: pulseAnim.value,
              child: child,
            ),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _VerdLogoMark(size: 52),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // App name
          Text(
            'VERD',
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              letterSpacing: 6,
              fontSize: 32,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Crop Health Intelligence',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: AppSpacing.huge2),

          // Animated dots
          _AnimatedDots(controller: dotsCtrl, color: Colors.white70),
        ],
      ),
    );
  }
}

// ─── Simple body ─────────────────────────────────────────────────────────────

class _SimpleBody extends StatelessWidget {
  final String? message;
  const _SimpleBody({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaleFactor =
    MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              message!,
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: AppTypography.base * scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Progress body ────────────────────────────────────────────────────────────

class _ProgressBody extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final String? message;

  const _ProgressBody({
    required this.steps,
    required this.currentStep,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    final scaleFactor =
    MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final progress =
    steps.isEmpty ? 0.0 : (currentStep + 1) / steps.length;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinner
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Current step label
            if (currentStep < steps.length)
              Text(
                steps[currentStep],
                style: AppTypography.h4.copyWith(
                  fontSize: AppTypography.lg * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),

            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: AppTypography.sm * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Linear progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Step counter
            Text(
              'Step ${currentStep + 1} of ${steps.length}',
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: AppTypography.xs * scaleFactor,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Step list
            ...List.generate(steps.length, (i) {
              final isDone = i < currentStep;
              final isCurrent = i == currentStep;
              return Padding(
                padding:
                const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isCurrent
                            ? AppColors.primary
                            : AppColors.gray200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 13)
                            : isCurrent
                            ? const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor:
                            AlwaysStoppedAnimation(
                                Colors.white),
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: AppTypography.body.copyWith(
                          color: isDone
                              ? theme.colorScheme.onSurfaceVariant
                              : isCurrent
                              ? theme.colorScheme.onSurface
                              : AppColors.textDisabled,
                          fontWeight: isCurrent
                              ? AppTypography.semibold
                              : AppTypography.regular,
                          fontSize:
                          AppTypography.base * scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── VERD logo mark (leaf icon drawn with CustomPainter) ────────────────────

class _VerdLogoMark extends StatelessWidget {
  final double size;
  const _VerdLogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LeafPainter(),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Leaf shape
    final path = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..cubicTo(w * 0.82, h * 0.08, w * 0.92, h * 0.42, w * 0.5, h * 0.62)
      ..cubicTo(w * 0.08, h * 0.42, w * 0.18, h * 0.08, w * 0.5, h * 0.08);
    canvas.drawPath(path, paint);

    // Stem
    final stemPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.5, h * 0.62), Offset(w * 0.5, h * 0.92), stemPaint);

    // Midrib line inside leaf
    final midribPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.5, h * 0.18), Offset(w * 0.5, h * 0.58), midribPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Animated dots ────────────────────────────────────────────────────────────

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _AnimatedDots({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t =
          ((controller.value - i / 3) % 1.0).clamp(0.0, 1.0);
          final bounce = (1 - (t * 2 - 1).abs()).clamp(0.0, 1.0);
          final scale = 0.5 + 0.5 * bounce;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8 * scale,
            height: 8 * scale,
            decoration: BoxDecoration(
              color: color.withValues(alpha: scale),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}