import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:screens/Model/CarModel.dart';
import 'package:screens/Model/UserModel.dart';
import 'package:screens/Model/AlertModel.dart';
import 'package:screens/Model/FamilyMemberModel.dart';

class ApiInterface {
  static String ip = "192.168.31.189";
  // 192.168.0.109
  static String get baseUrl {
    final raw = ip.trim().isNotEmpty ? ip.trim() : "192.168.31.189";
    final clean = raw
        .replaceFirst(RegExp(r'^https?:\/\/'), '')
        .replaceAll(RegExp(r'\/+$'), '');
    return "http://$clean/AccidentDetectionApi/api";
  }
  // muj
  //static const baseUrl = "http://10.230.211.245/AccidentDetectionApi/api";
  //static const baseUrl = "http://192.168.0.102/FypApi1/api";

  Null get gyroY => null;

  Null get gyroX => null;
  //
  //static const baseUrl = "http://localhost/FinalApi/api";

  static Future<String> CreateUser(Usermodel userData) async {
    var url = Uri.parse('$baseUrl/Auth/CreateUser');

    try {
      http.Response response = await http.post(
        url,
        body: jsonEncode(userData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      switch (response.statusCode) {
        case 200:
          return response.body;
        case 409:
          throw Exception("User already exists");
        default:
          throw Exception(
            "Server error ${response.statusCode}: ${response.body}",
          );
      }
    } on Exception {
      rethrow; // ✅ re-throws cleanly without wrapping
    } catch (e) {
      throw Exception('Unexpected error: $e'); // only for non-Exception errors
    }
  }

  //forget Password
  static Future<http.Response> ForgetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    var url = Uri.parse(
      "$baseUrl/Auth/ForgotPassword?email=$email&newPassword=$newPassword&confirmPassword=$confirmPassword",
    );
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
    return response;
  }

  ////////////// bring vehicle from db
  static Future<List<Cars>> ShowVechile(String userEmail) async {
    var url = Uri.parse(
      "$baseUrl/UserSelectVehicle/showVehicle?email=$userEmail",
    );
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Cars> vechiles = body.map((e) => Cars.fromJson(e)).toList();
      return vechiles;
    } else {
      throw Exception('Failed to load vechiles');
    }
  }

