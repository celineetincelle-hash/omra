import 'package:flutter/foundation.dart'; // Add for debugPrint

class GpsDeviceModel {
  final String id;
  final String userId; // L'ID de l'utilisateur associé à cet appareil
  final String groupId; // L'ID du groupe auquel l'utilisateur appartient
  final String deviceName; // Nom de l'appareil (ex: Montre Senior de [Nom du senior])
  final String imei; // IMEI de l'appareil GPS
  final String platformDeviceId; // ID de l'appareil sur la plateforme GPS-Trace
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? speed;
  final double? course;
  final DateTime? timestamp; // Dernière mise à jour de la position
  final bool? isOnline;
  final bool? sosTriggered;
  final bool? fallDetected;

  GpsDeviceModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.deviceName,
    required this.imei,
    required this.platformDeviceId,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.course,
    this.timestamp,
    this.isOnline,
    this.sosTriggered,
    this.fallDetected,
  });

  // Replaced fromFirestore with a generic fromMap
  factory GpsDeviceModel.fromMap(Map<String, dynamic> data, String id) {
    return GpsDeviceModel(
      id: id,
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      deviceName: data['deviceName'] ?? '',
      imei: data['imei'] ?? '',
      platformDeviceId: data['platformDeviceId'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      altitude: (data['altitude'] as num?)?.toDouble(),
      speed: (data['speed'] as num?)?.toDouble(),
      course: (data['course'] as num?)?.toDouble(),
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : null,
      isOnline: data['isOnline'] ?? false,
      sosTriggered: data['sosTriggered'] ?? false,
      fallDetected: data['fallDetected'] ?? false,
    );
  }

  // Replaced toFirestore with a generic toMap
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupId': groupId,
      'deviceName': deviceName,
      'imei': imei,
      'platformDeviceId': platformDeviceId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'course': course,
      'timestamp': timestamp?.millisecondsSinceEpoch, // Use milliseconds since epoch
      'isOnline': isOnline,
      'sosTriggered': sosTriggered,
      'fallDetected': fallDetected,
    };
  }

  GpsDeviceModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? deviceName,
    String? imei,
    String? platformDeviceId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? course,
    DateTime? timestamp,
    bool? isOnline,
    bool? sosTriggered,
    bool? fallDetected,
  }) {
    return GpsDeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      deviceName: deviceName ?? this.deviceName,
      imei: imei ?? this.imei,
      platformDeviceId: platformDeviceId ?? this.platformDeviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      course: course ?? this.course,
      timestamp: timestamp ?? this.timestamp,
      isOnline: isOnline ?? this.isOnline,
      sosTriggered: sosTriggered ?? this.sosTriggered,
      fallDetected: fallDetected ?? this.fallDetected,
    );
  }
}
