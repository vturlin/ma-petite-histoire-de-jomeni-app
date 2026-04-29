import 'package:flutter_tts/flutter_tts.dart';
import 'app_settings_service.dart';

class VoiceGuideService {
  final FlutterTts _tts = FlutterTts();
  bool _langSet = false;

  Future<void> _apply() async {
    if (!_langSet) {
      await _tts.setLanguage('fr-FR');
      _langSet = true;
    }
    // Voix personnalisée si définie, sinon voix système fr-FR
    final name   = appSettings.voiceName;
    final locale = appSettings.voiceLocale;
    if (name != null && locale != null) {
      await _tts.setVoice({'name': name, 'locale': locale});
    }
    await _tts.setSpeechRate(appSettings.speechRate);
    await _tts.setVolume(appSettings.speechVolume);
    await _tts.setPitch(appSettings.speechPitch);
  }

  Future<List<Map<String, String>>> getFrenchVoices() async {
    final all = await _tts.getVoices;
    final result = <Map<String, String>>[];
    for (final v in all) {
      final map = Map<String, String>.from(v as Map);
      final locale = (map['locale'] ?? '').toLowerCase();
      if (locale.startsWith('fr')) result.add(map);
    }
    result.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    return result;
  }

  Future<void> speak(String text) async {
    await _apply();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}

final voiceGuide = VoiceGuideService();
