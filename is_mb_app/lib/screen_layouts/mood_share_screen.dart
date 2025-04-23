import 'package:flutter/material.dart';
import 'package:is_mb_app/partical_layouts/post_dialog.dart';
import 'package:is_mb_app/services/auth_service.dart';
import 'package:is_mb_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../partical_layouts/bottom_loading_bar.dart';

class MoodShareScreen extends StatefulWidget {
  final Map<String, dynamic> moodEntry;

  const MoodShareScreen({super.key, required this.moodEntry});

  @override
  State<MoodShareScreen> createState() => _MoodShareScreenState();
}

class _MoodShareScreenState extends State<MoodShareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showShareOptions = false;
  late ApiService apiService;
  late NavigationService navService;
  late AuthService authService;
  bool _isLoading = false;
  double _uploadProgress = 0;
  String _currentPrivacy = "";

  @override
  void initState() {
    super.initState();

    apiService = Provider.of<ApiService>(context, listen: false);
    navService = Provider.of<NavigationService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    _currentPrivacy = authService.privacyGetter();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Show share options after animation completes
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => _showShareOptions = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              // Loading bar positioned at bottom
              if (_isLoading)
                Positioned(
                  bottom: 64, // Match your padding
                  left: 24, // Match your padding
                  right: 24, // Match your padding
                  child: BottomLoadingBar(
                    progress: _uploadProgress,
                    statusText: _getStatusText(),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Confirmation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getMoodColor(widget.moodEntry['intensity'])
                              .withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 80,
                          color: _getMoodColor(widget.moodEntry['intensity']),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mood Message
                  Text(
                    'Your ${widget.moodEntry['mood']} mood\nwas saved successfully!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sentiment Score
                  Text(
                    'Sentiment Score: ${widget.moodEntry['feedback']}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Share Options (Animated)
                  if (_showShareOptions) ...[
                    AnimatedOpacity(
                      opacity: _showShareOptions ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            'Share your mood with friends:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                icon: Icons.facebook,
                                color: const Color(0xFF1877F2),
                                onPressed: _shareToFacebook,
                              ),
                              const SizedBox(width: 16),
                              _buildSocialButton(
                                icon: Icons.message,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                                onPressed: _shareViaMessage,
                              ),
                              const SizedBox(width: 16),
                              _buildSocialButton(
                                icon: Icons.more_horiz,
                                color: Colors.grey.shade600,
                                onPressed: _showMoreOptions,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Return Home Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _returnToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        foregroundColor:
                            _getMoodColor(widget.moodEntry['intensity']),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Return to Home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    if (_uploadProgress < 0.3) return 'Preparing post...';
    if (_uploadProgress < 0.6) return 'Uploading content...';
    if (_uploadProgress < 0.9) return 'Processing...';
    return 'Almost done!';
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 28, color: color),
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Color _getMoodColor(int? intensity) {
    intensity ?? 0;
    switch (intensity) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.orange.shade600;
      case 3:
        return Colors.blue.shade600;
      case 4:
        return Colors.indigo.shade600;
      case 5:
        return Colors.red.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  void _shareToFacebook() {
    // Implement Facebook sharing
  }

  Future<void> _shareViaMessage() async {
    final content = widget.moodEntry['tip'].toString();
    final privacy = authService.privacyGetter();
    final userId = authService.userIdGetter();

    // Show confirmation dialog
    final shouldProceed =
        await PostDialog(content: content, privacy: privacy, context: context)
            .show();

    if (shouldProceed != true) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.75;
    });

    try {
      final response = await apiService.createCommunityPost(
        userId,
        content,
        privacyMode: privacy,
      );

      apiService.getResBodyJson(response);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post shared successfully!')),
          );
        }
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 1.0;
        });
      }
    }
  }

  Future<void> _showMoreOptions() async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                'Update Privacy Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 24),

              // Privacy options
              _buildPrivacyOption(
                icon: Icons.public,
                title: 'Public',
                subtitle: 'Visible to everyone',
                isSelected: _currentPrivacy == 'public',
                onTap: () => _updatePrivacy('public'),
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 16),

              _buildPrivacyOption(
                icon: Icons.people,
                title: 'Friends Only',
                subtitle: 'Visible to your friends',
                isSelected: _currentPrivacy == 'friends',
                onTap: () => _updatePrivacy('friends'),
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 16),

              _buildPrivacyOption(
                icon: Icons.lock,
                title: 'Private',
                subtitle: 'Only visible to you',
                isSelected: _currentPrivacy == 'private',
                onTap: () => _updatePrivacy('private'),
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 32),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.blue.shade400, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.blue.shade400
                  : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue.shade400,
              ),
          ],
        ),
      ),
    );
  }

  void _updatePrivacy(String privacy) async {
    try {
      if (mounted) {
        Navigator.pop(context);
      }
      // Show loading state if needed
      setState(() => _isLoading = true);

      // Update privacy settings
      await authService.privacySetter(privacy);
      final rtn = await apiService.updatePrivacySetting(privacy);
      apiService.getResBodyJson(rtn);

      if (mounted) {
// Show success message with current privacy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Privacy set to: $privacy'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }

      // Update UI and close dialog
      setState(() {
        _currentPrivacy = privacy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update privacy: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _returnToHome() {
    navService.navigateTo("/", tabIndex: 0);
  }
}
