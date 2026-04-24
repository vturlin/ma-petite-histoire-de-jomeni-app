import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress.dart';

class MagicObjectScreen extends StatefulWidget {
  final StoryConfig config;
  const MagicObjectScreen({super.key, required this.config});

  @override
  State<MagicObjectScreen> createState() => _MagicObjectScreenState();
}

class _MagicObjectScreenState extends State<MagicObjectScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  final List<String> _suggestions = [
    '🪄 Baguette magique',
    '🗡️ Épée enchantée',
    '🔮 Boule de cristal',
    '🧢 Chapeau invisible',
    '🌟 Étoile filante',
    '📿 Collier magique',
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.magicObject;
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
              const StepProgress(currentStep: 6, totalSteps: 6),
              const SizedBox(height: 32),
              const Text(
                '🪄 L\'objet magique',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quel objet magique accompagne ton héros ?',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Dis ou écris ton objet magique...',
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
                  suffixIcon: GestureDetector(
                    onTap: _speechAvailable ? _toggleListening : null,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? AppTheme.secondary
                          : AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ou choisis une suggestion :',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _suggestions.map((s) {
                  return GestureDetector(
                    onTap: () => setState(() => _controller.text = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(s,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                }).toList(),
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
                            widget.config.magicObject =
                                _controller.text.trim();
                            context.push('/generating',
                                extra: widget.config);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.background,
                    ),
                    child: const Text('✨ Créer l\'histoire !'),
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
