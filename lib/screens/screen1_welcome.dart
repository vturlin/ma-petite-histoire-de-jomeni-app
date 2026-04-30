import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_step_frame.dart';

class WelcomeScreen extends StatefulWidget {
  final StoryConfig config;
  const WelcomeScreen({super.key, required this.config});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.storyTitle;
    if (widget.config.ageCategory == null) {
      final profileAge = userProfileService.currentProfile?.age;
      if (profileAge != null) {
        widget.config.ageCategory = AgeCategory.values.firstWhere(
          (a) => a.name == profileAge.name,
          orElse: () => AgeCategory.child,
        );
      }
    }
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
      step: 1,
      microLabel: 'titre de l\'histoire',
      voiceInstruction: 'Quel est le titre de ton histoire ?',
      canContinue: _controller.text.trim().isNotEmpty,
      onContinue: () {
        widget.config.storyTitle = _controller.text.trim();
        context.push('/character', extra: widget.config);
      },
      content: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            style: AppText.bodyLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'ex : L\'aventure de Léo le brave',
            ),
          ),
          const SizedBox(height: AppSpacing.s40),
          Center(
            child: GestureDetector(
              onTap: _speechAvailable ? _toggleListening : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.forestGold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGold.withValues(
                          alpha: _isListening ? 0.7 : 0.35),
                      blurRadius: _isListening ? 28 : 14,
                      spreadRadius: _isListening ? 6 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 46,
                  color: AppColors.forestInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Center(
            child: Text(
              _isListening
                  ? 'J\'écoute…'
                  : _speechAvailable
                      ? '· appuie pour dicter ·'
                      : '· micro non disponible ·',
              style: AppText.microLabel,
            ),
          ),
        ],
      ),
    );
  }
}
