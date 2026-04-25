class StoryConfig {
  String storyTitle;
  AgeCategory? ageCategory;
  CharacterType? characterType;
  String heroName;
  StoryTheme? theme;
  StoryType? storyType;
  String magicObject;

  StoryConfig({
    this.storyTitle = '',
    this.ageCategory,
    this.characterType,
    this.heroName = '',
    this.theme,
    this.storyType,
    this.magicObject = '',
  });
}

enum AgeCategory {
  toddler('2-4 ans', '👶'),
  preschool('4-6 ans', '🧒'),
  child('6-8 ans', '👦'),
  older('8-10 ans', '🧑');

  final String label;
  final String emoji;
  const AgeCategory(this.label, this.emoji);
}

enum CharacterType {
  myself('Moi-même', '🧒'),
  hero('Un héros', '🦸');

  final String label;
  final String emoji;
  const CharacterType(this.label, this.emoji);
}

enum StoryTheme {
  dinosaur('Dinosaures', '🦕'),
  jungle('Animaux de la jungle', '🦁'),
  pokemon('Pokémon', '⚡'),
  dragonball('Dragon Ball', '🥋'),
  disney('Disney', '🐭'),
  knight('Chevaliers & Princesses', '⚔️');

  final String label;
  final String emoji;
  const StoryTheme(this.label, this.emoji);
}

enum StoryType {
  adventure('Aventure', '🗺️'),
  mystery('Enquête', '🔍'),
  fairytale('Conte de fée', '🏰'),
  fable('Fable', '🦊'),
  funny('Histoire drôle', '😄');

  final String label;
  final String emoji;
  const StoryType(this.label, this.emoji);
}
