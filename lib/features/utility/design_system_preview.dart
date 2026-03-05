import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verd/core/constants/app_theme.dart';

// ─── Entry point for standalone testing ────────────────────────────────────
// Add this route to your app_router.dart temporarily:
//   GoRoute(path: '/preview', builder: (_, __) => const DesignSystemPreview())

class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  static const _sections = [
    'Buttons',
    'Text Fields',
    'Cards',
    'Status Bars',
    'Loading',
    'Empty States',
    'Error Views',
    'Progress Dots',
    'Colors',
    'Typography',
    'Spacing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.widgets_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Design System'),
          ],
        ),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gray200),
        ),
      ),
      body: SafeArea(  // ← Added SafeArea
        child: Row(
        children: [
          // ── Sidebar nav (visible on wide screens) ──────────────────────
          if (MediaQuery.sizeOf(context).width >= 600)
            _Sidebar(sections: _sections),

          // ── Main content ───────────────────────────────────────────────
          Expanded(
            child: _PreviewContent(sections: _sections),
          ),
        ],
      ),
     ),
    );
  }
}

// ─── Sidebar ───────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final List<String> sections;
  const _Sidebar({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: Text('COMPONENTS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: AppTypography.semibold,
                )),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sections.map((s) => _SidebarItem(label: s)),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  const _SidebarItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      onTap: () {
        // Scroll to section — handled by GlobalKey in _PreviewContent
        _PreviewContent.scrollToSection(context, label);
      },
      hoverColor: AppColors.primary50,
    );
  }
}

// ─── Main scrollable content ───────────────────────────────────────────────

class _PreviewContent extends StatefulWidget {
  final List<String> sections;
  const _PreviewContent({required this.sections});

  static void scrollToSection(BuildContext context, String label) {
    // Simple approach: find the state and call scroll
    final state =
    context.findAncestorStateOfType<_PreviewContentState>();
    state?.scrollTo(label);
  }

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    for (final s in widget.sections) {
      _keys[s] = GlobalKey();
    }
  }

  void scrollTo(String label) {
    final key = _keys[label];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final hPad = sw < 400 ? AppSpacing.lg : AppSpacing.xxl;

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: AppSpacing.xxl),
      children: [
        _sectionHeader('Buttons', _keys['Buttons']!),
        const _ButtonsSection(),
        _divider(),

        _sectionHeader('Text Fields', _keys['Text Fields']!),
        const _TextFieldsSection(),
        _divider(),

        _sectionHeader('Cards', _keys['Cards']!),
        const _CardsSection(),
        _divider(),

        _sectionHeader('Status Bars', _keys['Status Bars']!),
        const _StatusBarsSection(),
        _divider(),

        _sectionHeader('Loading', _keys['Loading']!),
        const _LoadingSection(),
        _divider(),

        _sectionHeader('Empty States', _keys['Empty States']!),
        const _EmptyStatesSection(),
        _divider(),

        _sectionHeader('Error Views', _keys['Error Views']!),
        const _ErrorViewsSection(),
        _divider(),

        _sectionHeader('Progress Dots', _keys['Progress Dots']!),
        const _ProgressDotsSection(),
        _divider(),

        _sectionHeader('Colors', _keys['Colors']!),
        const _ColorsSection(),
        _divider(),

        _sectionHeader('Typography', _keys['Typography']!),
        const _TypographySection(),
        _divider(),

        _sectionHeader('Spacing', _keys['Spacing']!),
        const _SpacingSection(),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionHeader(String title, GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(title,
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
    child: Divider(color: AppColors.gray200, thickness: 1),
  );
}

// ─── Preview tile wrapper ──────────────────────────────────────────────────

class _PreviewTile extends StatelessWidget {
  final String label;
  final Widget child;
  final String? description;

  const _PreviewTile({
    required this.label,
    required this.child,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Text(label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  )),
            ),
            if (description != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(description!,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textDisabled)),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
                color: AppColors.gray200),
          ),
          child: child,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: BUTTONS
