import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_button.dart';
import '../widgets/step_progress.dart';

class HeroNameScreen extends StatefulWidget {
  final StoryConfig config;
  const HeroNameScreen({super.key, required this.config});

  @override
  State<HeroNameScreen> createState() => _HeroNameScreenState();
}

class _HeroNameScreenState extends State<HeroNameScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.heroName;
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          }
        },
        localeId: 'fr_FR',
      );
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
                  Expanded(child: StepProgress(currentStep: 3, totalSteps: 6)),
                  ProfileButton(),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '🎤 Nomme ton héros',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dis ou écris le nom de ton héros',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'ex: Léo, Emma, Zara...',
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
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _speechAvailable ? _toggleListening : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? AppTheme.secondary
                          : AppTheme.primary,
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: AppTheme.secondary.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _isListening
                      ? 'J\'écoute...'
                      : _speechAvailable
                          ? 'Appuie pour parler'
                          : 'Micro non disponible',
                  style: TextStyle(
                    color: _isListening
                        ? AppTheme.secondary
                        : Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('← Retour',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _controller.text.trim().isNotEmpty
                        ? () {
                            widget.config.heroName =
                                _controller.text.trim();
                            context.push('/theme', extra: widget.config);
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
