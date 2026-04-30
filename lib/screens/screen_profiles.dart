import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/api_key_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_background.dart';
import '../widgets/profile_sheet.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<UserProfile> _profiles = [];

  static const List<Color> _orbColors = [
    AppColors.rose,
    AppColors.mint,
    AppColors.sky,
    AppColors.lilac,
    AppColors.butter,
    AppColors.moss,
    AppColors.coral,
    AppColors.peach,
  ];

  @override
  void initState() {
    super.initState();
    _load();
    if (!apiKeyService.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectApiKey());
    }
  }

  void _load() => setState(() => _profiles = userProfileService.getAll());

  void _selectProfile(UserProfile profile) {
    userProfileService.currentProfile = profile;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestBg1,
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s40),
              Text(
                'Qui écoute aujourd\'hui ?',
                style: AppText.displayLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '· choisis ton personnage ·',
                style: AppText.microLabel,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.s32),
              Expanded(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.s16,
                      mainAxisSpacing: AppSpacing.s16,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _profiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _profiles.length) {
                        return _AddProfileCard(onTap: _showCreateSheet)
                            .animate()
                            .scale(
                              delay: Duration(milliseconds: index * 80),
                              duration: 300.ms,
                              curve: Curves.elasticOut,
                            );
                      }
                      final profile = _profiles[index];
                      return _ProfileCard(
                        profile: profile,
                        color: _orbColors[
                            profile.colorIndex % _orbColors.length],
                        onTap: () => _selectProfile(profile),
                        onLongPress: () => _showProfileOptions(profile),
                      ).animate().scale(
                            delay: Duration(milliseconds: index * 80),
                            duration: 300.ms,
                            curve: Curves.elasticOut,
                          );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s16,
                    AppSpacing.s20,
                    AppSpacing.s24),
                child: Text(
                  '· appuie longtemps pour modifier ·',
                  style: AppText.microLabel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectApiKey() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forestBg2,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        title: Text('🔑 Clé API à utiliser', style: AppText.titleLarge),
        content: Text(
          'Choisis la clé Gemini pour cette session.',
          style: AppText.bodyMedium,
        ),
        actions: [
          _ApiKeyOption(
            label: '🧪 Gemini API Key',
            description: '…77kQ',
            color: AppColors.forestGold,
            onTap: () {
              apiKeyService.selectProduction();
              Navigator.pop(context);
            },
          ),
          _ApiKeyOption(
            label: '🧪 Jomeni app test',
            description: '…8OD4',
            color: AppColors.sky,
            onTap: () {
              apiKeyService.selectTest();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showProfileOptions(UserProfile profile) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forestBg2,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        title: Row(
          children: [
            Text(profile.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.s8),
            Text(profile.name, style: AppText.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.forestGold),
              title: Text('Modifier', style: AppText.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showEditSheet(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.forestBerry),
              title: Text('Supprimer',
                  style: AppText.bodyLarge
                      .copyWith(color: AppColors.forestBerry)),
              onTap: () {
                Navigator.pop(context);
                _deleteProfile(profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProfile(UserProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forestBg2,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        title: Text('Supprimer ${profile.name} ?', style: AppText.titleLarge),
        content: Text(
          'Toutes les histoires de ce profil seront supprimées.',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style:
                    AppText.labelLarge.copyWith(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer',
                style: AppText.labelLarge
                    .copyWith(color: AppColors.forestBerry)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await userProfileService.delete(profile.id);
      _load();
    }
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(
        onSaved: (profile) {
          _load();
          _selectProfile(profile);
        },
      ),
    );
  }

  void _showEditSheet(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(
        existingProfile: profile,
        onSaved: (_) => _load(),
        onDeleted: _load,
      ),
    );
  }
}

// ── Card profil ───────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileCard({
    required this.profile,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 1.2,
            colors: [
              Color.lerp(color, Colors.white, 0.2)!.withValues(alpha: 0.35),
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(profile.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: AppSpacing.s8),
            Text(
              profile.name,
              style: AppText.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (profile.age != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  borderRadius: AppRadius.all(AppRadius.pill),
                  border:
                      Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  '${profile.age!.emoji} ${profile.age!.label}',
                  style: AppText.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Card "Ajouter" ────────────────────────────────────────────────────────────

class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: AppColors.forestBg2,
          border: Border.all(
            color: AppColors.forestGold.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.forestGold.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.forestGold.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child:
                  const Icon(Icons.add, color: AppColors.forestGold, size: 28),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text('Nouveau profil', style: AppText.titleMedium),
          ],
        ),
      ),
    );
  }
}

// ── Option clé API ────────────────────────────────────────────────────────────

class _ApiKeyOption extends StatelessWidget {
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ApiKeyOption({
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4, vertical: AppSpacing.s4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.all(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.labelLarge),
              const SizedBox(height: 2),
              Text(description, style: AppText.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
