import 'package:equatable/equatable.dart';

// Type pour les membres du groupe
class GroupMember extends Equatable {
  final String id;
  final String name;
  final bool isLeader;
  final double? latitude;
  final double? longitude;
  final String? deviceId;
  bool isConnected;

  GroupMember({
    required this.id,
    required this.name,
    this.isLeader = false,
    this.latitude,
    this.longitude,
    this.deviceId,
    this.isConnected = false,
  });

  @override
  List<Object?> get props => [id, name, isLeader, latitude, longitude, deviceId, isConnected];

  // Méthode pour créer un membre à partir d'un JSON (si nécessaire)
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      name: json['name'] as String,
      isLeader: json['isLeader'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      deviceId: json['deviceId'] as String?,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  // Méthode pour convertir en JSON (si nécessaire)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isLeader': isLeader,
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'isConnected': isConnected,
    };
  }
}

// Énumération pour les événements de groupe
enum GroupEventType {
  groupCreated,
  groupJoined,
  groupRestored,
  groupLeft,
  memberJoined,
  memberLeft,
  memberDiscovered,
  memberConnected,
  permissionDenied,
  bluetoothEnabled,
  bluetoothDisabled,
  error,
}

// Classe pour les événements de groupe
class GroupEvent extends Equatable {
  final GroupEventType type;
  final String data;

  const GroupEvent({
    required this.type,
    required this.data,
  });

  @override
  List<Object?> get props => [type, data];
}
