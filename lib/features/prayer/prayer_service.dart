import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Simple Prayer Times Calculator
// Based on standard astronomical calculations
class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class PrayerService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<PrayerTimes?> getPrayerTimes({Position? position}) async {
    try {
      Position currentPosition;
      
      if (position != null) {
        currentPosition = position;
      } else {
        // Get current location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return null;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        }

        currentPosition = await Geolocator.getCurrentPosition();
      }

      // Calculate prayer times using astronomical formulas
      return _calculatePrayerTimes(
        currentPosition.latitude,
        currentPosition.longitude,
        DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error calculating prayer times: $e');
      return null;
    }
  }

  PrayerTimes _calculatePrayerTimes(double latitude, double longitude, DateTime date) {
    // Simplified prayer time calculation
    // Using Muslim World League method (Fajr: 18°, Isha: 17°)
    
    final jd = _julianDate(date);
    final tz = longitude / 15.0; // Timezone offset
    
    // Calculate sun times
    final transit = _sunTransit(jd, longitude);
    final sunrise = _sunTime(jd, latitude, longitude, 0.833, true);
    final sunset = _sunTime(jd, latitude, longitude, 0.833, false);
    
    // Prayer times
    final fajrAngle = 18.0; // Muslim World League
    final ishaAngle = 17.0;
    
    final fajr = _sunTime(jd, latitude, longitude, fajrAngle, true);
    final dhuhr = transit;
    final asr = _asrTime(jd, latitude, longitude);
    final maghrib = sunset;
    final isha = _sunTime(jd, latitude, longitude, ishaAngle, false);
    
    return PrayerTimes(
      fajr: _toDateTime(date, fajr),
      sunrise: _toDateTime(date, sunrise),
      dhuhr: _toDateTime(date, dhuhr),
      asr: _toDateTime(date, asr),
      maghrib: _toDateTime(date, maghrib),
      isha: _toDateTime(date, isha),
    );
  }

  double _julianDate(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    
    if (m <= 2) {
      return 367 * y - (7 * (y + 5001 + (m - 9) ~/ 7)) ~/ 4 +
          (275 * m) ~/ 9 + d + 1729777.0;
    }
    return 367 * y - (7 * (y + (m + 9) ~/ 12)) ~/ 4 +
        (275 * m) ~/ 9 + d + 1721014.0;
  }

  double _sunTransit(double jd, double longitude) {
    final n = jd - 2451545.0 + 0.0008;
    final j = n - longitude / 360.0;
    final m = (357.5291 + 0.98560028 * j) % 360;
    final c = 1.9148 * _sin(m) + 0.02 * _sin(2 * m) + 0.0003 * _sin(3 * m);
    final lambda = (m + c + 180 + 102.9372) % 360;
    final jTransit = 2451545.0 + j + 0.0053 * _sin(m) - 0.0069 * _sin(2 * lambda);
    
    return (jTransit - jd.floor()) * 24.0;
  }

  double _sunTime(double jd, double lat, double lng, double angle, bool rising) {
    final transit = _sunTransit(jd, lng);
    final n = jd - 2451545.0 + 0.0008;
    final j = n - lng / 360.0;
    final m = (357.5291 + 0.98560028 * j) % 360;
    final c = 1.9148 * _sin(m) + 0.02 * _sin(2 * m);
    final lambda = (m + c + 180 + 102.9372) % 360;
    final delta = _asin(_sin(lambda) * _sin(23.44));
    
    final hourAngle = _acos(
      (_sin(-angle) - _sin(lat) * _sin(delta)) /
      (_cos(lat) * _cos(delta))
    );
    
    return rising ? transit - hourAngle / 15.0 : transit + hourAngle / 15.0;
  }

