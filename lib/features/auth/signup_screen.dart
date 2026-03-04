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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (_isLoading || _isGoogleLoading) return;

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).register(
            name: name,
            email: email,
            password: password,
          );
      if (mounted) context.go('/permissions');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignUp() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        ref.invalidate(authStateProvider);
        context.go('/permissions');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError('Google Sign-Up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(AppAssets.logoSvg, height: 48),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Join VERD',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create your account to get started',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              AppTextField.email(controller: _emailController),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSignUp(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                text: _isLoading ? 'CREATING ACCOUNT...' : 'SIGN UP WITH EMAIL',
                onPressed: _isLoading || _isGoogleLoading ? null : _onSignUp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── OR Divider ──
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('OR', style: AppTypography.bodySmall.copyWith(color: AppColors.gray500, fontWeight: FontWeight.bold)),
                  ),
                  const Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Google Sign Up Button ──
              AppButton(
                text: _isGoogleLoading ? 'PLEASE WAIT...' : 'SIGN UP WITH GOOGLE',
                onPressed: _isLoading || _isGoogleLoading ? null : _onGoogleSignUp,
                isLoading: _isGoogleLoading,
                variant: AppButtonVariant.outlined,
                icon: const Icon(Icons.g_mobiledata, size: 32),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Login',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
