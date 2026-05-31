import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/app_session_store.dart';

const demoPsychologistEmail = 'panipuri@macxcode';

enum UserRole { psychologist, patient }
enum AppointmentStatus { pending, confirmed, cancelled, completed, noShow }
enum PatientStatus { newCase, active, underTreatment, followUp, completed, cancelled }

class DriftHistoryEntry {
  final double driftValue;
  final DateTime timestamp;
  final String source;

  const DriftHistoryEntry({
    required this.driftValue,
    required this.timestamp,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'driftValue': driftValue,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
      };

  factory DriftHistoryEntry.fromJson(Map<String, dynamic> json) => DriftHistoryEntry(
        driftValue: (json['driftValue'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(json['timestamp'] as String),
        source: json['source'] as String? ?? '',
      );
}

class TypingHistoryEntry {
  final DateTime timestamp;
  final int wpm;
  final double accuracy;
  final int corrections;
  final double stressScore;

  const TypingHistoryEntry({
    required this.timestamp,
    required this.wpm,
    required this.accuracy,
    required this.corrections,
    required this.stressScore,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'wpm': wpm,
        'accuracy': accuracy,
        'corrections': corrections,
        'stressScore': stressScore,
      };

  factory TypingHistoryEntry.fromJson(Map<String, dynamic> json) => TypingHistoryEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        wpm: json['wpm'] as int? ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        corrections: json['corrections'] as int? ?? 0,
        stressScore: (json['stressScore'] as num?)?.toDouble() ?? 0.0,
      );
}

class BreathingHistoryEntry {
  final DateTime timestamp;
  final String technique;
  final int durationSeconds;
  final int cyclesCompleted;

  const BreathingHistoryEntry({
    required this.timestamp,
    required this.technique,
    required this.durationSeconds,
    required this.cyclesCompleted,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'technique': technique,
        'durationSeconds': durationSeconds,
        'cyclesCompleted': cyclesCompleted,
      };

  factory BreathingHistoryEntry.fromJson(Map<String, dynamic> json) => BreathingHistoryEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        technique: json['technique'] as String? ?? '',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        cyclesCompleted: json['cyclesCompleted'] as int? ?? 0,
      );
}

class ClinicalNote {
  final String id;
  final DateTime timestamp;
  final String note;
  final String authorName;

  const ClinicalNote({
    required this.id,
    required this.timestamp,
    required this.note,
    required this.authorName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'authorName': authorName,
      };

  factory ClinicalNote.fromJson(Map<String, dynamic> json) => ClinicalNote(
        id: json['id'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String? ?? '',
        authorName: json['authorName'] as String? ?? '',
      );
}

class AdherenceRecord {
  final DateTime timestamp;
  final String medicineName;
  final bool taken;

  const AdherenceRecord({
    required this.timestamp,
    required this.medicineName,
    required this.taken,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'medicineName': medicineName,
        'taken': taken,
      };

  factory AdherenceRecord.fromJson(Map<String, dynamic> json) => AdherenceRecord(
        timestamp: DateTime.parse(json['timestamp'] as String),
        medicineName: json['medicineName'] as String? ?? '',
        taken: json['taken'] as bool? ?? false,
      );
}

class AppProfile {
  final UserRole role;
  final String name;
  final DateTime? dateOfBirth;
  final String? email;
  final String? psychologistEmail;
  final int avatarIconCodePoint;
  final int avatarColorValue;
  final String? profileImagePath;
  final double driftIndex;
  final PatientStatus status;

  const AppProfile({
    required this.role,
    required this.name,
    this.dateOfBirth,
    this.email,
    this.psychologistEmail,
    this.avatarIconCodePoint = 0xe7fd,
    this.avatarColorValue = 0xFF8B5CF6,
    this.profileImagePath,
    this.driftIndex = 0.0,
    this.status = PatientStatus.active,
  });

  bool get hasPsychologist =>
      psychologistEmail != null && psychologistEmail!.trim().isNotEmpty;

  AppProfile copyWith({
    UserRole? role,
    String? name,
    DateTime? dateOfBirth,
    String? email,
    String? psychologistEmail,
    int? avatarIconCodePoint,
    int? avatarColorValue,
    String? profileImagePath,
    double? driftIndex,
    PatientStatus? status,
  }) {
    return AppProfile(
      role: role ?? this.role,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      psychologistEmail: psychologistEmail ?? this.psychologistEmail,
      avatarIconCodePoint: avatarIconCodePoint ?? this.avatarIconCodePoint,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      driftIndex: driftIndex ?? this.driftIndex,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'name': name,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'email': email,
        'psychologistEmail': psychologistEmail,
        'avatarIconCodePoint': avatarIconCodePoint,
        'avatarColorValue': avatarColorValue,
        'profileImagePath': profileImagePath,
        'driftIndex': driftIndex,
        'status': status.name,
      };

  factory AppProfile.fromJson(Map<String, dynamic> json) => AppProfile(
        role: UserRole.values.firstWhere(
          (role) => role.name == json['role'],
          orElse: () => UserRole.patient,
        ),
        name: json['name'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] == null
            ? null
            : DateTime.parse(json['dateOfBirth'] as String),
        email: json['email'] as String?,
        psychologistEmail: json['psychologistEmail'] as String?,
        avatarIconCodePoint: json['avatarIconCodePoint'] as int? ?? 0xe7fd,
        avatarColorValue: json['avatarColorValue'] as int? ?? 0xFF8B5CF6,
        profileImagePath: json['profileImagePath'] as String?,
        driftIndex: (json['driftIndex'] as num?)?.toDouble() ?? 0.0,
        status: PatientStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PatientStatus.active,
        ),
      );
}

class Appointment {
  final String psychologistEmail;
  final String psychologistName;
  final String patientName;
  final String? patientEmail;
  final DateTime startsAt;
  final String type;
  final String note;
  final AppointmentStatus status;
  final double driftIndex;

  String get displayPatientName {
    final trimmed = patientName.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'patient') {
      if (patientEmail != null && patientEmail!.isNotEmpty) {
        final emailStub = patientEmail!.split('@').first;
        if (emailStub.isNotEmpty) {
          if (emailStub.toLowerCase() == 'patient') {
            return 'Unnamed Client';
          }
          return emailStub[0].toUpperCase() + emailStub.substring(1);
        }
      }
      return 'Unnamed Client';
    }
    return patientName;
  }

  const Appointment({
    required this.psychologistEmail,
    required this.psychologistName,
    required this.patientName,
    this.patientEmail,
    required this.startsAt,
    required this.type,
    required this.note,
    this.status = AppointmentStatus.pending,
    this.driftIndex = 0.0,
  });

  bool get confirmed => status == AppointmentStatus.confirmed;

  Appointment copyWith({
    String? psychologistEmail,
    String? psychologistName,
    String? patientName,
    String? patientEmail,
    DateTime? startsAt,
    String? type,
    String? note,
    AppointmentStatus? status,
    double? driftIndex,
  }) {
    return Appointment(
      psychologistEmail: psychologistEmail ?? this.psychologistEmail,
      psychologistName: psychologistName ?? this.psychologistName,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      startsAt: startsAt ?? this.startsAt,
      type: type ?? this.type,
      note: note ?? this.note,
      status: status ?? this.status,
      driftIndex: driftIndex ?? this.driftIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'psychologistEmail': psychologistEmail,
        'psychologistName': psychologistName,
        'patientName': patientName,
        'patientEmail': patientEmail,
        'startsAt': startsAt.toIso8601String(),
        'type': type,
        'note': note,
        'status': status.name,
        'driftIndex': driftIndex,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    AppointmentStatus status = AppointmentStatus.pending;
    if (json.containsKey('status')) {
      status = AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      );
    } else if (json['confirmed'] as bool? ?? false) {
      status = AppointmentStatus.confirmed;
    }
    return Appointment(
      psychologistEmail: json['psychologistEmail'] as String? ?? '',
      psychologistName: json['psychologistName'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      patientEmail: json['patientEmail'] as String?,
      startsAt: DateTime.parse(json['startsAt'] as String),
      type: json['type'] as String? ?? '',
      note: json['note'] as String? ?? '',
      status: status,
      driftIndex: (json['driftIndex'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Represents a medication time for prescription reminders
class MedicationTime {
  final int hour;
  final int minute;

  const MedicationTime({
    required this.hour,
    required this.minute,
  });

  String toDisplayString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  MedicationTime copyWith({
    int? hour,
    int? minute,
  }) {
    return MedicationTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
      };

  factory MedicationTime.fromJson(Map<String, dynamic> json) => MedicationTime(
        hour: json['hour'] as int? ?? 0,
        minute: json['minute'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

class Prescription {
  final String id;
  final String patientName;
  final String? patientEmail;
  final String prescribedByName;
  final String prescribedByEmail;
  final List<String> medicines;
  final List<MedicationTime>
      reminderTimes; // Times to receive medication reminders
  final String note;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.patientName,
    this.patientEmail,
    required this.prescribedByName,
    required this.prescribedByEmail,
    required this.medicines,
    this.reminderTimes = const [],
    required this.note,
    required this.createdAt,
  });

  Prescription copyWith({
    String? id,
    String? patientName,
    String? patientEmail,
    String? prescribedByName,
    String? prescribedByEmail,
    List<String>? medicines,
    List<MedicationTime>? reminderTimes,
    String? note,
    DateTime? createdAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      prescribedByName: prescribedByName ?? this.prescribedByName,
      prescribedByEmail: prescribedByEmail ?? this.prescribedByEmail,
      medicines: medicines ?? this.medicines,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'patientEmail': patientEmail,
        'prescribedByName': prescribedByName,
        'prescribedByEmail': prescribedByEmail,
        'medicines': medicines,
        'reminderTimes': reminderTimes.map((time) => time.toJson()).toList(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        patientEmail: json['patientEmail'] as String?,
        prescribedByName: json['prescribedByName'] as String? ?? '',
        prescribedByEmail: json['prescribedByEmail'] as String? ?? '',
        medicines: (json['medicines'] as List<dynamic>? ?? []).cast<String>(),
        reminderTimes: (json['reminderTimes'] as List<dynamic>? ?? [])
            .map((item) => MedicationTime.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class MoodEntry {
  final DateTime createdAt;
  final int value;
  final String label;
  final String note;

  const MoodEntry({
    required this.createdAt,
    required this.value,
    required this.label,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'value': value,
        'label': label,
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        createdAt: DateTime.parse(json['createdAt'] as String),
        value: json['value'] as int? ?? 0,
        label: json['label'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );
}

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

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'content': content,
        'summary': summary,
        'sharedWithPsychologist': sharedWithPsychologist,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        createdAt: DateTime.parse(json['createdAt'] as String),
        content: json['content'] as String,
        summary: json['summary'] as String?,
        sharedWithPsychologist:
            json['sharedWithPsychologist'] as bool? ?? false,
      );
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        receiverId: json['receiverId'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}

class AppPsychologist {
  final String name;
  final String email;
  final String specialty;
  final String availability;
  final bool acceptingPatients;
  final double rating;

  const AppPsychologist({
    required this.name,
    required this.email,
    required this.specialty,
    required this.availability,
    this.acceptingPatients = true,
    this.rating = 4.8,
  });
}

const demoPsychologists = [
  AppPsychologist(
    name: 'Dr. Aisha Mehta',
    email: demoPsychologistEmail,
    specialty: 'Anxiety and young adult care',
    availability: 'Mon, Wed, Fri',
    rating: 4.9,
  ),
  AppPsychologist(
    name: 'Dr. Rohan Sen',
    email: 'rohan.sen@psychol.demo',
    specialty: 'CBT and stress management',
    availability: 'Tue, Thu',
    rating: 4.7,
  ),
  AppPsychologist(
    name: 'Dr. Kavya Iyer',
    email: 'kavya.iyer@psychol.demo',
    specialty: 'Mood support and sleep',
    availability: 'Weekends',
    rating: 4.8,
  ),
];

const demoMedicines = [
  'Prozac',
  'Valium',
  'Sertraline',
  'Lexapro',
  'Wellbutrin',
  'Zoloft',
  'Buspirone',
  'Melatonin',
  'Hydroxyzine',
];

class AppSession {
  final bool onboardingComplete;
  final bool appLockSet;
  final String? lockPin;
  final AppProfile? profile;
  final List<Appointment> appointments;
  final List<Prescription> prescriptions;
  final List<MoodEntry> moodEntries;
  final List<JournalEntry> journalEntries;
  final List<ChatMessage> messages;
  final bool isLocked;
  final DateTime? lastUnlockedAt;
  final int lockTimeoutMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<DriftHistoryEntry> driftHistory;
  final List<TypingHistoryEntry> typingHistory;
  final List<BreathingHistoryEntry> breathingHistory;
  final List<AdherenceRecord> adherenceHistory;
  final List<ClinicalNote> clinicalNotes;

  const AppSession({
    this.onboardingComplete = false,
    this.appLockSet = false,
    this.lockPin,
    this.profile,
    this.appointments = const [],
    this.prescriptions = const [],
    this.moodEntries = const [],
    this.journalEntries = const [],
    this.messages = const [],
    this.isLocked = false,
    this.lastUnlockedAt,
    this.lockTimeoutMinutes = 10,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.driftHistory = const [],
    this.typingHistory = const [],
    this.breathingHistory = const [],
    this.adherenceHistory = const [],
    this.clinicalNotes = const [],
  });

  AppSession copyWith({
    bool? onboardingComplete,
    bool? appLockSet,
    String? lockPin,
    AppProfile? profile,
    List<Appointment>? appointments,
    List<Prescription>? prescriptions,
    List<MoodEntry>? moodEntries,
    List<JournalEntry>? journalEntries,
    List<ChatMessage>? messages,
    bool? isLocked,
    DateTime? lastUnlockedAt,
    int? lockTimeoutMinutes,
    int? currentStreak,
    int? longestStreak,
    List<DriftHistoryEntry>? driftHistory,
    List<TypingHistoryEntry>? typingHistory,
    List<BreathingHistoryEntry>? breathingHistory,
    List<AdherenceRecord>? adherenceHistory,
    List<ClinicalNote>? clinicalNotes,
  }) {
    return AppSession(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      appLockSet: appLockSet ?? this.appLockSet,
      lockPin: lockPin ?? this.lockPin,
      profile: profile ?? this.profile,
      appointments: appointments ?? this.appointments,
      prescriptions: prescriptions ?? this.prescriptions,
      moodEntries: moodEntries ?? this.moodEntries,
      journalEntries: journalEntries ?? this.journalEntries,
      messages: messages ?? this.messages,
      isLocked: isLocked ?? this.isLocked,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      driftHistory: driftHistory ?? this.driftHistory,
      typingHistory: typingHistory ?? this.typingHistory,
      breathingHistory: breathingHistory ?? this.breathingHistory,
      adherenceHistory: adherenceHistory ?? this.adherenceHistory,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingComplete': onboardingComplete,
        'appLockSet': appLockSet,
        'lockPin': lockPin,
        'profile': profile?.toJson(),
        'appointments':
            appointments.map((appointment) => appointment.toJson()).toList(),
        'prescriptions':
            prescriptions.map((prescription) => prescription.toJson()).toList(),
        'moodEntries': moodEntries.map((entry) => entry.toJson()).toList(),
        'journalEntries':
            journalEntries.map((entry) => entry.toJson()).toList(),
        'messages': messages.map((message) => message.toJson()).toList(),
        'isLocked': isLocked,
        'lastUnlockedAt': lastUnlockedAt?.toIso8601String(),
        'lockTimeoutMinutes': lockTimeoutMinutes,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'driftHistory': driftHistory.map((e) => e.toJson()).toList(),
        'typingHistory': typingHistory.map((e) => e.toJson()).toList(),
        'breathingHistory': breathingHistory.map((e) => e.toJson()).toList(),
        'adherenceHistory': adherenceHistory.map((e) => e.toJson()).toList(),
        'clinicalNotes': clinicalNotes.map((e) => e.toJson()).toList(),
      };

  factory AppSession.fromJson(Map<String, dynamic> json) => AppSession(
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
        appLockSet: json['appLockSet'] as bool? ?? false,
        lockPin: json['lockPin'] as String?,
        profile: json['profile'] == null
            ? null
            : AppProfile.fromJson(
                Map<String, dynamic>.from(json['profile'] as Map),
              ),
        appointments: (json['appointments'] as List<dynamic>? ?? [])
            .map((item) => Appointment.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        prescriptions: (json['prescriptions'] as List<dynamic>? ?? [])
            .map((item) => Prescription.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        moodEntries: (json['moodEntries'] as List<dynamic>? ?? [])
            .map((item) => MoodEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        journalEntries: (json['journalEntries'] as List<dynamic>? ?? [])
            .map((item) => JournalEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((item) => ChatMessage.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        isLocked: json['isLocked'] as bool? ?? false,
        lastUnlockedAt: json['lastUnlockedAt'] == null
            ? null
            : DateTime.parse(json['lastUnlockedAt'] as String),
        lockTimeoutMinutes: json['lockTimeoutMinutes'] as int? ?? 10,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        driftHistory: (json['driftHistory'] as List<dynamic>? ?? [])
            .map((item) => DriftHistoryEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        typingHistory: (json['typingHistory'] as List<dynamic>? ?? [])
            .map((item) => TypingHistoryEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        breathingHistory: (json['breathingHistory'] as List<dynamic>? ?? [])
            .map((item) => BreathingHistoryEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        adherenceHistory: (json['adherenceHistory'] as List<dynamic>? ?? [])
            .map((item) => AdherenceRecord.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        clinicalNotes: (json['clinicalNotes'] as List<dynamic>? ?? [])
            .map((item) => ClinicalNote.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
      );
}

final initialAppSessionProvider = Provider<AppSession>(
  (ref) => const AppSession(),
);

final appSessionStoreProvider = Provider<AppSessionStore>(
  (ref) => const AppSessionStore(),
);

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSession>(
  (ref) => AppSessionNotifier(
    initialSession: ref.watch(initialAppSessionProvider),
    store: ref.watch(appSessionStoreProvider),
  ),
);

class AppSessionNotifier extends StateNotifier<AppSession> {
  final AppSessionStore _store;

  AppSessionNotifier({
    required AppSession initialSession,
    required AppSessionStore store,
  })  : _store = store,
        super(initialSession);

  void recalculateDriftIndex(String source) {
    final profile = state.profile;
    if (profile == null) return;

    double drift = 0.35; // baseline

    // 1. Mood Component (25% weight)
    if (state.moodEntries.isNotEmpty) {
      final recentMoods = state.moodEntries.length > 7
          ? state.moodEntries.sublist(state.moodEntries.length - 7)
          : state.moodEntries;
      double sum = 0.0;
      for (var entry in recentMoods) {
        sum += entry.value;
      }
      double avg = sum / recentMoods.length;
      double moodScore = (5.0 - avg) / 4.0;
      drift += moodScore * 0.25;
    } else {
      drift += 0.1 * 0.25;
    }

    // 2. Typing Component (25% weight)
    if (state.typingHistory.isNotEmpty) {
      final recentTyping = state.typingHistory.length > 7
          ? state.typingHistory.sublist(state.typingHistory.length - 7)
          : state.typingHistory;
      double sum = 0.0;
      for (var entry in recentTyping) {
        sum += entry.stressScore;
      }
      double avg = sum / recentTyping.length;
      drift += avg * 0.25;
    } else {
      drift += 0.1 * 0.25;
    }

    // 3. Journal Sentiment (20% weight / adjustment)
    double journalAdj = 0.0;
    if (state.journalEntries.isNotEmpty) {
      final recentJournals = state.journalEntries.length > 7
          ? state.journalEntries.sublist(state.journalEntries.length - 7)
          : state.journalEntries;
      for (var entry in recentJournals) {
        final content = entry.content.toLowerCase();
        int pos = 0;
        int neg = 0;
        final posWords = ["calm", "happy", "steady", "peaceful", "relaxed", "joy", "excited", "positive", "content", "great", "better", "excellent", "good"];
        final negWords = ["anxiety", "anxious", "overthinking", "panic", "stressed", "stress", "sad", "depressed", "terrible", "bad", "lonely", "fear", "scared", "angry", "worry", "worried"];
        for (var w in posWords) {
          if (content.contains(w)) pos++;
        }
        for (var w in negWords) {
          if (content.contains(w)) neg++;
        }
        if (neg > pos) {
          journalAdj += 0.1;
        } else if (pos > neg) {
          journalAdj -= 0.1;
        }
      }
      drift += journalAdj.clamp(-0.2, 0.2);
    }

    // 4. Medication Adherence (15% weight)
    double medAdj = 0.0;
    if (state.adherenceHistory.isNotEmpty) {
      final recentAdherence = state.adherenceHistory.length > 7
          ? state.adherenceHistory.sublist(state.adherenceHistory.length - 7)
          : state.adherenceHistory;
      int missed = recentAdherence.where((r) => !r.taken).length;
      if (missed == 0) {
        medAdj = -0.15;
      } else {
        medAdj = missed * 0.10;
      }
      drift += medAdj.clamp(-0.15, 0.35);
    }

    // 5. Appointments (15% weight)
    double apptAdj = 0.0;
    if (state.appointments.isNotEmpty) {
      for (var appt in state.appointments) {
        if (appt.status == AppointmentStatus.completed) {
          apptAdj -= 0.05;
        } else if (appt.status == AppointmentStatus.cancelled) {
          apptAdj += 0.15;
        }
      }
      drift += apptAdj.clamp(-0.15, 0.35);
    }

    // 6. Breathing Sessions relief
    if (state.breathingHistory.isNotEmpty) {
      drift -= 0.06 * state.breathingHistory.length;
    }

    drift = drift.clamp(0.0, 1.0);

    final newHistoryEntry = DriftHistoryEntry(
      driftValue: drift,
      timestamp: DateTime.now(),
      source: source,
    );

    final updatedHistory = [...state.driftHistory, newHistoryEntry];
    
    state = state.copyWith(
      profile: profile.copyWith(driftIndex: drift),
      driftHistory: updatedHistory,
    );
    _persist();
  }

  void completeOnboarding({
    required AppProfile profile,
    required String lockPin,
  }) {
    state = state.copyWith(
      onboardingComplete: true,
      appLockSet: true,
      lockPin: lockPin,
      profile: profile,
      isLocked: false,
    );
    recalculateDriftIndex('Onboarding Complete');
  }

  void addAppointment(Appointment appointment) {
    final updated = [
      ...state.appointments,
      appointment,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    state = state.copyWith(appointments: updated);
    recalculateDriftIndex('Appointment Scheduled');
  }

  void approveAppointment(Appointment appointment) {
    final updated = state.appointments
        .map((item) =>
            identical(item, appointment) || _sameAppointment(item, appointment)
                ? item.copyWith(status: AppointmentStatus.confirmed)
                : item)
        .toList();
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void completeAppointment(Appointment appointment) {
    final updated = state.appointments
        .map((item) =>
            identical(item, appointment) || _sameAppointment(item, appointment)
                ? item.copyWith(status: AppointmentStatus.completed)
                : item)
        .toList();
    state = state.copyWith(appointments: updated);
    recalculateDriftIndex('Appointment Completed');
  }

  void cancelAppointment(Appointment appointment) {
    final timeDiff = appointment.startsAt.difference(DateTime.now());
    final isLateCancel = timeDiff.inHours < 24;

    final updated = state.appointments
        .map((item) =>
            identical(item, appointment) || _sameAppointment(item, appointment)
                ? item.copyWith(status: AppointmentStatus.cancelled)
                : item)
        .toList();
    state = state.copyWith(appointments: updated);

    if (isLateCancel) {
      recalculateDriftIndex('Late Appointment Cancellation');
    } else {
      recalculateDriftIndex('Appointment Cancellation');
    }
  }

  void removeAppointment(Appointment appointment) {
    final updated = state.appointments
        .where((item) => !_sameAppointment(item, appointment))
        .toList();
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void addPrescription(Prescription prescription) {
    final updated = [...state.prescriptions, prescription];
    state = state.copyWith(prescriptions: updated);
    _persist();
  }

  void removePrescription(String prescriptionId) {
    final updated =
        state.prescriptions.where((item) => item.id != prescriptionId).toList();
    state = state.copyWith(prescriptions: updated);
    _persist();
  }

  void updatePrescription(Prescription prescription) {
    final updated = state.prescriptions
        .map((item) => item.id == prescription.id ? prescription : item)
        .toList();
    state = state.copyWith(prescriptions: updated);
    _persist();
  }

  void updateProfile(AppProfile profile) {
    state = state.copyWith(profile: profile);
    _persist();
  }

  void addJournalEntry(String content) {
    final entry = JournalEntry(
      createdAt: DateTime.now(),
      content: content,
    );
    final updated = [...state.journalEntries, entry];
    state = state.copyWith(journalEntries: updated);
    recalculateDriftIndex('Journal Entry');
  }

  void updateJournalEntry(JournalEntry entry) {
    final updated = state.journalEntries.map((e) {
      if (e.createdAt == entry.createdAt) {
        return entry;
      }
      return e;
    }).toList();
    state = state.copyWith(journalEntries: updated);
    recalculateDriftIndex('Journal Entry');
  }

  void removeJournalEntry(JournalEntry entry) {
    final updated = state.journalEntries
        .where((e) => e.createdAt != entry.createdAt)
        .toList();
    state = state.copyWith(journalEntries: updated);
    recalculateDriftIndex('Journal Entry Removed');
  }

  void addMessage(ChatMessage message) {
    final updated = [...state.messages, message]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    state = state.copyWith(messages: updated);
    _persist();
  }

  void markMessagesAsRead(String fromSenderId) {
    final updated = state.messages.map((m) {
      if (m.senderId == fromSenderId && !m.isRead) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
    _persist();
  }

  void updateLockTimeout(int minutes) {
    state = state.copyWith(lockTimeoutMinutes: minutes);
    _persist();
  }

  void lock() {
    if (state.onboardingComplete && state.appLockSet && !state.isLocked) {
      final lastUnlockedAt = state.lastUnlockedAt;
      final timeout = Duration(minutes: state.lockTimeoutMinutes);
      if (lastUnlockedAt != null &&
          DateTime.now().difference(lastUnlockedAt) < timeout) {
        return;
      }
      state = state.copyWith(isLocked: true);
    }
  }

  bool unlock(String pin) {
    if (pin.trim() == state.lockPin) {
      state = state.copyWith(isLocked: false, lastUnlockedAt: DateTime.now());
      _persist();
      return true;
    }
    return false;
  }

  void addMoodEntry(MoodEntry entry) {
    final updated = [...state.moodEntries, entry];
    final streaks = _calculateStreaks(updated);
    state = state.copyWith(
      moodEntries: updated,
      currentStreak: streaks['current']!,
      longestStreak: streaks['longest']!,
    );
    recalculateDriftIndex('Mood Check-in');
  }

  void addTypingHistoryEntry(TypingHistoryEntry entry) {
    state = state.copyWith(typingHistory: [...state.typingHistory, entry]);
    recalculateDriftIndex('Typing Stress Test');
  }

  void addBreathingHistoryEntry(BreathingHistoryEntry entry) {
    state = state.copyWith(breathingHistory: [...state.breathingHistory, entry]);
    recalculateDriftIndex('Breathing Session');
  }

  void logMedicationAdherence(AdherenceRecord record) {
    state = state.copyWith(adherenceHistory: [...state.adherenceHistory, record]);
    recalculateDriftIndex('Medication Compliance');
  }

  void addClinicalNote(ClinicalNote note) {
    state = state.copyWith(clinicalNotes: [...state.clinicalNotes, note]);
    _persist();
  }

  void updatePatientStatus(PatientStatus status) {
    final profile = state.profile;
    if (profile != null) {
      state = state.copyWith(profile: profile.copyWith(status: status));
      _persist();
    }
  }

  Map<String, int> _calculateStreaks(List<MoodEntry> entries) {
    if (entries.isEmpty) return {'current': 0, 'longest': 0};

    final days = entries
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort();

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final lastDay = days.last;

    if (lastDay == today ||
        lastDay == today.subtract(const Duration(days: 1))) {
      currentStreak = 1;
      for (int i = days.length - 2; i >= 0; i--) {
        if (days[i + 1].difference(days[i]).inDays == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  void logout() {
    state = const AppSession(); // Reset to initial state
    _persist();
  }

  Future<void> _persist() async {
    await _store.save(state);
  }

  bool _sameAppointment(Appointment a, Appointment b) {
    return a.psychologistEmail == b.psychologistEmail &&
        a.patientName == b.patientName &&
        a.startsAt == b.startsAt &&
        a.type == b.type;
  }
}
