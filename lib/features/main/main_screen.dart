import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:verd/core/constants/app_theme.dart';
import 'package:verd/features/home/home_screen.dart';
import 'package:verd/features/profile/profile_screen.dart';
import 'package:verd/features/scan/scan_screen.dart';
import 'package:verd/shared/widgets/connectivity_banner.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onScanTap: () => _onTabTapped(1)),
      const ScanScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ConnectivityBanner(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.xl,
          ),
          child: GNav(
            selectedIndex: _currentIndex,
            onTabChange: _onTabTapped,
            rippleColor: AppColors.primary.withValues(alpha: 0.2), // tab button ripple color when pressed
            hoverColor: AppColors.primary.withValues(alpha: 0.1), // tab button hover color
            haptic: true, // haptic feedback
            tabBorderRadius: 24, 
            tabActiveBorder: Border.all(color: AppColors.primary, width: 1), // tab button border
            tabBorder: Border.all(color: Colors.transparent, width: 1), // tab button border
            tabShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1), 
                blurRadius: 8
              )
            ], // tab button shadow
            curve: Curves.easeOutExpo, // tab animation curves
            duration: const Duration(milliseconds: 300), // tab animation duration
            gap: 8, // the tab button gap between icon and text 
            color: AppColors.gray500, // unselected icon color
            activeColor: Colors.white, // selected icon and text color
            iconSize: 26, // tab button icon size
            tabBackgroundColor: AppColors.primary, // selected tab background color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // navigation bar padding
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
              ),
              GButton(
                icon: Icons.camera_alt_outlined,
                text: 'Scan',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
