// class NodePositionPreset {
//   final String name;
//   final String force;
//   final double left;
//   final double top;

//   const NodePositionPreset({
//     required this.name,
//     required this.force,
//     required this.left,
//     required this.top,
//   });
// }

// class SensorNodeConfig {
//   final int id;
//   String name;
//   String force;
//   double left;
//   double top;
//   int? categoryId;

//   SensorNodeConfig({
//     required this.id,
//     required this.name,
//     required this.force,
//     required this.left,
//     required this.top,
//     this.categoryId,
//   });

//   Map<String, dynamic> toJson() => {
//     "Node_Id": id,
//     "Category_Id": categoryId,
//     "Node_Position": name,
//     "Force": double.tryParse(force) ?? 0.0,
//   };

//   factory SensorNodeConfig.fromJson(Map<String, dynamic> json) {
//     return SensorNodeConfig(
//       id: json["Node_Id"] ?? json["node_Id"] ?? json["id"] ?? 0,
//       name:
//           (json["Node_Position"] ?? json["node_Position"] ?? json["name"] ?? "")
//               .toString(),
//       force: (json["Force"] ?? json["force"] ?? "0").toString(),
//       left: (json["left"] as num?)?.toDouble() ?? 50.0,
//       top: (json["top"] as num?)?.toDouble() ?? 50.0,
//       categoryId: json["Category_Id"] ?? json["category_Id"],
//     );
//   }

//   SensorNodeConfig copyWith({
//     int? id,
//     String? name,
//     String? force,
//     double? left,
//     double? top,
//     int? categoryId,
//   }) {
//     return SensorNodeConfig(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       force: force ?? this.force,
//       left: left ?? this.left,
//       top: top ?? this.top,
//       categoryId: categoryId ?? this.categoryId,
//     );
//   }
// }

// int getNodeCountByCarType(String type) {
//   final clean = type.trim().toLowerCase();
//   if (clean == "suv") return 26;
//   if (clean == "hatchback") return 23;
//   return 30; // Sedan default
// }

// const Map<String, Map<int, NodePositionPreset>> masterNodesData = {
//   "sedan": {
//     1: NodePositionPreset(
//       name: "Front Bumper Center / Grille",
//     //  force: "3.00",
//       left: 51.36,
//       top: 3.13,
//     ),

//     2: NodePositionPreset(
//       name: "Front Left Headlight / Corner",
//       force: "2.00",
//       left: 25.37,
//       top: 9.82,
//     ),

//     3: NodePositionPreset(
//       name: "Front Right Headlight / Corner",
//       force: "2.00",
//       left: 77.43,
//       top: 9.67,
//     ),

//     4: NodePositionPreset(
//       name: "Engine Hood / Bonnet",
//       force: "2.00",
//       left: 51.37,
//       top: 13.73,
//     ),

//     5: NodePositionPreset(
//       name: "Windshield Base / Cowl",
//       force: "2.00",
//       left: 51.38,
//       top: 24.14,
//     ),

//     6: NodePositionPreset(
//       name: "Left A-Pillar (Lower / Front Fender Area)",
//       force: "2.00",
//       left: 27.06,
//       top: 26.58,
//     ),

//     7: NodePositionPreset(
//       name: "Right A-Pillar (Lower / Front Fender Area)",
//       force: "2.00",
//       left: 75.77,
//       top: 26.58,
//     ),

//     8: NodePositionPreset(
//       name: "Left Side Mirror / Front Door Forward Anchor",
//       force: "2.00",
//       left: 26.30,
//       top: 34.51,
//     ),

//     9: NodePositionPreset(
//       name: "Right Side Mirror / Front Door Forward Anchor",
//       force: "2.00",
//       left: 77.29,
//       top: 34.66,
//     ),

//     10: NodePositionPreset(
//       name: "Left A-Pillar (Upper / Windshield Frame)",
//       force: "2.00",
//       left: 32.95,
//       top: 40.52,
//     ),

