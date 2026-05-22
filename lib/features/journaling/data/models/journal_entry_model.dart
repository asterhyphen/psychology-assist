import '../../domain/entities/journal_entry.dart';

/// Serializable model for JournalEntry
/// This handles JSON serialization/deserialization for persistence
class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.createdAt,
    required super.content,
    super.summary,
    super.sharedWithPsychologist = false,
  });

  /// Create model from domain entity
  factory JournalEntryModel.fromEntity(JournalEntry entity) {
    return JournalEntryModel(
      createdAt: entity.createdAt,
      content: entity.content,
      summary: entity.summary,
      sharedWithPsychologist: entity.sharedWithPsychologist,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'content': content,
        'summary': summary,
        'sharedWithPsychologist': sharedWithPsychologist,
      };

  /// Create model from JSON
  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
      summary: json['summary'] as String?,
      sharedWithPsychologist: json['sharedWithPsychologist'] as bool? ?? false,
    );
  }

  /// Convert to domain entity
  JournalEntry toEntity() => JournalEntry(
        createdAt: createdAt,
        content: content,
        summary: summary,
        sharedWithPsychologist: sharedWithPsychologist,
      );
}
