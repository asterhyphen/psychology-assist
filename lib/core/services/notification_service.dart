import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local notifications (mood check-ins, medication reminders).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;

  NotificationService._internal();

  factory NotificationService() => _instance;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload ?? 'no payload'}');
      },
    );
    await _createAndroidChannels();
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await _ensureInitialized();

    final androidPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidPermissions ?? iosPermissions ?? false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();
    await _notificationsPlugin.show(
      id,
      title,
      body,
      _defaultDetails('calmora_channel'),
      payload: payload,
    );
  }

  Future<void> scheduleMoodCheckIn({
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();

    final scheduledDate = _nextDailyTime(hour: hour, minute: minute);
    final id = 1000 + hour;

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'Mood check-in',
        'Take a moment to log your mood and reflect on your wellness.',
        scheduledDate,
        _defaultDetails('calmora_checkin'),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'mood-checkin',
      );
      debugPrint(
        'Scheduled mood check-in at $hour:${minute.toString().padLeft(2, '0')}',
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule mood check-in: $error');
      debugPrintStack(stackTrace: stackTrace);
      await showNotification(
        id: id,
        title: 'Mood check-in',
        body: 'Take a moment to log your mood and reflect on your wellness.',
        payload: 'mood-checkin',
      );
    }
  }

  Future<void> scheduleMoodCheckInsEvery(int hours) async {
    await _ensureInitialized();
    final interval = hours.clamp(2, 12);
    final random = Random();

    await cancelMoodCheckIns();
    for (var hour = 9; hour <= 21; hour += interval) {
      await scheduleMoodCheckIn(hour: hour, minute: random.nextInt(45));
    }
  }

  Future<void> cancelMoodCheckIns() async {
    await _ensureInitialized();
    for (var hour = 0; hour < 24; hour++) {
      await _notificationsPlugin.cancel(1000 + hour);
    }
  }

  Future<void> scheduleMedicationReminder({
    required int hour,
    required int minute,
    required String medicationName,
    int id = 2000,
  }) async {
    await _scheduleDailyMedicationReminder(
      hour: hour,
      minute: minute,
      medicationName: medicationName,
      id: id,
    );
  }

  Future<void> scheduleMedicationReminders({
    required List<String> medicines,
    required List<({int hour, int minute})> times,
  }) async {
    await _ensureInitialized();
    await cancelMedicationReminders();

    if (medicines.isEmpty || times.isEmpty) return;

    final medicineList = medicines.join(', ');
    for (var i = 0; i < times.length; i++) {
      final time = times[i];
      await _scheduleDailyMedicationReminder(
        hour: time.hour,
        minute: time.minute,
        medicationName: medicineList,
        id: 2000 + i,
      );
    }
  }

  Future<void> cancelMedicationReminders() async {
    await _ensureInitialized();
    for (var i = 0; i < 10; i++) {
      await _notificationsPlugin.cancel(2000 + i);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notificationsPlugin.cancelAll();
  }

  Future<void> _scheduleDailyMedicationReminder({
    required int hour,
    required int minute,
    required String medicationName,
    required int id,
  }) async {
    await _ensureInitialized();
    final scheduledDate = _nextDailyTime(hour: hour, minute: minute);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'Medication reminder',
        'Time to take: $medicationName',
        scheduledDate,
        _defaultDetails('calmora_medication'),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medication-reminder',
      );
      debugPrint(
        'Scheduled medication reminder $id at $hour:${minute.toString().padLeft(2, '0')}',
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule medication reminder: $error');
      debugPrintStack(stackTrace: stackTrace);
      await showNotification(
        id: id,
        title: 'Medication reminder',
        body: 'Time to take: $medicationName',
        payload: 'medication-reminder',
      );
    }
  }

  NotificationDetails _defaultDetails(String channelId) {
    final channelName = switch (channelId) {
      'calmora_checkin' => 'Mood Check-ins',
      'calmora_medication' => 'Medication Reminders',
      _ => 'Calmora Notifications',
    };
    final description = switch (channelId) {
      'calmora_medication' => 'Daily medication reminders',
      _ => 'Mood check-ins and reminders',
    };

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: description,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _nextDailyTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  Future<void> _createAndroidChannels() async {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'calmora_channel',
        'Calmora Notifications',
        description: 'Mood check-ins and reminders',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'calmora_checkin',
        'Mood Check-ins',
        description: 'Daily mood check-in reminders',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'calmora_medication',
        'Medication Reminders',
        description: 'Daily medication reminders',
        importance: Importance.high,
      ),
    );
  }
}
