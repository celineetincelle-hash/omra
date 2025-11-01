import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omra_track/features/prayer/prayer_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();
  
  PrayerTimes? _prayerTimes;
  String? _nextPrayer;
  DateTime? _nextPrayerTime;
  double? _qiblaDirection;
  bool _isLoading = false;
  String? _error;

  PrayerTimes? get prayerTimes => _prayerTimes;
  String? get nextPrayer => _nextPrayer;
  DateTime? get nextPrayerTime => _nextPrayerTime;
  double? get qiblaDirection => _qiblaDirection;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _prayerService.initialize();
      await fetchPrayerTimes();
    } catch (e) {
      _error = 'Failed to initialize prayer service: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrayerTimes({Position? position}) async {
    try {
      _prayerTimes = await _prayerService.getPrayerTimes(position: position);
      
      if (_prayerTimes != null) {
        _nextPrayer = _prayerService.getNextPrayer(_prayerTimes!);
        _nextPrayerTime = _prayerService.getNextPrayerTime(_prayerTimes!);
        await _prayerService.schedulePrayerNotifications(_prayerTimes!);
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
      notifyListeners();
    }
  }

  Future<void> fetchQiblaDirection(Position position) async {
    try {
      _qiblaDirection = await _prayerService.getQiblaDirection(position);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch Qibla direction: $e';
      notifyListeners();
    }
  }

  String getPrayerName(String? prayer) {
    if (prayer == null) return '';
    return prayer;
  }

  DateTime? getPrayerTime(String? prayer) {
    if (_prayerTimes == null || prayer == null) return null;

    switch (prayer.toLowerCase()) {
      case 'fajr':
        return _prayerTimes!.fajr;
      case 'sunrise':
        return _prayerTimes!.sunrise;
      case 'dhuhr':
        return _prayerTimes!.dhuhr;
      case 'asr':
        return _prayerTimes!.asr;
      case 'maghrib':
        return _prayerTimes!.maghrib;
      case 'isha':
        return _prayerTimes!.isha;
      default:
        return null;
    }
  }
}
