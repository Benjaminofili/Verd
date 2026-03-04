import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/shared/widgets/loading_indicator.dart';
import 'package:verd/shared/widgets/empty_state.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        items = [
          {'title': 'Healthy', 'date': '2026-03-01', 'type': 'healthy'},
          {'title': 'Leaf Blight', 'date': '2026-03-01', 'type': 'blight'},
          {'title': 'Rust', 'date': '2026-02-28', 'type': 'rust'},
          {'title': 'Healthy', 'date': '2026-02-28', 'type': 'healthy'},
          {'title': 'Mildew', 'date': '2026-02-27', 'type': 'mildew'},
          {'title': 'Healthy', 'date': '2026-02-27', 'type': 'healthy'},
          {'title': 'Blight', 'date': '2026-02-26', 'type': 'blight'},
          {'title': 'Healthy', 'date': '2026-02-26', 'type': 'healthy'},
          {'title': 'Spot', 'date': '2026-02-25', 'type': 'rust'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
          ),
        ),
        title: Text(
          'Gallery',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : items.isEmpty
              ? EmptyState(
                  icon: Icons.image_not_supported_outlined,
                  title: 'No Images Yet',
                  subtitle: 'Scanned plant images will appear here.',
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.85, // Approximately matching the image 
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildGalleryItem(
                        title: item['title'],
                        date: item['date'],
                        type: item['type'],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildGalleryItem({
    required String title,
    required String date,
    required String type,
  }) {
    List<Color> gradientColors;
    
    switch (type) {
      case 'healthy':
        gradientColors = [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
        break;
      case 'blight':
        gradientColors = [const Color(0xFFFFB74D), const Color(0xFFF57C00)];
        break;
      case 'rust':
        gradientColors = [const Color(0xFFEF5350), const Color(0xFFC62828)];
        break;
      case 'mildew':
        gradientColors = [const Color(0xFFAB47BC), const Color(0xFF6A1B9A)];
        break;
      default:
        gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Icons.energy_savings_leaf, // A leafy icon 
            color: Colors.white,
            size: 32,
          ),
          const Spacer(),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
