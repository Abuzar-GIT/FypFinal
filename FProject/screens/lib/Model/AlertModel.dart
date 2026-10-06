class AlertModel {
  final int alertId;
  final int accidentId;
  final String victimUid;
  final String victimName;
  final String victimContact;
  final String vehicleMake;
  final String registrationNo;
  final String impactSide;
  final String relationship;
  final String location;
  final double impactForce;
  final double cabinForce;
  final String severity;
  final DateTime time;
  final bool status;
  final String targetType;

  AlertModel({
    required this.alertId,
    required this.accidentId,
    required this.victimUid,
    required this.victimName,
    this.victimContact = "",
    this.vehicleMake = "Car",
    this.registrationNo = "-",
    this.impactSide = "Front",
    this.relationship = "Family Member",
    required this.location,
    required this.impactForce,
    required this.cabinForce,
    required this.severity,
    required this.time,
    required this.status,
    required this.targetType,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['Alert_Id'] ?? json['alert_Id'] ?? 0,
      accidentId: json['Accident_Id'] ?? json['accident_Id'] ?? 0,
      victimUid: json['VictimUid'] ?? json['victimUid'] ?? "Unknown",
      victimName: json['VictimName'] ?? json['victimName'] ?? (json['VictimUid'] ?? "Victim"),
      victimContact: json['VictimContact'] ?? json['victimContact'] ?? "",
      vehicleMake: json['VehicleMake'] ?? json['vehicleMake'] ?? "Car",
      registrationNo: json['RegistrationNo'] ?? json['registrationNo'] ?? "-",
      impactSide: json['ImpactSide'] ?? json['impactSide'] ?? "Front",
      relationship: json['Relationship'] ?? json['relationship'] ?? "Family Member",
      location: json['Location'] ?? json['location'] ?? "Unknown",
      impactForce: (json['ImpactForce'] ?? json['impactForce'] ?? 0).toDouble(),
      cabinForce: (json['CabinForce'] ?? json['cabinForce'] ?? 0).toDouble(),
      severity: json['Severity'] ?? json['severity'] ?? "High",
      time: DateTime.tryParse(json['Time'] ?? json['time'] ?? '') ?? DateTime.now(),
      status: json['Status'] ?? json['status'] ?? false,
      targetType: json['TargetType'] ?? json['targetType'] ?? "Alert",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Alert_Id': alertId,
      'Accident_Id': accidentId,
      'VictimUid': victimUid,
      'VictimName': victimName,
      'VictimContact': victimContact,
      'VehicleMake': vehicleMake,
      'RegistrationNo': registrationNo,
      'ImpactSide': impactSide,
      'Relationship': relationship,
      'Location': location,
      'ImpactForce': impactForce,
      'CabinForce': cabinForce,
      'Severity': severity,
      'Time': time.toIso8601String(),
      'Status': status,
      'TargetType': targetType,
    };
  }
}
