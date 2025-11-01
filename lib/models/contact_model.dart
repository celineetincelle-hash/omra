class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String description;
  final ContactType type;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.type,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      description: map['description'] ?? '',
      type: ContactType.values.firstWhere(
        (e) => e.toString() == 'ContactType.${map['type']}',
        orElse: () => ContactType.other,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'description': description,
      'type': type.toString().split('.').last,
    };
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? description,
    ContactType? type,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
}

enum ContactType {
  guide,
  agency,
  embassy,
  emergency,
  other,
}

