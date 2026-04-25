import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/choice_card.dart';
import '../widgets/wizard_scaffold.dart';

class CharacterScreen extends StatefulWidget {
  final StoryConfig config;
  const CharacterScreen({super.key, required this.config});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  CharacterType? _selected;

  static const _bgColors = [
    AppColors.rose,
    AppColors.accentSoft,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.characterType;
  }

  @override
  Widget build(BuildContext context) {
    // Emoji du profil actif pour l'option "Moi-même"
    final profileEmoji =
        userProfileService.currentProfile?.emoji ?? '🧒';

    return WizardScaffold(
      step: 2,
      pastilleColor: AppColors.rose,
      pastilleIcon: Icons.person_outline,
      title: 'Qui est le héros ?',
      subtitle: 'Choisis le personnage principal de l\'histoire',
      voiceInstruction:
          'Qui est le héros de ton histoire ? Toi-même, ou un autre personnage ?',
      canContinue: _selected != null,
      onContinue: () {
        widget.config.characterType = _selected;
        if (_selected == CharacterType.hero) {
          context.push('/hero-name', extra: widget.config);
        } else {
          context.push('/theme', extra: widget.config);
        }
      },
      content: Row(
        children: List.generate(CharacterType.values.length, (i) {
          final type = CharacterType.values[i];
          // Remplace l'emoji générique par l'avatar du profil pour "Moi-même"
          final emoji =
              type == CharacterType.myself ? profileEmoji : type.emoji;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 8,
                right: i == CharacterType.values.length - 1 ? 0 : 8,
              ),
              child: AspectRatio(
                aspectRatio: 0.85,
                child: ChoiceCard(
                  emoji: emoji,
                  label: type.label,
                  isSelected: _selected == type,
                  bgColor: _bgColors[i % _bgColors.length],
                  emojiSize: 68,
                  onTap: () => setState(() => _selected = type),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
