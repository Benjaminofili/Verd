import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/constants/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Gas effect animation controllers
  late final AnimationController _gasController;

  @override
  void initState() {
    super.initState();

    // Main content fade-in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Gas animation - slow continuous drift
    _gasController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Navigate after splash duration — check auth state
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // User is already logged in — go straight to home
          context.go('/home');
        } else {
          // Not logged in — show onboarding
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Green Gas / Mist Effect at the bottom ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: AnimatedBuilder(
              animation: _gasController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GreenGasPainter(
                    animationValue: _gasController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    SvgPicture.asset(AppAssets.logoSvg, width: 90),

                    const SizedBox(height: 16),

                    // App Name
                    Text(
                      'VERD',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.primary800,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    Text(
                      'CLARITY FOR YOUR CROPS',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray700,
                        fontSize: 13,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Bottom text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Text(
                        'powered by an offline AI',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// Green Gas / Mist Painter
// Creates a realistic organic green mist effect at the bottom of the screen
// using multiple layered radial gradients that animate slowly.
// ─────────────────────────────────────────────────────────────────────────────

class _GreenGasPainter extends CustomPainter {
  final double animationValue;

  _GreenGasPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Layer 1: Wide base wash ──
    // A very wide, soft green that covers the entire bottom area
    _drawGasBlob(
      canvas,
      center: Offset(w * 0.5, h * 1.05),
      radiusX: w * 1.0,
      radiusY: h * 0.85,
      color: const Color(0xFF4CAF50),
      opacity: 0.18,
      animOffset: 0.0,
    );

    // ── Layer 2: Left mist blob ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * (0.25 + 0.05 * sin(animationValue * 2 * pi)),
        h * (0.65 + 0.04 * sin(animationValue * 2 * pi + 1.0)),
      ),
      radiusX: w * 0.55,
      radiusY: h * 0.50,
      color: const Color(0xFF66BB6A),
      opacity: 0.25,
      animOffset: 0.0,
    );

    // ── Layer 3: Right mist blob ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * (0.75 - 0.04 * sin(animationValue * 2 * pi + 2.0)),
        h * (0.70 + 0.03 * sin(animationValue * 2 * pi + 0.5)),
      ),
      radiusX: w * 0.50,
      radiusY: h * 0.45,
      color: const Color(0xFF43A047),
      opacity: 0.22,
      animOffset: 0.0,
    );

    // ── Layer 4: Center bright bloom ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * (0.5 + 0.03 * sin(animationValue * 2 * pi + 3.0)),
        h * (0.75 + 0.02 * sin(animationValue * 2 * pi + 1.5)),
      ),
      radiusX: w * 0.45,
      radiusY: h * 0.40,
      color: const Color(0xFF81C784),
      opacity: 0.20,
      animOffset: 0.0,
    );

    // ── Layer 5: Bottom-center intense spot ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * 0.5,
        h * (0.95 + 0.02 * sin(animationValue * 2 * pi + 4.0)),
      ),
      radiusX: w * 0.60,
      radiusY: h * 0.35,
      color: const Color(0xFF4CAF50),
      opacity: 0.15,
      animOffset: 0.0,
    );

    // ── Layer 6: Subtle light-green wisp (top edge of gas) ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * (0.4 + 0.06 * sin(animationValue * 2 * pi + 5.0)),
        h * (0.35 + 0.05 * sin(animationValue * 2 * pi + 2.5)),
      ),
      radiusX: w * 0.50,
      radiusY: h * 0.30,
      color: const Color(0xFFA5D6A7),
      opacity: 0.12,
      animOffset: 0.0,
    );

    // ── Layer 7: Far-right wisp ──
    _drawGasBlob(
      canvas,
      center: Offset(
        w * (0.85 + 0.03 * sin(animationValue * 2 * pi + 1.2)),
        h * (0.55 + 0.04 * sin(animationValue * 2 * pi + 3.7)),
      ),
      radiusX: w * 0.35,
      radiusY: h * 0.28,
      color: const Color(0xFF66BB6A),
      opacity: 0.10,
      animOffset: 0.0,
    );
  }

  void _drawGasBlob(
    Canvas canvas, {
    required Offset center,
    required double radiusX,
    required double radiusY,
    required Color color,
    required double opacity,
    required double animOffset,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: [
        color.withValues(alpha: opacity),
        color.withValues(alpha: opacity * 0.5),
        color.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.srcOver;

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(_GreenGasPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

