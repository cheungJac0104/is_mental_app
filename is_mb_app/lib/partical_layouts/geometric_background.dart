import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometricBackground extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final int shapeCount;
  final double maxSize;
  final Duration animationDuration;

  const GeometricBackground({
    super.key,
    this.primaryColor = const Color(0xFF6C5CE7),
    this.secondaryColor = const Color(0xFF00CEFF),
    this.shapeCount = 12,
    this.maxSize = 120,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<GeometricBackground> createState() => _GeometricBackgroundState();
}

class _GeometricBackgroundState extends State<GeometricBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ShapePosition> _shapes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
    _generateShapes();
  }

  void _generateShapes() {
    final random = math.Random();
    _shapes.clear();

    for (int i = 0; i < widget.shapeCount; i++) {
      _shapes.add(ShapePosition(
        type: random.nextBool() ? ShapeType.square : ShapeType.triangle,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 0.3 + random.nextDouble() * 0.7,
        speed: 0.5 + random.nextDouble(),
        rotation: random.nextDouble() * 2 * math.pi,
      ));
    }
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
        return SizedBox.expand(
          child: Stack(
            children: _shapes.map((shape) {
              final time = DateTime.now().millisecondsSinceEpoch / 1000;
              final x = (shape.x + 0.1 * math.cos(time * shape.speed)) *
                  MediaQuery.of(context).size.width;
              final y = (shape.y + 0.1 * math.sin(time * shape.speed * 0.7)) *
                  MediaQuery.of(context).size.height;
              final size = widget.maxSize * shape.size;
              final rotation = shape.rotation + time * 0.1 * shape.speed;
              final color = shape.type == ShapeType.square
                  ? widget.primaryColor
                  : widget.secondaryColor;

              return Positioned(
                left: x - size / 2,
                top: y - size / 2,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: 0.15,
                    child: shape.type == ShapeType.square
                        ? _RoundedSquare(size: size, color: color)
                        : _RoundedTriangle(size: size, color: color),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

enum ShapeType { square, triangle }

class ShapePosition {
  final ShapeType type;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double rotation;

  ShapePosition({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
  });
}

class _RoundedSquare extends StatelessWidget {
  final double size;
  final Color color;

  const _RoundedSquare({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
    );
  }
}

class _RoundedTriangle extends StatelessWidget {
  final double size;
  final Color color;

  const _RoundedTriangle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(color: color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
