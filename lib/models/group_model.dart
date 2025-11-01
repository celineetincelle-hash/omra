class GroupModel {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final String qrCode;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isActive;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.qrCode,
    required this.memberIds,
    required this.createdAt,
    this.isActive = true,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      qrCode: map['qrCode'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'qrCode': qrCode,
      'memberIds': memberIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    String? qrCode,
    List<String>? memberIds,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      qrCode: qrCode ?? this.qrCode,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

