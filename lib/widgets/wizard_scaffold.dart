import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/voice_guide_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'star_background.dart';

class WizardScaffold extends StatefulWidget {
  final int step;
  final int totalSteps;
  final Color pastilleColor;
  final IconData pastilleIcon;
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool canContinue;

  /// Texte lu automatiquement à l'ouverture de l'écran.
  /// Si null, aucune lecture automatique.
  final String? voiceInstruction;

  const WizardScaffold({
    super.key,
    required this.step,
    this.totalSteps = 6,
    required this.pastilleColor,
    required this.pastilleIcon,
    required this.title,
    required this.subtitle,
    required this.content,
    this.onBack,
    this.onContinue,
    this.continueLabel = 'Continuer',
    this.canContinue = true,
    this.voiceInstruction,
  });

  @override
  State<WizardScaffold> createState() => _WizardScaffoldState();
}

class _WizardScaffoldState extends State<WizardScaffold> {
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    if (widget.voiceInstruction != null) {
      // Courte pause pour laisser la page s'afficher avant de parler
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: StarBackground(child: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, 0),
              child: Row(
                children: [
                  _RoundBtn(
                    icon: Icons.arrow_back,
                    onTap: widget.onBack ?? () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Étape ${widget.step} / ${widget.totalSteps}',
                      textAlign: TextAlign.center,
                      style: AppText.titleMedium
                          .copyWith(color: AppColors.inkSoft),
                    ),
                  ),
                  _RoundBtn(
                    icon: Icons.close,
                    onTap: () {
                      voiceGuide.stop();
                      context.go('/');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            // ── Progress bar ───────────────────────────────────────────────
            Padding(
              padding: AppSpacing.screenH,
              child: ClipRRect(
                borderRadius: AppRadius.all(8),
                child: LinearProgressIndicator(
                  value: widget.step / widget.totalSteps,
                  minHeight: 6,
                  backgroundColor: AppColors.paper2,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.accent2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            // ── Step heading ───────────────────────────────────────────────
            Padding(
              padding: AppSpacing.screenH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: widget.pastilleColor,
                          borderRadius: AppRadius.all(AppRadius.md),
                        ),
                        child: Icon(widget.pastilleIcon,
                            color: AppColors.ink, size: 24),
                      ),
                      if (widget.voiceInstruction != null) ...[
                        const SizedBox(width: AppSpacing.s12),
                        _SpeakButton(
                          isSpeaking: _isSpeaking,
                          onTap: _isSpeaking ? null : _replay,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(widget.title, style: AppText.headlineMedium),
                  const SizedBox(height: AppSpacing.s4),
                  Text(widget.subtitle, style: AppText.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            // ── Contenu scrollable ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s8),
                child: widget.content,
              ),
            ),
            // ── Footer ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s20,
                  AppSpacing.s12, AppSpacing.s20, AppSpacing.s24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack ?? () => context.pop(),
                      child: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: widget.canContinue
                          ? BoxDecoration(
                              borderRadius: AppRadius.all(AppRadius.xl),
                              boxShadow: AppShadows.cta,
                            )
                          : null,
                      child: ElevatedButton(
                        onPressed:
                            widget.canContinue ? widget.onContinue : null,
                        child: Text(widget.continueLabel),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

// ── Bouton réécouter ──────────────────────────────────────────────────────────

class _SpeakButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback? onTap;

  const _SpeakButton({required this.isSpeaking, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSpeaking ? AppColors.accentSoft : Colors.white,
          border: Border.all(
            color: isSpeaking ? AppColors.accent2 : AppColors.line,
            width: 2,
          ),
          boxShadow: isSpeaking ? AppShadows.cta : AppShadows.soft,
        ),
        child: Icon(
          isSpeaking ? Icons.volume_up : Icons.play_arrow_rounded,
          size: 28,
          color: isSpeaking ? AppColors.accent2 : AppColors.inkSoft,
        ),
      ),
    );
  }
}

// ── Bouton rond top bar ───────────────────────────────────────────────────────

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.iconBtnTopbar,
        height: AppSize.iconBtnTopbar,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, color: AppColors.ink, size: 18),
      ),
    );
  }
}