// ═══════════════════════════════════════════════════════════════════════════

class _ButtonsSection extends StatefulWidget {
  const _ButtonsSection();

  @override
  State<_ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<_ButtonsSection> {
  bool _loading = false;

  void _simulateLoad() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'variant: primary / secondary / ghost',
        child: Column(children: [
          _previewButton('Primary', AppButtonVariant.primary),
          const SizedBox(height: AppSpacing.sm),
          _previewButton('Secondary', AppButtonVariant.secondary),
          const SizedBox(height: AppSpacing.sm),
          _previewButton('Ghost', AppButtonVariant.ghost),
        ]),
      ),
      _PreviewTile(
        label: 'size: small / medium / large',
        child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
          _sizedButton('Small', AppButtonSize.small),
          _sizedButton('Medium', AppButtonSize.medium),
          _sizedButton('Large', AppButtonSize.large),
        ]),
      ),
      _PreviewTile(
        label: 'state: loading',
        description: 'Tap to simulate',
        child: _AppButtonPreview(
          text: 'Loading State',
          onPressed: _loading ? null : _simulateLoad,
          isLoading: _loading,
        ),
      ),
      _PreviewTile(
        label: 'state: disabled',
        child: _AppButtonPreview(
          text: 'Disabled Button',
          onPressed: () {},
          isDisabled: true,
        ),
      ),
      _PreviewTile(
        label: 'with icons',
        child: Column(children: [
          _AppButtonPreview(
            text: 'Scan Now',
            onPressed: () {},
            leadingIcon: const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          _AppButtonPreview(
            text: 'Continue',
            onPressed: () {},
            trailingIcon: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 18),
          ),
        ]),
      ),
      _PreviewTile(
        label: 'customColor: warning / info / error',
        child: Column(children: [
          _AppButtonPreview(
              text: 'Warning Action',
              onPressed: () {},
              customColor: AppColors.warning),
          const SizedBox(height: AppSpacing.sm),
          _AppButtonPreview(
              text: 'Info Action',
              onPressed: () {},
              customColor: AppColors.info),
          const SizedBox(height: AppSpacing.sm),
          _AppButtonPreview(
              text: 'Danger Action',
              onPressed: () {},
              customColor: AppColors.error),
        ]),
      ),
      _PreviewTile(
        label: 'isFullWidth: false',
        child: Center(
          child: _AppButtonPreview(
            text: 'Compact Button',
            onPressed: () {},
            isFullWidth: false,
          ),
        ),
      ),
    ]);
  }

  Widget _previewButton(String label, AppButtonVariant variant) =>
      _AppButtonPreview(text: label, onPressed: () {}, variant: variant);

  Widget _sizedButton(String label, AppButtonSize size) => _AppButtonPreview(
    text: label,
    onPressed: () {},
    size: size,
    isFullWidth: false,
  );
}

// Inline recreation of AppButton to avoid import in preview page
// (In your project, import from verd/shared/widgets/app_button.dart)
class _AppButtonPreview extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color? customColor;

  const _AppButtonPreview({
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.customColor,
  });

  EdgeInsets _padding(BuildContext context) {
    final sh = MediaQuery.sizeOf(context).height;
    final vPad = switch (size) {
      AppButtonSize.small  => sh * 0.010,
      AppButtonSize.medium => sh * 0.013,
      AppButtonSize.large  => sh * 0.018,
    };
    final hPad = switch (size) {
      AppButtonSize.small  => AppSpacing.lg,
      AppButtonSize.medium => AppSpacing.xl,
      AppButtonSize.large  => AppSpacing.xxl,
    };
    return EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = !isLoading && !isDisabled && onPressed != null;
    final Color base = customColor ?? AppColors.primary;

    Widget label = isLoading
        ? SizedBox(
        height: 20, width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary ? Colors.white : base,
          ),
        ))
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
        Flexible(child: Text(text, style: AppTypography.button, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon!],
      ],
    );

    final style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: base, foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.gray300, disabledForegroundColor: AppColors.gray500,
          padding: _padding(context), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button))),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundSecondary, foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.gray100, disabledForegroundColor: AppColors.gray400,
          padding: _padding(context), elevation: 0,
          side: BorderSide(color: isActive ? AppColors.gray300 : AppColors.gray200, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button))),
      AppButtonVariant.ghost => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, foregroundColor: base,
          disabledBackgroundColor: Colors.transparent, disabledForegroundColor: AppColors.gray400,
          padding: _padding(context), elevation: 0, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button))),
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(onPressed: isActive ? onPressed : null, style: style, child: label),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: TEXT FIELDS
// ═══════════════════════════════════════════════════════════════════════════

