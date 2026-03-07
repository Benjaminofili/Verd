import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _pickedImageFile;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) {
      setState(() => _pickedImageFile = File(picked.path));
    }
  }

  Future<void> _onSignUp() async {
    if (_isLoading || _isGoogleLoading) return;

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError(AppLocalizations.of(context)!.fill_all_fields);
      return;
    }
    if (password.length < 6) {
      _showError(AppLocalizations.of(context)!.password_too_short);
      return;
    }
    if (password != confirmPassword) {
      _showError(AppLocalizations.of(context)!.passwords_do_not_match);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).register(
            name: name,
            email: email,
            password: password,
          );
      if (_pickedImageFile != null) {
        await ref.read(authNotifierProvider.notifier).updateProfile(photoFile: _pickedImageFile);
      }
      if (mounted) context.go('/permissions');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(FirebaseAuthService.friendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.unexpected_error);
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
      if (mounted) _showError(AppLocalizations.of(context)!.google_sign_up_failed);
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
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
                      'create_account',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'create_profile',
                      style: AppTypography.body.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Profile Picture ──
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      _buildAvatarCircle(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_pickedImageFile != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context)!.profile_photo_selected,
                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                label: AppLocalizations.of(context)!.full_name,
                hint: AppLocalizations.of(context)!.full_name,
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              AppTextField.email(controller: _emailController),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(label: AppLocalizations.of(context)!.password,
                hint: AppLocalizations.of(context)!.password,
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField.password(label: 'confirm_password',
                hint: 'confirm_password',
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSignUp(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                text: _isLoading ? 'loading' : 'sign_up'.toUpperCase(),
                onPressed: _isLoading || _isGoogleLoading ? null : _onSignUp,
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

              // ── Google Sign Up Button ──
              AppButton(
                text: _isGoogleLoading ? 'loading' : 'google_sign_in'.toUpperCase(),
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
                    '${'already_have_account'.split('?').first}? ',
                    style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'login',
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

  Widget _buildAvatarCircle() {
    const size = 100.0;

    if (_pickedImageFile != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(_pickedImageFile!),
        backgroundColor: AppColors.primary200,
      );
    }

    // Fallback: placeholder icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Icon(
        Icons.person_add,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}
