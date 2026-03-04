import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onResetPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).resetPassword(email);
      if (mounted) {
        setState(() => _emailSent = true);
        _showSuccess('Password reset email sent! Check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Bar (Back Button) ──
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                  label: Text(
                    'Back',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Logo ──
              SvgPicture.asset(
                AppAssets.logoSvg,
                height: 64,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Title & Subtitle ──
              Text(
                'Forgot Password?',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  _emailSent
                      ? "We've sent a password reset link to your email. Check your inbox and follow the instructions."
                      : "No worries! Enter your email and we'll send you reset instructions",
                  style: AppTypography.body.copyWith(
                    color: _emailSent ? Colors.green.shade700 : AppColors.gray600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // ── Form ──
              if (!_emailSent) ...[
                AppTextField.email(
                  controller: _emailController,
                ),
                const SizedBox(height: 32),

                // ── Reset Button ──
                AppButton(
                  text: _isLoading ? 'SENDING...' : 'RESET PASSWORD',
                  onPressed: _isLoading ? null : _onResetPassword,
                  isLoading: _isLoading,
                ),
              ] else ...[
                // ── Success State — show return to login ──
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'BACK TO LOGIN',
                  onPressed: () => context.pop(),
                ),
              ],
              const SizedBox(height: 32),

              // ── Back to Login Link ──
              if (!_emailSent)
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.xl,
                      ),
                    ),
                    child: Text(
                      'Back to Login',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
