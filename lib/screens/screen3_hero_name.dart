import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_step_frame.dart';

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
          if (mounted) setState(() => _controller.text = result.recognizedWords);
        },
        localeId: 'fr_FR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ForestStepFrame(
      step: 3,
      microLabel: 'nomme ton héros',
      voiceInstruction:
          'Comment s\'appelle ton héros ? Tu peux le dire à voix haute ou l\'écrire.',
      canContinue: _controller.text.trim().isNotEmpty,
      onContinue: () {
        widget.config.heroName = _controller.text.trim();
        context.push('/theme', extra: widget.config);
      },
      content: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            style: AppText.titleLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'ex: Léo, Emma, Zara…',
            ),
          ),
          const SizedBox(height: AppSpacing.s40),
          Center(
            child: GestureDetector(
              onTap: _speechAvailable ? _toggleListening : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.forestGold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGold.withValues(
                          alpha: _isListening ? 0.7 : 0.35),
                      blurRadius: _isListening ? 24 : 12,
                      spreadRadius: _isListening ? 5 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: AppColors.forestInk,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Center(
            child: Text(
              _isListening
                  ? 'J\'écoute…'
                  : _speechAvailable
                      ? '· appuie pour parler ·'
                      : '· micro non disponible ·',
              style: AppText.microLabel,
            ),
          ),
        ],
      ),
    );
  }
}
