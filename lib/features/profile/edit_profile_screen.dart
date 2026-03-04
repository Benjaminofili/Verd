import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';
import 'package:verd/shared/dialogs/confirmation_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isSaving = false;

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: 'Profile updated successfully',
        variant: ToastVariant.success,
      );
      context.pop();
    }
  }

  void _handleCancel() async {
    final discard = await ConfirmationDialog.discardChanges(context);
    if (discard == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _handleCancel,
          child: Text(
            'Cancel',
            style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(
          'Edit Profile',
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
              'Save',
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
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Green profile color
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Change',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          AppToast.show(
                            context,
                            message: 'Camera access coming soon',
                            variant: ToastVariant.info,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            // Edit Fields
            AppTextField(
              label: 'Full Name',
              hint: 'John Doe',
              controller: TextEditingController(text: 'John Doe'),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.email(
              label: 'Email',
              hint: 'john.doe@example.com',
              controller: TextEditingController(text: 'john.doe@example.com'),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Phone Number',
              hint: '+1 234 567 8900',
              controller: TextEditingController(text: '+1 234 567 8900'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Location',
              hint: 'California, USA',
              controller: TextEditingController(text: 'California, USA'),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
