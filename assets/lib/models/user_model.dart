class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String groupId;
  final bool isAdmin;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.groupId,
    this.isAdmin = false,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      groupId: map['groupId'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLocationUpdate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'groupId': groupId,
      'isAdmin': isAdmin,
      'latitude': latitude,
      'longitude': longitude,
      'lastLocationUpdate': lastLocationUpdate?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? groupId,
    bool? isAdmin,
    double? latitude,
    double? longitude,
    DateTime? lastLocationUpdate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      groupId: groupId ?? this.groupId,
      isAdmin: isAdmin ?? this.isAdmin,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
}

