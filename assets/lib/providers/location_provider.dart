import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omra_track/models/gps_device_model.dart';
import 'package:omra_track/models/alert_model.dart';
import 'package:omra_track/services/gps_trace_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Position? _guidePosition;
  List<GpsDeviceModel> _gpsDevices = [];
  List<AlertModel> _alerts = [];
  Timer? _gpsDeviceFetchTimer;
  Timer? _alertFetchTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Removed
  GpsTraceService? _gpsTraceService;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  Position? get guidePosition => _guidePosition;
  List<GpsDeviceModel> get gpsDevices => _gpsDevices;
  List<AlertModel> get alerts => _alerts;
  bool get isTracking => _isTracking;

  void initializeGpsTraceService(String accessToken) {
    _gpsTraceService = GpsTraceService(accessToken);
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  Future<void> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('Permission de géolocalisation refusée');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la position: $e');
    }
  }

  Future<void> startLocationTracking(String groupId) async {
    if (_isTracking) return;
    
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return;

    _isTracking = true;
    
    // Écouter les changements de position
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      // _updateLocationInFirestore(groupId, position); // Removed Firestore call
      notifyListeners();
    });

    // Lancer la récupération des appareils GPS à intervalles réguliers
    _gpsDeviceFetchTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchGpsDevicesLocations();
    });

    // Lancer la récupération des alertes à intervalles réguliers
    _alertFetchTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchAlerts();
    });
  }

  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _gpsDeviceFetchTimer?.cancel();
    _alertFetchTimer?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  // Removed _updateLocationInFirestore

  Future<void> fetchGpsDevicesLocations() async {
    if (_gpsTraceService == null) return;
    
    try {
      // Assuming getDevicesLocations is a method that returns a list of GpsDeviceModel
      List<GpsDeviceModel> devices = await _gpsTraceService!.getDevicesLocations();
      _gpsDevices = devices;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des appareils GPS: $e');
    }
  }

  Future<void> fetchAlerts() async {
    if (_gpsTraceService == null) return;
    
    try {
      // Mock alert data since Firestore is removed
      _alerts = [
        AlertModel(
          id: 'demo_1',
          deviceId: 'device_1',
          userId: 'user_1',
          groupId: 'group_1',
          type: 'SOS',
          message: 'Alerte SOS déclenchée',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isResolved: false,
        ),
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des alertes: $e');
    }
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
