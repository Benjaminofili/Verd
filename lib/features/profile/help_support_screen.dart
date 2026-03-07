import 'package:verd/l10n/app_localizations.dart';
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
            AppLocalizations.of(context)!.back,
            style: AppTypography.buttonSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.help_support,
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
              AppLocalizations.of(context)!.contact_us,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildContactItem(
              context: context,
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.email_support,
              subtitle: 'support@verd.app',
              onTap: () {},
            ),
            _buildContactItem(
              context: context,
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context)!.call_us,
              subtitle: '+1 (800) 123-4567',
              onTap: () {},
            ),
            _buildContactItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: AppLocalizations.of(context)!.live_chat,
              subtitle: AppLocalizations.of(context)!.live_chat_desc,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            Text(
              AppLocalizations.of(context)!.faqs,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFAQItem(
              context: context,
              question: AppLocalizations.of(context)!.faq_scan_q,
              answer: AppLocalizations.of(context)!.faq_scan_a,
            ),
            _buildFAQItem(
              context: context,
              question: AppLocalizations.of(context)!.faq_accuracy_q,
              answer: AppLocalizations.of(context)!.faq_accuracy_a,
            ),
            _buildFAQItem(
              context: context,
              question: AppLocalizations.of(context)!.faq_offline_q,
              answer: AppLocalizations.of(context)!.faq_offline_a,
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
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
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

    final theme = Theme.of(context);
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
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              answer,
              style: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
