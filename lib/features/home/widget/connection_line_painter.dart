import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Animated connection line painter that draws a bezier curve from user to server
class ConnectionLinePainter extends CustomPainter {
  ConnectionLinePainter({
    required this.userPosition,
    required this.serverPosition,
    required this.progress,
    required this.color,
    this.particleProgress = 0.0,
  });

  final Offset userPosition;
  final Offset serverPosition;
  final double progress; // 0.0 to 1.0 for line drawing animation
  final double particleProgress; // 0.0 to 1.0 for particle flow animation
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final start = userPosition;
    final end = serverPosition;

    // Calculate control points for bezier curve (arc upward)
    final midX = (start.dx + end.dx) / 2;
    final midY = min(start.dy, end.dy) - (end - start).distance * 0.25;
    final control = Offset(midX, midY);

    // Create the path
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Draw quadratic bezier curve
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    // Create gradient along path
    final gradient = LinearGradient(
      colors: [
        color.withOpacity(0.2),
        color.withOpacity(0.8),
        color.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Main line paint with gradient
    final linePaint = Paint()
      ..shader = gradient.createShader(Rect.fromPoints(start, end))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Create animated path based on progress
    final pathMetrics = path.computeMetrics().first;
    final animatedPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );

    // Draw glow first
    canvas.drawPath(animatedPath, glowPaint);
    // Draw main line
    canvas.drawPath(animatedPath, linePaint);

    // Draw data flow particles
    if (progress >= 1.0) {
      _drawParticles(canvas, path, pathMetrics);
    }

    // Draw endpoints
    _drawEndpoint(canvas, start, color, isUser: true);
    if (progress >= 1.0) {
      _drawEndpoint(canvas, end, color, isUser: false);
    }
  }

  void _drawParticles(Canvas canvas, Path path, PathMetric pathMetric) {
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Draw 3 particles at different positions along the path
    for (int i = 0; i < 3; i++) {
      final offset = (particleProgress + i * 0.33) % 1.0;
      final tangent = pathMetric.getTangentForOffset(
        pathMetric.length * offset,
      );

      if (tangent != null) {
        // Particle size varies slightly
        final size = 3.0 + sin(offset * pi * 2) * 1.0;
        canvas.drawCircle(tangent.position, size, particlePaint);

        // Particle glow
        final glowPaint = Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(tangent.position, size + 2, glowPaint);
      }
    }
  }

  void _drawEndpoint(Canvas canvas, Offset position, Color color, {required bool isUser}) {
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(position, 8, glowPaint);

    // Inner dot
    final dotPaint = Paint()
      ..color = isUser ? Colors.white : color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 5, dotPaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, 5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ConnectionLinePainter oldDelegate) =>
      userPosition != oldDelegate.userPosition ||
      serverPosition != oldDelegate.serverPosition ||
      progress != oldDelegate.progress ||
      particleProgress != oldDelegate.particleProgress ||
      color != oldDelegate.color;
}

/// Widget wrapper for animated connection line
class AnimatedConnectionLine extends StatefulWidget {
  const AnimatedConnectionLine({
    super.key,
    required this.userPosition,
    required this.serverPosition,
    required this.isConnected,
    this.color = const Color(0xFF00BCD4), // Cyan - Avalanche theme
  });

  final Offset userPosition;
  final Offset serverPosition;
  final bool isConnected;
  final Color color;

  @override
  State<AnimatedConnectionLine> createState() => _AnimatedConnectionLineState();
}

class _AnimatedConnectionLineState extends State<AnimatedConnectionLine>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _particleController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeOutCubic,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    if (widget.isConnected) {
      _lineController.forward();
      _particleController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedConnectionLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isConnected && !oldWidget.isConnected) {
      _lineController.forward(from: 0);
      _particleController.repeat();
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _lineController.reverse();
      _particleController.stop();
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_lineAnimation, _particleController]),
      builder: (context, child) {
        return CustomPaint(
          painter: ConnectionLinePainter(
            userPosition: widget.userPosition,
            serverPosition: widget.serverPosition,
            progress: _lineAnimation.value,
            particleProgress: _particleController.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}
