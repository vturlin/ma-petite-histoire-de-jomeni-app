import 'user_profile.dart';

class StoryConfig {
  String storyTitle;
  AgeCategory? ageCategory;
  CharacterType? characterType;
  String heroName;
  String themeLabel;
  String themeEmoji;
  StoryType? storyType;
  String magicObject;
  ProfileGender? childGender;

  StoryConfig({
    this.storyTitle = '',
    this.ageCategory,
    this.characterType,
    this.heroName = '',
    this.themeLabel = '',
    this.themeEmoji = '✨',
    this.storyType,
    this.magicObject = '',
    this.childGender,
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
  dinosaur  ('Dinosaures',  '🦕'),
  jungle    ('Jungle',      '🦁'),
  forest    ('Forêt',       '🌲'),
  arctic    ('Banquise',    '❄️'),
  future    ('Le futur',    '🚀'),
  gauls     ('Les Gaulois', '🐗'),
  knight    ('Chevalier',   '⚔️'),
  princess  ('Princesse',   '👸'),
  pokemon   ('Pokémon',     '⚡'),
  dragonball('Dragon Ball', '🥋'),
  disney    ('Disney',      '🐭');

  final String label;
  final String emoji;
  const StoryTheme(this.label, this.emoji);
}

enum StoryType {
  adventure(
    'Aventure', '🗺️',
    'Rythme enlevé avec des obstacles à surmonter un après l\'autre. '
    'Scènes d\'action et de mouvement. Un but précis à atteindre grâce à l\'objet magique. '
    'Tension qui monte, mini-victoires, et une grande victoire finale.',
  ),
  mystery(
    'Enquête', '🔍',
    'Suspense et intrigue dès les premières lignes. '
    'Des indices subtils semés tout au long du récit. '
    'Au moins deux rebondissements inattendus. '
    'Une révélation finale satisfaisante qui explique tout.',
  ),
  fairytale(
    'Conte de fée', '🏰',
    'Structure classique : "Il était une fois…" avec un monde enchanté. '
    'Atmosphère poétique, magie omniprésente, créatures fantastiques bienveillantes. '
    'Le héros traverse une épreuve qui le fait grandir. '
    'Fin lumineuse et heureuse, comme dans les grands contes.',
  ),
  fable(
    'Fable', '🦊',
    'Personnages symboliques (souvent des animaux avec des traits de caractère humains). '
    'Une situation qui illustre un défaut ou une vertu. '
    'Rythme sage et bienveillant. '
    'Morale explicite et accessible énoncée à la toute fin.',
  ),
  funny(
    'Histoire drôle', '😄',
    'Blagues, gags visuels et situations comiques adaptés à l\'âge de l\'enfant. '
    'Quiproquos, malentendus hilarants et péripéties burlesques. '
    'Personnages dans des situations absurdes et inattendues. '
    'Ton léger, beaucoup d\'énergie, pour faire rire aux éclats du début à la fin.',
  );

  final String label;
  final String emoji;
  final String promptHint;
  const StoryType(this.label, this.emoji, this.promptHint);
}
