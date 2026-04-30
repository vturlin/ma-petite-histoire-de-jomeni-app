import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_orb.dart';
import '../widgets/forest_step_frame.dart';

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

  static const _suggestions = [
    ('🪄', 'Baguette'),
    ('🗝️', 'Clé'),
    ('🗺️', 'Carte'),
    ('🌟', 'Étoile'),
    ('🔮', 'Cristal'),
    ('🧭', 'Boussole'),
  ];

  static const _orbColors = [
    AppColors.forestGold,
    AppColors.lilac,
    AppColors.butter,
    AppColors.mint,
    AppColors.rose,
    AppColors.sky,
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
          if (mounted) setState(() => _controller.text = result.recognizedWords);
        },
        localeId: 'fr_FR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ForestStepFrame(
      step: 6,
      microLabel: 'l\'objet magique',
      voiceInstruction:
          'Quel objet magique accompagne ton héros ? Une baguette, une clé, une étoile ?',
      canContinue: _controller.text.trim().isNotEmpty,
      onContinue: () {
        widget.config.magicObject = _controller.text.trim();
        context.push('/generating', extra: widget.config);
      },
      content: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            style: AppText.bodyLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Ton objet magique…',
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
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
                  size: 42,
                  color: AppColors.forestInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
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
          const SizedBox(height: AppSpacing.s24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_suggestions.length, (i) {
              final (emoji, label) = _suggestions[i];
              final fullText = '$emoji $label';
              return ForestOrb(
                emoji: emoji,
                label: label,
                isSelected: _controller.text == fullText,
                orbColor: _orbColors[i % _orbColors.length],
                size: 80,
                onTap: () => setState(() => _controller.text = fullText),
              );
            }),
          ),
        ],
      ),
    );
  }
}
