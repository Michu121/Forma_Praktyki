import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_activities/live_activities.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

abstract interface class RestNotificationController {
  Future<String?> startRest(Duration duration);

  Future<void> finishRest();

  Future<void> cancelRest();
}

abstract interface class WorkoutReminderController {
  Future<String?> updateWorkoutReminders({
    required bool enabled,
    required List<int> days,
    required int hour,
    required int minute,
  });
}

class RestNotificationService
    implements RestNotificationController, WorkoutReminderController {
  RestNotificationService._();

  static final RestNotificationService instance = RestNotificationService._();

  static const _activityId = 'forma-rest-timer';
  static const _appGroupId = 'group.com.example.silowniaPraktyki';
  static const _notificationChannelId = 'forma_rest_channel';
  static const _notificationChannelName = 'Przerwy treningowe';
  static const _workoutReminderChannelId = 'forma_workout_reminders';
  static const _workoutReminderChannelName = 'Przypomnienia o treningu';
  static const _finishedTitle = 'Koniec przerwy';
  static const _finishedBody = 'Pora na serię.';
  static const _workoutReminderIdBase = 71000;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LiveActivities _liveActivities = LiveActivities();
  bool _initialized = false;
  bool _notificationPermissionGranted = false;
  bool _activityStarted = false;
  bool _exactAlarmPermissionRequested = false;
  bool _exactAlarmsAllowed = false;

  int get _notificationId {
    final digest = sha256.convert(utf8.encode(_activityId)).bytes;
    final unsignedValue = BigInt.parse(
      digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
    final signedValue = digest.first >= 0x80
        ? unsignedValue - (BigInt.one << (digest.length * 8))
        : unsignedValue;
    return signedValue.abs().toUnsigned(32).toSigned(32).toInt();
  }

  @override
  Future<String?> startRest(Duration duration) async {
    await _ensureInitialized();
    _notificationPermissionGranted = await _requestNotificationPermission();
    if (Platform.isAndroid && _notificationPermissionGranted) {
      await _requestExactAlarmPermissionIfNeeded();
    }

    final endTime = DateTime.now().add(duration);
    final supportsActivities = await _liveActivities.areActivitiesSupported();
    final activitiesEnabled = supportsActivities
        ? await _liveActivities.areActivitiesEnabled()
        : false;
    _activityStarted = activitiesEnabled;

    if (activitiesEnabled) {
      await _liveActivities.createOrUpdateActivity(_activityId, {
        'title': 'PRZERWA',
        'restEndTime': endTime.millisecondsSinceEpoch,
        'isComplete': false,
      }, iOSEnableRemoteUpdates: false);
    }

    if (_notificationPermissionGranted) {
      if (!activitiesEnabled) {
        await _showRestNotification(endTime);
      }
      await _scheduleFinishedNotification(endTime);
    }

    if (!_notificationPermissionGranted) {
      return 'Włącz powiadomienia, aby otrzymywać przypomnienia o przerwie.';
    }
    if (Platform.isAndroid && !_exactAlarmsAllowed) {
      return 'Alarmy dokładne są wyłączone — powiadomienie może się opóźnić.';
    }
    return null;
  }

  @override
  Future<void> finishRest() async {
    await _ensureInitialized();
    await _notifications.cancel(id: _notificationId);

    if (_activityStarted) {
      await _liveActivities.updateActivity(_activityId, {
        'title': _finishedTitle.toUpperCase(),
        'isComplete': true,
      });
    }

    if (_notificationPermissionGranted) {
      await _notifications.show(
        id: _notificationId,
        title: _finishedTitle,
        body: _finishedBody,
        notificationDetails: _finishedNotificationDetails,
      );
    }

    if (_activityStarted && Platform.isIOS) {
      await _liveActivities.endActivity(_activityId);
      _activityStarted = false;
    }
  }

  @override
  Future<void> cancelRest() async {
    await _ensureInitialized();
    await _notifications.cancel(id: _notificationId);
    if (_activityStarted) {
      await _liveActivities.endActivity(_activityId);
      _activityStarted = false;
    }
  }

  @override
  Future<String?> updateWorkoutReminders({
    required bool enabled,
    required List<int> days,
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();
    await Future.wait([
      for (var day = DateTime.monday; day <= DateTime.sunday; day++)
        _notifications.cancel(id: _workoutReminderIdBase + day),
    ]);
    if (!enabled) return null;

    final permissionGranted = await _requestNotificationPermission();
    if (!permissionGranted) {
      return 'Włącz powiadomienia w ustawieniach urządzenia, aby otrzymywać przypomnienia.';
    }

    if (days.isEmpty ||
        days.any((day) => day < DateTime.monday || day > DateTime.sunday)) {
      throw ArgumentError.value(
        days,
        'days',
        'Wybierz prawidłowe dni tygodnia.',
      );
    }

    if (Platform.isAndroid) {
      await _requestExactAlarmPermissionIfNeeded();
    } else {
      _exactAlarmsAllowed = true;
    }

    final now = timezone.TZDateTime.now(timezone.local);
    for (final day in days.toSet()) {
      var scheduledDate = timezone.TZDateTime(
        timezone.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      while (scheduledDate.weekday != day || !scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: _workoutReminderIdBase + day,
        title: 'Czas na trening',
        body: 'Twój zaplanowany trening czeka. Zrób dziś coś dla siebie!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _workoutReminderChannelId,
            _workoutReminderChannelName,
            channelDescription: 'Cotygodniowe przypomnienia o treningu',
            category: AndroidNotificationCategory.reminder,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: _exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    if (Platform.isAndroid && !_exactAlarmsAllowed) {
      return 'Przypomnienia zapisano, ale bez alarmów dokładnych mogą pojawić się z opóźnieniem.';
    }
    return null;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Powiadomienia przerw są obsługiwane na Androidzie i iOS.',
      );
    }

    timezone_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
    final initialized = await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    if (initialized == null) {
      throw StateError('Nie udało się zainicjalizować powiadomień.');
    }

    await _liveActivities.init(
      appGroupId: _appGroupId,
      requestAndroidNotificationPermission: false,
    );
    _initialized = true;
  }

  Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        ) ??
        false;
  }

  Future<void> _requestExactAlarmPermissionIfNeeded() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? true;
    if (_exactAlarmsAllowed || _exactAlarmPermissionRequested) return;

    _exactAlarmPermissionRequested = true;
    await android?.requestExactAlarmsPermission();
    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? false;
  }

  Future<void> _showRestNotification(DateTime endTime) => _notifications.show(
    id: _notificationId,
    title: 'Przerwa w treningu',
    body: 'Do kolejnej serii:',
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: 'Odliczanie przerw między seriami',
        category: AndroidNotificationCategory.progress,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        when: endTime.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: true,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
        presentBanner: false,
        presentList: false,
        presentSound: false,
      ),
    ),
  );

  Future<void> _scheduleFinishedNotification(DateTime endTime) =>
      _notifications.zonedSchedule(
        id: _notificationId,
        title: _finishedTitle,
        body: _finishedBody,
        scheduledDate: timezone.TZDateTime.from(endTime.toUtc(), timezone.UTC),
        notificationDetails: _finishedNotificationDetails,
        androidScheduleMode: _exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );

  NotificationDetails get _finishedNotificationDetails =>
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Przypomnienia o zakończeniu przerwy',
          category: AndroidNotificationCategory.reminder,
          importance: Importance.high,
          priority: Priority.high,
          ongoing: false,
          autoCancel: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      );
}
