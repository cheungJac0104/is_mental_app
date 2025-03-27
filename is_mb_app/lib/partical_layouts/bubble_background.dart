import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleBackground extends StatefulWidget {
  final Color? color;
  final int bubbleCount;
  final double maxBubbleSize;
  final Duration animationDuration;

  const BubbleBackground({
    super.key,
    this.color,
    this.bubbleCount = 15,
    this.maxBubbleSize = 100,
    this.animationDuration = const Duration(seconds: 6),
  });

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final time = DateTime.now().millisecondsSinceEpoch / 1000;
        return SizedBox.expand(
          child: Stack(
            children: List.generate(widget.bubbleCount, (index) {
              final x = (0.5 + 0.4 * math.cos(time + index * 0.7)) *
                  MediaQuery.of(context).size.width;
              final y = (0.5 + 0.4 * math.sin(time * 0.5 + index * 0.9)) *
                  MediaQuery.of(context).size.height;
              final size = widget.maxBubbleSize *
                  (0.5 + 0.5 * math.sin(time * 0.3 + index * 0.5));
              final opacity = 0.2 + 0.1 * math.sin(time * 0.2 + index * 0.3);

              return Positioned(
                left: x - size / 2,
                top: y - size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(opacity),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
