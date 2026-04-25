import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../widgets/choice_card.dart';
import '../widgets/wizard_scaffold.dart';

class ThemeScreen extends StatefulWidget {
  final StoryConfig config;
  const ThemeScreen({super.key, required this.config});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  StoryTheme? _selected;

  // Couleur de fond par univers
  static const _bgColors = [
    AppColors.butter,   // Dinosaures
    AppColors.mint,     // Jungle
    AppColors.sky,      // Pokémon
    AppColors.rose,     // Dragon Ball
    AppColors.lilac,    // Disney
    AppColors.moss,     // Chevaliers
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.theme;
  }

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 4,
      pastilleColor: AppColors.mint,
      pastilleIcon: Icons.public,
      title: 'Choisis l\'univers',
      subtitle: 'Dans quel monde se passe l\'aventure ?',
      voiceInstruction:
          'Dans quel univers se passe ton histoire ? Choisis le monde de ton aventure.',
      canContinue: _selected != null,
      onContinue: () {
        widget.config.theme = _selected;
        context.push('/story-type', extra: widget.config);
      },
      content: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(StoryTheme.values.length, (i) {
          final theme = StoryTheme.values[i];
          final imageAsset = switch (theme) {
            StoryTheme.pokemon    => 'assets/illus/pikachu.png',
            StoryTheme.dragonball => 'assets/illus/sangoku.png',
            StoryTheme.disney     => 'assets/illus/mickey.png',
            _                     => null,
          };
          return ChoiceCard(
            emoji: theme.emoji,
            label: theme.label,
            isSelected: _selected == theme,
            bgColor: _bgColors[i % _bgColors.length],
            emojiSize: 60,
            imageAsset: imageAsset,
            onTap: () => setState(() => _selected = theme),
          );
        }),
      ),
    );
  }
}
