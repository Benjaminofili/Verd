import 'package:df_localization/df_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/app_card.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';
import 'package:verd/shared/widgets/empty_state.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool _isLoading = true;
  // Filter values match item['status'] values exactly (case-sensitive)
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Healthy', 'Medium', 'High', 'Low'];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'All') return _historyItems;
    return _historyItems.where((item) => item['status'] == _selectedFilter).toList();
  }

  final List<Map<String, dynamic>> _historyItems = [
    {
      'title': 'Healthy Crop',
      'subtitle': 'Tomato • 98% confidence',
      'date': 'Mar 3, 2026 at 09:30 AM',
      'status': 'Healthy',
    },
    {
      'title': 'Early Blight',
      'subtitle': 'Potato • 92% confidence',
      'date': 'Mar 2, 2026 at 02:15 PM',
      'status': 'Medium',
    },
    {
      'title': 'Leaf Rust',
      'subtitle': 'Wheat • 95% confidence',
      'date': 'Mar 1, 2026 at 11:45 AM',
      'status': 'High',
    },
    {
      'title': 'Healthy Crop',
      'subtitle': 'Corn • 97% confidence',
      'date': 'Feb 28, 2026 at 04:20 PM',
      'status': 'Healthy',
    },
    {
      'title': 'Powdery Mildew',
      'subtitle': 'Cucumber • 89% confidence',
      'date': 'Feb 27, 2026 at 10:00 AM',
      'status': 'Low',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
                'Filter by Status',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    filter,
                    style: AppTypography.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedFilter = filter);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Scan History||scan_history'.tr(),
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
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = filter),
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
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        filter,
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
            child: _isLoading
                ? const ScanListSkeleton()
                : _filteredItems.isEmpty
                    ? EmptyState.noScans()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildHistoryCard(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
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
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    Color iconBackgroundColor;
    IconData iconData;
    Color statusColor;

    switch (item['status']) {
      case 'Healthy':
        iconBackgroundColor = const Color(0xFF4CAF50);
        iconData = Icons.check;
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'Low':
        iconBackgroundColor = const Color(0xFF81C784);
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFF81C784);
        break;
      case 'Medium':
        iconBackgroundColor = const Color(0xFFFF9800);
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFFFF9800);
        break;
      case 'High':
        iconBackgroundColor = const Color(0xFFE53935);
        iconData = Icons.warning_amber_rounded;
        statusColor = const Color(0xFFE53935);
        break;
      default:
        iconBackgroundColor =
            theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
        iconData = Icons.info_outline;
        statusColor =
            theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    }

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 32,
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
                        item['title'],
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'],
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
                  item['subtitle'],
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
