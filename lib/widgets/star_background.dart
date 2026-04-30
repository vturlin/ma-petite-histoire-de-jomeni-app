import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fond texturé avec de petites étoiles/étincelles dispersées aléatoirement.
class StarBackground extends StatelessWidget {
  final Widget child;
  const StarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _StarPainter()),
        ),
        child,
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  // Points fixes générés une seule fois (seed constant)
  static final List<_Star> _stars = _generate();

  static List<_Star> _generate() {
    final rng = Random(42);
    return List.generate(60, (_) => _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 3 + 1,
      opacity: rng.nextDouble() * 0.25 + 0.08,
      type: rng.nextInt(3), // 0=cercle, 1=croix, 2=étoile 4pts
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final paint = Paint()
        ..color = _starColor(s.type).withValues(alpha: s.opacity)
        ..style = PaintingStyle.fill;

      final cx = s.x * size.width;
      final cy = s.y * size.height;

      if (s.type == 0) {
        canvas.drawCircle(Offset(cx, cy), s.size, paint);
      } else if (s.type == 1) {
        // Petite croix +
        final p = Paint()
          ..color = paint.color
          ..strokeWidth = s.size * 0.7
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx - s.size, cy), Offset(cx + s.size, cy), p);
        canvas.drawLine(Offset(cx, cy - s.size), Offset(cx, cy + s.size), p);
      } else {
        // Étoile 4 branches ✦
        final path = Path();
        final r = s.size * 1.2;
        final r2 = r * 0.35;
        for (int i = 0; i < 4; i++) {
          final angle = i * pi / 2 - pi / 2;
          final inner = angle + pi / 4;
          if (i == 0) {
            path.moveTo(cx + cos(angle) * r, cy + sin(angle) * r);
          } else {
            path.lineTo(cx + cos(angle) * r, cy + sin(angle) * r);
          }
          path.lineTo(cx + cos(inner) * r2, cy + sin(inner) * r2);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  Color _starColor(int type) {
    switch (type) {
      case 0: { return AppColors.accent2; }
      case 1: { return AppColors.rose; }
      default: { return AppColors.sky; }
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => false;
}

class _Star {
  final double x, y, size, opacity;
  final int type;
  const _Star({
    required this.x, required this.y,
    required this.size, required this.opacity,
    required this.type,
  });
}
