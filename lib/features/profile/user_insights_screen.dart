import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/providers/ai_provider.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class UserInsightsScreen extends ConsumerStatefulWidget {
  const UserInsightsScreen({super.key});

  @override
  ConsumerState<UserInsightsScreen> createState() => _UserInsightsScreenState();
}

class _UserInsightsScreenState extends ConsumerState<UserInsightsScreen> {
  Map<String, dynamic>? _insights;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final insights = await ref.read(aiServiceProvider).getUserFarmingInsights(user.uid);
        if (mounted) {
          setState(() {
            _insights = insights;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Failed to load insights: $e',
          variant: ToastVariant.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.farming_insights),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadInsights,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _insights == null
              ? _buildEmptyState()
              : _buildInsightsContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_insights_yet,
            style: AppTypography.h3.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.start_scanning_desc,
            style: AppTypography.body.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed('scan_result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(AppLocalizations.of(context)!.start_scanning),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    final insights = _insights!;
    final scanCount = insights['scanCount'] as int? ?? 0;
    final cropTypes = insights['cropTypes'] as List<String>? ?? [];
    final lastUpdated = insights['lastUpdated'] as String? ?? '';
    final error = insights['error'] as String?;

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.insights_error,
                style: AppTypography.h3.copyWith(
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTypography.body.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          _buildStatsCard(scanCount, cropTypes.length, lastUpdated),
          const SizedBox(height: AppSpacing.lg),

          // AI Insights
          if (insights['insights'] != null)
            _buildInsightsCard(insights['insights']),
          const SizedBox(height: AppSpacing.lg),

          // Crop Diversity
          if (cropTypes.isNotEmpty)
            _buildCropDiversityCard(cropTypes),
          const SizedBox(height: AppSpacing.lg),

          // Recommendations
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int scanCount, int cropCount, String lastUpdated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.farming_overview,
            style: AppTypography.h4.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.total_scans,
                  scanCount.toString(),
                  Icons.camera_alt,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.crop_types,
                  cropCount.toString(),
                  Icons.eco,
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: ${_formatDate(lastUpdated)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(dynamic insights) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[600], size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.ai_insights_title,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              insights.toString(),
              style: AppTypography.body.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropDiversityCard(List<String> cropTypes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green[600], size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.crop_diversity,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cropTypes.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(
                  crop,
                  style: AppTypography.caption.copyWith(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.purple[600], size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.recommendations,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            AppLocalizations.of(context)!.rec_scan_regularly,
            AppLocalizations.of(context)!.rec_diversify,
            AppLocalizations.of(context)!.rec_document,
          ].map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTypography.body.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return AppLocalizations.of(context)!.unknown;
    }
  }
}
