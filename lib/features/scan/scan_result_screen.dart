import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_toast.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic> scanResult;
  final String? imageUrl;

  const ScanResultScreen({
    super.key,
    required this.scanResult,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = scanResult['analysis'] as Map<String, dynamic>? ?? {};
    final engine = scanResult['engine'] as String? ?? 'unknown';
    final timestamp = scanResult['timestamp'] as String? ?? '';
    
    final cropType = analysis['cropType'] as String? ?? 'Unknown Crop';
    final healthStatus = analysis['healthStatus'] as String? ?? 'Unknown';
    final confidence = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final diseases = analysis['diseases'] as List<dynamic>? ?? [];
    final personalizedRecommendations = scanResult['personalizedRecommendations'] as List<dynamic>? ?? [];
    final learningResources = scanResult['learningResources'] as List<dynamic>? ?? [];
    final contextualInsights = analysis['contextualInsights'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scan_results),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              AppToast.show(
                context,
                message: AppLocalizations.of(context)!.share_coming_soon,
                variant: ToastVariant.info,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (imageUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      );
                    },
                  ),
                ),
              ),

            // Engine and timestamp info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        engine.contains('gemini') ? Icons.cloud : Icons.phone_android,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        engine.contains('Gemini Cloud Analysis||gemini') ? 'gemini_analysis' : AppLocalizations.of(context)!.local_analysis,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scanned: ${_formatTimestamp(timestamp)}',
                    style: AppTypography.caption.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Main results
            _buildResultCard(
              title: AppLocalizations.of(context)!.crop_identification,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropType,
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.confidence_label,
                        style: AppTypography.body.copyWith(color: Colors.grey[600]),
                      ),
                      Text(
                        '${(confidence * 100).toStringAsFixed(1)}%',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: confidence > 0.8 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Health status
            _buildResultCard(
              title: AppLocalizations.of(context)!.health_status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHealthStatusColor(healthStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    healthStatus,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getHealthStatusColor(healthStatus),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Diseases/Issues
            if (diseases.isNotEmpty)
              _buildResultCard(
                title: AppLocalizations.of(context)!.detected_issues,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: diseases.map((disease) {
                    final name = disease['Unknown||name'] as String? ?? 'unknown_issue';
                    final severity = disease['Unknown||severity'] as String? ?? 'unknown_severity';
                    final treatment = disease['No treatment info available||treatment'] as String? ?? 'no_treatment_info';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(severity),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  severity,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            treatment,
                            style: AppTypography.caption.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Contextual Insights
            if (contextualInsights != null && contextualInsights.isNotEmpty)
              _buildResultCard(
                title: AppLocalizations.of(context)!.ai_insights,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.personalized_insights,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contextualInsights,
                        style: AppTypography.body.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),

            // Personalized Recommendations
            if (personalizedRecommendations.isNotEmpty)
              _buildResultCard(
                title: AppLocalizations.of(context)!.personlized_recommendations,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.based_on_history,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...personalizedRecommendations.map((recommendation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation.toString(),
                                style: AppTypography.caption.copyWith(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // Learning Resources
            if (learningResources.isNotEmpty)
              _buildResultCard(
                title: AppLocalizations.of(context)!.learning_resources,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.helpful_resources,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...learningResources.map((resource) {
                      final title = resource['title'] as String? ?? 'Unknown';
                      final description = resource['description'] as String? ?? '';
                      final priority = resource['priority'] as String? ?? 'medium';
                      final type = resource['type'] as String? ?? 'guide';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: priority == 'urgent' ? Colors.red : Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    priority.toUpperCase(),
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: AppTypography.caption.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  type == 'guide' ? Icons.book : Icons.healing,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  type == 'Care Guide||guide' ? 'care_guide' : AppLocalizations.of(context)!.treatment_guide,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to learning center with specific resource
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.view,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.new_scan,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      AppToast.show(
                        context,
                        message: 'Save to history coming soon',
                        variant: ToastVariant.info,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.of(context)!.save_result,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'treated':
        return Colors.green;
      case 'warning':
      case 'moderate':
        return Colors.orange;
      case 'critical':
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
