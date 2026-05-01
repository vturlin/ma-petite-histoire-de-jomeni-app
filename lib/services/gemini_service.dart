import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/story_config.dart';
import '../models/user_profile.dart';

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
        'IMPORTANT : le texte sera lu à voix haute par un moteur de synthèse vocale (TTS). '
        'Tu dois donc soigner particulièrement la ponctuation pour rendre la lecture naturelle : '
        'utilise des virgules pour les pauses courtes, des points pour les pauses longues, '
        'des points d\'exclamation pour l\'enthousiasme, des points de suspension pour le suspense. '
        'Évite les longues phrases sans ponctuation. Aère les dialogues avec des tirets. '
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
    final theme = config.themeLabel.isNotEmpty ? config.themeLabel : 'aventure';
    final typeLabel = config.storyType?.label ?? 'Aventure';
    final typeHint  = config.storyType?.promptHint ?? '';
    final magicObject = config.magicObject.isEmpty
        ? 'un objet magique mystérieux'
        : config.magicObject;

    // Genre : explicite si l'enfant joue son propre rôle, déduit du prénom sinon
    String genderLine;
    if (config.characterType == CharacterType.myself) {
      genderLine = switch (config.childGender) {
        ProfileGender.boy =>
          '- Genre du héros : garçon — accorde tous les adjectifs et participes au masculin\n',
        ProfileGender.girl =>
          '- Genre du héros : fille — accorde tous les adjectifs et participes au féminin\n',
        null => '',
      };
    } else {
      // Héros nommé : Gemini déduit le genre à partir du prénom
      genderLine = heroName != 'le héros'
          ? '- Genre du héros : à déduire du prénom "$heroName" — accorde les adjectifs et participes en conséquence\n'
          : '';
    }

    return 'Écris une histoire pour enfants de $age ans avec :\n'
        '- Personnage principal : $character\n'
        '$genderLine'
        '- Univers / thème : $theme\n'
        '- Type d\'histoire : $typeLabel\n'
        '- Consignes de style pour ce type : $typeHint\n'
        '- Objet magique : $magicObject — cet objet doit être au cœur de l\'histoire et de l\'intrigue : c\'est lui qui déclenche l\'aventure, permet de surmonter l\'obstacle principal ou révèle son pouvoir au moment décisif\n\n'
        'L\'histoire doit durer 3-5 minutes à lire à voix haute (400-600 mots). '
        'Termine sur un message positif ou une leçon douce. '
        'Rappel : soigne la ponctuation car le texte sera lu par un robot TTS.';
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
