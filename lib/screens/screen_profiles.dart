import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<UserProfile> _profiles = [];

  // Couleurs des cartes de profil
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
              // Grille de profils
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
                    itemCount: _profiles.length + 1, // +1 pour le bouton "+"
                    itemBuilder: (context, index) {
                      if (index == _profiles.length) {
                        return _AddProfileCard(onTap: () => _showCreateDialog());
                      }
                      return _ProfileCard(
                        profile: _profiles[index],
                        color: _cardColors[_profiles[index].colorIndex % _cardColors.length],
                        onTap: () => _selectProfile(_profiles[index]),
                        onDelete: () => _deleteProfile(_profiles[index]),
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
                'Appuie longtemps pour supprimer un profil',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
            child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await userProfileService.delete(profile.id);
      _load();
    }
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateProfileSheet(
        onCreated: (profile) {
          _load();
          _selectProfile(profile);
        },
      ),
    );
  }
}

// ─── Carte profil ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProfileCard({
    required this.profile,
    required this.color,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              ),
              child: Center(
                child: Text(profile.emoji, style: const TextStyle(fontSize: 44)),
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

// ─── Feuille de création de profil ────────────────────────────────────────────

class _CreateProfileSheet extends StatefulWidget {
  final void Function(UserProfile) onCreated;

  const _CreateProfileSheet({required this.onCreated});

  @override
  State<_CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends State<_CreateProfileSheet> {
  final _controller = TextEditingController();
  String _selectedEmoji = UserProfile.availableEmojis.first;
  int _selectedColor = 0;

  static const List<Color> _colors = [
    Color(0xFF6C3CE1), Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFFFFD93D), Color(0xFF95E1D3), Color(0xFFF38181),
    Color(0xFF3D5A80), Color(0xFFE8A87C),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24, left: 24, right: 24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Aperçu
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _colors[_selectedColor].withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _colors[_selectedColor], width: 2),
            ),
            child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 20),
          // Nom
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Prénom',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          // Choix emoji
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Avatar', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: UserProfile.availableEmojis.map((e) {
              final selected = e == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? _colors[_selectedColor].withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? _colors[_selectedColor] : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Choix couleur
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Couleur', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_colors.length, (i) {
              final selected = i == _selectedColor;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedColor = i),
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _colors[i],
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Bouton créer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () async {
                      final profile = await userProfileService.create(
                        name: _controller.text.trim(),
                        emoji: _selectedEmoji,
                        colorIndex: _selectedColor,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        widget.onCreated(profile);
                      }
                    },
              child: const Text('Créer le profil'),
            ),
          ),
        ],
      ),
    );
  }
}
