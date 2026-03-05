import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
          style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildContactItem(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@verd.app',
              onTap: () {},
            ),
            _buildContactItem(
              context: context,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+1 (800) 123-4567',
              onTap: () {},
            ),
            _buildContactItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with our team',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            Text(
              'Frequently Asked Questions',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFAQItem(
              context: context,
              question: 'How do I scan a crop?',
              answer: 'Go to the Scan tab, position your crop within the frame, and tap the camera button. The app will analyze the image and provide results.',
            ),
            _buildFAQItem(
              context: context,
              question: 'How accurate is the disease detection?',
              answer: 'Our AI model has been trained on thousands of crop images and maintains a 95% accuracy rate for common crop diseases.',
            ),
            _buildFAQItem(
              context: context,
              question: 'Can I use the app offline?',
              answer: 'Yes! Enable offline mode in settings. Previously downloaded disease data will be available for scanning.',
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C), // Dark green icon bg
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              answer,
              style: AppTypography.body.copyWith(
                color: AppColors.gray600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
