import 'package:hive/hive.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 0)
class Medication extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dosage;

  @HiveField(3)
  List<String> times; // Times in HH:mm format

  @HiveField(4)
  String frequency; // daily, twice_daily, three_times_daily, custom

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.frequency,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times,
      'frequency': frequency,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: List<String>.from(json['times']),
      frequency: json['frequency'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
