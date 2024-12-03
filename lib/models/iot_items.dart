class IoTItem {
  final String sensorName;
  final int distance;
  final bool isFall;
  final DateTime timestamp;

  IoTItem({
    required this.sensorName,
    required this.distance,
    required this.isFall,
    required this.timestamp,
  });

  factory IoTItem.fromJson(String sensorName, Map<String, dynamic> json, date) {

    return IoTItem(
      sensorName: sensorName,
      distance: json['Distance'] ?? 0, 
      isFall: json['IsFall'] ?? false, 
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json['Timestamp'] ?? 0) * 1000)
    );
  }
  IoTItem copyWith({
    String? sensorName,
    int? distance,
    bool? isFall,
    DateTime? timestamp,
  }) {
    return IoTItem(
      sensorName: sensorName ?? this.sensorName,
      distance: distance ?? this.distance,
      isFall: isFall ?? this.isFall,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
