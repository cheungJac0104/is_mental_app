import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveBackground extends StatefulWidget {
  final List<Color> colors;
  final int numberOfWaves;
  final double amplitude;
  final Duration animationDuration;

  const WaveBackground({
    super.key,
    this.colors = const [Colors.blue, Colors.lightBlue],
    this.numberOfWaves = 3,
    this.amplitude = 100.0,
    this.animationDuration = const Duration(seconds: 5),
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animationValue: _controller.value,
            colors: widget.colors,
            numberOfWaves: widget.numberOfWaves,
            amplitude: widget.amplitude,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final int numberOfWaves;
  final double amplitude;

  _WavePainter({
    required this.animationValue,
    required this.colors,
    required this.numberOfWaves,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < numberOfWaves; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final path = Path();
      final phase = progress * 2 * math.pi;

      // Create gradient
      final gradient = LinearGradient(
        colors: [
          colors[i % colors.length].withOpacity(0.4),
          colors[(i + 1) % colors.length].withOpacity(0.2),
        ],
      ).createShader(rect);

      path.moveTo(0, size.height / 2);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height / 2 +
            amplitude *
                math.sin((x / size.width * 4 * math.pi) + phase) *
                math.sin(x / size.width * math.pi + phase) *
                (1 - i * 0.15);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colors != colors ||
        oldDelegate.numberOfWaves != numberOfWaves ||
        oldDelegate.amplitude != amplitude;
  }
}
