import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.all(AppRadius.xl)),
          title: Row(
            children: [
              Text(widget.existingProfile!.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'Supprimer ${widget.existingProfile!.name} ?',
                  style: AppText.titleLarge,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette action est irréversible. Toutes les histoires seront supprimées.',
                style: AppText.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text('Tape "$phrase" pour confirmer :',
                  style: AppText.bodySmall),
              const SizedBox(height: AppSpacing.s8),
              TextField(
                controller: confirmController,
                autofocus: true,
                style: AppText.bodyLarge,
                decoration: InputDecoration(hintText: phrase),
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
              child: Text('Annuler',
                  style: AppText.labelLarge
                      .copyWith(color: AppColors.inkSoft)),
            ),
            TextButton(
              onPressed:
                  confirmController.text.trim().toLowerCase() == phrase
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
              child: Text('Supprimer définitivement',
                  style: AppText.labelLarge
                      .copyWith(color: const Color(0xFFB3261E))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _colors[_selectedColor % _colors.length];
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
        top: AppSpacing.s24,
        left: AppSpacing.s24,
        right: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.all(AppRadius.xxl),
        boxShadow: AppShadows.soft,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: AppRadius.all(AppRadius.pill),
              ),
            ),
            // Titre
            Text(
              _isEdit ? 'Modifier le profil' : 'Nouveau profil',
              style: AppText.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s20),
            // Aperçu avatar
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: AppRadius.all(AppRadius.lg),
                boxShadow: AppShadows.soft,
              ),
              child: Center(
                child: Text(_selectedEmoji,
                    style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Nom
            TextField(
              controller: _controller,
              autofocus: !_isEdit,
              style: AppText.titleMedium,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Prénom'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Emoji
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Avatar', style: AppText.bodySmall),
            ),
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: UserProfile.availableEmojis.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor
                          : AppColors.paper2,
                      borderRadius: AppRadius.all(AppRadius.sm),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent2
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(e,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Couleur
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Couleur', style: AppText.bodySmall),
            ),
            const SizedBox(height: AppSpacing.s8),
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
                        borderRadius: AppRadius.all(AppRadius.xs),
                        border: selected
                            ? Border.all(
                                color: AppColors.ink, width: 2.5)
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.s20),
            // Âge
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Âge de l'enfant (optionnel)",
                  style: AppText.bodySmall),
            ),
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: ProfileAge.values.map((age) {
                final selected = _selectedAge == age;
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedAge = selected ? null : age,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentSoft
                          : AppColors.paper2,
                      borderRadius: AppRadius.all(AppRadius.sm),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent2
                            : AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(age.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: AppSpacing.s4),
                        Text(age.label,
                            style: AppText.labelLarge.copyWith(
                              color: selected
                                  ? AppColors.accentInk
                                  : AppColors.ink,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.s24),
            // Bouton principal
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: _controller.text.trim().isNotEmpty
                    ? BoxDecoration(
                        borderRadius: AppRadius.all(AppRadius.xl),
                        boxShadow: AppShadows.cta,
                      )
                    : null,
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
            ),
            if (_isEdit) ...[
              const SizedBox(height: AppSpacing.s8),
              TextButton(
                onPressed: _confirmDelete,
                child: Text(
                  'Supprimer ce profil',
                  style: AppText.bodySmall
                      .copyWith(color: const Color(0xFFB3261E)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
