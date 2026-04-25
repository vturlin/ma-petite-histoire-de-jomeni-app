/// Tranche d'âge stockée dans le profil (valeurs identiques à AgeCategory).
enum ProfileAge {
  toddler('2-4 ans', '👶'),
  preschool('4-6 ans', '🧒'),
  child('6-8 ans', '👦'),
  older('8-10 ans', '🧑');

  final String label;
  final String emoji;
  const ProfileAge(this.label, this.emoji);
}

class UserProfile {
  final String id;
  final String name;
  final String emoji;
  final int colorIndex;
  final DateTime createdAt;
  final ProfileAge? age; // null = pas défini, sera demandé à la création

  const UserProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorIndex,
    required this.createdAt,
    this.age,
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
        if (age != null) 'age': age!.name,
      };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '🧒',
        colorIndex: map['colorIndex'] as int? ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
        age: map['age'] != null
            ? ProfileAge.values.firstWhere(
                (e) => e.name == map['age'],
                orElse: () => ProfileAge.child,
              )
            : null,
      );
}
