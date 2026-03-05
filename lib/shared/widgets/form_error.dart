import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FORM VALIDATORS
// Composable validators to use with AppTextField / TextFormField
// ═══════════════════════════════════════════════════════════════════════════

class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!re.hasMatch(value.trim())) return 'Please enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) return '${fieldName ?? 'This field'} is required';
    if (value.length < min) return '${fieldName ?? 'This field'} must be at least $min characters';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final re = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!re.hasMatch(value.trim())) return 'Please enter a valid phone number';
    return null;
  }

  /// Chain multiple validators — returns first error found
  static FormFieldValidator<String> compose(
      List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INLINE FIELD ERROR
// Shown below a text field — use errorText on InputDecoration
// ═══════════════════════════════════════════════════════════════════════════

/// Animated inline field error with icon.
/// Wrap your field + this widget in a Column.
class FieldError extends StatelessWidget {
  final String? error;

  const FieldError({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final scaleFactor =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: error != null
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      error!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontSize: AppTypography.xs * scaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FORM-LEVEL ERROR BANNER
// Shown at the top of a form (e.g., "Invalid credentials")
// ═══════════════════════════════════════════════════════════════════════════

class FormErrorBanner extends StatelessWidget {
  final String? error;

  const FormErrorBanner({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final scaleFactor =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: error != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.error_outline,
                          size: 18, color: AppColors.error),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.errorDark,
                          fontSize: AppTypography.sm * scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VALIDATED TEXT FIELD
// AppTextField + validator + live error state combined
// ═══════════════════════════════════════════════════════════════════════════

class ValidatedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool validateOnChange; // live validation as user types
  final bool _isPassword;

  const ValidatedTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validateOnChange = false,
  }) : _isPassword = false;

  const ValidatedTextField._pw({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.validateOnChange = false,
  })  : _isPassword = true,
        obscureText = true,
        keyboardType = TextInputType.visiblePassword,
        prefixIcon = null;

  factory ValidatedTextField.email({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool validateOnChange = false,
  }) =>
      ValidatedTextField(
        key: key,
        label: 'Email Address',
        hint: 'Enter your email',
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        validator: validator ?? Validators.email,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        validateOnChange: validateOnChange,
      );

  factory ValidatedTextField.password({
    Key? key,
    String? label,
    TextEditingController? controller,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validateOnChange = false,
    TextInputAction textInputAction = TextInputAction.done,
  }) =>
      ValidatedTextField._pw(
        key: key,
        label: label ?? 'Password',
        hint: 'Enter your password',
        controller: controller,
        focusNode: focusNode,
        validator: validator ?? Validators.password,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        enabled: enabled,
        validateOnChange: validateOnChange,
        textInputAction: textInputAction,
      );

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _error;
  bool _obscure = true;
  late final TextEditingController _ctrl;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ctrl = TextEditingController();
      _ownsController = true;
    } else {
      _ctrl = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  void _validate(String value) {
    if (!widget.validateOnChange) return;
    setState(() => _error = widget.validator?.call(value));
  }

  // Called externally via GlobalKey<_ValidatedTextFieldState> or Form
  String? validate() {
    final err = widget.validator?.call(_ctrl.text);
    setState(() => _error = err);
    return err;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final hasError = _error != null;

    final Widget? suffix = widget._isPassword
        ? IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.gray500,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTypography.medium,
              fontSize: AppTypography.base * scaleFactor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: _ctrl,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget._isPassword ? _obscure : widget.obscureText,
          enabled: widget.enabled,
          textAlignVertical: TextAlignVertical.center,
          style: AppTypography.body.copyWith(
            color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
            fontSize: AppTypography.base * scaleFactor,
          ),
          onChanged: (v) {
            _validate(v);
            widget.onChanged?.call(v);
          },
          onFieldSubmitted: widget.onSubmitted,
          // Remove built-in error text — we render FieldError ourselves
          // so we have full control over animation and styling
          validator: (v) {
            final err = widget.validator?.call(v);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _error = err);
            });
            return null; // suppress default red underline
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffix,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.backgroundSecondary
                : AppColors.gray100,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: MediaQuery.sizeOf(context).height * 0.016,
            ),
            // Override border to show error state without Flutter's default
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.gray300,
                width: hasError ? 1.5 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide:
                  const BorderSide(color: AppColors.gray200, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
        ),
        // Our custom animated error row
        FieldError(error: _error),
      ],
    );
  }
}
