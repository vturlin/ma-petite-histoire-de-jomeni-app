import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/api_key_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/profile_sheet.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<UserProfile> _profiles = [];

  // Couleurs catégorielles du design system
  static const List<Color> _cardColors = [
    AppColors.rose,
    AppColors.accentSoft,
    AppColors.butter,
    AppColors.sky,
    AppColors.lilac,
    AppColors.mint,
    AppColors.moss,
    AppColors.accent1,
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
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s40),
            // Titre
            Text(
              'Qui écoute aujourd\'hui ?',
              style: AppText.headlineLarge,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Sélectionne ton personnage',
              style: AppText.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.s32),
            // Grille
            Expanded(
              child: Padding(
                padding: AppSpacing.screenH,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.s16,
                    mainAxisSpacing: AppSpacing.s16,
                    childAspectRatio: 0.9,
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
                      color: _cardColors[profile.colorIndex % _cardColors.length],
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
                  AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s24),
              child: Text(
                'Appuie longtemps pour modifier ou supprimer',
                style: AppText.bodySmall.copyWith(color: AppColors.inkMute),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── API key dialog ──────────────────────────────────────────────────────────

  Future<void> _selectApiKey() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        title: Text('🔑 Clé API à utiliser', style: AppText.titleLarge),
        content: Text(
          'Choisis la clé Gemini pour cette session.',
          style: AppText.bodyMedium,
        ),
        actions: [
          _ApiKeyOption(
            label: '🧪 Gemini API Key',
            description: '…77kQ',
            color: AppColors.accent2,
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

  // ── Actions profil ──────────────────────────────────────────────────────────

  Future<void> _showProfileOptions(UserProfile profile) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
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
              leading: const Icon(Icons.edit_outlined, color: AppColors.inkSoft),
              title: Text('Modifier', style: AppText.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showEditSheet(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Color(0xFFB3261E)),
              title: Text('Supprimer',
                  style: AppText.bodyLarge.copyWith(
                      color: const Color(0xFFB3261E))),
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
        backgroundColor: Colors.white,
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
                style: AppText.labelLarge.copyWith(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer',
                style: AppText.labelLarge
                    .copyWith(color: const Color(0xFFB3261E))),
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
          color: color,
          borderRadius: AppRadius.all(AppRadius.lg),
          boxShadow: AppShadows.soft,
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
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: AppRadius.all(AppRadius.xs),
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
          color: Colors.white,
          borderRadius: AppRadius.all(AppRadius.lg),
          border: Border.all(color: AppColors.line2, width: 2),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadius.all(AppRadius.md),
              ),
              child: const Icon(Icons.add, color: AppColors.accent2, size: 28),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text('Ajouter', style: AppText.titleMedium),
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
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.labelLarge.copyWith(color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(description, style: AppText.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
