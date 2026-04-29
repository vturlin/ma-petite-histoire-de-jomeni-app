import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends ChangeNotifier {
  static const _keyRate        = 'voice_rate';
  static const _keyVolume      = 'voice_volume';
  static const _keyPitch       = 'voice_pitch';
  static const _keyAudioVolume = 'audio_volume';
  static const _keyVoiceName    = 'voice_name';
  static const _keyVoiceLocale  = 'voice_locale';

  double _speechRate   = kIsWeb ? 0.75 : 0.45;
  double _speechVolume = 1.0;
  double _speechPitch  = 1.05;
  // 0.5 par défaut : headroom anti-saturation sur l'audio PCM Gemini TTS
  double _audioVolume  = 0.5;
  // null = laisser l'OS choisir la voix par défaut
  String? _voiceName;
  String? _voiceLocale;
  double  get speechRate    => _speechRate;
  double  get speechVolume  => _speechVolume;
  double  get speechPitch   => _speechPitch;
  double  get audioVolume   => _audioVolume;
  String? get voiceName     => _voiceName;
  String? get voiceLocale   => _voiceLocale;

  static Future<AppSettingsService> load() async {
    final svc = AppSettingsService();
    final prefs = await SharedPreferences.getInstance();
    svc._speechRate   = prefs.getDouble(_keyRate)        ?? svc._speechRate;
    svc._speechVolume = prefs.getDouble(_keyVolume)      ?? svc._speechVolume;
    svc._speechPitch  = prefs.getDouble(_keyPitch)       ?? svc._speechPitch;
    svc._audioVolume  = prefs.getDouble(_keyAudioVolume) ?? svc._audioVolume;
    svc._voiceName    = prefs.getString(_keyVoiceName);
    svc._voiceLocale  = prefs.getString(_keyVoiceLocale);
    return svc;
  }

  Future<void> setSpeechRate(double v) async {
    _speechRate = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyRate, v);
  }

  Future<void> setSpeechVolume(double v) async {
    _speechVolume = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, v);
  }

  Future<void> setSpeechPitch(double v) async {
    _speechPitch = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPitch, v);
  }

  Future<void> setAudioVolume(double v) async {
    _audioVolume = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAudioVolume, v);
  }

  Future<void> setVoice(String? name, String? locale) async {
    _voiceName   = name;
    _voiceLocale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove(_keyVoiceName);
      await prefs.remove(_keyVoiceLocale);
    } else {
      await prefs.setString(_keyVoiceName, name);
      if (locale != null) await prefs.setString(_keyVoiceLocale, locale);
    }
  }
}

late final AppSettingsService appSettings;
