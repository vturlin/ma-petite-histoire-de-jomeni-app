import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/story_library_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_background.dart';

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
                      onTap: () => context.push('/profiles'),
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
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Branche
          CustomPaint(
            size: const Size(280, 60),
            painter: _BranchPainter(),
          ),
          // Lanterne suspendue
          Positioned(
            top: 20,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.forestBark.withValues(alpha: 0.8),
                ),
                _Lantern(),
              ],
            ),
          ),
          // Luciole qui peeks
          Positioned(
            right: 60,
            top: 10,
            child: Text('🪲', style: const TextStyle(fontSize: 20))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -8, duration: 1500.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class _Lantern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.forestGold,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGold.withValues(alpha: 0.7),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.local_fire_department,
            color: AppColors.forestInk, size: 20),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .custom(
       duration: 1400.ms,
       builder: (ctx, v, child) => Opacity(opacity: 0.8 + v * 0.2, child: child),
     );
  }
}

class _BranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestBark.withValues(alpha: 0.85)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(size.width * 0.2, size.height * 0.4,
          size.width * 0.5, size.height * 0.3,
          size.width, size.height * 0.5);
    canvas.drawPath(path, paint);

    // Petites feuilles
    final leafPaint = Paint()
      ..color = AppColors.forestLeaf.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    for (final pos in [0.2, 0.5, 0.75]) {
      canvas.drawCircle(
        Offset(size.width * pos, size.height * 0.2),
        6,
        leafPaint,
      );
    }
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
