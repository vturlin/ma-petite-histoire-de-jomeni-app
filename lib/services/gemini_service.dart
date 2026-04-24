import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/story_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Tu es un conteur expert pour enfants. '
        'Tes histoires doivent être douces, bienveillantes, sans violence ni peur. '
        'Utilise un vocabulaire simple, poétique et imagé. '
        'Structure toujours : introduction magique → aventure avec l\'objet magique → fin positive. '
        'Écris uniquement l\'histoire, sans titre ni introduction de ta part.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
  }

  String buildPrompt(StoryConfig config) {
    final age = config.ageCategory?.label ?? '4-6 ans';
    final heroName = config.heroName.isEmpty ? 'le héros' : config.heroName;
    final character = config.characterType == CharacterType.myself
        ? "l'enfant lui-même"
        : 'un héros nommé $heroName';
    final theme = config.theme?.label ?? 'aventure';
    final type = config.storyType?.label ?? 'aventure';
    final magicObject = config.magicObject.isEmpty
        ? 'un objet magique mystérieux'
        : config.magicObject;

    return 'Écris une histoire pour enfants de $age ans avec :\n'
        '- Personnage principal : $character\n'
        '- Univers / thème : $theme\n'
        '- Type d\'histoire : $type\n'
        '- Objet magique : $magicObject\n\n'
        'L\'histoire doit durer 3-5 minutes à lire à voix haute (400-600 mots). '
        'Termine sur un message positif ou une leçon douce.';
  }

  /// Génère l'histoire en streaming mot par mot
  Stream<String> generateStoryStream(StoryConfig config) async* {
    final prompt = buildPrompt(config);
    try {
      final stream = _model.generateContentStream([Content.text(prompt)]);
      await for (final chunk in stream) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      throw Exception('Erreur Gemini : $e');
    }
  }

  /// Génère l'histoire en un seul bloc
  Future<String> generateStory(StoryConfig config) async {
    final prompt = buildPrompt(config);
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? "Désolé, je n'ai pas pu créer l'histoire.";
  }
}
