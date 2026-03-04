import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/core/constants/app_assets.dart';
import 'package:verd/shared/widgets/app_card.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Simulated content based on ID
    final title = _getTitle(articleId);
    final icon = _getIcon(articleId);
    final color = _getColor(articleId);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, title, icon, color),
          SliverToBoxAdapter(
            child: _buildAudioPlayer(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildContentChunk(
                  context,
                  title: '1. What does it look like?',
                  content: 'Look for small, brown spots on older leaves. These spots grow larger and look like a target with rings inside them. The leaves may turn yellow and fall off early.',
                  icon: Icons.visibility,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildContentChunk(
                  context,
                  title: '2. Immediate Action',
                  content: 'Remove and burn any infected leaves immediately. Do not leave them on the ground. Wash your hands and tools after touching the sick plant.',
                  icon: Icons.warning_amber_rounded,
                  isAlert: true,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildContentChunk(
                  context,
                  title: '3. Long-term Treatment',
                  content: 'Space your crops further apart so wind can dry the leaves. Water the soil directly, not the leaves. Use an organic copper fungicide if the problem spreads to the stems.',
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: AppSpacing.huge),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String title, IconData icon, Color color) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: color,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: AppSpacing.xl, bottom: AppSpacing.lg, right: AppSpacing.xl),
        title: Text(
          title,
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.onboarding2, // Reusing field image
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    color.withValues(alpha: 0.8),
                    color,
                  ],
                  stops: const [0.3, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: AppSpacing.xl,
              child: Hero(
                tag: 'hero_icon_$articleId',
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Listen to this guide (Audio)',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentChunk(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    bool isAlert = false,
  }) {
    final theme = Theme.of(context);
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isAlert ? theme.colorScheme.error : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: AppTypography.bodyLarge.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500, // Makes it easier to read
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers for Demo Data ---

  String _getTitle(String id) {
    switch (id) {
      case 'diseases':
        return 'Crop Diseases Guide';
      case 'pests':
        return 'Pest Control Basics';
      case 'soil':
        return 'Improving Soil Health';
      case 'water':
        return 'Smart Irrigation';
      case 'featured':
        return 'Identify Fall Armyworm';
      default:
        return 'Learning Topic';
    }
  }

  IconData _getIcon(String id) {
    switch (id) {
      case 'diseases':
        return Icons.coronavirus;
      case 'pests':
        return Icons.bug_report;
      case 'soil':
        return Icons.grass;
      case 'water':
        return Icons.water_drop;
      case 'featured':
        return Icons.star;
      default:
        return Icons.menu_book;
    }
  }

  Color _getColor(String id) {
    switch (id) {
      case 'diseases':
        return const Color(0xFFE53935);
      case 'pests':
        return const Color(0xFFFF9800);
      case 'soil':
        return const Color(0xFF4CAF50);
      case 'water':
        return const Color(0xFF2196F3);
      case 'featured':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF4CAF50); // Fallback color
    }
  }
}
