import '../../domain/entities/mood_entry.dart';

/// Serializable model for MoodEntry
class MoodEntryModel extends MoodEntry {
  const MoodEntryModel({
    required super.createdAt,
    required super.value,
    required super.label,
    required super.note,
  });

  factory MoodEntryModel.fromEntity(MoodEntry entity) {
    return MoodEntryModel(
      createdAt: entity.createdAt,
      value: entity.value,
      label: entity.label,
      note: entity.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'value': value,
        'label': label,
        'note': note,
      };

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      createdAt: DateTime.parse(json['createdAt'] as String),
      value: json['value'] as int,
      label: json['label'] as String,
      note: json['note'] as String? ?? '',
    );
  }

  MoodEntry toEntity() => MoodEntry(
        createdAt: createdAt,
        value: value,
        label: label,
        note: note,
      );
}
