import 'package:flutter/material.dart';
import 'package:is_mb_app/partical_layouts/loading_screen.dart';
import 'package:is_mb_app/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/navigation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late final NavigationService navService;
  late final AuthService authService;
  User? user;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    navService = Provider.of<NavigationService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final fetchedUser = await authService.getUser();
      setState(() {
        user = fetchedUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await authService.clearToken();

    setState(() => _isLoading = false);
    navService.navigateTo("/login");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    if (_isLoading) {
      return const LoadingScreen();
    }

    if (_errorMessage != null || user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'User data not available'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user!.username, style: const TextStyle(fontSize: 16)),
              background: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(90.0), // Adjust the radius as needed
                ),
                child: Container(
                  color: primaryColor.withOpacity(0.2),
                  child: const Icon(
                    Icons.people_alt_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? Colors.black : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    user!.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${user!.username}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(Icons.mood, 'Moods', user!.moodCount),
                      _buildStatItem(Icons.people_outline, 'Juornals',
                          user!.followingCount),
                      _buildStatItem(
                          Icons.person_add, 'Friends', user!.followerCount),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sections
                  _buildSection('Account', Icons.account_circle_outlined, [
                    _buildListTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: user!.email,
                    ),
                    _buildListTile(
                      icon: Icons.lock_outline,
                      title: 'Password',
                      value: '••••••••',
                    ),
                  ]),

                  _buildSection('Preferences', Icons.settings_outlined, [
                    _buildListTile(
                      icon: Icons.color_lens_outlined,
                      title: 'Theme',
                      value: isDarkMode ? 'Dark' : 'Light',
                    ),
                    _buildListTile(
                      icon: Icons.language,
                      title: 'Language',
                      value: 'English',
                    ),
                  ]),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: () {}, // Add navigation as needed
    );
  }

  Widget _buildStatItem(IconData icon, String label, int count) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
