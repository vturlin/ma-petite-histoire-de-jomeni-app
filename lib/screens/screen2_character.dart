import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../widgets/profile_button.dart';
import '../widgets/step_progress.dart';
import '../widgets/choice_card.dart';

class CharacterScreen extends StatefulWidget {
  final StoryConfig config;
  const CharacterScreen({super.key, required this.config});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  CharacterType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.config.characterType;
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
                  Expanded(child: StepProgress(currentStep: 2, totalSteps: 6)),
                  ProfileButton(),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '🦸 Qui est le héros ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisis le personnage principal de l\'histoire',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  children: CharacterType.values.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceCard(
                          emoji: type.emoji,
                          label: type.label,
                          isSelected: _selected == type,
                          onTap: () => setState(() => _selected = type),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
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
                            widget.config.characterType = _selected;
                            if (_selected == CharacterType.hero) {
                              context.push('/hero-name',
                                  extra: widget.config);
                            } else {
                              context.push('/theme', extra: widget.config);
                            }
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
