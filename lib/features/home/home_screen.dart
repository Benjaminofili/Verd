import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/core/constants/app_assets.dart';

import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onScanTap;
  
  const HomeScreen({super.key, this.onScanTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading to show skeleton
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const DashboardSkeleton(),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcome_to_verd,
                          style: AppTypography.h2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.smart_companion,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.logoPng,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield_outlined, // Fallback if logo png isn't found
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Quick Actions ──
              Text(
                AppLocalizations.of(context)!.quick_actions,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActionCard(
                iconBackgroundColor: const Color(0xFF4CAF50),
                icon: Icons.camera_alt,
                title: AppLocalizations.of(context)!.scan_crop,
                subtitle: AppLocalizations.of(context)!.scan_crop_desc_short,
                onTap: widget.onScanTap,
              ),
              _buildQuickActionCard(
                iconBackgroundColor: const Color(0xFF1976D2),
                icon: Icons.menu_book,
                title: AppLocalizations.of(context)!.learning_center_title,
                subtitle: AppLocalizations.of(context)!.learning_center_desc_short,
                onTap: () {
                  context.push('/learning-center');
                },
              ),
              _buildQuickActionCard(
                iconBackgroundColor: const Color(0xFFFF9800),
                icon: Icons.bar_chart,
                title: AppLocalizations.of(context)!.view_history,
                subtitle: AppLocalizations.of(context)!.view_history_desc_short,
                onTap: () {
                  context.push('/scan-history');
                },
              ),
              _buildQuickActionCard(
                iconBackgroundColor: const Color(0xFF9C27B0),
                icon: Icons.photo_library,
                title: AppLocalizations.of(context)!.gallery,
                subtitle: AppLocalizations.of(context)!.gallery_desc_short,
                onTap: () {
                  context.push('/gallery');
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Tip of the Day ──
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tip_of_the_day,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppLocalizations.of(context)!.early_detection_title,
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppLocalizations.of(context)!.early_detection_desc,
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Popular Topics ──
              Text(
                AppLocalizations.of(context)!.popular_topics,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
                children: [
                  _buildTopicCard(
                    iconBackgroundColor: const Color(0xFFE53935),
                    icon: Icons.coronavirus,
                    title: AppLocalizations.of(context)!.crop_diseases,
                    subtitle: AppLocalizations.of(context)!.crop_diseases_desc_short,
                    onTap: () => context.push('/article/diseases'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: const Color(0xFFFF9800),
                    icon: Icons.bug_report,
                    title: AppLocalizations.of(context)!.pest_control,
                    subtitle: AppLocalizations.of(context)!.pest_control_desc_short,
                    onTap: () => context.push('/article/pests'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: const Color(0xFF4CAF50),
                    icon: Icons.grass,
                    title: AppLocalizations.of(context)!.soil_health,
                    subtitle: AppLocalizations.of(context)!.soil_health_desc_short,
                    onTap: () => context.push('/article/soil'),
                  ),
                  _buildTopicCard(
                    iconBackgroundColor: const Color(0xFF2196F3),
                    icon: Icons.water_drop,
                    title: AppLocalizations.of(context)!.irrigation,
                    subtitle: AppLocalizations.of(context)!.irrigation_desc_short,
                    onTap: () => context.push('/article/water'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildQuickActionCard({
    required Color iconBackgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return BouncingCard(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
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
      ),
    );
  }

  Widget _buildTopicCard({
    required Color iconBackgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return BouncingCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ),
    );
  }
}