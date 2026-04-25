import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';

class ProfileSheet extends StatefulWidget {
  final UserProfile? existingProfile;
  final void Function(UserProfile) onSaved;
  final VoidCallback? onDeleted;

  const ProfileSheet({
    super.key,
    this.existingProfile,
    required this.onSaved,
    this.onDeleted,
  });

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final TextEditingController _controller;
  late String _selectedEmoji;
  late int _selectedColor;
  ProfileAge? _selectedAge;

  bool get _isEdit => widget.existingProfile != null;

  static const List<Color> _colors = [
    Color(0xFF6C3CE1), Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFFFFD93D), Color(0xFF95E1D3), Color(0xFFF38181),
    Color(0xFF3D5A80), Color(0xFFE8A87C),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _controller = TextEditingController(text: p?.name ?? '');
    _selectedEmoji = p?.emoji ?? UserProfile.availableEmojis.first;
    _selectedColor = p?.colorIndex ?? 0;
    _selectedAge = p?.age;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmController = TextEditingController();
    const phrase = 'je veux supprimer';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: Row(
            children: [
              Text(widget.existingProfile!.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Supprimer ${widget.existingProfile!.name} ?',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cette action est irréversible. Toutes les histoires de ce profil seront supprimées.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Text(
                'Tape  "$phrase"  pour confirmer :',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: phrase,
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                confirmController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: confirmController.text.trim().toLowerCase() == phrase
                  ? () async {
                      confirmController.dispose();
                      Navigator.pop(ctx);
                      final nav = Navigator.of(context);
                      final onDeleted = widget.onDeleted;
                      await userProfileService
                          .delete(widget.existingProfile!.id);
                      nav.pop();
                      onDeleted?.call();
                    }
                  : null,
              child: const Text('Supprimer définitivement',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEdit ? 'Modifier le profil' : 'Nouveau profil',
              style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _colors[_selectedColor].withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _colors[_selectedColor], width: 2),
              ),
              child: Center(
                child: Text(_selectedEmoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: !_isEdit,
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
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Âge de l'enfant (optionnel)",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProfileAge.values.map((age) {
                final selected = _selectedAge == age;
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedAge = selected ? null : age,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? _colors[_selectedColor].withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _colors[_selectedColor] : Colors.white12,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(age.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          age.label,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white60,
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () async {
                        if (_isEdit) {
                          final updated = UserProfile(
                            id: widget.existingProfile!.id,
                            name: _controller.text.trim(),
                            emoji: _selectedEmoji,
                            colorIndex: _selectedColor,
                            createdAt: widget.existingProfile!.createdAt,
                            age: _selectedAge,
                          );
                          await userProfileService.update(updated);
                          if (context.mounted) {
                            Navigator.pop(context);
                            widget.onSaved(updated);
                          }
                        } else {
                          final profile = await userProfileService.create(
                            name: _controller.text.trim(),
                            emoji: _selectedEmoji,
                            colorIndex: _selectedColor,
                            age: _selectedAge,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            widget.onSaved(profile);
                          }
                        }
                      },
                child: Text(_isEdit ? 'Enregistrer' : 'Créer le profil'),
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _confirmDelete(),
                child: const Text(
                  'Supprimer ce profil',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
