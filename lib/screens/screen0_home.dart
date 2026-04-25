import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/story_library_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/profile_button.dart';

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
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          // Blobs décoratifs
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent1.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            bottom: -80, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sky.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Contenu
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s16),
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ProfileButton(),
                      _RoundIconBtn(
                        icon: Icons.library_books_outlined,
                        onTap: _savedCount == 0
                            ? null
                            : () => context.push('/library'),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const Spacer(),
                  // Avatar
                  Center(
                    child: Container(
                      width: AppSize.avatarLg + 44,
                      height: AppSize.avatarLg + 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accentSoft, AppColors.accent1],
                        ),
                        boxShadow: AppShadows.cta,
                      ),
                      child: Center(
                        child: Text(
                          profile?.emoji ?? '📖',
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        delay: 100.ms,
                      ),
                  const SizedBox(height: AppSpacing.s24),
                  // Salutation
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Bonjour, ${profile?.name ?? 'toi'} !',
                          style: AppText.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Que veux-tu faire aujourd\'hui ?',
                          style: AppText.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const Spacer(),
                  // Card "Créer une histoire"
                  _HomeCard(
                    bgColor: AppColors.accent1,
                    iconBg: AppColors.accentSoft,
                    icon: Icons.auto_fix_high,
                    title: 'Créer une histoire',
                    subtitle: 'Une nouvelle aventure',
                    onTap: () => context.push('/create'),
                  ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 400.ms)
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: AppSpacing.s16),
                  // Card "Écouter une histoire"
                  _HomeCard(
                    bgColor: Colors.white,
                    iconBg: AppColors.sky,
                    icon: Icons.headphones,
                    title: 'Écouter une histoire',
                    subtitle: _savedCount == 0
                        ? 'Aucune histoire sauvegardée'
                        : '$_savedCount histoire${_savedCount > 1 ? 's' : ''} sauvegardée${_savedCount > 1 ? 's' : ''}',
                    onTap: _savedCount == 0 ? null : () => context.push('/library'),
                    bordered: true,
                  ).animate().slideY(begin: 0.3, delay: 500.ms, duration: 400.ms)
                      .fadeIn(delay: 500.ms),
                  const SizedBox(height: AppSpacing.s32),
                  // Footer
                  Center(
                    child: Text(
                      'Propulsé par Gemini AI',
                      style: AppText.bodySmall
                          .copyWith(color: AppColors.inkMute),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card d'action ─────────────────────────────────────────────────────────────

class _HomeCard extends StatelessWidget {
  final Color bgColor;
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool bordered;

  const _HomeCard({
    required this.bgColor,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.all(AppRadius.xl),
            border: bordered
                ? Border.all(color: AppColors.line, width: 2)
                : null,
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.all(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.accent2, size: 28),
              ),
              const SizedBox(width: AppSpacing.s16),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: AppText.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.bodyMedium),
                  ],
                ),
              ),
              // Chevron
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right,
                    color: AppColors.inkSoft, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouton icône rond ─────────────────────────────────────────────────────────

class _RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: Container(
          width: AppSize.iconBtnTopbar,
          height: AppSize.iconBtnTopbar,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line, width: 1.5),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, color: AppColors.ink, size: 20),
        ),
      ),
    );
  }
}
