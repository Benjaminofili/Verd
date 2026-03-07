import 'package:verd/l10n/app_localizations.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_isLoading || _isGoogleLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(AppLocalizations.of(context)!.fill_all_fields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).login(email, password);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.unexpected_error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignIn() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        // Refresh the provider state to show the new user
        ref.invalidate(authStateProvider);
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}');
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e, st) {
      debugPrint('🔥 Exact Google Sign-In Exception: $e');
      debugPrint('🔥 Stacktrace: $st');
      if (mounted) _showError('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _onSendEmailLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(AppLocalizations.of(context)!.enter_email_link_error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendSignInLink(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in link sent to $email! Check your inbox.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.send_link_failed);
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset(AppAssets.logoSvg, height: 64),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  'welcome',
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'login',
                  style: AppTypography.body.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                AppTextField.email(controller: _emailController),
                const SizedBox(height: AppSpacing.lg),
                AppTextField.password(controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onSendEmailLink,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.email_me_link,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'forgot_password',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  text: _isLoading ? 'loading' : 'sign_in'.toUpperCase(),
                  onPressed: _isLoading || _isGoogleLoading ? null : _onLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // ── OR Divider ──
                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outlineVariant, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(AppLocalizations.of(context)!.orDivider, style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: cs.outlineVariant, thickness: 1)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Google Sign In Button ──
                AppButton(
                  text: _isGoogleLoading ? 'loading'.toUpperCase() : 'google_sign_in'.toUpperCase(),
                  onPressed: _isLoading || _isGoogleLoading ? null : _onGoogleSignIn,
                  isLoading: _isGoogleLoading,
                  variant: AppButtonVariant.outlined,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${'dont_have_account'.split('?').first}? ',
                      style: AppTypography.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        'sign_up',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
