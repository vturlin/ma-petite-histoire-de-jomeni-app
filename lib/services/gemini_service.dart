import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/story_config.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  String _buildPrompt(StoryConfig config) {
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

    return '''
Tu es un conteur d'histoires pour enfants bienveillant et créatif.

Écris une histoire pour enfants de $age avec les caractéristiques suivantes :
- Personnage principal : $character
- Univers / thème : $theme
- Type d'histoire : $type
- Objet magique : $magicObject

Consignes importantes :
- L'histoire doit être adaptée à des enfants de $age
- Utilise un langage simple, vivant et imagé
- L'histoire doit durer environ 3-5 minutes à lire à voix haute (400 à 600 mots)
- Structure : introduction, aventure avec l'objet magique, résolution positive
- Termine toujours sur un message positif ou une leçon douce
- N'utilise pas de violence ni de peur excessive
- Écris uniquement l'histoire, sans titre ni introduction de ta part
''';
  }

  Future<String> generateStory(StoryConfig config) async {
    final prompt = _buildPrompt(config);
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Désolé, je n'ai pas pu créer l'histoire.";
  }
}
