import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/wizard_scaffold.dart';

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

  // Suggestions sous forme emoji + label
  static const _suggestions = [
    ('🪄', 'Baguette'),
    ('🗝️', 'Clé'),
    ('🗺️', 'Carte'),
    ('🌟', 'Étoile'),
    ('🔮', 'Cristal'),
    ('🧭', 'Boussole'),
  ];

  static const _bgColors = [
    AppColors.accentSoft,
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
    return WizardScaffold(
      step: 6,
      pastilleColor: AppColors.lilac,
      pastilleIcon: Icons.auto_fix_high,
      title: 'L\'objet magique',
      subtitle: 'Quel objet magique accompagne ton héros ?',
      voiceInstruction:
          'Quel objet magique accompagne ton héros ? Une baguette, une clé, une étoile ?',
      canContinue: _controller.text.trim().isNotEmpty,
      continueLabel: '✨ Créer l\'histoire !',
      onContinue: () {
        widget.config.magicObject = _controller.text.trim();
        context.push('/generating', extra: widget.config);
      },
      content: Column(
        children: [
          // Champ texte (résultat micro ou saisie)
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            style: AppText.bodyLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Ton objet magique…',
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          // Gros bouton micro centré
          Center(
            child: GestureDetector(
              onTap: _speechAvailable ? _toggleListening : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? AppColors.accent2
                      : AppColors.accentSoft,
                  boxShadow: _isListening ? AppShadows.cta : AppShadows.soft,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 46,
                  color: _isListening ? Colors.white : AppColors.accent2,
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
                      ? 'Appuie pour dicter'
                      : 'Micro non disponible',
              style: AppText.bodySmall.copyWith(
                color:
                    _isListening ? AppColors.accent2 : AppColors.inkMute,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          // Grille de suggestions
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(_suggestions.length, (i) {
              final (emoji, label) = _suggestions[i];
              final fullText = '$emoji $label';
              final selected = _controller.text == fullText;
              return GestureDetector(
                onTap: () => setState(() => _controller.text = fullText),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentSoft : _bgColors[i],
                    borderRadius: AppRadius.all(AppRadius.lg),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent2
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected ? AppShadows.soft : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: AppSpacing.s4),
                      Text(label, style: AppText.labelLarge),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
