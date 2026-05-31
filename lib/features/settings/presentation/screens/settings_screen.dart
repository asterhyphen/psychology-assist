import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/app_state.dart';
import '../../../../app/home_screen.dart';
import '../../../../app/theme_provider.dart';
import '../../../../app/user_preferences_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/nfc_service.dart';
import '../../../../core/services/ai_settings.dart';
import '../../../../core/services/ai_service.dart';
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
  final TextEditingController _geminiController = TextEditingController();
  final TextEditingController _ollamaEndpointController = TextEditingController();
  final TextEditingController _ollamaModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _animationController.forward();
    // Load stored Gemini key into controller if present
    Future.microtask(() async {
      final key = await ref.read(geminiKeyProvider.future);
      if (key != null && _geminiController.text.isEmpty) {
        _geminiController.text = key;
      }
      final endpoint = await ref.read(ollamaEndpointProvider.future);
      if (_ollamaEndpointController.text.isEmpty) {
        _ollamaEndpointController.text = endpoint;
      }
      final model = await ref.read(ollamaModelProvider.future);
      if (_ollamaModelController.text.isEmpty) {
        _ollamaModelController.text = model;
      }
    });
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _ollamaEndpointController.dispose();
    _ollamaModelController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showGeminiSavedSnackBar() {
    AppSnackBar.showSuccess(
      context,
      title: 'Saved',
      message: 'Gemini API key saved securely.',
    );
  }

  void _showGeminiRemovedSnackBar() {
    AppSnackBar.showInfo(
      context,
      title: 'Removed',
      message: 'Gemini API key removed.',
    );
  }

  void _showOllamaEndpointSavedSnackBar() {
    AppSnackBar.showSuccess(
      context,
      title: 'Saved',
      message: 'Ollama Server URL saved.',
    );
  }

  void _showOllamaEndpointRemovedSnackBar() {
    AppSnackBar.showInfo(
      context,
      title: 'Removed',
      message: 'Ollama Server URL reset to default.',
    );
  }

  void _showOllamaModelSavedSnackBar() {
    AppSnackBar.showSuccess(
      context,
      title: 'Saved',
      message: 'Ollama Model Name saved.',
    );
  }

  void _showOllamaModelRemovedSnackBar() {
    AppSnackBar.showInfo(
      context,
      title: 'Removed',
      message: 'Ollama Model Name reset to default.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final session = ref.watch(appSessionProvider);
    final profile = session.profile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Atmospheric Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.brightness == Brightness.dark
                      ? [
                          const Color(0xFF080C11),
                          const Color(0xFF0E121E),
                        ]
                      : [
                          const Color(0xFFF7F8FC),
                          const Color(0xFFF0EFF5),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top-left soft ambient teal glow
          Positioned(
            top: -120,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0FA58A).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.08 : 0.05,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 85, sigmaY: 85),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Mid-right soft ambient indigo glow
          Positioned(
            top: 350,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.06 : 0.04,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Scrollable body content
          Positioned.fill(
            child: SingleChildScrollView(
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
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0FA58A),
                                        Color(0xFF8B5CF6)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6)
                                            .withValues(alpha: 0.18),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                        Color(profile.avatarColorValue),
                                    backgroundImage: profile.profileImagePath ==
                                            null
                                        ? null
                                        : FileImage(
                                            File(profile.profileImagePath!)),
                                    child: profile.profileImagePath == null
                                        ? Icon(
                                            _avatarIconFor(
                                              profile.avatarIconCodePoint,
                                            ),
                                            color: Colors.white,
                                            size: 26,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style:
                                            AppTypography.labelLarge.copyWith(
                                          color:
                                              theme.textTheme.labelLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile.role == UserRole.psychologist
                                            ? profile.email ?? 'Psychologist'
                                            : profile.psychologistEmail ??
                                                'No psychologist linked',
                                        style: AppTypography.bodySmall.copyWith(
                                          color:
                                              theme.textTheme.bodySmall?.color,
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
                                      isSelected:
                                          currentTheme == AppThemeMode.light,
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
                                      isSelected:
                                          currentTheme == AppThemeMode.dark,
                                      onTap: () {
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .setThemeMode(AppThemeMode.dark);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                subtitle:
                                    'Receive mood check-ins and reminders',
                                value: preferences.notificationsEnabled,
                                onChanged: (value) {
                                  ref
                                      .read(userPreferencesProvider.notifier)
                                      .updateNotificationsEnabled(value);
                                  if (!value) {
                                    NotificationService()
                                        .cancelAllNotifications();
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
                                    NotificationService()
                                        .cancelMedicationReminders();
                                  }
                                },
                                enabled: preferences.notificationsEnabled,
                              ),
                              const SizedBox(height: 16),
                              Divider(height: 1, color: theme.dividerColor),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                    Icons.notifications_active_outlined),
                                title: const Text('Alert center'),
                                subtitle: const Text(
                                    'Test and schedule Calmora alerts'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const NotificationsScreen(),
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
                            padding: const EdgeInsets.all(16),
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.04),
                            borderColor: theme.colorScheme.primary
                                .withValues(alpha: 0.18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check-in Frequency',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: theme.textTheme.labelLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10.0,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 24.0,
                                    ),
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor: theme
                                        .colorScheme.primary
                                        .withValues(alpha: 0.16),
                                    thumbColor: theme.colorScheme.primary,
                                    overlayColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: Slider(
                                    value: preferences.moodCheckInInterval
                                        .toDouble(),
                                    min: 2,
                                    max: 12,
                                    divisions: 5,
                                    label:
                                        '${preferences.moodCheckInInterval}h',
                                    onChanged: (value) {
                                      final hours = value.toInt();
                                      ref
                                          .read(
                                              userPreferencesProvider.notifier)
                                          .updateMoodCheckInInterval(hours);
                                      _scheduleMoodCheckIns(hours);
                                    },
                                  ),
                                ),
                                Text(
                                  'Randomized during the day, about every ${preferences.moodCheckInInterval} hours.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color:
                                        theme.colorScheme.onSurface.withValues(
                                      alpha: 0.68,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                              const SizedBox(height: 8),
                              Text(
                                'Program an NFC tag to quickly launch a feature by tapping it against your phone.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: SmoothButton(
                                  onPressed: _showNfcProgrammingDialog,
                                  icon: const Icon(Icons.nfc,
                                      size: 16, color: Colors.white),
                                  label: 'Program NFC Tag',
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white,
                                  borderRadius: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                              const SizedBox(height: 10),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10.0,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 24.0,
                                  ),
                                  activeTrackColor: theme.colorScheme.primary,
                                  inactiveTrackColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.16),
                                  thumbColor: theme.colorScheme.primary,
                                  overlayColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.12),
                                ),
                                child: Slider(
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
                    const SizedBox(height: 20),

                    // Privacy Section
                    _SettingsSection(
                      title: 'Privacy & Data',
                      children: [
                        SmoothCard(
                          padding: const EdgeInsets.all(16),
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.04),
                          borderColor:
                              AppColors.success.withValues(alpha: 0.18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Data is Private',
                                      style: AppTypography.labelLarge.copyWith(
                                        color:
                                            theme.textTheme.labelLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildPrivacyItem(context,
                                        'All data stored locally on your device'),
                                    const SizedBox(height: 6),
                                    _buildPrivacyItem(context,
                                        'End-to-end encrypted securely'),
                                    const SizedBox(height: 6),
                                    _buildPrivacyItem(context,
                                        'Never shared or sold to third parties'),
                                    const SizedBox(height: 6),
                                    _buildPrivacyItem(context,
                                        'You have full, absolute control'),
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
                    // Calmora AI settings: provider selection and Gemini API key
                    _SettingsSection(
                      title: 'Calmora AI',
                      children: [
                        SmoothCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Provider',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Consumer(builder: (context, ref, _) {
                                final mode = ref.watch(aiModeProvider);
                                final manager = ref.watch(aiManagerProvider);
                                return Column(
                                  children: [
                                    RadioListTile<AiMode>(
                                      value: AiMode.auto,
                                      groupValue: mode,
                                      title: const Text('Auto (recommended)'),
                                      onChanged: (v) => ref
                                          .read(aiModeProvider.notifier)
                                          .state = v!,
                                    ),
                                    RadioListTile<AiMode>(
                                      value: AiMode.calmora,
                                      groupValue: mode,
                                      title: const Text('CalmoraAI (Ollama)'),
                                      onChanged: (v) => ref
                                          .read(aiModeProvider.notifier)
                                          .state = v!,
                                    ),
                                    RadioListTile<AiMode>(
                                      value: AiMode.gemini,
                                      groupValue: mode,
                                      title: const Text('Gemini'),
                                      onChanged: (v) => ref
                                          .read(aiModeProvider.notifier)
                                          .state = v!,
                                    ),
                                    const SizedBox(height: 8),
                                    // Status indicators: show configuration and availability separately
                                    Builder(builder: (context) {
                                      final geminiConfigured =
                                          ref.watch(geminiConfiguredProvider);
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder(
                                            future: Future.wait([
                                              manager.primary.isAvailable(),
                                              manager.secondary.isAvailable()
                                            ]),
                                            builder: (context, snap) {
                                              String ollamaStatus = 'Unknown';
                                              String geminiAvailability =
                                                  'Unknown';
                                              if (snap.connectionState ==
                                                      ConnectionState.done &&
                                                  snap.hasData) {
                                                final results =
                                                    snap.data as List<dynamic>;
                                                final primaryAvailable =
                                                    results[0] as bool;
                                                final secondaryAvailable =
                                                    results[1] as bool;
                                                if (manager.primaryBackend ==
                                                    AiBackend.ollama) {
                                                  ollamaStatus =
                                                      primaryAvailable
                                                          ? 'Running'
                                                          : 'Not running';
                                                  geminiAvailability =
                                                      secondaryAvailable
                                                          ? 'Available'
                                                          : 'Unavailable';
                                                } else {
                                                  geminiAvailability =
                                                      primaryAvailable
                                                          ? 'Available'
                                                          : 'Unavailable';
                                                  ollamaStatus =
                                                      secondaryAvailable
                                                          ? 'Running'
                                                          : 'Not running';
                                                }
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Ollama: $ollamaStatus',
                                                      style: AppTypography
                                                          .bodySmall
                                                          .copyWith(
                                                              color: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      'Gemini: ${geminiConfigured ? 'Configured' : 'Not configured'} • $geminiAvailability',
                                                      style: AppTypography
                                                          .bodySmall
                                                          .copyWith(
                                                              color: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color)),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Note: "Configured" means an API key is present (from Settings or .env). "Available" means the provider responded to a quick health check.',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                    color: theme.textTheme
                                                        .bodySmall?.color
                                                        ?.withValues(
                                                            alpha: 0.68)),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                );
                              }),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: theme.dividerColor),
                              const SizedBox(height: 12),
                              Text(
                                'Gemini API Key',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _geminiController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter your Gemini API key (optional)',
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () async {
                                          final key =
                                              _geminiController.text.trim();
                                          if (key.isEmpty) {
                                            AppSnackBar.showInfo(context,
                                                title: 'No key',
                                                message:
                                                    'Please enter a valid API key to save.');
                                            return;
                                          }
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .saveGeminiKey(key);
                                          final _ =
                                              ref.refresh(geminiKeyProvider);
                                          await ref
                                              .read(geminiKeyProvider.future);
                                          if (!mounted) return;
                                          _showGeminiSavedSnackBar();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .deleteGeminiKey();
                                          _geminiController.clear();
                                          final _ =
                                              ref.refresh(geminiKeyProvider);
                                          await ref
                                              .read(geminiKeyProvider.future);
                                          if (!mounted) return;
                                          _showGeminiRemovedSnackBar();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: theme.dividerColor),
                              const SizedBox(height: 12),
                              Text(
                                'Ollama Server URL',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ollamaEndpointController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter Ollama URL (e.g. http://127.0.0.1:8000/chat)',
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () async {
                                          final url =
                                              _ollamaEndpointController.text.trim();
                                          if (url.isEmpty) {
                                            AppSnackBar.showInfo(context,
                                                title: 'No URL',
                                                message:
                                                    'Please enter a valid URL to save.');
                                            return;
                                          }
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .saveOllamaEndpoint(url);
                                          final _ =
                                              ref.refresh(ollamaEndpointProvider);
                                          await ref
                                              .read(ollamaEndpointProvider.future);
                                          if (!mounted) return;
                                          _showOllamaEndpointSavedSnackBar();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .deleteOllamaEndpoint();
                                          _ollamaEndpointController.clear();
                                          final _ =
                                              ref.refresh(ollamaEndpointProvider);
                                          await ref
                                              .read(ollamaEndpointProvider.future);
                                          if (!mounted) return;
                                          _showOllamaEndpointRemovedSnackBar();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: theme.dividerColor),
                              const SizedBox(height: 12),
                              Text(
                                'Ollama Model Name',
                                style: AppTypography.labelLarge.copyWith(
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ollamaModelController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter model (e.g. llama3.2:1b-instruct-q4_K_M)',
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () async {
                                          final model =
                                              _ollamaModelController.text.trim();
                                          if (model.isEmpty) {
                                            AppSnackBar.showInfo(context,
                                                title: 'No model',
                                                message:
                                                    'Please enter a valid model name to save.');
                                            return;
                                          }
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .saveOllamaModel(model);
                                          final _ =
                                              ref.refresh(ollamaModelProvider);
                                          await ref
                                              .read(ollamaModelProvider.future);
                                          if (!mounted) return;
                                          _showOllamaModelSavedSnackBar();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          await ref
                                              .read(geminiKeyActionsProvider)
                                              .deleteOllamaModel();
                                          _ollamaModelController.clear();
                                          final _ =
                                              ref.refresh(ollamaModelProvider);
                                          await ref
                                              .read(ollamaModelProvider.future);
                                          if (!mounted) return;
                                          _showOllamaModelRemovedSnackBar();
                                        },
                                      ),
                                    ],
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
                                  backgroundColor:
                                      theme.brightness == Brightness.dark
                                          ? theme.colorScheme.secondary
                                              .withValues(alpha: 0.3)
                                          : theme.colorScheme.secondary
                                              .withValues(alpha: 0.85),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  if (profile?.role == UserRole.psychologist) {
                                    await ref
                                        .read(appSessionProvider.notifier)
                                        .switchUser(
                                          'patient@example.com',
                                          UserRole.patient,
                                          'Mindful Friend',
                                        );
                                    ref
                                        .read(selectedTabProvider.notifier)
                                        .state = 0;
                                    if (context.mounted) {
                                      AppSnackBar.showSuccess(
                                        context,
                                        title: 'Switched to Patient',
                                        message:
                                            'You are now viewing as Mindful Friend.',
                                      );
                                    }
                                  } else {
                                    await ref
                                        .read(appSessionProvider.notifier)
                                        .switchUser(
                                          demoPsychologistEmail,
                                          UserRole.psychologist,
                                          'Dr. Panipuri',
                                        );
                                    ref
                                        .read(selectedTabProvider.notifier)
                                        .state = 0;
                                    if (context.mounted) {
                                      AppSnackBar.showSuccess(
                                        context,
                                        title: 'Switched to Psychologist',
                                        message:
                                            'You are now viewing as Dr. Panipuri.',
                                      );
                                    }
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
                              .withValues(alpha: 0.03),
                          borderColor: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.1),
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
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.error
                                            .withValues(alpha: 0.4)
                                        : theme.colorScheme.error
                                            .withValues(alpha: 0.6),
                                    width: 1.2,
                                  ),
                                  foregroundColor:
                                      theme.brightness == Brightness.dark
                                          ? theme.colorScheme.error
                                              .withValues(alpha: 0.85)
                                          : theme.colorScheme.error
                                              .withValues(alpha: 0.9),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(appSessionProvider.notifier)
                                      .logout();
                                  ref.read(selectedTabProvider.notifier).state =
                                      0;
                                  AppSnackBar.showInfo(
                                    context,
                                    title: 'Logged out',
                                    message:
                                        'You can now sign in again as a patient or psychologist.',
                                  );
                                },
                                icon: const Icon(Icons.logout, size: 18),
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
          ),
        ],
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

  Widget _buildPrivacyItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings section header