class _TextFieldsSection extends StatefulWidget {
  const _TextFieldsSection();
  @override
  State<_TextFieldsSection> createState() => _TextFieldsSectionState();
}

class _TextFieldsSectionState extends State<_TextFieldsSection> {
  String? _emailError;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'AppTextField (default)',
        child: _buildField(label: 'Full Name', hint: 'John Doe'),
      ),
      _PreviewTile(
        label: 'AppTextField.email()',
        child: _buildField(
            label: 'Email',
            hint: 'your.email@example.com',
            keyboard: TextInputType.emailAddress),
      ),
      _PreviewTile(
        label: 'AppTextField.password() — visibility toggle',
        child: _PasswordFieldPreview(),
      ),
      _PreviewTile(
        label: 'errorText state',
        description: 'Tap to toggle error',
        child: GestureDetector(
          onTap: () => setState(() {
            _emailError = _emailError == null ? 'Please enter a valid email' : null;
          }),
          child: _buildField(
            label: 'Email',
            hint: 'Tap to toggle error',
            error: _emailError,
          ),
        ),
      ),
      _PreviewTile(
        label: 'disabled state',
        child: _buildField(
            label: 'Read Only', hint: 'Cannot edit this field', enabled: false),
      ),
      _PreviewTile(
        label: 'with prefix icon (search)',
        child: _buildField(
          hint: 'Search crops, diseases...',
          prefix: const Icon(Icons.search_outlined, size: 20, color: AppColors.gray500),
        ),
      ),
      _PreviewTile(
        label: 'multiline / textarea',
        child: _buildField(
            label: 'Notes', hint: 'Describe what you observe...', maxLines: 4),
      ),
    ]);
  }

  Widget _buildField({
    String? label,
    String? hint,
    String? error,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
    Widget? prefix,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label,
              style: AppTypography.body
                  .copyWith(fontWeight: AppTypography.medium)),
          const SizedBox(height: 4),
        ],
        TextFormField(
          keyboardType: keyboard,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            prefixIcon: prefix,
            filled: true,
            fillColor: enabled ? AppColors.backgroundSecondary : AppColors.gray100,
            isDense: true,
          ),
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _PasswordFieldPreview extends StatefulWidget {
  @override
  State<_PasswordFieldPreview> createState() => _PasswordFieldPreviewState();
}

