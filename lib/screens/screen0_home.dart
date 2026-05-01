import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/story_library_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_background.dart';
import '../widgets/lulu_mascot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _savedCount = storyLibrary.count;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _savedCount = storyLibrary.count);
  }

  @override
  Widget build(BuildContext context) {
    final profile = userProfileService.currentProfile;

    return Scaffold(
      backgroundColor: AppColors.forestBg1,
      body: ForestBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // ── Top bar ─────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pill profil
                    GestureDetector(
                      onTap: () async {
                        await context.push('/profiles');
                        if (mounted) setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.forestBg2,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: AppColors.forestCream
                                  .withValues(alpha: 0.2),
                              width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(profile?.emoji ?? '🧒',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(profile?.name ?? 'Invité',
                                style: AppText.labelLarge),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more,
                                color: AppColors.forestCream
                                    .withValues(alpha: 0.5),
                                size: 16),
                          ],
                        ),
                      ),
                    ),
                    // Boutons droite
                    Row(
                      children: [
                        _TopBtn(
                          icon: Icons.settings_outlined,
                          onTap: () => context.push('/settings'),
                        ),
                        const SizedBox(width: 8),
                        _TopBtn(
                          icon: Icons.library_books_outlined,
                          onTap: _savedCount == 0
                              ? null
                              : () => context.push('/library'),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const Spacer(),

                // ── Illustration branche + lanterne ────────────────────────
                _BranchIllustration()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideY(begin: -0.1, delay: 100.ms),

                const SizedBox(height: 24),

                // ── Salutation ─────────────────────────────────────────────
                Text(
                  'Bonjour, ${profile?.name ?? 'toi'} !',
                  style: AppText.displayLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 6),
                Text(
                  '· tap pour écouter ·',
                  style: AppText.microLabel,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 350.ms),

                const Spacer(),

                // ── CTA Créer ──────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.push('/create'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.forestGold,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGold.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Créer une histoire',
                                  style: AppText.titleLarge.copyWith(
                                      color: AppColors.forestInk)),
                              Text('Une nouvelle aventure',
                                  style: AppText.bodySmall.copyWith(
                                      color: AppColors.forestInk
                                          .withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forestInk.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.chevron_right,
                              color: AppColors.forestInk, size: 20),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 450.ms, duration: 400.ms)
                    .fadeIn(delay: 450.ms),

                const SizedBox(height: 14),

                // ── CTA Écouter ────────────────────────────────────────────
                GestureDetector(
                  onTap: _savedCount == 0 ? null : () => context.push('/library'),
                  child: Opacity(
                    opacity: _savedCount == 0 ? 0.45 : 1.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.forestCream.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                            color: AppColors.forestCream.withValues(alpha: 0.25),
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('🎧', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Écouter une histoire',
                                    style: AppText.titleLarge),
                                Text(
                                  _savedCount == 0
                                      ? 'Aucune histoire sauvegardée'
                                      : '$_savedCount conte${_savedCount > 1 ? 's' : ''} prêt${_savedCount > 1 ? 's' : ''}',
                                  style: AppText.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppColors.forestCream
                                  .withValues(alpha: 0.4),
                              size: 20),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 550.ms, duration: 400.ms)
                    .fadeIn(delay: 550.ms),

                const SizedBox(height: 20),
                Text('Propulsé par Gemini AI',
                    style: AppText.bodySmall.copyWith(
                        color: AppColors.forestCream.withValues(alpha: 0.3)))
                    .animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Illustration branche ──────────────────────────────────────────────────────

class _BranchIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo de lumière sous la lanterne
          Positioned(
            top: 60,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.forestGold.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scaleXY(begin: 0.85, end: 1.15, duration: 2000.ms,
                 curve: Curves.easeInOut),
          ),
          // Branche
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(300, 70),
              painter: _BranchPainter(),
            ),
          ),
          // Fil + lanterne
          Positioned(
            top: 12,
            child: Column(
              children: [
                Container(
                  width: 1.5,
                  height: 36,
                  color: AppColors.forestBark.withValues(alpha: 0.7),
                ),
                _Lantern(),
              ],
            ),
          ),
          // Lulu mascotte (flottante à droite)
          Positioned(
            right: 30,
            top: 55,
            child: LuluMascot(size: 36)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -10, duration: 2200.ms,
                    curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

// ── Lanterne dessinée ─────────────────────────────────────────────────────────

class _Lantern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 92,
      child: CustomPaint(painter: _LanternPainter()),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .custom(
       duration: 1600.ms,
       curve: Curves.easeInOut,
       builder: (ctx, v, child) =>
           Opacity(opacity: 0.82 + v * 0.18, child: child),
     );
  }
}

