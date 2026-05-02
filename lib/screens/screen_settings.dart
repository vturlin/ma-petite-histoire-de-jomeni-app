import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/story_config.dart';
import '../models/user_profile.dart';
import '../services/app_settings_service.dart';
import '../services/voice_guide_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _rate;
  late double _volume;
  late double _pitch;
  late double _audioVolume;
  bool _isTesting = false;
  List<Map<String, String>> _voices = [];
  bool _loadingVoices = false;

  @override
  void initState() {
    super.initState();
    _rate        = appSettings.speechRate;
    _volume      = appSettings.speechVolume;
    _pitch       = appSettings.speechPitch;
    _audioVolume = appSettings.audioVolume;
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    setState(() => _loadingVoices = true);
    final voices = await voiceGuide.getFrenchVoices();
    if (mounted) setState(() { _voices = voices; _loadingVoices = false; });
  }

  Future<void> _test() async {
    setState(() => _isTesting = true);
    await voiceGuide.speak(
        'Bonjour ! Voici un exemple de la voix avec ces réglages.');
    if (mounted) setState(() => _isTesting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestBg1,
      body: ForestBackground(child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, 0),
              child: Row(
                children: [
                  _RoundBtn(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Text('Réglages', style: AppText.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section voix premium
                    _SectionHeader(
                        icon: Icons.mic_external_on_outlined,
                        label: 'Voix du guide'),
                    const SizedBox(height: AppSpacing.s12),
                    _VoicePicker(
                      voices: _voices,
                      loading: _loadingVoices,
                      selected: appSettings.voiceName,
                      onSelect: (voice) async {
                        await appSettings.setVoice(
                          voice?['name'],
                          voice?['locale'],
                        );
                        setState(() {});
                        if (voice != null) {
                          await voiceGuide.speak('Bonjour, je suis votre guide.');
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Section lecture audio
                    _SectionHeader(
                        icon: Icons.headphones_outlined,
                        label: 'Lecture des histoires'),
                    const SizedBox(height: AppSpacing.s16),
                    _SettingSlider(
                      icon: Icons.volume_up_outlined,
                      label: 'Volume de lecture',
                      value: _audioVolume,
                      min: 0.3,
                      max: 1.0,
                      divisions: 14,
                      leftLabel: 'Doux',
                      rightLabel: 'Fort',
                      displayValue: '${(_audioVolume * 100).round()} %',
                      onChanged: (v) => setState(() => _audioVolume = v),
                      onChangeEnd: (v) => appSettings.setAudioVolume(v),
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Section voix
                    _SectionHeader(
                        icon: Icons.record_voice_over_outlined,
                        label: 'Guide vocal'),
                    const SizedBox(height: AppSpacing.s16),

                    // Vitesse
                    _SettingSlider(
                      icon: Icons.speed,
                      label: 'Vitesse de lecture',
                      value: _rate,
                      min: 0.2,
                      max: 0.9,
                      divisions: 14,
                      leftLabel: 'Lent',
                      rightLabel: 'Rapide',
                      displayValue: _rateLabel(_rate),
                      onChanged: (v) => setState(() => _rate = v),
                      onChangeEnd: (v) => appSettings.setSpeechRate(v),
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // Volume
                    _SettingSlider(
                      icon: Icons.volume_up_outlined,
                      label: 'Volume',
                      value: _volume,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      leftLabel: 'Faible',
                      rightLabel: 'Fort',
                      displayValue: '${(_volume * 100).round()} %',
                      onChanged: (v) => setState(() => _volume = v),
                      onChangeEnd: (v) => appSettings.setSpeechVolume(v),
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // Tonalité
                    _SettingSlider(
                      icon: Icons.graphic_eq,
                      label: 'Tonalité',
                      value: _pitch,
                      min: 0.8,
                      max: 1.4,
                      divisions: 12,
                      leftLabel: 'Grave',
                      rightLabel: 'Aigu',
                      displayValue: _pitchLabel(_pitch),
                      onChanged: (v) => setState(() => _pitch = v),
                      onChangeEnd: (v) => appSettings.setSpeechPitch(v),
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // Bouton tester
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.all(AppRadius.xl),
                          boxShadow:
                              _isTesting ? [] : AppShadows.cta,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isTesting ? null : _test,
                          icon: Icon(
                            _isTesting
                                ? Icons.volume_up
                                : Icons.play_circle_outline,
                          ),
                          label: Text(_isTesting
                              ? 'En cours…'
                              : 'Tester la voix'),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Bouton réinitialiser
                    Center(
                      child: TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh,
                            size: 16, color: AppColors.inkMute),
                        label: Text('Réinitialiser les réglages',
                            style: AppText.bodySmall),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),

                    // ── Mode bêta ──────────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.science_outlined,
                      label: 'Mode Bêta',
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: AppColors.forestBg2,
                        borderRadius: AppRadius.all(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.forestGold.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('gemini-3-flash-preview',
                                    style: AppText.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  'Génération de texte avec le modèle Gemini 3. '
                                  'Même audio TTS qu\'en mode normal.',
                                  style: AppText.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Switch(
                            value: appSettings.betaMode,
                            activeThumbColor: AppColors.forestGold,
                            activeTrackColor: AppColors.forestGold.withValues(alpha: 0.5),
                            onChanged: (v) async {
                              await appSettings.setBetaMode(v);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    if (appSettings.betaMode) ...[
                      const SizedBox(height: AppSpacing.s12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Config minimal pour tester directement
                            final config = StoryConfig(
                              storyTitle: 'Test bêta',
                              themeLabel: 'Forêt enchantée',
                              themeEmoji: '🌲',
                              heroName: 'Léo',
                              characterType: CharacterType.hero,
                              magicObject: '🪄 Baguette',
                              childGender: ProfileGender.boy,
                            );
                            context.push('/generating', extra: config);
                          },
                          icon: const Icon(Icons.science_outlined),
                          label: const Text('Tester la génération →'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  String _rateLabel(double v) {
    if (v < 0.35) return 'Très lent';
    if (v < 0.5)  return 'Lent';
    if (v < 0.65) return 'Normal';
    if (v < 0.8)  return 'Rapide';
    return 'Très rapide';
  }

  String _pitchLabel(double v) {
    if (v < 0.9)  return 'Grave';
    if (v < 1.1)  return 'Normal';
    if (v < 1.25) return 'Aigu';
    return 'Très aigu';
  }

  Future<void> _reset() async {
    await appSettings.setSpeechRate(0.45);
    await appSettings.setSpeechVolume(1.0);
    await appSettings.setSpeechPitch(1.05);
    await appSettings.setAudioVolume(0.5);
    setState(() {
      _rate        = appSettings.speechRate;
      _volume      = appSettings.speechVolume;
      _pitch       = appSettings.speechPitch;
      _audioVolume = appSettings.audioVolume;
    });
  }
}

// ── Widgets locaux ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadius.all(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.accent2, size: 18),
        ),
        const SizedBox(width: AppSpacing.s12),
        Text(label, style: AppText.titleMedium),
      ],
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String leftLabel;
  final String rightLabel;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SettingSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.leftLabel,
    required this.rightLabel,
    required this.displayValue,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.forestBg2,
        borderRadius: AppRadius.all(AppRadius.xl),
        border: Border.all(
            color: AppColors.forestCream.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.inkSoft),
              const SizedBox(width: AppSpacing.s8),
              Text(label, style: AppText.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: AppRadius.all(AppRadius.xs),
                ),
                child: Text(displayValue,
                    style: AppText.labelLarge
                        .copyWith(color: AppColors.accentInk)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent2,
              inactiveTrackColor: AppColors.paper2,
              thumbColor: AppColors.accent2,
              overlayColor:
                  AppColors.accent2.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leftLabel, style: AppText.bodySmall),
                Text(rightLabel, style: AppText.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoicePicker extends StatelessWidget {
  final List<Map<String, String>> voices;
  final bool loading;
  final String? selected;
  final void Function(Map<String, String>?) onSelect;

  const _VoicePicker({
    required this.voices,
    required this.loading,
    required this.selected,
    required this.onSelect,
  });

  String _label(Map<String, String> v) {
    final name   = v['name']   ?? '';
    final locale = v['locale'] ?? '';
    // Indique clairement les voix premium / améliorées
    final badge = name.toLowerCase().contains('premium')
        ? ' ⭐'
        : name.toLowerCase().contains('enhanc')
            ? ' ✨'
            : '';
    return '$name ($locale)$badge';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s16),
          child: CircularProgressIndicator(
              color: AppColors.accent2, strokeWidth: 2),
        ),
      );
    }

    if (voices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.forestBg2,
          borderRadius: AppRadius.all(AppRadius.xl),
          border: Border.all(
              color: AppColors.forestCream.withValues(alpha: 0.08), width: 1),
        ),
        child: Text(
          'Aucune voix française trouvée sur cet appareil.',
          style: AppText.bodyMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.forestBg2,
        borderRadius: AppRadius.all(AppRadius.xl),
        border: Border.all(
            color: AppColors.forestCream.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        children: [
          // Option "Par défaut"
          _VoiceTile(
            label: '🔄 Voix système par défaut',
            subtitle: 'Laisse Android choisir',
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          const Divider(height: 1, color: AppColors.line),
          ...voices.asMap().entries.map((e) {
            final i = e.key;
            final v = e.value;
            final name = v['name'] ?? '';
            return Column(
              children: [
                _VoiceTile(
                  label: _label(v),
                  subtitle: v['locale'] ?? '',
                  isSelected: selected == name,
                  onTap: () => onSelect(v),
                ),
                if (i < voices.length - 1)
                  const Divider(height: 1, color: AppColors.line),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _VoiceTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoiceTile({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.all(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accent2 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.accent2 : AppColors.line,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.forestInk, size: 14)
                  : null,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: isSelected
                          ? AppText.titleMedium
                              .copyWith(color: AppColors.accentInk)
                          : AppText.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.iconBtnTopbar,
        height: AppSize.iconBtnTopbar,
        decoration: BoxDecoration(
          color: AppColors.forestBg2,
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.forestCream.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Icon(icon, color: AppColors.forestCream, size: 18),
      ),
    );
  }
}
