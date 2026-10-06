import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:screens/Api/Api.dart';

class AdminApi {
  static String ip = "";
  static String get baseUrl {
    if (ip.trim().isNotEmpty) {
      return "http://${ip.trim()}/AccidentDetectionApi/api";
    }
    if (ApiInterface.baseUrl.trim().isNotEmpty) {
      return "http://${ApiInterface.ip.trim()}/AccidentDetectionApi/api";
    }
    return "http://localhost/AccidentDetectionApi/api";
  }

  // static const baseUrl = "http://10.70.53.245/FypApi1/api";
  static Future<http.Response> addType(String type, String weight) async {
    final url = Uri.parse('$baseUrl/admin/AddType');

    final response = await http.post(
      url,
      body: jsonEncode({"name": type, "weight": weight}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  //show type
  static Future<List<Map<String, dynamic>>> ShowTypes() async {
    final url = Uri.parse('$baseUrl/admin/showtypes');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load users");
    }
  }

  // ================= CONFIGURE NODES API =================
  /// Fetch nodes configuration and vehicle weight
  /// URL: api/ConfigureNodes/GetNodes?categoryId={categoryId}
  static Future<Map<String, dynamic>> getNodes(int categoryId) async {
    final url = Uri.parse(
      '$baseUrl/ConfigureNodes/GetNodes?categoryId=$categoryId',
    );
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch nodes: ${response.statusCode}");
    }
  }

  /// Save nodes configuration and vehicle weight
  /// URL: api/ConfigureNodes/SaveConfiguration?weight={weight}
  static Future<http.Response> saveConfiguration({
    required int categoryId,
    required String weight,
    required List<Map<String, dynamic>> payload,
  }) async {
    final cleanWeight = double.tryParse(weight) ?? 0.0;
    final url = Uri.parse(
      '$baseUrl/ConfigureNodes/SaveConfiguration?weight=$cleanWeight',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return response;
  }
}

// // import 'dart:convert';

// // import 'package:http/http.dart' as http;

// // class AdminApi {
// //   static const baseUrl = "http://10.0.2.2/FynApi/api";

// //   static Future<http.Response> addType(String type, String weight) async {
// //     final url = Uri.parse('$baseUrl/admin/AddType');

// //     final response = await http.post(
// //       url,
// //       body: jsonEncode({"name": type, "weight": weight}),
// //       headers: {
// //         'Content-Type': 'application/json',
// //         'Accept': 'application/json',
// //       },
// //     );
// //     return response;
// //   }

// //   //show type
// //   static Future<List<Map<String, dynamic>>> ShowTypes() async {
// //     final url = Uri.parse('$baseUrl/admin/showtypes');
// //     final response = await http.get(url);
// //     if (response.statusCode == 200) {
// //       final List<dynamic> data = jsonDecode(response.body);
// //       return data.cast<Map<String, dynamic>>();
// //     } else {
// //       throw Exception("Failed to load users");
// //     }
// //   }
// // }
// import 'dart:convert';

// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:main_project/Model/CarModel.dart';
// import 'package:main_project/Model/UserModel.dart';
// import 'package:main_project/Myscreen/Log_in.dart';

// class ApiInterface {
//   //static const baseUrl = "http://10.0.2.2/FinalApi/api";
//   //  10.122.90.245
//   //static const baseUrl = "http://192.168.0.104:55452/api";
//   //realdevice
//   static const baseUrl = "http://10.46.93.245/FinalApi/api";
//   //static const baseUrl = "http://10.25.76.245/FinalApi/api";
//   //static const baseUrl = "http://192.168.0.104/FinalApi/api";

//   get gyroY => null;

//   get gyroX => null;
//   //
//   //static const baseUrl = "http://localhost/FinalApi/api";

//   static Future<String> CreateUser(Usermodel userData) async {
//     var url = Uri.parse('$baseUrl/Auth/CreateUser');

//     try {
//       http.Response response = await http.post(
//         url,
//         body: jsonEncode(userData.toJson()),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       switch (response.statusCode) {
//         case 200:
//           return response.body;
//         case 409:
//           throw Exception("User already exists");
//         default:
//           throw Exception(
//             "Server error ${response.statusCode}: ${response.body}",
//           );
//       }
//     } on Exception {
//       rethrow; // ✅ re-throws cleanly without wrapping
//     } catch (e) {
//       throw Exception('Unexpected error: $e'); // only for non-Exception errors
//     }
//   }

//   //login
//   static Future<http.Response> Login(String email, String password) async {
//     var url = Uri.parse('$baseUrl/Auth/Login?email=$email&pas=$password');
//     var response = await http.post(url);
//     print("Response Code: ${response.statusCode}");
//     print("Response Body: ${response.body}");
//     return (response);
//   }

//   // static Future<http.Response> Login(String email, String password) async {
//   //   var url = Uri.parse('$baseUrl/Auth/Login?email=$email&pas=$password');

//   //   var response = await http.post(
//   //     url,
//   //     headers: {"Content-Type": "application/json"},
//   //     // body: jsonEncode({"email": email, "pas": password}),
//   //   );

//   //   print("Response Code: ${response.statusCode}");
//   //   print("Response Body: ${response.body}");
//   //   return response;
//   // }

//   //forget Password
//   static Future<http.Response> ForgetPassword({
//     required String email,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     var url = Uri.parse(
//       "$baseUrl/Auth/ForgotPassword?email=$email&newPassword=$newPassword&confirmPassword=$confirmPassword",
//     );
//     var response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//     );
//     return response;
//   }

//   static Future<List<cars>> ShowVechile(String userEmail) async {
//     var url = Uri.parse(
//       "$baseUrl/UserSelectVehicle/showVehicle?email=$userEmail",
//     );
//     http.Response response = await http.get(url);
//     if (response.statusCode == 200) {
//       List<dynamic> body = jsonDecode(response.body);
//       List<cars> vechiles = body.map((e) => cars.fromJson(e)).toList();
//       return vechiles;
//     } else {
//       throw Exception('Failed to load vechiles');
//     }
//   }

//   ///   addVechile
//   // static Future<http.Response> addVehicle(
//   //   String email,
//   //   String registrationNo,
//   //   String type,
//   //   String model,
//   // ) async {
//   //   var url = Uri.parse(
//   //     "$baseUrl/UserSelectVehicle/AddVehicle"
//   //     "?email=$email&regno=$registrationNo&type=$type&model=$model",
//   //   );

//   //   return await http.post(url);
//   // }

//   static Future<http.Response> addVehicle(
//     String email,
//     String registrationNo,
//     String type,
//     String model,
//   ) async {
//     var url = Uri.parse("$baseUrl/UserSelectVehicle/AddVehicle");

//     return await http.post(
//       url,
//       body: jsonEncode({
//         "Uid": email,
//         "Registration_No": registrationNo,
//         "Make": model,
//         "Category": {"Name": type},
//       }),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
//   }

//   static Future<http.Response> DeleteVehicle(int carId) async {
//     var url = Uri.parse(
//       "$baseUrl/UserSelectVehicle/DeleteVehicle?carId=$carId",
//     );

//     return await http.delete(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
//   }

//   /// send sensor data
//   // Future<void> sendToApi(String impactSide, double force, double damage) async {
//   //   try {
//   //     await http.post(
//   //       Uri.parse("${baseUrl}/sensor/add"),
//   //       headers: {"Content-Type": "application/json"},
//   //       body: jsonEncode({
//   //         // "email": email,
//   //         "impactSide": impactSide,
//   //         "force": force,
//   //         "cabinDamage": damage,
//   //         "status": damage > 0 ? "Accident" : "Safe",
//   //         "timestamp": DateTime.now().toIso8601String(),
//   //       }),
//   //     );
//   //   } catch (e) {
//   //     print("API Error: $e");
//   //   }
//   // }
//   // Future<void> sendToApi(
//   //   String impactSide,
//   //   double acceleration,
//   //   double damage,
//   //   Position position,
//   // ) async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse("${ApiInterface.baseUrl}/Location/AddAccident"), // ✅ FIXED
//   //       headers: {"Content-Type": "application/json"},
//   //       body: jsonEncode({
//   //         "Car_Id": 1,
//   //         "Impact_Side": impactSide,
//   //         "Acceleration": acceleration,
//   //         "GyroX": gyroX,
//   //         "GyroY": gyroY,
//   //         "Location": "${position.latitude}, ${position.longitude}",
//   //       }),
//   //     );

//   //     print("Status: ${response.statusCode}");
//   //     print("Body: ${response.body}");
//   //   } catch (e) {
//   //     print("API Error: $e");
//   //   }
//   // }

//   static Future<dynamic> fetchLatestSensor() async {
//     final response = await http.get(Uri.parse("$baseUrl/Location/latest"));

//     print("STATUS CODE: ${response.statusCode}");
//     print("BODY: ${response.body}");

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed: ${response.statusCode}");
//     }
//   }
// }