class _PasswordFieldPreviewState extends State<_PasswordFieldPreview> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Password',
            style: AppTypography.body.copyWith(fontWeight: AppTypography.medium)),
        const SizedBox(height: 4),
        TextFormField(
          obscureText: _obscure,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.gray500, size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: CARDS
// ═══════════════════════════════════════════════════════════════════════════

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'variant: elevated',
        child: _card(AppCardVariant.elevated, 'Elevated Card',
            'Default card with subtle shadow.'),
      ),
      _PreviewTile(
        label: 'variant: outlined',
        child: _card(AppCardVariant.outlined, 'Outlined Card',
            'Border only, no shadow.'),
      ),
      _PreviewTile(
        label: 'variant: filled',
        child: _card(AppCardVariant.filled, 'Filled Card',
            'Filled with gray background.'),
      ),
      _PreviewTile(
        label: 'variant: ghost',
        child: _card(AppCardVariant.ghost, 'Ghost Card',
            'Transparent — useful for layering.'),
      ),
      _PreviewTile(
        label: 'AppStatCard — dashboard tile',
        child: Row(children: [
          Expanded(
            child: _StatCardPreview(
              label: 'Total Scans',
              value: '248',
              icon: Icons.document_scanner_outlined,
              iconBg: AppColors.primary50,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCardPreview(
              label: 'Diseases Found',
              value: '12',
              icon: Icons.bug_report_outlined,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: AppColors.warning,
            ),
          ),
        ]),
      ),
      _PreviewTile(
        label: 'onTap — interactive card',
        description: 'Has ripple effect',
        child: _InteractiveCardPreview(),
      ),
    ]);
  }

  Widget _card(AppCardVariant variant, String title, String subtitle) {
    final decoration = switch (variant) {
      AppCardVariant.elevated => BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [AppShadows.card],
      ),
      AppCardVariant.outlined => BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.gray300, width: 1.5),
      ),
      AppCardVariant.filled => BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      AppCardVariant.ghost => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: decoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: 4),
        Text(subtitle,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _StatCardPreview extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconBg, iconColor;

  const _StatCardPreview(
      {required this.label,
        required this.value,
        required this.icon,
        required this.iconBg,
        required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [AppShadows.card],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTypography.h3),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _InteractiveCardPreview extends StatefulWidget {
  @override
  State<_InteractiveCardPreview> createState() =>
      _InteractiveCardPreviewState();
}

class _InteractiveCardPreviewState extends State<_InteractiveCardPreview> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => setState(() => _taps++),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [AppShadows.card],
          ),
          child: Row(children: [
            const Icon(Icons.touch_app_outlined,
                color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tap Me!', style: AppTypography.h4),
                Text('Tapped $_taps time${_taps == 1 ? '' : 's'}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: STATUS BARS
// ═══════════════════════════════════════════════════════════════════════════

class _StatusBarsSection extends StatefulWidget {
  const _StatusBarsSection();
  @override
  State<_StatusBarsSection> createState() => _StatusBarsSectionState();
}

class _StatusBarsSectionState extends State<_StatusBarsSection> {
  bool _showDismissable = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'variant: success',
        child: _StatusBarPreview(
            message: 'Scan completed successfully!',
            variant: StatusBarVariant.success),
      ),
      _PreviewTile(
        label: 'variant: error',
        child: _StatusBarPreview(
            message: 'Failed to analyze image. Please try again.',
            variant: StatusBarVariant.error),
      ),
      _PreviewTile(
        label: 'variant: warning',
        child: _StatusBarPreview(
            message: 'Low image quality detected. Results may vary.',
            variant: StatusBarVariant.warning),
      ),
      _PreviewTile(
        label: 'variant: info',
        child: _StatusBarPreview(
            message: 'Analysis usually takes 2–5 seconds.',
            variant: StatusBarVariant.info),
      ),
      _PreviewTile(
        label: 'dismissable',
        description: _showDismissable ? 'Tap × to dismiss' : 'Dismissed!',
        child: _showDismissable
            ? _StatusBarPreview(
          message: 'This alert can be dismissed.',
          variant: StatusBarVariant.info,
          onDismiss: () => setState(() => _showDismissable = false),
        )
            : TextButton(
          onPressed: () => setState(() => _showDismissable = true),
          child: const Text('Show again'),
        ),
      ),
    ]);
  }
}

class _StatusBarPreview extends StatelessWidget {
  final String message;
  final StatusBarVariant variant;
  final VoidCallback? onDismiss;

  const _StatusBarPreview(
      {required this.message, required this.variant, this.onDismiss});

  Color get _bg => switch (variant) {
    StatusBarVariant.success => AppColors.success.withValues(alpha: 0.10),
    StatusBarVariant.error   => AppColors.error.withValues(alpha: 0.10),
    StatusBarVariant.warning => AppColors.warning.withValues(alpha: 0.10),
    StatusBarVariant.info    => AppColors.info.withValues(alpha: 0.10),
  };
  Color get _fg => switch (variant) {
    StatusBarVariant.success => AppColors.successDark,
    StatusBarVariant.error   => AppColors.errorDark,
    StatusBarVariant.warning => AppColors.warningDark,
    StatusBarVariant.info    => AppColors.infoDark,
  };
  Color get _border => switch (variant) {
    StatusBarVariant.success => AppColors.success,
    StatusBarVariant.error   => AppColors.error,
    StatusBarVariant.warning => AppColors.warning,
    StatusBarVariant.info    => AppColors.info,
  };
  IconData get _icon => switch (variant) {
    StatusBarVariant.success => Icons.check_circle_outline,
    StatusBarVariant.error   => Icons.error_outline,
    StatusBarVariant.warning => Icons.warning_amber_outlined,
    StatusBarVariant.info    => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _border.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(_icon, size: 18, color: _fg),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(message,
              style: AppTypography.bodySmall.copyWith(
                  color: _fg, fontWeight: AppTypography.medium)),
        ),
        if (onDismiss != null)
          GestureDetector(
            onTap: onDismiss,
            child: SizedBox(
              width: 44, height: 44,
              child: Center(child: Icon(Icons.close, size: 16, color: _fg)),
            ),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: LOADING
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'variant: spinner — sizes',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _loadingWithLabel(
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                ),
                'small'),
            _loadingWithLabel(
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                ),
                'medium'),
            _loadingWithLabel(
                const SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                ),
                'large'),
          ],
        ),
      ),
      _PreviewTile(
        label: 'variant: linear',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: const LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
            backgroundColor: Color(0x264CAF50),
            minHeight: 3,
          ),
        ),
      ),
      _PreviewTile(
        label: 'variant: dots (animated)',
        child: const Center(child: _DotsPreview()),
      ),
      _PreviewTile(
        label: 'LoadingOverlay — modal blocking',
        description: 'Tap button to preview',
        child: const _LoadingOverlayDemo(),
      ),
    ]);
  }

  Widget _loadingWithLabel(Widget indicator, String label) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      indicator,
      const SizedBox(height: 8),
      Text(label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}

