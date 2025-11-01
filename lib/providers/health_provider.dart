import 'package:flutter/material.dart';
import 'package:omra_track/features/health/health_service.dart';
import 'package:omra_track/models/health_data_model.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  
  HealthData? _currentHealthData;
  List<HealthData> _healthHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _permissionsGranted = false;

  HealthData? get currentHealthData => _currentHealthData;
  List<HealthData> get healthHistory => _healthHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionsGranted => _permissionsGranted;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _permissionsGranted = await _healthService.requestPermissions();
      
      if (_permissionsGranted) {
        await fetchHealthData();
        await fetchHealthHistory(7); // Last 7 days
      } else {
        _error = 'Health permissions not granted';
      }
    } catch (e) {
      _error = 'Failed to initialize health service: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHealthData() async {
    try {
      _currentHealthData = await _healthService.getLatestHealthData();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch health data: $e';
      notifyListeners();
    }
  }

  Future<void> fetchHealthHistory(int days) async {
    try {
      _healthHistory = await _healthService.getHealthHistory(days);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch health history: $e';
      notifyListeners();
    }
  }

  bool hasAbnormalValues() {
    return _currentHealthData?.hasAbnormalValues() ?? false;
  }

  String? getHealthAlert() {
    if (_currentHealthData == null) return null;

    final data = _currentHealthData!;
    
    if (data.heartRate != null && data.heartRate! > 100) {
      return 'high_heart_rate_alert';
    }
    if (data.oxygenLevel != null && data.oxygenLevel! < 95) {
      return 'low_oxygen_alert';
    }
    
    return null;
  }
}
