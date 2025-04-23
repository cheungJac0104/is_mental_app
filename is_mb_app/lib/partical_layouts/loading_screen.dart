import 'package:flutter/material.dart';

import '../screen_layouts/tailwind.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TwColors.primary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(Icons.access_time_filled_rounded),
            ),
            const SizedBox(height: 32),

            // Animated Progress Bar
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  backgroundColor: TwColors.secondary(context).withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    TwColors.primary(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Loading Text with Dot Animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading',
                  style: TextStyle(
                    fontSize: 16,
                    color: TwColors.text(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                _buildAnimatedDots(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return const SizedBox(
      width: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _AnimatedDot(delay: 0),
          _AnimatedDot(delay: 200),
          _AnimatedDot(delay: 400),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  __AnimatedDotState createState() => __AnimatedDotState();
}

class __AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: TwColors.primary(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
