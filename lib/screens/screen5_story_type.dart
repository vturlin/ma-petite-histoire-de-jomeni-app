import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/forest_orb.dart';
import '../widgets/forest_step_frame.dart';

class StoryTypeScreen extends StatefulWidget {
  final StoryConfig config;
  const StoryTypeScreen({super.key, required this.config});

  @override
  State<StoryTypeScreen> createState() => _StoryTypeScreenState();
}

class _StoryTypeScreenState extends State<StoryTypeScreen> {
  StoryType? _selected;

  static const _orbColors = [
    AppColors.sky,
    AppColors.lilac,
    AppColors.rose,
    AppColors.mint,
    AppColors.butter,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.config.storyType;
  }

  @override
  Widget build(BuildContext context) {
    return ForestStepFrame(
      step: 5,
      microLabel: 'type d\'histoire',
      voiceInstruction:
          'Quel type d\'histoire veux-tu ? Une aventure, une enquête, un conte de fée ?',
      canContinue: _selected != null,
      onContinue: () {
        widget.config.storyType = _selected;
        context.push('/magic-object', extra: widget.config);
      },
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(StoryType.values.length, (i) {
            final type = StoryType.values[i];
            return ForestOrb(
              emoji: type.emoji,
              label: type.label,
              isSelected: _selected == type,
              orbColor: _orbColors[i % _orbColors.length],
              size: 92,
              onTap: () => setState(() => _selected = type),
            );
          }),
        ),
      ),
    );
  }
}
