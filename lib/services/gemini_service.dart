import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/story_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Tu es un auteur de contes pour enfants. '
        'Ton but est de produire un récit fleuri, vivant et immersif. '
        'Ne résume jamais l\'histoire : raconte-la avec des détails sensoriels, '
        'des dialogues simples et des images poétiques. '
        'L\'histoire doit toujours comporter une introduction, une aventure '
        'avec l\'objet magique, et une fin douce et positive. '
        'Vocabulaire adapté à l\'âge indiqué. Pas de violence, pas de peur excessive. '
        'Écris uniquement le récit, sans titre ni introduction de ta part.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        maxOutputTokens: 2048,
      ),
      // Filtres de sécurité : HARASSMENT et HATE_SPEECH bloqués au max.
      // Les deux autres laissés au défaut Gemini pour éviter de bloquer
      // des éléments narratifs innocents (loups, obscurité, magie, feu...).
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
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

  Future<String> generateStory(StoryConfig config) async {
    final prompt = buildPrompt(config);
    final response = await _model.generateContent([Content.text(prompt)]);

    // Diagnostic : affiche dans la console le résultat brut de l'API
    final candidate = response.candidates.isNotEmpty
        ? response.candidates.first
        : null;
    final finishReason = candidate?.finishReason;
    final textLength = response.text?.length ?? 0;

    debugPrint('--- Gemini debug ---');
    debugPrint('finishReason : $finishReason');
    debugPrint('Longueur texte reçu : $textLength caractères');
    debugPrint('Début : ${response.text?.substring(0, textLength.clamp(0, 80))}...');
    debugPrint('--------------------');

    if (response.text == null || response.text!.isEmpty) {
      throw Exception(
        'Gemini n\'a pas renvoyé de texte. '
        'Raison d\'arrêt : $finishReason',
      );
    }

    return response.text!;
  }

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
      throw Exception('Erreur Gemini streaming : $e');
    }
  }
}
