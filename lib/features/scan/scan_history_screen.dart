import 'package:verd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/providers/auth_provider.dart';
import 'package:verd/providers/scan_provider.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/empty_state.dart';

class ScanHistoryScreen extends ConsumerStatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  ConsumerState<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends ConsumerState<ScanHistoryScreen> {
  String _selectedFilter = 'all';
  List<Map<String, String>> _getFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'all', 'label': l10n.filter_all},
      {'key': 'healthy', 'label': l10n.healthy},
      {'key': 'warning', 'label': l10n.warning},
      {'key': 'critical', 'label': l10n.critical},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.please_log_in)));
    }

    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: _buildIconButton(
              theme: theme,
              icon: Icons.chevron_left,
              onTap: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.scan_history,
          style: AppTypography.h3.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: _buildIconButton(
                theme: theme,
                icon: Icons.filter_alt_outlined,
                onTap: _showFilterSheet,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Filters horizontal pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: _getFilters(context).map((filter) {
                final isSelected = _selectedFilter == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = filter['key']!),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        filter['label']!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // History List
          Expanded(
            child: historyAsync.when(
              loading: () => const ScanListSkeleton(),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (items) {
                final filtered = _selectedFilter == 'all'
                    ? items
                    : items.where((item) => item.diagnosis.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                if (filtered.isEmpty) {
                  return EmptyState.noScans();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildHistoryCard(context, filtered[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                AppLocalizations.of(context)!.filter_by_status,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._getFilters(context).map((filter) {
                final isSelected = _selectedFilter == filter['key'];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    filter['label']!,
                    style: AppTypography.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedFilter = filter['key']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ScanResult item) {
    final statusColor = _getStatusColor(item.diagnosis);
    
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push('/scan-result', extra: item),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.image, color: statusColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.plantName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.diagnosis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${(item.confidence * 100).toStringAsFixed(1)}% confidence',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(item.scannedAt),
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy': return Colors.green;
      case 'warning': return Colors.orange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
