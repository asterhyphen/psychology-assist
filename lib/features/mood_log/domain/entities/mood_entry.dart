/// Domain entity representing a mood entry
class MoodEntry {
  final DateTime createdAt;
  final int value; // 1-5
  final String label;
  final String note;

  const MoodEntry({
    required this.createdAt,
    required this.value,
    required this.label,
    required this.note,
  });

  MoodEntry copyWith({
    DateTime? createdAt,
    int? value,
    String? label,
    String? note,
  }) {
    return MoodEntry(
      createdAt: createdAt ?? this.createdAt,
      value: value ?? this.value,
      label: label ?? this.label,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          value == other.value &&
          label == other.label &&
          note == other.note;

  @override
  int get hashCode =>
      createdAt.hashCode ^ value.hashCode ^ label.hashCode ^ note.hashCode;
}
