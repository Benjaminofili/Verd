import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, theme),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFeaturedArticle(context, theme),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  AppLocalizations.of(context)!.explore_categories,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCategoryGrid(context, theme),
                const SizedBox(height: AppSpacing.huge), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      backgroundColor: theme.colorScheme.surface,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.article_library,
        style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
          onPressed: () => _showSearchSheet(context, theme),
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context)!.search_articles,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search_hint,
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context)!.quick_topics,
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppLocalizations.of(context)!.crop_diseases,
                  AppLocalizations.of(context)!.pest_control,
                  AppLocalizations.of(context)!.soil_health,
                  AppLocalizations.of(context)!.irrigation
                ]
                    .map((topic) => ActionChip(
                          label: Text(topic),
                          onPressed: () => Navigator.pop(ctx),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, ThemeData theme) {
    return BouncingCard(
      onTap: () => context.push('/article/featured'),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage(AppAssets.onboarding1),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.audio_guide,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'How to Identify Fall Armyworm',
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.9,
      children: [
        _buildCategoryCard(
          context,
          theme: theme,
          id: 'diseases',
          title: AppLocalizations.of(context)!.crop_diseases,
          icon: Icons.coronavirus,
          color: const Color(0xFFE53935),
        ),
        _buildCategoryCard(
          context,
          theme: theme,
          id: 'pests',
          title: AppLocalizations.of(context)!.pest_control,
          icon: Icons.bug_report,
          color: const Color(0xFFFF9800),
        ),
        _buildCategoryCard(
          context,
          theme: theme,
          id: 'soil',
          title: AppLocalizations.of(context)!.soil_health,
          icon: Icons.grass,
          color: const Color(0xFF4CAF50),
        ),
        _buildCategoryCard(
          context,
          theme: theme,
          id: 'water',
          title: AppLocalizations.of(context)!.irrigation,
          icon: Icons.water_drop,
          color: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required ThemeData theme,
    required String id,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return BouncingCard(
      onTap: () => context.push('/article/$id'),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Hero(
                tag: 'hero_icon_$id',
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
