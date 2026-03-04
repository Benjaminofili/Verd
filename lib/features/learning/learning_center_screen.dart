import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/shared/widgets/bouncing_card.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFeaturedArticle(context),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'Explore Categories',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCategoryGrid(context),
                const SizedBox(height: AppSpacing.huge), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundPrimary,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Learning Center',
        style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            // Future search implementation
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedArticle(BuildContext context) {
    return BouncingCard(
      onTap: () => context.push('/article/featured'),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage(AppAssets.onboarding1), // Reusing existing hero image
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
                      'AUDIO GUIDE',
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

  Widget _buildCategoryGrid(BuildContext context) {
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
          id: 'diseases',
          title: 'Crop Diseases',
          icon: Icons.coronavirus,
          color: const Color(0xFFE53935),
        ),
        _buildCategoryCard(
          context,
          id: 'pests',
          title: 'Pest Control',
          icon: Icons.bug_report,
          color: const Color(0xFFFF9800),
        ),
        _buildCategoryCard(
          context,
          id: 'soil',
          title: 'Soil Health',
          icon: Icons.grass,
          color: const Color(0xFF4CAF50),
        ),
        _buildCategoryCard(
          context,
          id: 'water',
          title: 'Irrigation',
          icon: Icons.water_drop,
          color: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