//     11: NodePositionPreset(
//       name: "Right A-Pillar (Upper / Windshield Frame)",
//       force: "2.00",
//       left: 70.49,
//       top: 40.37,
//     ),

//     12: NodePositionPreset(
//       name: "Front Roof Crossmember / Header",
//       force: "2.00",
//       left: 51.36,
//       top: 41.72,
//     ),

//     13: NodePositionPreset(
//       name: "Main Roof Panel / Cabin Overhead",
//       force: "2.00",
//       left: 51.33,
//       top: 57.49,
//     ),

//     14: NodePositionPreset(
//       name: "Left B-Pillar (Upper / Center Roof Rail)",
//       force: "2.00",
//       left: 34.25,
//       top: 54.62,
//     ),

//     15: NodePositionPreset(
//       name: "Left B-Pillar (Exterior Side / Door Pillar)",
//       force: "2.00",
//       left: 23.13,
//       top: 53.32,
//     ),

//     16: NodePositionPreset(
//       name: "Right B-Pillar (Upper / Center Roof Rail)",
//       force: "2.00",
//       left: 70.50,
//       top: 54.62,
//     ),

//     17: NodePositionPreset(
//       name: "Right B-Pillar (Exterior Side / Door Pillar)",
//       force: "2.00",
//       left: 79.79,
//       top: 53.15,
//     ),

//     18: NodePositionPreset(
//       name: "Left C-Pillar (Upper / Rear Roof Rail)",
//       force: "2.00",
//       left: 33.66,
//       top: 65.49,
//     ),

//     19: NodePositionPreset(
//       name: "Left Rear Door / Quarter Panel Joint",
//       force: "2.00",
//       left: 23.72,
//       top: 71.05,
//     ),

//     20: NodePositionPreset(
//       name: "Right C-Pillar (Upper / Rear Roof Rail)",
//       force: "2.00",
//       left: 70.95,
//       top: 65.48,
//     ),

//     21: NodePositionPreset(
//       name: "Right Rear Door / Quarter Panel Joint",
//       force: "2.00",
//       left: 79.86,
//       top: 71.35,
//     ),

//     22: NodePositionPreset(
//       name: "Rear Windshield Top / Header",
//       force: "2.00",
//       left: 51.38,
//       top: 71.64,
//     ),

//     23: NodePositionPreset(
//       name: "Rear Windshield / Trunk Lid (Boot Lid)",
//       force: "2.00",
//       left: 51.38,
//       top: 81.07,
//     ),

//     24: NodePositionPreset(
//       name: "Left Rear Quarter Panel / C-Pillar Lower",
//       force: "2.00",
//       left: 31.68,
//       top: 77.21,
//     ),

//     25: NodePositionPreset(
//       name: "Right Rear Quarter Panel / C-Pillar Lower",
//       force: "2.00",
//       left: 73.57,
//       top: 77.21,
//     ),

//     26: NodePositionPreset(
//       name: "Left Rear Fender / Wheel Arch Area",
//       force: "2.00",
//       left: 27.62,
//       top: 84.93,
//     ),

//     27: NodePositionPreset(
//       name: "Right Rear Fender / Wheel Arch Area",
//       force: "2.00",
//       left: 76.35,
//       top: 84.95,
//     ),

//     28: NodePositionPreset(
//       name: "Rear Left Bumper Corner / Taillight",
//       force: "2.00",
//       left: 31.64,
//       top: 92.24,
//     ),

//     29: NodePositionPreset(
//       name: "Rear Right Bumper Corner / Taillight",
//       force: "2.00",
//       left: 72.42,
//       top: 92.24,
//     ),

//     30: NodePositionPreset(
//       name: "Rear Bumper Center",
//       force: "2.00",
//       left: 51.33,
//       top: 95.63,
//     ),
//   },
//   "suv": {
//     1: NodePositionPreset(
//       name: "Front Bumper Center / Grille",
//       force: "15.00",
//       left: 48.55,
//       top: 4.25,
//     ),