class _LanternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const topY = 10.0;
    const botY = 72.0;
    const midY = (topY + botY) / 2; // 41
    const topHW = 14.0; // demi-largeur haut/bas
    const midHW = 24.0; // demi-largeur ventre (barrel)

    // ── Silhouette barrel ──────────────────────────────────────────
    final body = Path()
      ..moveTo(cx - topHW, topY)
      ..lineTo(cx + topHW, topY)
      ..cubicTo(cx + midHW, topY + (midY - topY) * 0.65,
          cx + midHW, botY - (botY - midY) * 0.65, cx + topHW, botY)
      ..lineTo(cx - topHW, botY)
      ..cubicTo(cx - midHW, botY - (botY - midY) * 0.65,
          cx - midHW, topY + (midY - topY) * 0.65, cx - topHW, topY)
      ..close();

    // ── 1. Remplissage : dégradé chaud gauche→centre→droite ────────
    canvas.save();
    canvas.clipPath(body);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.width, s.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF7A4F20),
            Color(0xFFE8B04A),
            Color(0xFFF7E07A),
            Color(0xFFE8B04A),
            Color(0xFF7A4F20),
          ],
          stops: [0.0, 0.22, 0.5, 0.78, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // Reflet interne (highlight en haut à gauche)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - 5, midY - 8), width: 18, height: 26),
      Paint()..color = Colors.white.withValues(alpha: 0.20),
    );

    // Nervures verticales (2 séparateurs = 3 panneaux)
    final rib = Paint()
      ..color = const Color(0xFF5A3A22).withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 8, 0), Offset(cx - 8, s.height), rib);
    canvas.drawLine(Offset(cx + 8, 0), Offset(cx + 8, s.height), rib);

    canvas.restore();

    // ── 2. Contour du corps ────────────────────────────────────────
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF4A2E10)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    // ── 3. Bandes métal haut & bas ─────────────────────────────────
    final band = Paint()
      ..color = const Color(0xFF4A2E10)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(cx - topHW + 1, topY), Offset(cx + topHW - 1, topY), band);
    canvas.drawLine(
        Offset(cx - topHW + 1, botY), Offset(cx + topHW - 1, botY), band);

    // ── 4. Crochet haut ────────────────────────────────────────────
    canvas.drawLine(
      Offset(cx, topY),
      Offset(cx, topY - 6),
      Paint()
        ..color = const Color(0xFF4A2E10)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // ── 5. Gland bas (tige + perle) ────────────────────────────────
    canvas.drawLine(
      Offset(cx, botY),
      Offset(cx, botY + 8),
      Paint()
        ..color = const Color(0xFF4A2E10)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx, botY + 11),
      3.5,
      Paint()..color = AppColors.forestGold,
    );
  }

  @override
  bool shouldRepaint(_LanternPainter o) => false;
}

// ── Branche ───────────────────────────────────────────────────────────────────

class _BranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barkPaint = Paint()
      ..color = AppColors.forestBark.withValues(alpha: 0.88)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Branche principale (plus épaisse)
    barkPaint.strokeWidth = 10;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.65)
        ..cubicTo(size.width * 0.25, size.height * 0.35,
            size.width * 0.5, size.height * 0.28,
            size.width, size.height * 0.48),
      barkPaint,
    );

    // Ramification secondaire (à gauche)
    barkPaint.strokeWidth = 5;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.18, size.height * 0.50)
        ..cubicTo(size.width * 0.10, size.height * 0.20,
            size.width * 0.06, size.height * 0.05,
            size.width * 0.10, 0),
      barkPaint,
    );

    // Feuilles (formes ovales pointues)
    final leafPaint = Paint()..style = PaintingStyle.fill;

    void drawLeaf(Offset pos, double size2, double angle, Color color) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      final leaf = Path()
        ..moveTo(0, -size2)
        ..cubicTo(size2 * 0.55, -size2 * 0.4, size2 * 0.55, size2 * 0.4, 0, size2)
        ..cubicTo(-size2 * 0.55, size2 * 0.4, -size2 * 0.55, -size2 * 0.4, 0, -size2)
        ..close();
      leafPaint.color = color;
      canvas.drawPath(leaf, leafPaint);
      canvas.restore();
    }

    final leafColor = AppColors.forestLeaf.withValues(alpha: 0.75);
    final leafDark  = AppColors.moss.withValues(alpha: 0.65);

    drawLeaf(Offset(size.width * 0.12, size.height * 0.12), 9,  0.4,  leafColor);
    drawLeaf(Offset(size.width * 0.08, size.height * 0.05), 7,  -0.5, leafDark);
    drawLeaf(Offset(size.width * 0.22, size.height * 0.22), 8,  1.1,  leafColor);
    drawLeaf(Offset(size.width * 0.42, size.height * 0.15), 10, 0.2,  leafColor);
    drawLeaf(Offset(size.width * 0.48, size.height * 0.08), 7,  -0.6, leafDark);
    drawLeaf(Offset(size.width * 0.68, size.height * 0.18), 9,  0.7,  leafColor);
    drawLeaf(Offset(size.width * 0.75, size.height * 0.10), 6,  -0.3, leafDark);
    drawLeaf(Offset(size.width * 0.88, size.height * 0.22), 8,  1.2,  leafColor);
  }

  @override
  bool shouldRepaint(_BranchPainter o) => false;
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _TopBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.forestBg2,
            border: Border.all(
                color: AppColors.forestCream.withValues(alpha: 0.2),
                width: 1.5),
          ),
          child: Icon(icon, color: AppColors.forestCream, size: 18),
        ),
      ),
    );
  }
}
