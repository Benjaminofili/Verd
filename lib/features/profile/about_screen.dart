import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            'Back',
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          'About VERD',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shield, // Using shield as in screenshot
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'VERD',
              style: AppTypography.h1.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.huge),

            // Our Mission Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'VERD is dedicated to empowering farmers and agricultural professionals with cutting-edge AI technology to identify crop diseases early and improve crop yields. Our mission is to make agricultural expertise accessible to everyone.',
                    style: AppTypography.body.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Features Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeatureItem(context, 'AI-powered crop disease detection'),
                  _buildFeatureItem(context, 'Comprehensive learning resources'),
                  _buildFeatureItem(context, 'Offline mode for remote areas'),
                  _buildFeatureItem(context, 'History tracking and analytics'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Terms of Service Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.lg),
              onTap: () {
                AppToast.show(
                  context,
                  message: 'Terms of Service coming soon',
                  variant: ToastVariant.info,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms of Service',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