//     2: NodePositionPreset(
//       name: "Front Right Headlight / Corner",
//       force: "16.00",
//       left: 75.07,
//       top: 6.36,
//     ),

//     3: NodePositionPreset(
//       name: "Front Left Headlight / Corner",
//       force: "16.00",
//       left: 21.29,
//       top: 7.99,
//     ),

//     4: NodePositionPreset(
//       name: "Windshield Base Center / Cowl",
//       force: "14.00",
//       left: 48.07,
//       top: 22.98,
//     ),

//     5: NodePositionPreset(
//       name: "Left Front Fender / A-Pillar Lower Anchor",
//       force: "13.00",
//       left: 19.10,
//       top: 27.01,
//     ),

//     6: NodePositionPreset(
//       name: "Right Front Fender / A-Pillar Lower Anchor",
//       force: "13.00",
//       left: 79.22,
//       top: 27.75,
//     ),

//     7: NodePositionPreset(
//       name: "Left Windshield Pillar (A-Pillar Base)",
//       force: "12.00",
//       left: 24.95,
//       top: 34.04,
//     ),

//     8: NodePositionPreset(
//       name: "Windshield Header Center / Front Roof Rail",
//       force: "18.00",
//       left: 48.30,
//       top: 33.15,
//     ),

//     9: NodePositionPreset(
//       name: "Right Windshield Pillar (A-Pillar Base)",
//       force: "12.00",
//       left: 72.38,
//       top: 34.05,
//     ),

//     10: NodePositionPreset(
//       name: "Left Front Door / Exterior B-Pillar Outer",
//       force: "11.00",
//       left: 16.86,
//       top: 48.41,
//     ),

//     11: NodePositionPreset(
//       name: "Left Side Roof Rail (B-Pillar Upper)",
//       force: "10.00",
//       left: 24.24,
//       top: 48.24,
//     ),

//     12: NodePositionPreset(
//       name: "Right Side Roof Rail (B-Pillar Upper)",
//       force: "10.00",
//       left: 73.30,
//       top: 48.10,
//     ),

//     13: NodePositionPreset(
//       name: "Right Front Door / Exterior B-Pillar Outer",
//       force: "11.00",
//       left: 80.52,
//       top: 47.81,
//     ),

//     14: NodePositionPreset(
//       name: "Main Roof Center Panel",
//       force: "17.00",
//       left: 48.25,
//       top: 55.15,
//     ),

//     15: NodePositionPreset(
//       name: "Left Rear Roof Rail (C-Pillar Upper)",
//       force: "9.00",
//       left: 23.98,
//       top: 62.47,
//     ),

//     16: NodePositionPreset(
//       name: "Right Rear Roof Rail (C-Pillar Upper)",
//       force: "9.00",
//       left: 73.09,
//       top: 63.06,
//     ),

//     17: NodePositionPreset(
//       name: "Left Rear Door / Side Body Panel",
//       force: "8.00",
//       left: 16.15,
//       top: 67.87,
//     ),

//     18: NodePositionPreset(
//       name: "Right Rear Door / Side Body Panel",
//       force: "8.00",
//       left: 81.20,
//       top: 66.82,
//     ),

//     19: NodePositionPreset(
//       name: "Left C/D-Pillar / Quarter Panel Joint",
//       force: "7.00",
//       left: 21.99,
//       top: 78.20,
//     ),

//     20: NodePositionPreset(
//       name: "Rear Roof Crossmember / Antennas Area",
//       force: "7.00",
//       left: 48.54,
//       top: 77.00,
//     ),

//     21: NodePositionPreset(
//       name: "Right C/D-Pillar / Quarter Panel Joint",
//       force: "7.00",
//       left: 76.08,
//       top: 78.19,
//     ),

//     22: NodePositionPreset(
//       name: "Rear Hatch / Tailgate Glass Header",
//       force: "9.00",
//       left: 48.30,
//       top: 84.62,
//     ),