class _DotsPreview extends StatefulWidget {
  const _DotsPreview();
  @override
  State<_DotsPreview> createState() => _DotsPreviewState();
}

class _DotsPreviewState extends State<_DotsPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_c.value - i / 3) % 1.0).clamp(0.0, 1.0);
          final bounce = (1 - (t * 2 - 1).abs()).clamp(0.0, 1.0);
          final scale = 0.5 + 0.5 * bounce;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8 * scale, height: 8 * scale,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: scale),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingOverlayDemo extends StatefulWidget {
  const _LoadingOverlayDemo();
  @override
  State<_LoadingOverlayDemo> createState() => _LoadingOverlayDemoState();
}

class _LoadingOverlayDemoState extends State<_LoadingOverlayDemo> {
  bool _visible = false;

  void _show() async {
    setState(() => _visible = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _AppButtonPreview(text: 'Show Overlay (2s)', onPressed: _visible ? null : _show),
      if (_visible)
        Positioned.fill(
          child: AbsorbPointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [AppShadows.lg],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                      width: 40, height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Analyzing crop...',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                  ]),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: EMPTY STATES
// ═══════════════════════════════════════════════════════════════════════════

class _EmptyStatesSection extends StatelessWidget {
  const _EmptyStatesSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'EmptyState.noScans()',
        child: SizedBox(height: 280, child: _emptyState(
          Icons.document_scanner_outlined,
          'No Scans Yet',
          'Take your first photo to check\nyour crop health instantly.',
          'Scan a Crop',
        )),
      ),
      _PreviewTile(
        label: 'EmptyState.noConnection()',
        child: SizedBox(height: 260, child: _emptyState(
          Icons.wifi_off_outlined,
          'No Connection',
          'Check your internet connection\nand try again.',
          'Retry',
        )),
      ),
      _PreviewTile(
        label: 'EmptyState.noResults()',
        child: SizedBox(height: 260, child: _emptyState(
          Icons.search_off_outlined,
          'No Results Found',
          'We couldn\'t find anything for "blight".',
          'Clear Search',
        )),
      ),
    ]);
  }

