/// Domain entity representing a journal entry
/// This is independent of any storage or presentation concerns
class JournalEntry {
  final DateTime createdAt;
  final String content;
  final String? summary;
  final bool sharedWithPsychologist;

  const JournalEntry({
    required this.createdAt,
    required this.content,
    this.summary,
    this.sharedWithPsychologist = false,
  });

  JournalEntry copyWith({
    DateTime? createdAt,
    String? content,
    String? summary,
    bool? sharedWithPsychologist,
  }) {
    return JournalEntry(
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      sharedWithPsychologist:
          sharedWithPsychologist ?? this.sharedWithPsychologist,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          content == other.content &&
          summary == other.summary &&
          sharedWithPsychologist == other.sharedWithPsychologist;

  @override
  int get hashCode =>
      createdAt.hashCode ^
      content.hashCode ^
      summary.hashCode ^
      sharedWithPsychologist.hashCode;
}