//     23: NodePositionPreset(
//       name: "Rear Left Bumper Corner / Taillight",
//       force: "9.00",
//       left: 20.09,
//       top: 92.85,
//     ),

//     24: NodePositionPreset(
//       name: "Rear Center Spare Tire Mount / Trunk Lid",
//       force: "10.00",
//       left: 48.51,
//       top: 94.50,
//     ),

//     25: NodePositionPreset(
//       name: "Rear Right Bumper Corner / Taillight",
//       force: "9.00",
//       left: 78.03,
//       top: 93.01,
//     ),

//     26: NodePositionPreset(
//       name: "Hood Center / Engine Bay Core",
//       force: "13.00",
//       left: 48.55,
//       top: 14.78,
//     ),
//   },
//   "hatchback": {
//     1: NodePositionPreset(
//       name: "Front Bumper Center / Grille",
//       force: "8.00",
//       left: 44.75,
//       top: 4.04,
//     ),

//     2: NodePositionPreset(
//       name: "Front Left Headlight / Corner",
//       force: "12.00",
//       left: 27.08,
//       top: 9.08,
//     ),

//     3: NodePositionPreset(
//       name: "Front Right Headlight / Corner",
//       force: "12.00",
//       left: 64.52,
//       top: 9.09,
//     ),

//     4: NodePositionPreset(
//       name: "Engine Hood / Bonnet",
//       force: "15.00",
//       left: 44.57,
//       top: 14.78,
//     ),

//     5: NodePositionPreset(
//       name: "Windshield Base / Cowl",
//       force: "14.00",
//       left: 44.57,
//       top: 23.64,
//     ),

//     6: NodePositionPreset(
//       name: "Left A-Pillar (Lower / Front Fender Joint)",
//       force: "13.00",
//       left: 25.52,
//       top: 27.23,
//     ),

//     7: NodePositionPreset(
//       name: "Right A-Pillar (Lower / Front Fender Joint)",
//       force: "13.00",
//       left: 65.93,
//       top: 27.10,
//     ),

//     8: NodePositionPreset(
//       name: "Left A-Pillar (Upper / Windshield Frame)",
//       force: "11.00",
//       left: 30.24,
//       top: 36.53,
//     ),

//     9: NodePositionPreset(
//       name: "Front Roof Crossmember / Windshield Header Center",
//       force: "10.00",
//       left: 45.26,
//       top: 36.53,
//     ),

//     10: NodePositionPreset(
//       name: "Right A-Pillar (Upper / Windshield Frame)",
//       force: "11.00",
//       left: 60.51,
//       top: 35.93,
//     ),

//     11: NodePositionPreset(
//       name: "Left Side Mirror / Front Door Upper Edge",
//       force: "9.00",
//       left: 26.20,
//       top: 50.93,
//     ),

//     12: NodePositionPreset(
//       name: "Right Side Mirror / Front Door Upper Edge",
//       force: "9.00",
//       left: 65.57,
//       top: 49.13,
//     ),

//     13: NodePositionPreset(
//       name: "Left B-Pillar (Roof Rail / Upper Pillar)",
//       force: "8.00",
//       left: 31.10,
//       top: 55.60,
//     ),

//     14: NodePositionPreset(
//       name: "Main Roof Center Panel",
//       force: "10.00",
//       left: 45.47,
//       top: 53.18,
//     ),

//     15: NodePositionPreset(
//       name: "Right B-Pillar (Roof Rail / Upper Pillar)",
//       force: "8.00",
//       left: 61.89,
//       top: 53.93,
//     ),

//     16: NodePositionPreset(
//       name: "Left Rear Door / B-Pillar Lower Outer",
//       force: "7.00",
//       left: 24.26,
//       top: 70.43,
//     ),

//     17: NodePositionPreset(
//       name: "Right Rear Door / B-Pillar Lower Outer",
//       force: "7.00",
//       left: 65.76,
//       top: 70.75,
//     ),

