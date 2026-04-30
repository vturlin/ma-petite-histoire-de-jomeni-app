import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/forest_orb.dart';
import '../widgets/forest_step_frame.dart';

class ThemeScreen extends StatefulWidget {
  final StoryConfig config;
  const ThemeScreen({super.key, required this.config});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  StoryTheme? _selected;

  static const _orbColors = [
    AppColors.butter,
    AppColors.mint,
    AppColors.sky,
    AppColors.rose,
    AppColors.lilac,
    AppColors.moss,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.theme;
  }

  @override
  Widget build(BuildContext context) {
    return ForestStepFrame(
      step: 4,
      microLabel: 'choisis l\'univers',
      voiceInstruction:
          'Dans quel univers se passe ton histoire ? Choisis le monde de ton aventure.',
      canContinue: _selected != null,
      onContinue: () {
        widget.config.theme = _selected;
        context.push('/story-type', extra: widget.config);
      },
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(StoryTheme.values.length, (i) {
            final theme = StoryTheme.values[i];
            final imageAsset = switch (theme) {
              StoryTheme.pokemon    => 'assets/illus/pikachu.png',
              StoryTheme.dragonball => 'assets/illus/sangoku.png',
              StoryTheme.disney     => 'assets/illus/mickey.png',
              _                     => null,
            };
            return ForestOrb(
              emoji: theme.emoji,
              label: theme.label,
              isSelected: _selected == theme,
              orbColor: _orbColors[i % _orbColors.length],
              size: 92,
              imageAsset: imageAsset,
              onTap: () => setState(() => _selected = theme),
            );
          }),
        ),
      ),
    );
  }
}
