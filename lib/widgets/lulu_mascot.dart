import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Mascotte luciole "Lulu" — dessinée en Flutter.
class LuluMascot extends StatelessWidget {
  final double size;
  const LuluMascot({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final s = size;
    return SizedBox(
      width: s * 1.6,
      height: s * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo externe pulsant
          Container(
            width: s * 1.1,
            height: s * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.forestGold.withValues(alpha: 0.22),
                  AppColors.forestGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.8,
                  end: 1.2,
                  duration: 2400.ms,
                  curve: Curves.easeInOut),

          // Corps + tête + ailes via CustomPaint
          CustomPaint(
            size: Size(s, s * 1.25),
            painter: _FireflyPainter(size: s),
          ),

          // Queue lumineuse (abdomen qui clignote)
          Positioned(
            bottom: s * 0.08,
            child: Container(
              width: s * 0.3,
              height: s * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.forestGold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestGold.withValues(alpha: 0.9),
                    blurRadius: s * 0.25,
                    spreadRadius: s * 0.08,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 1300.ms,
                  curve: Curves.easeInOut,
                  builder: (ctx, v, child) =>
                      Opacity(opacity: 0.55 + v * 0.45, child: child),
                ),
          ),
        ],
      ),
    );
  }
}

class _FireflyPainter extends CustomPainter {
  final double size;
  const _FireflyPainter({required this.size});

  @override
  void paint(Canvas canvas, Size cs) {
    final s = size;
    final cx = cs.width / 2;

    // ── Ailes (dessinées avant le corps) ──────────────────────────────────────
    final wingFill = Paint()
      ..color = AppColors.forestGold.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final wingBorder = Paint()
      ..color = AppColors.forestGold.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Aile gauche — pétale incliné vers le haut-gauche
    final leftWing = Path()
      ..moveTo(cx - s * 0.12, s * 0.3)
      ..cubicTo(
        cx - s * 0.65, s * 0.05,
        cx - s * 0.62, s * 0.55,
        cx - s * 0.12, s * 0.47,
      )
      ..close();
    canvas.drawPath(leftWing, wingFill);
    canvas.drawPath(leftWing, wingBorder);

    // Aile droite — symétrique
    final rightWing = Path()
      ..moveTo(cx + s * 0.12, s * 0.3)
      ..cubicTo(
        cx + s * 0.65, s * 0.05,
        cx + s * 0.62, s * 0.55,
        cx + s * 0.12, s * 0.47,
      )
      ..close();
    canvas.drawPath(rightWing, wingFill);
    canvas.drawPath(rightWing, wingBorder);

    // ── Corps (oval vertical, dégradé vert) ───────────────────────────────────
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, s * 0.68),
      width: s * 0.46,
      height: s * 0.62,
    );
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.forestLeaf, AppColors.forestBg3],
      ).createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(s * 0.23)),
      bodyPaint,
    );

    // Reflet corps
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - s * 0.06, s * 0.52), width: s * 0.12, height: s * 0.18),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // ── Tête ──────────────────────────────────────────────────────────────────
    final headPaint = Paint()..color = AppColors.forestLeaf;
    canvas.drawCircle(Offset(cx, s * 0.24), s * 0.24, headPaint);

    // Reflet tête
    canvas.drawCircle(
      Offset(cx - s * 0.09, s * 0.17),
      s * 0.1,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    // ── Yeux ──────────────────────────────────────────────────────────────────
    const eyeWhite = Colors.white;
    const eyePupil = AppColors.forestInk;

    // Œil gauche
    canvas.drawCircle(
        Offset(cx - s * 0.1, s * 0.22), s * 0.075, Paint()..color = eyeWhite);
    canvas.drawCircle(
        Offset(cx - s * 0.088, s * 0.225), s * 0.042, Paint()..color = eyePupil);
    // Brillance
    canvas.drawCircle(
        Offset(cx - s * 0.1, s * 0.205), s * 0.02,
        Paint()..color = Colors.white.withValues(alpha: 0.8));

    // Œil droit
    canvas.drawCircle(
        Offset(cx + s * 0.1, s * 0.22), s * 0.075, Paint()..color = eyeWhite);
    canvas.drawCircle(
        Offset(cx + s * 0.088, s * 0.225), s * 0.042, Paint()..color = eyePupil);
    canvas.drawCircle(
        Offset(cx + s * 0.1, s * 0.205), s * 0.02,
        Paint()..color = Colors.white.withValues(alpha: 0.8));

    // ── Sourire ───────────────────────────────────────────────────────────────
    final smilePaint = Paint()
      ..color = AppColors.forestInk.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - s * 0.08, s * 0.3)
      ..quadraticBezierTo(cx, s * 0.37, cx + s * 0.08, s * 0.3);
    canvas.drawPath(smilePath, smilePaint);

    // ── Antennes ──────────────────────────────────────────────────────────────
    final antPaint = Paint()
      ..color = AppColors.forestBark
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Antenne gauche
    canvas.drawLine(
      Offset(cx - s * 0.12, s * 0.03),
      Offset(cx - s * 0.28, s * -0.1),
      antPaint,
    );
    canvas.drawCircle(
      Offset(cx - s * 0.28, s * -0.1),
      s * 0.045,
      Paint()..color = AppColors.forestBark,
    );

    // Antenne droite
    canvas.drawLine(
      Offset(cx + s * 0.12, s * 0.03),
      Offset(cx + s * 0.28, s * -0.1),
      antPaint,
    );
    canvas.drawCircle(
      Offset(cx + s * 0.28, s * -0.1),
      s * 0.045,
      Paint()..color = AppColors.forestBark,
    );
  }

  @override
  bool shouldRepaint(_FireflyPainter old) => old.size != size;
}
