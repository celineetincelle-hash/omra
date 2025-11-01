import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omra_track/models/medication_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MedicationService {
  static const String _boxName = 'medications';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize Hive
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicationAdapter());
    }
    await Hive.openBox<Medication>(_boxName);

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request permissions
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Box<Medication> _getBox() {
    return Hive.box<Medication>(_boxName);
  }

  Future<void> addMedication(Medication medication) async {
    final box = _getBox();
    await box.put(medication.id, medication);
    await _scheduleNotifications(medication);
  }

  Future<void> updateMedication(Medication medication) async {
    final box = _getBox();
    await box.put(medication.id, medication);
    await _cancelNotifications(medication.id);
    if (medication.isActive) {
      await _scheduleNotifications(medication);
    }
  }

  Future<void> deleteMedication(String id) async {
    final box = _getBox();
    await _cancelNotifications(id);
    await box.delete(id);
  }

  List<Medication> getAllMedications() {
    final box = _getBox();
    return box.values.toList();
  }

  Medication? getMedication(String id) {
    final box = _getBox();
    return box.get(id);
  }

  Future<void> _scheduleNotifications(Medication medication) async {
    if (!medication.isActive) return;

    for (int i = 0; i < medication.times.length; i++) {
      final time = medication.times[i];
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notificationId = medication.id.hashCode + i;

      await _notifications.zonedSchedule(
        notificationId,
        'حان وقت الدواء', // Medication time alert in Arabic
        '${medication.name} - ${medication.dosage}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
            sound: const RawResourceAndroidNotificationSound('notification'),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'notification.aiff',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _cancelNotifications(String medicationId) async {
    // Cancel all notifications for this medication
    // We use a range based on the medication ID hash
    final baseId = medicationId.hashCode;
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
