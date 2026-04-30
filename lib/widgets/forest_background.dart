import 'dart:math';
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Fond "Forêt enchantée" : gradient vert + grain + feuilles + lucioles.
class ForestBackground extends StatelessWidget {
  final Widget child;
  const ForestBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient radial vert mousse
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [AppColors.forestBg3, AppColors.forestBg1],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Silhouettes de feuilles
        Positioned.fill(child: CustomPaint(painter: _LeavesPainter())),
        // Grain papier
        Positioned.fill(child: CustomPaint(painter: _GrainPainter())),
        // Lucioles
        const Positioned.fill(child: _FirefliesLayer()),
        // Contenu
        child,
      ],
    );
  }
}

// ── Lucioles animées ──────────────────────────────────────────────────────────

class _FirefliesLayer extends StatelessWidget {
  const _FirefliesLayer();

  static final List<_FfData> _flies = _gen();
  static List<_FfData> _gen() {
    final r = Random(7);
    return List.generate(18, (i) => _FfData(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: r.nextDouble() * 4 + 3,
      delay: r.nextInt(3000),
      duration: r.nextInt(2000) + 2000,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: _flies.map((f) {
          final cx = f.x * constraints.maxWidth;
          final cy = f.y * constraints.maxHeight;
          return Positioned(
            left: cx - f.size * 3,
            top: cy - f.size * 3,
            child: _Firefly(size: f.size, delay: f.delay, duration: f.duration),
          );
        }).toList(),
      );
    });
  }
}

class _Firefly extends StatelessWidget {
  final double size;
  final int delay;
  final int duration;
  const _Firefly({required this.size, required this.delay, required this.duration});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 6,
      height: size * 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo externe
          Container(
            width: size * 6,
            height: size * 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.forestGold.withValues(alpha: 0.06),
            ),
          ).animate(
            onPlay: (c) => c.repeat(reverse: true),
          ).fadeIn(duration: duration.ms, delay: delay.ms)
           .fadeOut(duration: duration.ms),
          // Halo moyen
          Container(
            width: size * 3.5,
            height: size * 3.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.forestGold.withValues(alpha: 0.15),
            ),
          ).animate(
            onPlay: (c) => c.repeat(reverse: true),
          ).fadeIn(duration: (duration * 0.8).round().ms, delay: delay.ms)
           .fadeOut(duration: (duration * 0.8).round().ms),
          // Cœur lumineux
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.forestGoldLight,
            ),
          ).animate(
            onPlay: (c) => c.repeat(reverse: true),
          ).fadeIn(duration: (duration * 0.5).round().ms, delay: delay.ms)
           .fadeOut(duration: (duration * 0.5).round().ms),
        ],
      ),
    );
  }
}

class _FfData {
  final double x, y, size;
  final int delay, duration;
  const _FfData({required this.x, required this.y, required this.size,
      required this.delay, required this.duration});
}

// ── Silhouettes de feuilles ────────────────────────────────────────────────────

class _LeavesPainter extends CustomPainter {
  static final List<_LeafData> _leaves = _gen();
  static List<_LeafData> _gen() {
    final r = Random(3);
    return List.generate(12, (i) => _LeafData(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: r.nextDouble() * 40 + 20,
      angle: r.nextDouble() * pi * 2,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestLeaf.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (final l in _leaves) {
      canvas.save();
      canvas.translate(l.x * size.width, l.y * size.height);
      canvas.rotate(l.angle);
      // Feuille simple — ellipse pointue
      final path = Path()
        ..moveTo(0, -l.size)
        ..cubicTo(l.size * 0.5, -l.size * 0.5, l.size * 0.5, l.size * 0.5, 0, l.size)
        ..cubicTo(-l.size * 0.5, l.size * 0.5, -l.size * 0.5, -l.size * 0.5, 0, -l.size);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeavesPainter o) => false;
}

class _LeafData {
  final double x, y, size, angle;
  const _LeafData({required this.x, required this.y,
      required this.size, required this.angle});
}

// ── Grain papier ──────────────────────────────────────────────────────────────

class _GrainPainter extends CustomPainter {
  static final List<Offset> _pts = _gen();
  static List<Offset> _gen() {
    final r = Random(11);
    return List.generate(800, (_) => Offset(r.nextDouble(), r.nextDouble()));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestCream.withValues(alpha: 0.025)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (final p in _pts) {
      canvas.drawPoints(
        PointMode.points,
        [Offset(p.dx * size.width, p.dy * size.height)],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter o) => false;
}
