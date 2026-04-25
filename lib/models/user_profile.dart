class UserProfile {
  final String id;
  final String name;
  final String emoji;
  final int colorIndex;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorIndex,
    required this.createdAt,
  });

  static const List<int> availableColors = [0, 1, 2, 3, 4, 5, 6, 7];

  static const List<String> availableEmojis = [
    '🧒', '👧', '👦', '🧑', '👩', '👨',
    '🦊', '🐼', '🦁', '🐨', '🐸', '🦄',
    '🧙', '🧝', '🧚', '🧜', '🦸', '🌟',
  ];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorIndex': colorIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '🧒',
        colorIndex: map['colorIndex'] as int? ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
