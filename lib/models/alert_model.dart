import 'package:flutter/foundation.dart'; // Add for debugPrint

class AlertModel {
  final String id;
  final String deviceId;
  final String userId;
  final String groupId;
  final String type; // Ex: 'SOS', 'FallDetected', 'GeofenceEnter', 'GeofenceExit'
  final String message;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  bool isResolved;

  AlertModel({
    required this.id,
    required this.deviceId,
    required this.userId,
    required this.groupId,
    required this.type,
    required this.message,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.isResolved = false,
  });

  // Replaced fromFirestore with a generic fromMap
  factory AlertModel.fromMap(Map<String, dynamic> data, String id) {
    return AlertModel(
      id: id,
      deviceId: data['deviceId'] ?? '',
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      // Assuming timestamp is stored as a String (ISO 8601) or milliseconds since epoch
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : DateTime.now(),
      isResolved: data['isResolved'] ?? false,
    );
  }

  // Replaced toFirestore with a generic toMap
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'userId': userId,
      'groupId': groupId,
      'type': type,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch, // Use milliseconds since epoch
      'isResolved': isResolved,
    };
  }

  AlertModel copyWith({
    String? id,
    String? deviceId,
    String? userId,
    String? groupId,
    String? type,
    String? message,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isResolved,
  }) {
    return AlertModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
