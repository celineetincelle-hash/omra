import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:omra_truck/models/gps_device_model.dart';
import 'package:omra_truck/models/alert_model.dart'; // Pour les clés API

class GpsTraceService {
  final String _baseUrl = 'https://api.gps-trace.com/v1';
  final String _accessToken; // Obtenu depuis le Partner Panel

  GpsTraceService(this._accessToken);

  Future<List<GpsDeviceModel>> getDevicesLocations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/units'),
      headers: {
        'X-AccessToken': _accessToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<GpsDeviceModel> devices = [];
      for (var item in data) {
        // Ici, nous devrons mapper les données de l'API GPS-Trace
        // vers notre GpsDeviceModel. C'est une simplification.
        // L'API GPS-Trace renvoie des données plus complexes.
        // Pour l'exemple, nous allons simuler un mapping.
        devices.add(GpsDeviceModel(
          id: item['id'].toString(),
          userId: 'unknown',
          groupId: 'unknown',
          deviceName: item['name'] ?? 'Unknown Device',
          imei: item['imei'] ?? 'unknown',
          platformDeviceId: item['id'].toString(),
          latitude: item['location']?['lat']?.toDouble(),
          longitude: item['location']?['lng']?.toDouble(),
          speed: item['location']?['speed']?.toDouble(),
          timestamp: item['location']?['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(item['location']['timestamp'] * 1000)
              : null,
          isOnline: item['online'] ?? false,
        ));
      }
      return devices;
    } else {
      throw Exception('Failed to load devices: ${response.statusCode} ${response.body}');
    }
  }

  // Méthode pour obtenir la position d'un appareil spécifique
  Future<GpsDeviceModel> getDeviceLocation(String platformDeviceId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/units/$platformDeviceId'),
      headers: {
        'X-AccessToken': _accessToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> item = json.decode(response.body);
      return GpsDeviceModel(
        id: item['id'].toString(),
        userId: 'unknown',
        groupId: 'unknown',
        deviceName: item['name'] ?? 'Unknown Device',
        imei: item['imei'] ?? 'unknown',
        platformDeviceId: item['id'].toString(),
        latitude: item['location']?['lat']?.toDouble(),
        longitude: item['location']?['lng']?.toDouble(),
        speed: item['location']?['speed']?.toDouble(),
        timestamp: item['location']?['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(item['location']['timestamp'] * 1000)
            : null,
        isOnline: item['online'] ?? false,
      );
    } else {
      throw Exception('Failed to load device $platformDeviceId: ${response.statusCode} ${response.body}');
    }
  }

  // Méthode pour vérifier les alertes (simulation, car l'API peut ne pas le fournir directement)
  Future<List<AlertModel>> checkAlerts(List<GpsDeviceModel> devices) async {
    List<AlertModel> alerts = [];
    for (var device in devices) {
      if (device.sosTriggered == true) {
        alerts.add(AlertModel(
          id: "alert_${device.id}_sos",
          deviceId: device.id,
          userId: device.userId,
          groupId: device.groupId,
          type: "SOS",
          message: "Le bouton SOS a été déclenché par ${device.deviceName}.",
          latitude: device.latitude,
          longitude: device.longitude,
          timestamp: DateTime.now(),
        ));
      }
      if (device.fallDetected == true) {
        alerts.add(AlertModel(
          id: "alert_${device.id}_fall",
          deviceId: device.id,
          userId: device.userId,
          groupId: device.groupId,
          type: "FallDetected",
          message: "Une chute a été détectée pour ${device.deviceName}.",
          latitude: device.latitude,
          longitude: device.longitude,
          timestamp: DateTime.now(),
        ));
      }
    }
    return alerts;
  }
}