//     18: NodePositionPreset(
//       name: "Left C-Pillar (Upper Roof Rail Joint)",
//       force: "6.00",
//       left: 31.40,
//       top: 76.89,
//     ),

//     19: NodePositionPreset(
//       name: "Rear Roof Crossmember / Hatch Header Center",
//       force: "6.00",
//       left: 44.91,
//       top: 75.85,
//     ),

//     20: NodePositionPreset(
//       name: "Right C-Pillar (Upper Roof Rail Joint)",
//       force: "6.00",
//       left: 58.74,
//       top: 75.85,
//     ),

//     21: NodePositionPreset(
//       name: "Rear Left Quarter Panel / C-Pillar Lower",
//       force: "6.00",
//       left: 26.91,
//       top: 87.84,
//     ),

//     22: NodePositionPreset(
//       name: "Rear Right Quarter Panel / C-Pillar Lower",
//       force: "5.00",
//       left: 64.37,
//       top: 87.41,
//     ),

//     23: NodePositionPreset(
//       name: "Rear Bumper Center / Tailgate Base",
//       force: "7.00",
//       left: 45.60,
//       top: 92.39,
//     ),
//   },
// };

class NodePositionPreset {
  final String name;
  final double left;
  final double top;

  const NodePositionPreset({
    required this.name,
    required this.left,
    required this.top,
  });
}

class SensorNodeConfig {
  final int id;
  String name;

  // Force MUST come from database/API.
  String force;

  double left;
  double top;
  int? categoryId;

