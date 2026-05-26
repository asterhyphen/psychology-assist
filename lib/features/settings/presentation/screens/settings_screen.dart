import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/app_state.dart';
import '../../../../app/home_screen.dart';
import '../../../../app/theme_provider.dart';
import '../../../../app/user_preferences_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/nfc_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../../core/widgets/animations.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

part '../widgets/settings_section.dart';
part '../widgets/theme_button.dart';
part '../widgets/settings_toggle.dart';
part '../widgets/settings_info.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: StaggeredAnimationBuilder(
            duration: const Duration(milliseconds: 420),
            delay: const Duration(milliseconds: 45),
            children: [
              if (profile != null) ...[
                _SettingsSection(
                  title: 'Profile',
                  children: [
                    SmoothCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(profile.avatarColorValue),
                            backgroundImage: profile.profileImagePath == null
                                ? null
                                : FileImage(File(profile.profileImagePath!)),
                            child: profile.profileImagePath == null
                                ? Icon(
                                    _avatarIconFor(
                                      profile.avatarIconCodePoint,
                                    ),
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: theme.textTheme.labelLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.role == UserRole.psychologist
                                      ? profile.email ?? 'Psychologist'
                                      : profile.psychologistEmail ??
                                          'No psychologist linked',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit profile',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editProfile(profile),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Theme Section
              _SettingsSection(
                title: 'Appearance',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ThemeButton(
                                title: 'Light',
                                icon: Icons.light_mode,
                                isSelected: currentTheme == AppThemeMode.light,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.light);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ThemeButton(
                                title: 'Dark',
                                icon: Icons.dark_mode,
                                isSelected: currentTheme == AppThemeMode.dark,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.dark);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ThemeButton(
                                title: 'Journal',
                                icon: Icons.edit_note,
                                isSelected:
                                    currentTheme == AppThemeMode.journal,
                                onTap: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(AppThemeMode.journal);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: SizedBox()),
                            const SizedBox(width: 12),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _SettingsSection(
                title: 'Notifications',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SettingsToggle(
                          icon: Icons.notifications,
                          title: 'Enable Notifications',
                          subtitle: 'Receive mood check-ins and reminders',
                          value: preferences.notificationsEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateNotificationsEnabled(value);
                            if (!value) {
                              NotificationService().cancelAllNotifications();
                            } else if (preferences.moodCheckInsEnabled) {
                              _scheduleMoodCheckIns(
                                preferences.moodCheckInInterval,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        _SettingsToggle(
                          icon: Icons.poll,
                          title: 'Mood Check-ins',
                          subtitle:
                              'Random check-ins to log your mood throughout the day',
                          value: preferences.moodCheckInsEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateMoodCheckInsEnabled(value);
                            if (value) {
                              _scheduleMoodCheckIns(
                                preferences.moodCheckInInterval,
                              );
                            } else {
                              NotificationService().cancelMoodCheckIns();
                            }
                          },
                          enabled: preferences.notificationsEnabled,
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        _SettingsToggle(
                          icon: Icons.medication,
                          title: 'Medication Reminders',
                          subtitle:
                              'Reminders to take your prescribed medication',
                          value: preferences.medicationRemindersEnabled,
                          onChanged: (value) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updateMedicationRemindersEnabled(value);
                            if (value) {
                              _scheduleMedicationReminders();
                            } else {
                              NotificationService().cancelMedicationReminders();
                            }
                          },
                          enabled: preferences.notificationsEnabled,
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: theme.dividerColor),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.notifications_active_outlined),
                          title: const Text('Alert center'),
                          subtitle:
                              const Text('Test and schedule Calmora alerts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (preferences.moodCheckInsEnabled)
                    SmoothCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderColor:
                          theme.colorScheme.primary.withValues(alpha: 0.18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Check-in Frequency',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: theme.textTheme.labelLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _FrequencyOption(
                                hours: 2,
                                label: 'Often',
                                icon: Icons.flash_on_rounded,
                                color: AppColors.info,
                              ),
                              _FrequencyOption(
                                hours: 4,
                                label: 'Balanced',
                                icon: Icons.spa_rounded,
                                color: AppColors.success,
                              ),
                              _FrequencyOption(
                                hours: 6,
                                label: 'Easy',
                                icon: Icons.wb_sunny_outlined,
                                color: AppColors.warning,
                              ),
                              _FrequencyOption(
                                hours: 12,
                                label: 'Light',
                                icon: Icons.nightlight_round,
                                color: AppColors.neonViolet,
                              ),
                            ]
                                .map(
                                  (option) => _FrequencyChoice(
                                    option: option,
                                    selected: preferences.moodCheckInInterval ==
                                        option.hours,
                                    onTap: () {
                                      ref
                                          .read(
                                            userPreferencesProvider.notifier,
                                          )
                                          .updateMoodCheckInInterval(
                                            option.hours,
                                          );
                                      _scheduleMoodCheckIns(option.hours);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Randomized during the day, about every ${preferences.moodCheckInInterval} hours.',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.68,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              _SettingsSection(
                title: 'NFC Integration',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Program an NFC tag to quickly launch a feature by tapping it against your phone.',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _showNfcProgrammingDialog,
                          icon: const Icon(Icons.nfc),
                          label: const Text('Program NFC Tag'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _SettingsSection(
                title: 'App Lock',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIN timeout',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: session.lockTimeoutMinutes.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: '${session.lockTimeoutMinutes} min',
                          onChanged: (value) {
                            ref
                                .read(appSessionProvider.notifier)
                                .updateLockTimeout(value.toInt());
                          },
                        ),
                        Text(
                          'Ask for PIN after ${session.lockTimeoutMinutes} minutes away from the app.',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Privacy Section
              _SettingsSection(
                title: 'Privacy & Data',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.success.withValues(alpha: 0.05),
                    borderColor: AppColors.success.withValues(alpha: 0.2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Data is Private',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '✓ All data stored locally on your device\n✓ End-to-end encrypted\n✓ Never shared or sold\n✓ You have full control',
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmoothCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showPrivacyPolicy,
                        ),
                        Divider(height: 1, color: theme.dividerColor),
                        ListTile(
                          leading: const Icon(Icons.bug_report_outlined),
                          title: const Text('Report a Bug'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showBugReport,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _SettingsSection(
                title: 'Account',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withValues(alpha: 0.12),
                    borderColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          profile?.role == UserRole.psychologist
                              ? 'Switch to Patient View'
                              : 'Switch to Psychologist View',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.role == UserRole.psychologist
                              ? 'View the app as a patient'
                              : 'View patient requests and manage appointments as Dr. Panipuri',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme.secondaryContainer
                                .withValues(alpha: 0.9),
                          ),
                          onPressed: () {
                            if (profile?.role == UserRole.psychologist) {
                              ref
                                  .read(appSessionProvider.notifier)
                                  .updateProfile(
                                    AppProfile(
                                      role: UserRole.patient,
                                      name: 'Demo Patient',
                                      email: 'patient@example.com',
                                      psychologistEmail: demoPsychologistEmail,
                                      avatarColorValue: 0xFF8B5CF6,
                                      avatarIconCodePoint:
                                          Icons.person.codePoint,
                                    ),
                                  );
                              ref.read(selectedTabProvider.notifier).state = 0;
                              AppSnackBar.showSuccess(
                                context,
                                title: 'Switched to Patient',
                                message: 'You are now viewing as Demo Patient.',
                              );
                            } else {
                              ref
                                  .read(appSessionProvider.notifier)
                                  .updateProfile(
                                    AppProfile(
                                      role: UserRole.psychologist,
                                      name: 'Dr. Panipuri',
                                      email: demoPsychologistEmail,
                                      avatarColorValue: 0xFF4A6CF7,
                                      avatarIconCodePoint:
                                          Icons.psychology_alt.codePoint,
                                    ),
                                  );
                              ref.read(selectedTabProvider.notifier).state = 0;
                              AppSnackBar.showSuccess(
                                context,
                                title: 'Switched to Psychologist',
                                message: 'You are now viewing as Dr. Panipuri.',
                              );
                            }
                          },
                          icon: Icon(
                            profile?.role == UserRole.psychologist
                                ? Icons.person
                                : Icons.switch_account,
                          ),
                          label: Text(
                            profile?.role == UserRole.psychologist
                                ? 'Switch to Patient'
                                : 'Switch to Psychologist',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha: 0.12),
                    borderColor: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Switch account without deleting data',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer
                                .withValues(alpha: 0.9),
                          ),
                          onPressed: () {
                            ref.read(appSessionProvider.notifier).logout();
                            ref.read(selectedTabProvider.notifier).state = 0;
                            AppSnackBar.showInfo(
                              context,
                              title: 'Logged out',
                              message:
                                  'You can now sign in again as a patient or psychologist.',
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Log out / switch account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              _SettingsSection(
                title: 'About',
                children: [
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SettingsInfo(
                          label: 'App Version',
                          value: '1.0.0',
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 12),
                        const _SettingsInfo(
                          label: 'Built with',
                          value: 'Flutter + Riverpod',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Made with care for mental wellness',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleMoodCheckIns(int hours) async {
    await NotificationService().scheduleMoodCheckInsEvery(hours);
  }

  Future<void> _scheduleMedicationReminders() async {
    final prescriptions = ref.read(appSessionProvider).prescriptions;
    if (prescriptions.isNotEmpty) {
      final medicines =
          prescriptions.expand((p) => p.medicines).toSet().toList();
      final times = prescriptions
          .expand((p) =>
              p.reminderTimes.map((t) => (hour: t.hour, minute: t.minute)))
          .toSet()
          .toList();
      await NotificationService().scheduleMedicationReminders(
        medicines: medicines,
        times: times,
      );
    }
  }

  void _editProfile(AppProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(
      text: profile.role == UserRole.psychologist
          ? profile.email
          : profile.psychologistEmail,
    );
    var iconCodePoint = profile.avatarIconCodePoint;
    var colorValue = profile.avatarColorValue;
    var profileImagePath = profile.profileImagePath;
    final icons = [
      Icons.person,
      Icons.self_improvement,
      Icons.favorite,
      Icons.psychology_alt,
    ];
    final colors = [
      AppColors.neonViolet,
      const Color(0xFFB7C97B),
      AppColors.success,
      AppColors.info,
    ];

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: profile.role == UserRole.psychologist
                        ? 'Professional email'
                        : 'Psychologist email',
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(colorValue),
                        backgroundImage: profileImagePath == null
                            ? null
                            : FileImage(File(profileImagePath!)),
                        child: profileImagePath == null
                            ? Icon(
                                _avatarIconFor(iconCodePoint),
                                color: Colors.white,
                                size: 34,
                              )
                            : null,
                      ),
                      IconButton.filled(
                        tooltip: 'Choose from gallery',
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 82,
                            maxWidth: 900,
                          );
                          if (picked != null) {
                            setDialogState(
                              () => profileImagePath = picked.path,
                            );
                          }
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map(
                        (icon) => ChoiceChip(
                          selected: iconCodePoint == icon.codePoint,
                          avatar: Icon(icon, size: 18),
                          label: const Text(''),
                          onSelected: (_) => setDialogState(
                            () => iconCodePoint = icon.codePoint,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: colors
                      .map(
                        (color) => ChoiceChip(
                          selected: colorValue == color.toARGB32(),
                          label: CircleAvatar(
                            radius: 9,
                            backgroundColor: color,
                          ),
                          onSelected: (_) => setDialogState(
                            () => colorValue = color.toARGB32(),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = profile.copyWith(
                  name: nameController.text.trim(),
                  email: profile.role == UserRole.psychologist
                      ? emailController.text.trim()
                      : profile.email,
                  psychologistEmail: profile.role == UserRole.patient
                      ? emailController.text.trim()
                      : profile.psychologistEmail,
                  avatarIconCodePoint: iconCodePoint,
                  avatarColorValue: colorValue,
                  profileImagePath: profileImagePath,
                );
                ref.read(appSessionProvider.notifier).updateProfile(updated);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Calmora stores profile, moods, PIN settings, and appointments locally on this device for this prototype. Do not enter emergency or highly sensitive clinical information until production security and consent flows are finalized.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showNfcProgrammingDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Program NFC Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_stories),
                title: const Text('Open Journal'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startNfcWriteSession('journal');
                },
              ),
              ListTile(
                leading: const Icon(Icons.mood),
                title: const Text('Log Mood'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startNfcWriteSession('mood');
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Book Appointment'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startNfcWriteSession('appointment');
                },
              ),
              ListTile(
                leading: const Icon(Icons.sos, color: Colors.red),
                title: const Text('SOS Alert'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startNfcWriteSession('sos');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNfcWriteSession(String featureId) async {
    final available = await NfcService().isAvailable();
    if (!available) {
      if (mounted) {
        AppSnackBar.showError(context,
            title: 'NFC not available',
            message: 'Your device does not support NFC or it is turned off.');
      }
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            title: Text('Ready to Write'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.nfc, size: 64),
                SizedBox(height: 16),
                Text('Hold your device near an NFC tag...'),
              ],
            ),
          );
        },
      );
    }

    final success = await NfcService().writeFeatureToTag(featureId);

    if (mounted) {
      Navigator.of(context).pop(); // dismiss writing dialog
      if (success) {
        AppSnackBar.showSuccess(context,
            title: 'Success', message: 'NFC tag programmed successfully!');
      } else {
        AppSnackBar.showError(context,
            title: 'Error', message: 'Failed to program NFC tag.');
      }
    }
  }

  void _showBugReport() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'Send issue details to support@calmora.demo with your device, steps to reproduce, and screenshots if available.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  IconData _avatarIconFor(int codePoint) {
    const icons = [
      Icons.person,
      Icons.self_improvement,
      Icons.favorite,
      Icons.psychology_alt,
    ];
    return icons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.person,
    );
  }
}

class _FrequencyOption {
  final int hours;
  final String label;
  final IconData icon;
  final Color color;

  const _FrequencyOption({
    required this.hours,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _FrequencyChoice extends StatelessWidget {
  final _FrequencyOption option;
  final bool selected;
  final VoidCallback onTap;

  const _FrequencyChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onColor = theme.colorScheme.onSurface;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128, maxWidth: 180),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: option.color.withValues(alpha: selected ? 0.20 : 0.09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: option.color.withValues(alpha: selected ? 0.80 : 0.24),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(option.icon, color: option.color, size: 20),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: option.color,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                option.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Every ${option.hours}h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onColor.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings section header
