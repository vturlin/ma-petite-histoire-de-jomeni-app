import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/voice_guide_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'forest_background.dart';
import 'forest_progress.dart';
import 'lulu_mascot.dart';

/// Wrapper commun pour tous les écrans du wizard "Forêt enchantée".
class ForestStepFrame extends StatefulWidget {
  final int step;
  final int totalSteps;
  final String microLabel;
  final String? voiceInstruction;
  final Widget content;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool canContinue;

  const ForestStepFrame({
    super.key,
    required this.step,
    this.totalSteps = 6,
    required this.microLabel,
    this.voiceInstruction,
    required this.content,
    this.onBack,
    this.onContinue,
    this.continueLabel = '→',
    this.canContinue = true,
  });

  @override
  State<ForestStepFrame> createState() => _ForestStepFrameState();
}

class _ForestStepFrameState extends State<ForestStepFrame> {
  bool _isSpeaking = false;

  // ── Constantes layout ────────────────────────────────────────────────────────
  static const double _luluSize = 56;
  static const double _luluBoxH = _luluSize * 1.6; // 89.6
  static const double _luluHalf = _luluBoxH / 2;   // 44.8
  static const double _playBtnR = 36.0;             // rayon gros bouton play (72px)
  static const double _contBtnR = 38.0;             // rayon bouton suite (76px)
  static const double _footPadB = 24.0;

  // Header : padding-top(12) + row(~52px title+progress) + SizedBox(8)
  //          + reserved(luluBoxH+16) + playBtnR = ≈ 214
  static const double _playBtnCenterY = 214.0;

  @override
  void initState() {
    super.initState();
    if (widget.voiceInstruction != null) {
      Future.delayed(const Duration(milliseconds: 600), _autoSpeak);
    }
  }

  @override
  void dispose() {
    voiceGuide.stop();
    super.dispose();
  }

  Future<void> _autoSpeak() async {
    if (!mounted || widget.voiceInstruction == null) return;
    setState(() => _isSpeaking = true);
    await voiceGuide.speak(widget.voiceInstruction!);
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _replay() async {
    if (widget.voiceInstruction == null) return;
    setState(() => _isSpeaking = true);
    await voiceGuide.speak(widget.voiceInstruction!);
    if (mounted) setState(() => _isSpeaking = false);
  }

  /// Position de Lulu selon l'état canContinue.
  Alignment _luluAlignment(double safeW, double safeH) {
    final hw = safeW / 2;
    final hh = safeH / 2;
    double lx, ly;

    if (!widget.canContinue) {
      // À droite du gros bouton play, remontée pour aligner visuellement
      lx = hw + _playBtnR + 10 + _luluHalf;
      ly = _playBtnCenterY - 50;
    } else {
      // Près du bouton continuer — décalée à droite et plus basse
      lx = safeW - _luluHalf + 32;                          // dépasse le bord droit
      ly = safeH - _footPadB - _contBtnR * 2 + 28 - _luluHalf; // plus basse, frôle le bouton
    }

    return Alignment(
      (lx - hw) / hw,
      (ly - hh) / hh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestBg1,
      body: ForestBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safeW = constraints.maxWidth;
              final safeH = constraints.maxHeight;
              final alignment = _luluAlignment(safeW, safeH);

              return Stack(
                children: [
                  // ── Colonne principale ────────────────────────────────────────
                  Column(
                    children: [
                      // ── Header : titre centré + progression ─────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bouton retour
                            _CircleBtn(
                              icon: Icons.arrow_back,
                              onTap: widget.onBack ?? () => context.pop(),
                            ),
                            // Titre + progression centrés
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.microLabel,
                                    style: AppText.headlineMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  ForestProgress(
                                    currentStep: widget.step,
                                    totalSteps: widget.totalSteps,
                                  ),
                                ],
                              ),
                            ),
                            // Bouton fermer
                            _CircleBtn(
                              icon: Icons.close,
                              onTap: () {
                                voiceGuide.stop();
                                context.go('/');
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Espace réservé pour Lulu flottante
                      const SizedBox(height: _luluBoxH + 16),

                      // ── Gros bouton lecture (rejouer instruction) ───────────
                      GestureDetector(
                        onTap: _isSpeaking ? null : _replay,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSpeaking
                                ? AppColors.forestGoldLight
                                : AppColors.forestGold,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forestGold
                                    .withValues(alpha: 0.6),
                                blurRadius: _isSpeaking ? 24 : 12,
                                spreadRadius: _isSpeaking ? 4 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSpeaking
                                ? Icons.volume_up
                                : Icons.play_arrow_rounded,
                            color: AppColors.forestInk,
                            size: 36,
                          ),
                        ),
                      )
                          .animate(
                              onPlay: _isSpeaking
                                  ? (c) => c.repeat(reverse: true)
                                  : null)
                          .scaleXY(
                              begin: 1.0,
                              end: _isSpeaking ? 1.05 : 1.0,
                              duration: 800.ms,
                              curve: Curves.easeInOut),

                      const SizedBox(height: 12),

                      // ── Contenu scrollable ──────────────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s20),
                          child: widget.content,
                        ),
                      ),

                      // ── Footer ───────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleBtn(
                              icon: Icons.arrow_back,
                              onTap: widget.onBack ?? () => context.pop(),
                              size: 54,
                            ),
                            // Bouton continuer — grandit à l'activation
                            GestureDetector(
                              onTap: widget.canContinue
                                  ? widget.onContinue
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.elasticOut,
                                width: widget.canContinue ? 76 : 56,
                                height: widget.canContinue ? 76 : 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.canContinue
                                      ? AppColors.forestGold
                                      : AppColors.forestGold
                                          .withValues(alpha: 0.28),
                                  boxShadow: widget.canContinue
                                      ? [
                                          BoxShadow(
                                            color: AppColors.forestGold
                                                .withValues(alpha: 0.75),
                                            blurRadius: 28,
                                            spreadRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: widget.canContinue
                                      ? AppColors.forestInk
                                      : AppColors.forestInk
                                          .withValues(alpha: 0.35),
                                  size: widget.canContinue ? 34 : 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Lulu flottante ────────────────────────────────────────────
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.elasticOut,
                    alignment: alignment,
                    child: LuluMascot(size: _luluSize)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Bouton circulaire ─────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleBtn({required this.icon, required this.onTap, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.forestBg2,
          border: Border.all(
              color: AppColors.forestCream.withValues(alpha: 0.2),
              width: 1.5),
        ),
        child: Icon(icon, color: AppColors.forestCream, size: size * 0.45),
      ),
    );
  }
}