  Widget _emptyState(
      IconData icon, String title, String subtitle, String action) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
              color: AppColors.gray100, shape: BoxShape.circle),
          child: Icon(icon, size: 36, color: AppColors.gray400),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xxl),
        _AppButtonPreview(text: action, onPressed: () {}, isFullWidth: false),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: ERROR VIEWS
// ═══════════════════════════════════════════════════════════════════════════

class _ErrorViewsSection extends StatelessWidget {
  const _ErrorViewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'variant: fullPage — network error',
        child: SizedBox(
          height: 300,
          child: _fullPageError(
            Icons.wifi_off_outlined,
            'Connection Failed',
            'Unable to connect to the server.\nPlease check your internet connection.',
          ),
        ),
      ),
      _PreviewTile(
        label: 'variant: inline',
        child: _inlineError('Failed to load scan history.'),
      ),
      _PreviewTile(
        label: 'variant: banner',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            border: const Border(
                left: BorderSide(color: AppColors.error, width: 3)),
          ),
          child: Row(children: [
            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Server Error',
                        style: AppTypography.body.copyWith(
                            color: AppColors.errorDark,
                            fontWeight: AppTypography.semibold)),
                    Text('Our servers are down. Try again later.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.error)),
                  ]),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Retry',
                  style:
                  AppTypography.bodySmall.copyWith(color: AppColors.error)),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _fullPageError(IconData icon, String title, String message) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(message,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xxl),
        _AppButtonPreview(text: 'Try Again', onPressed: () {}, isFullWidth: false),
      ]),
    );
  }

  Widget _inlineError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(44, 44)),
          child: Text('Retry',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: PROGRESS DOTS
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressDotsSection extends StatefulWidget {
  const _ProgressDotsSection();
  @override
  State<_ProgressDotsSection> createState() => _ProgressDotsSectionState();
}

class _ProgressDotsSectionState extends State<_ProgressDotsSection> {
  int _current = 0;
  final int _total = 3;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PreviewTile(
        label: 'Interactive — tap arrows to change page',
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              onPressed: _current > 0
                  ? () => setState(() => _current--)
                  : null,
            ),
            const SizedBox(width: AppSpacing.lg),
            // Inline ProgressDots widget
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_total, (i) {
                final isActive = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.gray300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: _current < _total - 1
                  ? () => setState(() => _current++)
                  : null,
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text('Page ${_current + 1} of $_total',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
        ]),
      ),
      _PreviewTile(
        label: 'customColor: warning (notifications screen)',
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == 0 ? 24 : 8, height: 8,
              decoration: BoxDecoration(
                color: i == 0 ? AppColors.warning : AppColors.gray300,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: COLORS
// ═══════════════════════════════════════════════════════════════════════════

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _colorGroup('Primary', [
        ('50', AppColors.primary50), ('100', AppColors.primary100),
        ('200', AppColors.primary200), ('300', AppColors.primary300),
        ('400', AppColors.primary400), ('500 ★', AppColors.primary500),
        ('600', AppColors.primary600), ('700', AppColors.primary700),
        ('800', AppColors.primary800), ('900', AppColors.primary900),
      ]),
      const SizedBox(height: AppSpacing.xl),
      _colorGroup('Semantic', [
        ('success', AppColors.success), ('successDark', AppColors.successDark),
        ('warning', AppColors.warning), ('warningDark', AppColors.warningDark),
        ('error', AppColors.error), ('errorDark', AppColors.errorDark),
        ('info', AppColors.info), ('infoDark', AppColors.infoDark),
      ]),
      const SizedBox(height: AppSpacing.xl),
      _colorGroup('Grays', [
        ('50', AppColors.gray50), ('100', AppColors.gray100),
        ('200', AppColors.gray200), ('300', AppColors.gray300),
        ('400', AppColors.gray400), ('500', AppColors.gray500),
        ('600', AppColors.gray600), ('700', AppColors.gray700),
        ('800', AppColors.gray800), ('900', AppColors.gray900),
      ]),
    ]);
  }

  Widget _colorGroup(String label, List<(String, Color)> colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTypography.body
              .copyWith(fontWeight: AppTypography.semibold)),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: colors.map((c) => _ColorSwatch(name: c.$1, color: c.$2)).toList(),
      ),
    ]);
  }
}

