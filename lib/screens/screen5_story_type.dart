import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../widgets/choice_card.dart';
import '../widgets/wizard_scaffold.dart';

class StoryTypeScreen extends StatefulWidget {
  final StoryConfig config;
  const StoryTypeScreen({super.key, required this.config});

  @override
  State<StoryTypeScreen> createState() => _StoryTypeScreenState();
}

class _StoryTypeScreenState extends State<StoryTypeScreen> {
  StoryType? _selected;

  static const _bgColors = [
    AppColors.sky,      // Aventure
    AppColors.lilac,    // Enquête
    AppColors.rose,     // Conte de fée
    AppColors.mint,     // Fable
    AppColors.butter,   // Histoire drôle
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.storyType;
  }

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      step: 5,
      pastilleColor: AppColors.butter,
      pastilleIcon: Icons.auto_stories_outlined,
      title: 'Type d\'histoire',
      subtitle: 'Quelle sorte d\'aventure veux-tu vivre ?',
      voiceInstruction:
          'Quel type d\'histoire veux-tu ? Une aventure, une enquête, un conte de fée ?',
      canContinue: _selected != null,
      onContinue: () {
        widget.config.storyType = _selected;
        context.push('/magic-object', extra: widget.config);
      },
      content: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(StoryType.values.length, (i) {
          final type = StoryType.values[i];
          return ChoiceCard(
            emoji: type.emoji,
            label: type.label,
            isSelected: _selected == type,
            bgColor: _bgColors[i % _bgColors.length],
            emojiSize: 56,
            onTap: () => setState(() => _selected = type),
          );
        }),
      ),
    );
  }
}
