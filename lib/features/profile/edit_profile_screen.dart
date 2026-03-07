import 'package:verd/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/shared/dialogs/confirmation_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  File? _pickedImageFile;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill from cached user — runs once
    if (!_initialized) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.displayName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _locationController.text = user.farmLocation ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
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

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      AppToast.show(context, message: AppLocalizations.of(context)!.name_empty_error, variant: ToastVariant.error);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final currentUser = ref.read(currentUserProvider);
      await ref.read(authNotifierProvider.notifier).updateProfile(
        name: name != currentUser?.displayName ? name : null,
        phone: phone.isNotEmpty ? phone : null,
        location: location.isNotEmpty ? location : null,
        photoFile: _pickedImageFile,
      );
      if (mounted) {
        AppToast.show(context, message: AppLocalizations.of(context)!.profile_update_success, variant: ToastVariant.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: AppLocalizations.of(context)!.profile_update_error, variant: ToastVariant.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCancel() async {
    final discard = await ConfirmationDialog.discardChanges(context);
    if (discard == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _handleCancel,
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.edit_profile,
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          _isSaving
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                  ),
                )
              : TextButton(
                  onPressed: _handleSave,
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Profile Picture ──
            Center(
              child: GestureDetector(
                onTap: _pickedImageFile == null && !_isSaving ? _pickImage : null,
                child: Stack(
                  children: [
                    _buildAvatarCircle(user?.photoUrl, user?.displayName),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 2),
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
                AppLocalizations.of(context)!.new_photo_selected,
                style: AppTypography.caption.copyWith(color: theme.colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),

            // ── Edit Fields ──
            AppTextField(
              label: AppLocalizations.of(context)!.full_name,
              hint: AppLocalizations.of(context)!.full_name_hint,
              controller: _nameController,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.email(label: AppLocalizations.of(context)!.email,
              hint: AppLocalizations.of(context)!.email_hint,
              controller: _emailController,
              enabled: false, // Email cannot be changed here
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: AppLocalizations.of(context)!.phone_number,
              hint: AppLocalizations.of(context)!.phone_hint,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: AppLocalizations.of(context)!.farm_location,
              hint: AppLocalizations.of(context)!.farm_location_hint,
              controller: _locationController,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String? photoUrl, String? name) {
    const size = 100.0;

    if (_pickedImageFile != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    }

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: AppColors.primary200,
      );
    }

    // Fallback: initials
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
