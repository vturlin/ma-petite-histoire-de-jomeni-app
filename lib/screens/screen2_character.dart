import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/forest_orb.dart';
import '../widgets/forest_step_frame.dart';

class CharacterScreen extends StatefulWidget {
  final StoryConfig config;
  const CharacterScreen({super.key, required this.config});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  CharacterType? _selected;

  static const _orbColors = [AppColors.rose, AppColors.mint];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.characterType;
  }

  @override
  Widget build(BuildContext context) {
    final profileEmoji =
        userProfileService.currentProfile?.emoji ?? '🧒';

    return ForestStepFrame(
      step: 2,
      microLabel: 'qui est le héros ?',
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
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(CharacterType.values.length, (i) {
            final type = CharacterType.values[i];
            final emoji =
                type == CharacterType.myself ? profileEmoji : type.emoji;
            return ForestOrb(
              emoji: emoji,
              label: type.label,
              isSelected: _selected == type,
              orbColor: _orbColors[i % _orbColors.length],
              size: 138,
              onTap: () => setState(() => _selected = type),
            );
          }),
        ),
      ),
    );
  }
}
