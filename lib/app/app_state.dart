import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/app_session_store.dart';

const demoPsychologistEmail = 'panipuri@macxcode';

enum UserRole { psychologist, patient }

class AppProfile {
  final UserRole role;
  final String name;
  final DateTime? dateOfBirth;
  final String? email;
  final String? psychologistEmail;
  final int avatarIconCodePoint;
  final int avatarColorValue;

  const AppProfile({
    required this.role,
    required this.name,
    this.dateOfBirth,
    this.email,
    this.psychologistEmail,
    this.avatarIconCodePoint = 0xe7fd,
    this.avatarColorValue = 0xFF8B5CF6,
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
  }) {
    return AppProfile(
      role: role ?? this.role,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      psychologistEmail: psychologistEmail ?? this.psychologistEmail,
      avatarIconCodePoint: avatarIconCodePoint ?? this.avatarIconCodePoint,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }
}

class Appointment {
  final String psychologistEmail;
  final String psychologistName;
  final DateTime startsAt;
  final String type;
  final String note;
  final bool confirmed;

  const Appointment({
    required this.psychologistEmail,
    required this.psychologistName,
    required this.startsAt,
    required this.type,
    required this.note,
    this.confirmed = true,
  });
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
}

class AppPsychologist {
  final String name;
  final String email;
  final String specialty;
  final String availability;
  final bool acceptingPatients;

  const AppPsychologist({
    required this.name,
    required this.email,
    required this.specialty,
    required this.availability,
    this.acceptingPatients = true,
  });
}

const demoPsychologists = [
  AppPsychologist(
    name: 'Dr. Aisha Mehta',
    email: demoPsychologistEmail,
    specialty: 'Anxiety and young adult care',
    availability: 'Mon, Wed, Fri',
  ),
  AppPsychologist(
    name: 'Dr. Rohan Sen',
    email: 'rohan.sen@psychol.demo',
    specialty: 'CBT and stress management',
    availability: 'Tue, Thu',
  ),
  AppPsychologist(
    name: 'Dr. Kavya Iyer',
    email: 'kavya.iyer@psychol.demo',
    specialty: 'Mood support and sleep',
    availability: 'Weekends',
  ),
];

class AppSession {
  final bool onboardingComplete;
  final bool appLockSet;
  final String? lockPin;
  final AppProfile? profile;
  final List<Appointment> appointments;
  final List<MoodEntry> moodEntries;
  final bool isLocked;
  final DateTime? lastUnlockedAt;
  final int lockTimeoutMinutes;

  const AppSession({
    this.onboardingComplete = false,
    this.appLockSet = false,
    this.lockPin,
    this.profile,
    this.appointments = const [],
    this.moodEntries = const [],
    this.isLocked = false,
    this.lastUnlockedAt,
    this.lockTimeoutMinutes = 10,
  });

  AppSession copyWith({
    bool? onboardingComplete,
    bool? appLockSet,
    String? lockPin,
    AppProfile? profile,
    List<Appointment>? appointments,
    List<MoodEntry>? moodEntries,
    bool? isLocked,
    DateTime? lastUnlockedAt,
    int? lockTimeoutMinutes,
  }) {
    return AppSession(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      appLockSet: appLockSet ?? this.appLockSet,
      lockPin: lockPin ?? this.lockPin,
      profile: profile ?? this.profile,
      appointments: appointments ?? this.appointments,
      moodEntries: moodEntries ?? this.moodEntries,
      isLocked: isLocked ?? this.isLocked,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
    );
  }
}

final initialAppSessionProvider = Provider<AppSession>(
  (ref) => const AppSession(),
);

final appSessionStoreProvider = Provider<AppSessionStore>(
  (ref) => AppSessionStore(),
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
    _persist();
  }

  void addAppointment(Appointment appointment) {
    final updated = [
      ...state.appointments.where(
        (item) => item.startsAt.isBefore(DateTime.now()),
      ),
      appointment,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    state = state.copyWith(appointments: updated);
    _persist();
  }

  void addMoodEntry(MoodEntry entry) {
    final updated = [...state.moodEntries, entry]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = state.copyWith(moodEntries: updated);
    _persist();
  }

  void updateProfile(AppProfile profile) {
    state = state.copyWith(profile: profile);
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

  Future<void> _persist() async {
    await _store.save(state);
  }
}
