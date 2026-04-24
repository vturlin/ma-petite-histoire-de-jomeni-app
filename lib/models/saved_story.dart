class SavedStory {
  final String id;
  final String title;
  final String text;
  final DateTime createdAt;
  final String ageLabel;
  final String themeEmoji;
  final String themeLabel;
  final String storyTypeLabel;
  final String heroName;
  final String magicObject;
  final int audioChunkCount;

  const SavedStory({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.ageLabel,
    required this.themeEmoji,
    required this.themeLabel,
    required this.storyTypeLabel,
    required this.heroName,
    required this.magicObject,
    required this.audioChunkCount,
  });

  bool get hasAudio => audioChunkCount > 0;

  String get subtitle =>
      '$themeEmoji $themeLabel · $storyTypeLabel${heroName.isNotEmpty ? ' · $heroName' : ''}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'ageLabel': ageLabel,
        'themeEmoji': themeEmoji,
        'themeLabel': themeLabel,
        'storyTypeLabel': storyTypeLabel,
        'heroName': heroName,
        'magicObject': magicObject,
        'audioChunkCount': audioChunkCount,
      };

  factory SavedStory.fromMap(Map<dynamic, dynamic> map) => SavedStory(
        id: map['id'] as String,
        title: map['title'] as String,
        text: map['text'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        ageLabel: map['ageLabel'] as String? ?? '',
        themeEmoji: map['themeEmoji'] as String? ?? '✨',
        themeLabel: map['themeLabel'] as String? ?? '',
        storyTypeLabel: map['storyTypeLabel'] as String? ?? '',
        heroName: map['heroName'] as String? ?? '',
        magicObject: map['magicObject'] as String? ?? '',
        audioChunkCount: map['audioChunkCount'] as int? ?? 0,
      );
}
