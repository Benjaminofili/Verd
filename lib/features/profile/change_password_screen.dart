import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_text_field.dart';
import 'package:verd/shared/widgets/app_toast.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isSaving = false;

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: AppLocalizations.of(context)!.password_update_success,
        variant: ToastVariant.success,
      );
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
          onPressed: () {
            context.pop();
          },
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: AppTypography.buttonSmall.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.change_password,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField.password(label: AppLocalizations.of(context)!.current_password,
              hint: AppLocalizations.of(context)!.enter_current_password,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(label: AppLocalizations.of(context)!.new_password,
              hint: AppLocalizations.of(context)!.enter_new_password,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.password(label: AppLocalizations.of(context)!.confirm_new_password,
              hint: AppLocalizations.of(context)!.confirm_new_password,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.password_requirements,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_length),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_case),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_number),
                  _buildRequirementItem(context, AppLocalizations.of(context)!.pwd_rule_special),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
