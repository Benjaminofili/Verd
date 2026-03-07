import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verd/core/constants/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool _isPassword;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
  }) : _isPassword = false;

  const AppTextField._password({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    // ignore: unused_element_parameter
    this.helperText,
    this.controller,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  })  : _isPassword = true,
        obscureText = true,
        keyboardType = TextInputType.visiblePassword,
        readOnly = false,
        autofocus = false,
        maxLines = 1,
        maxLength = null,
        prefixIcon = null,
        suffixIcon = null,
        prefixText = null,
        suffixText = null,
        onTap = null,
        inputFormatters = null;

  /// Password field with built-in visibility toggle
  factory AppTextField.password({
    Key? key,
    String? label,
    String? hint,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField._password(
      key: key,
      label: label ?? 'Password',
      hint: hint ?? 'Enter your password',
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      textInputAction: textInputAction,
    );
  }

  /// Email field with correct keyboard and hint
  factory AppTextField.email({
    Key? key,
    String? label,
    String? hint,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email',
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
    );
  }

  /// Search field
  factory AppTextField.search({
    Key? key,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      hint: hint ?? 'Search...',
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search_outlined, size: 20),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Responsive font size — capped to avoid layout overflow
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final bodyStyle = AppTypography.body.copyWith(
      color: widget.enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      fontSize: (AppTypography.base) * scaleFactor,
    );

    final Widget? resolvedSuffix = widget._isPassword
        ? IconButton(
      icon: Icon(
        _obscure
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
      // Ensure icon button itself meets touch target
      padding: const EdgeInsets.all(AppSpacing.sm),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    )
        : widget.suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: AppTypography.medium,
              fontSize: AppTypography.base * scaleFactor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget._isPassword ? _obscure : widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: (widget._isPassword || widget.obscureText) ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: bodyStyle,
          // Prevent system font scaling from breaking layout
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperMaxLines: 2,
            errorMaxLines: 2,
            prefixIcon: widget.prefixIcon,
            suffixIcon: resolvedSuffix,
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            counterText: '', // hide character counter clutter
            filled: true,
            fillColor: widget.enabled
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            // isDense makes the field shorter on small screens
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: MediaQuery.sizeOf(context).height * 0.016,
            ),
          ),
        ),
      ],
    );
  }
}