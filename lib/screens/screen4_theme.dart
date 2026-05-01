import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/story_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_orb.dart';
import '../widgets/forest_step_frame.dart';

class ThemeScreen extends StatefulWidget {
  final StoryConfig config;
  const ThemeScreen({super.key, required this.config});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _selectedEmoji = '✨';

  // Suggestions — label + emoji + couleur d'orbe
  static const _suggestions = [
    ('Dinosaures',  '🦕', AppColors.butter),
    ('Jungle',      '🦁', AppColors.mint),
    ('Forêt',       '🌲', AppColors.forestLeaf),
    ('Banquise',    '❄️', AppColors.sky),
    ('Le futur',    '🚀', AppColors.forestBg3),
    ('Les Gaulois', '🐗', AppColors.coral),
    ('Chevalier',   '⚔️', AppColors.moss),
    ('Princesse',   '👸', AppColors.rose),
    ('Pokémon',     '⚡', AppColors.sky),
    ('Dragon Ball', '🥋', AppColors.butter),
    ('Disney',      '🐭', AppColors.lilac),
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.config.themeLabel;
    _selectedEmoji    = widget.config.themeEmoji;
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
              _selectedEmoji = '✨'; // emoji neutre pour saisie libre
            });
          }
        },
        localeId: 'fr_FR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ForestStepFrame(
      step: 4,
      microLabel: 'choisis l\'univers',
      voiceInstruction:
          'Dans quel univers se passe ton histoire ? Tu peux choisir dans la liste ou inventer le tien !',
      canContinue: _controller.text.trim().isNotEmpty,
      onContinue: () {
        widget.config.themeLabel = _controller.text.trim();
        widget.config.themeEmoji = _selectedEmoji;
        context.push('/story-type', extra: widget.config);
      },
      content: Column(
        children: [
          // Champ texte libre
          TextField(
            controller: _controller,
            onChanged: (v) => setState(() {
              // si l'utilisateur tape librement, on réinitialise l'emoji
              final match = _suggestions.where(
                  (s) => s.$1.toLowerCase() == v.trim().toLowerCase());
              _selectedEmoji = match.isNotEmpty ? match.first.$2 : '✨';
            }),
            style: AppText.bodyLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'ex : Espace, Moyen-Âge, Océan…',
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          // Bouton micro
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
          // Suggestions sous forme d'orbes
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _suggestions.map((s) {
              final (label, emoji, color) = s;
              final isSelected = _controller.text.trim() == label;
              return ForestOrb(
                emoji: emoji,
                label: label,
                isSelected: isSelected,
                orbColor: color,
                size: 80,
                onTap: () => setState(() {
                  _controller.text = label;
                  _selectedEmoji   = emoji;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
