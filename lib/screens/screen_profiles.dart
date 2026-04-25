import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/api_key_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_sheet.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<UserProfile> _profiles = [];

  static const List<Color> _cardColors = [
    Color(0xFF6C3CE1),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFD93D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFF3D5A80),
    Color(0xFFE8A87C),
  ];

  @override
  void initState() {
    super.initState();
    _load();
    if (!apiKeyService.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectApiKey());
    }
  }

  Future<void> _selectApiKey() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('🔑 Clé API à utiliser',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          'Choisis la clé Gemini pour cette session.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          _ApiKeyOption(
            label: '🧪 Gemini API Key',
            description: '…77kQ',
            color: AppTheme.primary,
            onTap: () {
              apiKeyService.selectProduction();
              Navigator.pop(context);
            },
          ),
          _ApiKeyOption(
            label: '🧪 Jomeni app test',
            description: '…8OD4',
            color: AppTheme.secondary,
            onTap: () {
              apiKeyService.selectTest();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _load() => setState(() => _profiles = userProfileService.getAll());

  void _selectProfile(UserProfile profile) {
    userProfileService.currentProfile = profile;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surface, AppTheme.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Qui écoute ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              const Text(
                'Sélectionne ton personnage',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _profiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _profiles.length) {
                        return _AddProfileCard(onTap: () => _showCreateSheet());
                      }
                      return _ProfileCard(
                        profile: _profiles[index],
                        color: _cardColors[_profiles[index].colorIndex % _cardColors.length],
                        onTap: () => _selectProfile(_profiles[index]),
                        onLongPress: () => _showProfileOptions(_profiles[index]),
                      ).animate().scale(
                        delay: Duration(milliseconds: index * 80),
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appuie longtemps pour modifier ou supprimer',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProfileOptions(UserProfile profile) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Row(
          children: [
            Text(profile.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(profile.name,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: const Text('Modifier',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditSheet(profile);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Supprimer',
                  style: TextStyle(color: Colors.redAccent)),
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
        backgroundColor: AppTheme.cardBg,
        title: Text('Supprimer ${profile.name} ?',
            style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Toutes les histoires de ce profil seront supprimées.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Annuler', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
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

// ─── Carte profil ─────────────────────────────────────────────────────────────

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
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(profile.emoji,
                        style: const TextStyle(fontSize: 44)),
                  ),
                  if (profile.age != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          profile.age!.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Carte "Ajouter" ──────────────────────────────────────────────────────────

class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white54, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajouter',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton de sélection de clé API ──────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