  SensorNodeConfig({
    required this.id,
    required this.name,
    required this.force,
    required this.left,
    required this.top,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    "Node_Id": id,
    "Category_Id": categoryId,
    "Node_Position": name,

    // Database/API value
    "Force": double.tryParse(force) ?? 0.0,
  };

  factory SensorNodeConfig.fromJson(Map<String, dynamic> json) {
    return SensorNodeConfig(
      id: json["Node_Id"] /* ?? json["node_Id"] ?? json["id"] ?? 0*/,

      name:
          (json["Node_Position"] /*?? json["node_Position"] ?? json["name"] ?? ""*/ )
              .toString(),

      // FORCE COMES FROM DATABASE
      force: (json["Force"] /* ?? json["force"] ?? "0"*/ ).toString(),

      // Position can come from API if available
      left: (json["left"] as num?)?.toDouble() ?? 50.0,
      top: (json["top"] as num?)?.toDouble() ?? 50.0,

      categoryId: json["Category_Id"] /*?? json["category_Id"]*/,
    );
  }

  SensorNodeConfig copyWith({
    int? id,
    String? name,
    String? force,
    double? left,
    double? top,
    int? categoryId,
  }) {
    return SensorNodeConfig(
      id: id ?? this.id,
      name: name ?? this.name,

      // Preserve database force
      force: force ?? this.force,

      left: left ?? this.left,
      top: top ?? this.top,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

// ============================================================
// NODE COUNT
// ============================================================
Map<int, NodePositionPreset> getVehicleNodes(String type) {
  return masterNodesData[type.trim().toLowerCase()] ?? {};
}

int getNodeCountByCarType(String type) {
  return getVehicleNodes(type).length;
}
// int getNodeCountByCarType(String type) {
//   final clean = type.trim().toLowerCase();

//   if (clean == "suv") {
//     return 26;
//   }

//   if (clean == "hatchback") {
//     return 23;
//   }

//   // Sedan default
//   return 30;
// }

const Map<String, Map<int, NodePositionPreset>> masterNodesData = {
  // ==========================================================
  // SEDAN
  // ==========================================================
  "sedan": {
    1: NodePositionPreset(
      name: "Front Bumper Center / Grille",
      left: 51.36,
      top: 3.13,
    ),

    2: NodePositionPreset(
      name: "Front Left Headlight / Corner",
      left: 25.37,
      top: 9.82,
    ),

    3: NodePositionPreset(
      name: "Front Right Headlight / Corner",
      left: 77.43,
      top: 9.67,
    ),

    4: NodePositionPreset(
      name: "Engine Hood / Bonnet",
      left: 51.37,
      top: 13.73,
    ),

    5: NodePositionPreset(
      name: "Windshield Base / Cowl",
      left: 51.38,
      top: 24.14,
    ),

    6: NodePositionPreset(
      name: "Left A-Pillar (Lower / Front Fender Area)",
      left: 27.06,
      top: 26.58,
    ),

    7: NodePositionPreset(
      name: "Right A-Pillar (Lower / Front Fender Area)",
      left: 75.77,
      top: 26.58,
    ),

    8: NodePositionPreset(
      name: "Left Side Mirror / Front Door Forward Anchor",
      left: 26.30,
      top: 34.51,
    ),

    9: NodePositionPreset(
      name: "Right Side Mirror / Front Door Forward Anchor",
      left: 77.29,
      top: 34.66,
    ),

    10: NodePositionPreset(
      name: "Left A-Pillar (Upper / Windshield Frame)",
      left: 32.95,
      top: 40.52,
    ),

    11: NodePositionPreset(
      name: "Right A-Pillar (Upper / Windshield Frame)",
      left: 70.49,
      top: 40.37,
    ),

    12: NodePositionPreset(
      name: "Front Roof Crossmember / Header",
      left: 51.36,
      top: 41.72,
    ),

    13: NodePositionPreset(
      name: "Main Roof Panel / Cabin Overhead",
      left: 51.33,
      top: 57.49,
    ),

    14: NodePositionPreset(
      name: "Left B-Pillar (Upper / Center Roof Rail)",
      left: 34.25,
      top: 54.62,
    ),

    15: NodePositionPreset(
      name: "Left B-Pillar (Exterior Side / Door Pillar)",
      left: 23.13,
      top: 53.32,
    ),

    16: NodePositionPreset(
      name: "Right B-Pillar (Upper / Center Roof Rail)",
      left: 70.50,
      top: 54.62,
    ),

    17: NodePositionPreset(
      name: "Right B-Pillar (Exterior Side / Door Pillar)",
      left: 79.79,
      top: 53.15,
    ),

    18: NodePositionPreset(
      name: "Left C-Pillar (Upper / Rear Roof Rail)",
      left: 33.66,
      top: 65.49,
    ),

    19: NodePositionPreset(
      name: "Left Rear Door / Quarter Panel Joint",
      left: 23.72,
      top: 71.05,
    ),

    20: NodePositionPreset(
      name: "Right C-Pillar (Upper / Rear Roof Rail)",
      left: 70.95,
      top: 65.48,
    ),

    21: NodePositionPreset(
      name: "Right Rear Door / Quarter Panel Joint",
      left: 79.86,
      top: 71.35,
    ),

    22: NodePositionPreset(
      name: "Rear Windshield Top / Header",
      left: 51.38,
      top: 71.64,
    ),

    23: NodePositionPreset(
      name: "Rear Windshield / Trunk Lid (Boot Lid)",
      left: 51.38,
      top: 81.07,
    ),

    24: NodePositionPreset(
      name: "Left Rear Quarter Panel / C-Pillar Lower",
      left: 31.68,
      top: 77.21,
    ),

    25: NodePositionPreset(
      name: "Right Rear Quarter Panel / C-Pillar Lower",
      left: 73.57,
      top: 77.21,
    ),

    26: NodePositionPreset(
      name: "Left Rear Fender / Wheel Arch Area",
      left: 27.62,
      top: 84.93,
    ),

    27: NodePositionPreset(
      name: "Right Rear Fender / Wheel Arch Area",
      left: 76.35,
      top: 84.95,
    ),

    28: NodePositionPreset(
      name: "Rear Left Bumper Corner / Taillight",
      left: 31.64,
      top: 92.24,
    ),

    29: NodePositionPreset(
      name: "Rear Right Bumper Corner / Taillight",
      left: 72.42,
      top: 92.24,
    ),

    30: NodePositionPreset(name: "Rear Bumper Center", left: 51.33, top: 95.63),
  },

  ////
  ///

  // ==========================================================
  // SUV
  // ==========================================================
  "suv": {
    1: NodePositionPreset(
      name: "Front Bumper Center / Grille",
      left: 48.55,
      top: 4.25,
    ),

    2: NodePositionPreset(
      name: "Front Right Headlight / Corner",
      left: 75.07,
      top: 6.36,
    ),

    3: NodePositionPreset(
      name: "Front Left Headlight / Corner",
      left: 21.29,
      top: 7.99,
    ),

    4: NodePositionPreset(
      name: "Windshield Base Center / Cowl",
      left: 48.07,
      top: 22.98,
    ),

    5: NodePositionPreset(
      name: "Left Front Fender / A-Pillar Lower Anchor",
      left: 19.10,
      top: 27.01,
    ),

    6: NodePositionPreset(
      name: "Right Front Fender / A-Pillar Lower Anchor",
      left: 79.22,
      top: 27.75,
    ),

    7: NodePositionPreset(
      name: "Left Windshield Pillar (A-Pillar Base)",
      left: 24.95,
      top: 34.04,
    ),

    8: NodePositionPreset(
      name: "Windshield Header Center / Front Roof Rail",
      left: 48.30,
      top: 33.15,
    ),

    9: NodePositionPreset(
      name: "Right Windshield Pillar (A-Pillar Base)",
      left: 72.38,
      top: 34.05,
    ),

    10: NodePositionPreset(
      name: "Left Front Door / Exterior B-Pillar Outer",
      left: 16.86,
      top: 48.41,
    ),

    11: NodePositionPreset(
      name: "Left Side Roof Rail (B-Pillar Upper)",
      left: 24.24,
      top: 48.24,
    ),

    12: NodePositionPreset(
      name: "Right Side Roof Rail (B-Pillar Upper)",
      left: 73.30,
      top: 48.10,
    ),

    13: NodePositionPreset(
      name: "Right Front Door / Exterior B-Pillar Outer",
      left: 80.52,
      top: 47.81,
    ),

    14: NodePositionPreset(
      name: "Main Roof Center Panel",
      left: 48.25,
      top: 55.15,
    ),

    15: NodePositionPreset(
      name: "Left Rear Roof Rail (C-Pillar Upper)",
      left: 23.98,
      top: 62.47,
    ),

    16: NodePositionPreset(
      name: "Right Rear Roof Rail (C-Pillar Upper)",
      left: 73.09,
      top: 63.06,
    ),

    17: NodePositionPreset(
      name: "Left Rear Door / Side Body Panel",
      left: 16.15,
      top: 67.87,
    ),

    18: NodePositionPreset(
      name: "Right Rear Door / Side Body Panel",
      left: 81.20,
      top: 66.82,
    ),

    19: NodePositionPreset(
      name: "Left C/D-Pillar / Quarter Panel Joint",
      left: 21.99,
      top: 78.20,
    ),

    20: NodePositionPreset(
      name: "Rear Roof Crossmember / Antennas Area",
      left: 48.54,
      top: 77.00,
    ),

    21: NodePositionPreset(
      name: "Right C/D-Pillar / Quarter Panel Joint",
      left: 76.08,
      top: 78.19,
    ),

    22: NodePositionPreset(
      name: "Rear Hatch / Tailgate Glass Header",
      left: 48.30,
      top: 84.62,
    ),

    23: NodePositionPreset(
      name: "Rear Left Bumper Corner / Taillight",
      left: 20.09,
      top: 92.85,
    ),

    24: NodePositionPreset(
      name: "Rear Center Spare Tire Mount / Trunk Lid",
      left: 48.51,
      top: 94.50,
    ),

    25: NodePositionPreset(
      name: "Rear Right Bumper Corner / Taillight",
      left: 78.03,
      top: 93.01,
    ),

    26: NodePositionPreset(
      name: "Hood Center / Engine Bay Core",
      left: 48.55,
      top: 14.78,
    ),
  },

  // ==========================================================
  // HATCHBACK
  // ==========================================================
  "hatchback": {
    1: NodePositionPreset(
      name: "Front Bumper Center / Grille",
      left: 44.75,
      top: 4.04,
    ),

    2: NodePositionPreset(
      name: "Front Left Headlight / Corner",
      left: 27.08,
      top: 9.08,
    ),

    3: NodePositionPreset(
      name: "Front Right Headlight / Corner",
      left: 64.52,
      top: 9.09,
    ),

    4: NodePositionPreset(
      name: "Engine Hood / Bonnet",
      left: 44.57,
      top: 14.78,
    ),

    5: NodePositionPreset(
      name: "Windshield Base / Cowl",
      left: 44.57,
      top: 23.64,
    ),

    6: NodePositionPreset(
      name: "Left A-Pillar (Lower / Front Fender Joint)",
      left: 25.52,
      top: 27.23,
    ),

    7: NodePositionPreset(
      name: "Right A-Pillar (Lower / Front Fender Joint)",
      left: 65.93,
      top: 27.10,
    ),

    8: NodePositionPreset(
      name: "Left A-Pillar (Upper / Windshield Frame)",
      left: 30.24,
      top: 36.53,
    ),

    9: NodePositionPreset(
      name: "Front Roof Crossmember / Windshield Header Center",
      left: 45.26,
      top: 36.53,
    ),

    10: NodePositionPreset(
      name: "Right A-Pillar (Upper / Windshield Frame)",
      left: 60.51,
      top: 35.93,
    ),

    11: NodePositionPreset(
      name: "Left Side Mirror / Front Door Upper Edge",
      left: 26.20,
      top: 50.93,
    ),

    12: NodePositionPreset(
      name: "Right Side Mirror / Front Door Upper Edge",
      left: 65.57,
      top: 49.13,
    ),

    13: NodePositionPreset(
      name: "Left B-Pillar (Roof Rail / Upper Pillar)",
      left: 31.10,
      top: 55.60,
    ),

    14: NodePositionPreset(
      name: "Main Roof Center Panel",
      left: 45.47,
      top: 53.18,
    ),

    15: NodePositionPreset(
      name: "Right B-Pillar (Roof Rail / Upper Pillar)",
      left: 61.89,
      top: 53.93,
    ),

    16: NodePositionPreset(
      name: "Left Rear Door / B-Pillar Lower Outer",
      left: 24.26,
      top: 70.43,
    ),

    17: NodePositionPreset(
      name: "Right Rear Door / B-Pillar Lower Outer",
      left: 65.76,
      top: 70.75,
    ),

    18: NodePositionPreset(
      name: "Left C-Pillar (Upper Roof Rail Joint)",
      left: 31.40,
      top: 76.89,
    ),

    19: NodePositionPreset(
      name: "Rear Roof Crossmember / Hatch Header Center",
      left: 44.91,
      top: 75.85,
    ),

    20: NodePositionPreset(
      name: "Right C-Pillar (Upper Roof Rail Joint)",
      left: 58.74,
      top: 75.85,
    ),

    21: NodePositionPreset(
      name: "Rear Left Quarter Panel / C-Pillar Lower",
      left: 26.91,
      top: 87.84,
    ),

    22: NodePositionPreset(
      name: "Rear Right Quarter Panel / C-Pillar Lower",
      left: 64.37,
      top: 87.41,
    ),

    23: NodePositionPreset(
      name: "Rear Bumper Center / Tailgate Base",
      left: 45.60,
      top: 92.39,
    ),
  },
};
