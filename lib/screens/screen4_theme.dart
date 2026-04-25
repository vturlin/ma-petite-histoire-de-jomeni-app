import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../widgets/profile_button.dart';
import '../widgets/step_progress.dart';
import '../widgets/choice_card.dart';

class ThemeScreen extends StatefulWidget {
  final StoryConfig config;
  const ThemeScreen({super.key, required this.config});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  StoryTheme? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.config.theme;
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
                  Expanded(child: StepProgress(currentStep: 4, totalSteps: 6)),
                  ProfileButton(),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '🌍 Choisis ton univers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dans quel monde se passe l\'aventure ?',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: StoryTheme.values.map((theme) {
                    return ChoiceCard(
                      emoji: theme.emoji,
                      label: theme.label,
                      isSelected: _selected == theme,
                      onTap: () => setState(() => _selected = theme),
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
                            widget.config.theme = _selected;
                            context.push('/story-type',
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
