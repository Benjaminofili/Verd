import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:df_localization/df_localization.dart';
import 'package:verd/core/constants/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Available supported languages mapping to our YAML files
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'nativeName': 'English', 'code': 'en', 'country': 'us'},
    {'name': 'French', 'nativeName': 'Français', 'code': 'fr', 'country': 'fr'},
    {'name': 'Hausa', 'nativeName': 'Hausa', 'code': 'ha', 'country': 'ng'},
    {'name': 'Spanish', 'nativeName': 'Español', 'code': 'es', 'country': 'es'},
    {'name': 'German', 'nativeName': 'Deutsch', 'code': 'de', 'country': 'de'},
    {'name': 'Portuguese', 'nativeName': 'Português', 'code': 'pt', 'country': 'br'},
    {'name': 'Chinese', 'nativeName': '中文', 'code': 'zh', 'country': 'cn'},
    {'name': 'Japanese', 'nativeName': '日本語', 'code': 'ja', 'country': 'jp'},
    {'name': 'Korean', 'nativeName': '한국어', 'code': 'ko', 'country': 'kr'},
    {'name': 'Arabic', 'nativeName': 'العربية', 'code': 'ar', 'country': 'sa'},
    {'name': 'Hindi', 'nativeName': 'हिन्दी', 'code': 'hi', 'country': 'in'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = TranslationController.i.locale ?? const Locale('en', 'us');
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Back',
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          'language'.tr(),
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            child: Text(
              'Done',
              style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: ListView.separated(
          itemCount: _languages.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            color: AppColors.gray200,
            indent: AppSpacing.xl,
          ),
          itemBuilder: (context, index) {
            final language = _languages[index];
            final isSelected = currentLocale.languageCode == language['code'];

            return InkWell(
              onTap: () {
                TranslationController.i.setLocale(
                  Locale(language['code']!, language['country']),
                );
                setState(() {}); // Re-render the tick icon
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language['name']!,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: AppTypography.medium,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language['nativeName']!,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
