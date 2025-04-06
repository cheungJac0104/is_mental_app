import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../partical_layouts/loading_screen.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'mood_entry_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import 'tailwind.dart';

class MainWrapper extends StatefulWidget {
  final int? initialIndex;

  const MainWrapper({super.key, this.initialIndex});

  @override
  MainWrapperState createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late AuthService authService;
  late NavigationService navigationService;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityScreen(),
    const MoodEntryScreen(),
    const StatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    authService = Provider.of<AuthService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
  }

  Future<void> _checkAuth() async {
    // Check if token exists and is not expired
    //await authService.clearToken();
    final token = await authService.getToken();
    final isExpired = await authService.isTokenExpired();

    if (token == null || isExpired) {
      // Redirect to login screen
      if (mounted) {
        await authService.clearToken();
        navigationService.navigateTo('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: TwColors.primary(context),
      unselectedItemColor: TwColors.secondary(context),
      backgroundColor: TwColors.background(context),
      selectedLabelStyle: TwTextStyles.body(context).copyWith(fontSize: 16),
      unselectedLabelStyle: TwTextStyles.body(context).copyWith(fontSize: 12),
      iconSize: TwSizes.p5,
      items: [
        _buildNavItem(Icons.home, 'Home'),
        _buildNavItem(Icons.people, 'Community'),
        _buildNavItem(Icons.emoji_emotions, 'Check-In'),
        _buildNavItem(Icons.analytics, 'Stats'),
        _buildNavItem(Icons.person, 'Profile'),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(TwSizes.p2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TwSizes.p2),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
