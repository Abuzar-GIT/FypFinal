class SensorData {
  final String impactSide;
  final String force;
  final double cabinDamage;
  final String lastEvent;

  SensorData({
    required this.impactSide,
    required this.force,
    required this.cabinDamage,
    required this.lastEvent,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      impactSide: json['impactSide'] ?? "-",
      force: json['force'] ?? "OFF",
      cabinDamage: (json['cabinDamage'] ?? 0).toDouble(),
      lastEvent: json['lastEvent'] ?? "-",
    );
  }
}
