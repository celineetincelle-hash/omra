class HealthData {
  final DateTime timestamp;
  final double? heartRate;
  final double? oxygenLevel;
  final int? steps;
  final double? systolicBP;
  final double? diastolicBP;
  final double? temperature;

  HealthData({
    required this.timestamp,
    this.heartRate,
    this.oxygenLevel,
    this.steps,
    this.systolicBP,
    this.diastolicBP,
    this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'oxygenLevel': oxygenLevel,
      'steps': steps,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'temperature': temperature,
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['heartRate']?.toDouble(),
      oxygenLevel: json['oxygenLevel']?.toDouble(),
      steps: json['steps'],
      systolicBP: json['systolicBP']?.toDouble(),
      diastolicBP: json['diastolicBP']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
    );
  }

  bool hasAbnormalValues() {
    if (heartRate != null && (heartRate! > 100 || heartRate! < 60)) {
      return true;
    }
    if (oxygenLevel != null && oxygenLevel! < 95) {
      return true;
    }
    if (systolicBP != null && (systolicBP! > 140 || systolicBP! < 90)) {
      return true;
    }
    if (temperature != null && (temperature! > 38 || temperature! < 36)) {
      return true;
    }
    return false;
  }
}
