class Cars {
  final int carId;
  final String registrationNo;
  final String make;
  final String uName;
  final String? cName;
  final String driverSide;

  Cars({
    required this.carId,
    required this.registrationNo,
    required this.make,
    required this.uName,
    this.cName,
    required this.driverSide,
  });

  factory Cars.fromJson(Map<String, dynamic> json) {
    return Cars(
      carId: json['Car_Id'] ?? 0,
      registrationNo: json['Registration_No'] ?? "",
      make: json['Make'] ?? "",
      uName: json['UName'] ?? json['Uid'] ?? "",
      cName: json['CName']?.toString(),

      // Support multiple property names and case variations from backend
      driverSide: (json['Steering_Side'] ??
              json['steering_side'] ??
              json['steeringSide'] ??
              json['SteeringSide'] ??
              json['driverSide'] ??
              json['DriverSide'] ??
              "")
          .toString(),
    );
  }
}
