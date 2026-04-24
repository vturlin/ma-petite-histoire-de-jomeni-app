import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress.dart';

class WelcomeScreen extends StatefulWidget {
  final StoryConfig config;
  const WelcomeScreen({super.key, required this.config});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  AgeCategory? _selected;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.storyTitle;
    _selected = widget.config.ageCategory;
  }

  bool get _canContinue =>
      _controller.text.trim().isNotEmpty && _selected != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepProgress(currentStep: 1, totalSteps: 6),
              const SizedBox(height: 32),
              const Text(
                '✨ Créons ton histoire !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Donne un titre à ton aventure',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'ex: L\'aventure de Léo le brave',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: AppTheme.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  prefixIcon:
                      const Icon(Icons.auto_stories, color: AppTheme.accent),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Quel âge a l\'enfant ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: AgeCategory.values.map((age) {
                    final isSelected = _selected == age;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = age),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accent
                                : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(age.emoji,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              age.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue
                      ? () {
                          widget.config.storyTitle =
                              _controller.text.trim();
                          widget.config.ageCategory = _selected;
                          context.push('/character', extra: widget.config);
                        }
                      : null,
                  child: const Text('Continuer →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