class _ColorSwatch extends StatelessWidget {
  final String name;
  final Color color;
  const _ColorSwatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final hexStr =
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: hexStr));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $hexStr'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.gray900,
          ),
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gray200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.md),
                  bottomRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                name,
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════════════════

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final styles = [
      ('h1 — 32px Bold', AppTypography.h1, 'Crop Health Report'),
      ('h2 — 24px Bold', AppTypography.h2, 'Disease Detection'),
      ('h3 — 20px SemiBold', AppTypography.h3, 'Scan Results'),
      ('h4 — 18px SemiBold', AppTypography.h4, 'Field Overview'),
      ('bodyLarge — 16px', AppTypography.bodyLarge, 'Detailed analysis of your crop scan.'),
      ('body — 14px', AppTypography.body, 'Your plant appears healthy with no signs of disease.'),
      ('bodySmall — 12px', AppTypography.bodySmall, 'Last scanned 2 hours ago · Field A'),
      ('caption — 11px', AppTypography.caption, 'Confidence score: 97.3%'),
      ('button — 16px SemiBold', AppTypography.button, 'SCAN NOW'),
      ('buttonSmall — 14px SemiBold', AppTypography.buttonSmall, 'VIEW DETAILS'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: styles.map((s) => _TypographyRow(
          label: s.$1, style: s.$2, sample: s.$3)).toList(),
    );
  }
}

class _TypographyRow extends StatelessWidget {
  final String label, sample;
  final TextStyle style;
  const _TypographyRow(
      {required this.label, required this.style, required this.sample});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 180,
          child: Text(label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary, fontFamily: 'monospace'),
              maxLines: 2),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(sample,
              style: style.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION: SPACING
// ═══════════════════════════════════════════════════════════════════════════

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final tokens = [
      ('xs', AppSpacing.xs, '4'),
      ('sm', AppSpacing.sm, '8'),
      ('md', AppSpacing.md, '12'),
      ('lg', AppSpacing.lg, '16'),
      ('xl', AppSpacing.xl, '20'),
      ('xxl', AppSpacing.xxl, '24'),
      ('xxxl', AppSpacing.xxxl, '28'),
      ('xxxxl', AppSpacing.xxxxl, '32'),
      ('huge', AppSpacing.huge, '40'),
      ('huge2', AppSpacing.huge2, '48'),
      ('huge3', AppSpacing.huge3, '56'),
      ('huge4', AppSpacing.huge4, '64'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tokens.map((t) => _SpacingRow(
          name: t.$1, value: t.$2, px: t.$3)).toList(),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  final String name, px;
  final double value;
  const _SpacingRow({required this.name, required this.value, required this.px});

  @override
  Widget build(BuildContext context) {
    // Bar maxes out at huge4 = 64px
    final fraction = (value / 64).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 56,
          child: Text(name,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              )),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: LayoutBuilder(builder: (_, c) {
            return Stack(children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 20,
                width: c.maxWidth * fraction,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ]);
          }),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 32,
          child: Text('${px}px',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right),
        ),
      ]),
    );
  }
}

// ─── Enums (mirrored from widget files to avoid import issues in this file) ─

enum AppButtonVariant { primary, secondary, ghost }
enum AppButtonSize { small, medium, large }
enum AppCardVariant { elevated, outlined, filled, ghost }
enum StatusBarVariant { success, error, warning, info }