import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/core/providers/theme_provider.dart';
import 'package:verd/shared/widgets/app_button.dart';
import 'package:verd/shared/dialogs/confirmation_dialog.dart';
import 'package:verd/shared/widgets/skeleton_loader.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for the profile skeleton
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const ProfileSkeleton(),
      );
    }
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Deep green from the inspiration Image #3
    final headerBgColor = isDark ? const Color(0xFF081C0B) : const Color(0xFF13401A);

    return Scaffold(
      backgroundColor: headerBgColor, // Bleeds into status bar
      body: Stack(
        children: [
          // Geometric abstract background patterns
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Column(
            children: [
              // HEADER (Constrained by SafeArea)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile', style: AppTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF81C784), width: 3), // Light green border
                              color: const Color(0xFF4CAF50),
                            ),
                            child: const Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/edit-profile'),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(bottom: 4, right: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE68A00), // Orange badge like the inspiration
                                shape: BoxShape.circle,
                                border: Border.all(color: headerBgColor, width: 2), // Cutout effect
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Ada Farmer',
                        style: AppTypography.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ada.farmer@verd.com',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // BOTTOM OVERLAPPING CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.xxl,
                        bottom: 120, // Pad enough for nav bar area + safety
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Overview',
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF2196F3), // Light Blue
                            title: 'My Profile',
                            onTap: () => context.push('/edit-profile'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.history,
                            iconColor: const Color(0xFF4CAF50), // Green 
                            title: 'Scan History',
                            onTap: () => context.push('/history'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.notifications_none,
                            iconColor: const Color(0xFFE91E63), // Pink
                            title: 'Notifications',
                            onTap: () => context.push('/notifications'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.lock_outline,
                            iconColor: const Color(0xFFFF9800), // Orange
                            title: 'Change Password',
                            onTap: () => context.push('/change-password'),
                          ),
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.language,
                            iconColor: const Color(0xFF9C27B0), // Purple
                            title: 'Change Language',
                            onTap: () => context.push('/language'),
                          ),

                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Preferences & Support',
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          _buildThemeToggleItem(theme),
                          
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.help_outline,
                            iconColor: const Color(0xFF00BCD4), // Cyan
                            title: 'Help & Support',
                            onTap: () => context.push('/help-support'),
                          ),
                          
                          _buildMenuItem(
                            theme: theme,
                            icon: Icons.logout,
                            iconColor: const Color(0xFFF44336), // Red
                            title: 'Logout',
                            onTap: () async {
                              final confirmed = await ConfirmationDialog.logout(context);
                              if (confirmed == true && context.mounted) {
                                context.go('/login');
                              }
                            },
                            hideChevron: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool hideChevron = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12), // Soft rectangular icon background
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (!hideChevron)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem(ThemeData theme) {
    final currentMode = ref.watch(themeProvider);
    
    // Determine the active icon 
    IconData activeIcon = Icons.brightness_auto;
    const Color activeColor = Color(0xFF673AB7); // Deep Purple
    
    if (currentMode == ThemeMode.dark) {
      activeIcon = Icons.dark_mode;
    } else if (currentMode == ThemeMode.light) {
      activeIcon = Icons.light_mode;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(activeIcon, color: activeColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  'Appearance',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(left: 60.0), // Indent to match text
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto, size: 16),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode, size: 16),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode, size: 16),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (selection) {
                  ref.read(themeProvider.notifier).setTheme(selection.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