  ///   addVechile
  static Future<http.Response> addVehicle(
    String email,
    String plate,
    int categoryId,
    String make,
    String carType,
    String driverSide, // optional
  ) async {
    var url = Uri.parse("$baseUrl/UserSelectVehicle/AddVehicle");

    var body = jsonEncode({
      "Registration_No": plate.trim().toUpperCase(),
      "Make": make.trim(),
      "Uid": email.trim(),
      "Category_Id": categoryId,
      "Steering_Side": driverSide.trim(),
    });

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  ///delete veh
  static Future<http.Response> DeleteVehicle(int carId) async {
    var url = Uri.parse(
      "$baseUrl/UserSelectVehicle/DeleteVehicle?carId=$carId",
    );

    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// send sensor data
  // Future<void> sendToApi(String impactSide, double force, double damage) async {
  //   try {
  //     await http.post(
  //       Uri.parse("${baseUrl}/sensor/add"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         // "email": email,
  //         "impactSide": impactSide,
  //         "force": force,
  //         "cabinDamage": damage,
  //         "status": damage > 0 ? "Accident" : "Safe",
  //         "timestamp": DateTime.now().toIso8601String(),
  //       }),
  //     );
  //   } catch (e) {
  //     print("API Error: $e");
  //   }
  // }
  // Future<void> sendToApi(
  //   String impactSide,
  //   double acceleration,
  //   double damage,
  //   Position position,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("${ApiInterface.baseUrl}/Location/AddAccident"), // ✅ FIXED
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "Car_Id": 1,
  //         "Impact_Side": impactSide,
  //         "Acceleration": acceleration,
  //         "GyroX": gyroX,
  //         "GyroY": gyroY,
  //         "Location": "${position.latitude}, ${position.longitude}",
  //       }),
  //     );

  //     print("Status: ${response.statusCode}");
  //     print("Body: ${response.body}");
  //   } catch (e) {
  //     print("API Error: $e");
  //   }
  // }

  static Future<dynamic> fetchLatestSensor() async {
    final response = await http.get(Uri.parse("$baseUrl/Location/latest"));

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse(
      "$baseUrl/Auth/Login?email=${Uri.encodeComponent(email)}&pas=${Uri.encodeComponent(password)}",
    );

    final response = await http.post(url);

    return response;
  }

  // ================= GET VEHICLE INFO =================
  // static Future<Map<String, dynamic>> getVehicle(int carId) async {
  //   try {
  //     final url = Uri.parse("$baseUrl/Vehicle/Get?carId=$carId");

  //     final response = await http.get(url);

  //     final data = jsonDecode(response.body);

  //     return {"status": response.statusCode, "data": data};
  //   } catch (error) {
  //     return {"status": 0, "data": error.toString()};
  //   }
  // }

  ////////////impect send
  ///

  static Future<void> sendImpact({
    required int carId,
    required double acceleration,
    required double gyroX,
    required double gyroY,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/DetectAccident/ImpactCalculation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Car_Id": carId,
          "Acceleration": acceleration,
          "GyroX": gyroX,
          "GyroY": gyroY,
          "Latitude": latitude,
          "Longitude": longitude,
        }),
      );

      print("API STATUS: ${response.statusCode}");
      print("API BODY: ${response.body}");
    } catch (e) {
      print("API ERROR: $e");
    }
  }

  // ================= RESCUE APIS =================

  /// Register a new Rescue Team with Password and initial GPS Location
  static Future<http.Response> rescueRegister({
    required String password,
    String? location,
  }) async {
    final url = Uri.parse("$baseUrl/Rescue/Register");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Password": password.trim(),
        "Location": location?.trim(),
      }),
    );
  }

  /// Authenticate Rescue Team and update its current location
  static Future<http.Response> rescueLogin({
    required int rid,
    required String password,
    String? location,
  }) async {
    final url = Uri.parse("$baseUrl/Rescue/Login");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Rid": rid,
        "Password": password.trim(),
        "Location": location?.trim(),
      }),
    );
  }

  /// Update Rescue Team location
  static Future<http.Response> rescueUpdateLocation({
    required int rid,
    required String location,
  }) async {
    final url = Uri.parse("$baseUrl/Rescue/UpdateLocation");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Rid": rid, "Location": location.trim()}),
    );
  }

  // ================= FAMILY MEMBER APIS =================

  /// Add another user as family member / guardian
  static Future<http.Response> addFamilyMember({
    required String uid,
    required String guardianId,
    required String relationship,
  }) async {
    final url = Uri.parse("$baseUrl/FamilyMembers/Add");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Uid": uid.trim(),
        "Guardian_Id": guardianId.trim(),
        "Relationship": relationship.trim(),
      }),
    );
  }

  /// Get list of guardians added for a user
  static Future<List<FamilyMemberModel>> getGuardians(String uid) async {
    final url = Uri.parse(
      "$baseUrl/FamilyMembers/GetGuardians?uid=${Uri.encodeComponent(uid.trim())}",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => FamilyMemberModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load guardians: ${response.statusCode}");
    }
  }

  // ================= ALERTS APIS =================

  /// Get active unread alerts for either Guardian (uid) or Rescue (rid)
  static Future<List<AlertModel>> getUnreadAlerts({
    String? uid,
    int? rid,
  }) async {
    String query = "";
    if (uid != null && uid.isNotEmpty) {
      query = "?uid=${Uri.encodeComponent(uid.trim())}";
    } else if (rid != null && rid > 0) {
      query = "?rid=$rid";
    }

    final url = Uri.parse("$baseUrl/Alerts/Unread$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => AlertModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load alerts: ${response.statusCode}");
    }
  }

  /// Mark an alert as seen in database
  static Future<bool> markAlertAsSeen(int alertId) async {
    try {
      final url = Uri.parse("$baseUrl/Alerts/MarkAsSeen");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Alert_Id": alertId}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        // Fallback to MarkAsRead if needed
        return await markAlertAsRead(alertId);
      }
    } catch (e) {
      print("Error marking alert as seen: $e");
      return false;
    }
  }

  /// Mark an alert as read so it will not appear again
  static Future<bool> markAlertAsRead(int alertId) async {
    try {
      final url = Uri.parse("$baseUrl/Alerts/MarkAsRead");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Alert_Id": alertId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking alert as read: $e");
      return false;
    }
  }
}
