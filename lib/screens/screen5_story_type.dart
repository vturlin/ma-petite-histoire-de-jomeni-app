import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../widgets/profile_button.dart';
import '../widgets/step_progress.dart';
import '../widgets/choice_card.dart';

class StoryTypeScreen extends StatefulWidget {
  final StoryConfig config;
  const StoryTypeScreen({super.key, required this.config});

  @override
  State<StoryTypeScreen> createState() => _StoryTypeScreenState();
}

class _StoryTypeScreenState extends State<StoryTypeScreen> {
  StoryType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.config.storyType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(child: StepProgress(currentStep: 5, totalSteps: 6)),
                  ProfileButton(),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '📖 Type d\'histoire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quelle sorte d\'aventure veux-tu vivre ?',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: StoryType.values.map((type) {
                    return ChoiceCard(
                      emoji: type.emoji,
                      label: type.label,
                      isSelected: _selected == type,
                      onTap: () => setState(() => _selected = type),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('← Retour',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selected != null
                        ? () {
                            widget.config.storyType = _selected;
                            context.push('/magic-object',
                                extra: widget.config);
                          }
                        : null,
                    child: const Text('Continuer →'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
