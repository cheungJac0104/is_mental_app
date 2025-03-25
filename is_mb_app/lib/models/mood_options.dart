class MoodOptions {
  final List<Mood> moods;
  final int intensityLevels;
  final List<String> keywords;

  MoodOptions({
    required this.moods,
    required this.intensityLevels,
    required this.keywords,
  });

  factory MoodOptions.fromJson(Map<String, dynamic> json) {
    return MoodOptions(
      moods:
          (json['moods'] as List).map((mood) => Mood.fromJson(mood)).toList(),
      intensityLevels: json['intensityLevels'],
      keywords: (json['keywords'] as List).cast<String>(),
    );
  }
}

class Mood {
  final String emoji;
  final String label;

  Mood({required this.emoji, required this.label});

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      emoji: json['emoji'],
      label: json['label'],
    );
  }

  String get displayText => '$emoji $label';
}