  double _asrTime(double jd, double lat, double lng) {
    // Asr time when shadow length = object length + noon shadow
    final transit = _sunTransit(jd, lng);
    final n = jd - 2451545.0 + 0.0008;
    final j = n - lng / 360.0;
    final m = (357.5291 + 0.98560028 * j) % 360;
    final c = 1.9148 * _sin(m) + 0.02 * _sin(2 * m);
    final lambda = (m + c + 180 + 102.9372) % 360;
    final delta = _asin(_sin(lambda) * _sin(23.44));
    
    final angle = _atan(1 + _tan((lat - delta).abs()));
    final hourAngle = _acos(
      (_sin(angle) - _sin(lat) * _sin(delta)) /
      (_cos(lat) * _cos(delta))
    );
    
    return transit + hourAngle / 15.0;
  }

  DateTime _toDateTime(DateTime date, double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).floor();
    return DateTime(date.year, date.month, date.day, h, m);
  }

  double _sin(double degrees) => math.sin(degrees * math.pi / 180);
  double _cos(double degrees) => math.cos(degrees * math.pi / 180);
  double _tan(double degrees) => math.tan(degrees * math.pi / 180);
  double _asin(double value) => math.asin(value) * 180 / math.pi;
  double _acos(double value) => math.acos(value) * 180 / math.pi;
  double _atan(double value) => math.atan(value) * 180 / math.pi;

  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr, 'id': 1},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr, 'id': 2},
      {'name': 'Asr', 'time': prayerTimes.asr, 'id': 3},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib, 'id': 4},
      {'name': 'Isha', 'time': prayerTimes.isha, 'id': 5},
    ];

    for (var prayer in prayers) {
      final prayerTime = prayer['time'] as DateTime;
      final now = DateTime.now();

      // Only schedule if the prayer time hasn't passed
      if (prayerTime.isAfter(now)) {
        final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
        
        await _notifications.zonedSchedule(
          prayer['id'] as int,
          'وقت الصلاة', // Prayer time in Arabic
          'حان وقت صلاة ${_getArabicPrayerName(prayer['name'] as String)}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_channel',
              'Prayer Times',
              channelDescription: 'Notifications for prayer times',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              sound: 'adhan.aiff',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          
        );
      }
    }
  }

  String _getArabicPrayerName(String englishName) {
    switch (englishName) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return englishName;
    }
  }

  String? getNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    
    if (now.isBefore(prayerTimes.fajr)) {
      return 'fajr';
    } else if (now.isBefore(prayerTimes.sunrise)) {
      return 'sunrise';
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      return 'dhuhr';
    } else if (now.isBefore(prayerTimes.asr)) {
      return 'asr';
    } else if (now.isBefore(prayerTimes.maghrib)) {
      return 'maghrib';
    } else if (now.isBefore(prayerTimes.isha)) {
      return 'isha';
    } else {
      return 'fajr'; // Next day Fajr
    }
  }

  DateTime? getNextPrayerTime(PrayerTimes prayerTimes) {
    final nextPrayer = getNextPrayer(prayerTimes);
    
    switch (nextPrayer) {
      case 'fajr':
        return prayerTimes.fajr;
      case 'sunrise':
        return prayerTimes.sunrise;
      case 'dhuhr':
        return prayerTimes.dhuhr;
      case 'asr':
        return prayerTimes.asr;
      case 'maghrib':
        return prayerTimes.maghrib;
      case 'isha':
        return prayerTimes.isha;
      default:
        return null;
    }
  }

  Future<double?> getQiblaDirection(Position position) async {
    try {
      // Qibla direction calculation (towards Kaaba in Mecca)
      const kaabaLat = 21.4225; // Kaaba latitude
      const kaabaLng = 39.8262; // Kaaba longitude
      
      final lat1 = position.latitude * math.pi / 180;
      final lat2 = kaabaLat * math.pi / 180;
      final dLng = (kaabaLng - position.longitude) * math.pi / 180;
      
      final y = math.sin(dLng) * math.cos(lat2);
      final x = math.cos(lat1) * math.sin(lat2) -
          math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
      
      final bearing = math.atan2(y, x) * 180 / math.pi;
      return (bearing + 360) % 360;
    } catch (e) {
      // ignore: avoid_print
      print('Error calculating Qibla direction: $e');
      return null;
    }
  }
}
