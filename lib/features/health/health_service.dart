import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:omra_track/models/health_data_model.dart';

class HealthService {
  final Health _health = Health();
  
  static final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.STEPS,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
  ];

  Future<bool> requestPermissions() async {
    try {
      // Request activity recognition permission for Android
      if (await Permission.activityRecognition.isDenied) {
        await Permission.activityRecognition.request();
      }

      // Request health permissions
      bool? hasPermissions = await _health.hasPermissions(_types);
      
      if (hasPermissions == null || !hasPermissions) {
        hasPermissions = await _health.requestAuthorization(_types);
      }

      return hasPermissions ?? false;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  Future<HealthData?> getLatestHealthData() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: _types,
      );

      if (healthData.isEmpty) {
        // Return mock data for testing
        return _getMockHealthData();
      }

      double? heartRate;
      double? oxygenLevel;
      int? steps;
      double? systolicBP;
      double? diastolicBP;
      double? temperature;

      for (var point in healthData) {
        // Extract numeric value from HealthValue
        final value = point.value;
        double? numericValue;
        
        if (value is NumericHealthValue) {
          numericValue = value.numericValue.toDouble();
        }
        
        if (numericValue == null) continue;
        
        switch (point.type) {
          case HealthDataType.HEART_RATE:
            heartRate = numericValue;
            break;
          case HealthDataType.BLOOD_OXYGEN:
            oxygenLevel = numericValue;
            break;
          case HealthDataType.STEPS:
            steps = numericValue.toInt();
            break;
          case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
            systolicBP = numericValue;
            break;
          case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
            diastolicBP = numericValue;
            break;
          case HealthDataType.BODY_TEMPERATURE:
            temperature = numericValue;
            break;
          default:
            break;
        }
      }

      return HealthData(
        timestamp: now,
        heartRate: heartRate,
        oxygenLevel: oxygenLevel,
        steps: steps,
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
        temperature: temperature,
      );
    } catch (e) {
      print('Error fetching health data: $e');
      return _getMockHealthData();
    }
  }

  HealthData _getMockHealthData() {
    // Mock data for testing purposes
    return HealthData(
      timestamp: DateTime.now(),
      heartRate: 75.0,
      oxygenLevel: 98.0,
      steps: 5420,
      systolicBP: 120.0,
      diastolicBP: 80.0,
      temperature: 36.6,
    );
  }

  Future<List<HealthData>> getHealthHistory(int days) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: now,
        types: _types,
      );

      // Group data by day
      Map<DateTime, HealthData> dailyData = {};

      for (var point in healthData) {
        final date = DateTime(
          point.dateFrom.year,
          point.dateFrom.month,
          point.dateFrom.day,
        );

        if (!dailyData.containsKey(date)) {
          dailyData[date] = HealthData(timestamp: date);
        }
      }

      // If no real data, return mock history
      if (dailyData.isEmpty) {
        return _getMockHealthHistory(days);
      }

      return dailyData.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      print('Error fetching health history: $e');
      return _getMockHealthHistory(days);
    }
  }

  List<HealthData> _getMockHealthHistory(int days) {
    List<HealthData> history = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      history.add(HealthData(
        timestamp: date,
        heartRate: 70.0 + (i % 10),
        oxygenLevel: 96.0 + (i % 3),
        steps: 4000 + (i * 200),
        systolicBP: 115.0 + (i % 15),
        diastolicBP: 75.0 + (i % 10),
        temperature: 36.5 + (i % 2) * 0.2,
      ));
    }

    return history;
  }
}
