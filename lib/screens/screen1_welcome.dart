import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_button.dart';
import '../widgets/step_progress.dart';

class WelcomeScreen extends StatefulWidget {
  final StoryConfig config;
  const WelcomeScreen({super.key, required this.config});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.storyTitle;
    // Pre-fill age from profile if not already set
    if (widget.config.ageCategory == null) {
      final profileAge = userProfileService.currentProfile?.age;
      if (profileAge != null) {
        widget.config.ageCategory = AgeCategory.values.firstWhere(
          (a) => a.name == profileAge.name,
          orElse: () => AgeCategory.child,
        );
      }
    }
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
                  Expanded(child: StepProgress(currentStep: 1, totalSteps: 6)),
                  ProfileButton(),
                ],
              ),
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () {
                          widget.config.storyTitle = _controller.text.trim();
                          context.push('/character', extra: widget.config);
                        },
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
