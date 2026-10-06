import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screens/Myscreen/Log_in.dart';
import 'ConfigureNodes.dart';

class AdminDashboard extends StatefulWidget {
  final String email;
  const AdminDashboard({super.key, required this.email});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedVehicle = "SUV";
  var categoryMap = {
    "Sedan": {"id": 1, "model": "Toyota Corolla"},
    "SUV": {"id": 2, "model": "Honda CR-V"},
    "Hatchback": {"id": 3, "model": "Suzuki Swift"},
  };
  final List<Vehicle> vehicles = [
    Vehicle(
      title: "SUV",
      subtitle: "Sport Utility Vehicle",
      icon: "directions_car",
      color: "22c55e",
    ),
    Vehicle(
      title: "Sedan",
      subtitle: "Four-door Passenger Car",
      icon: "directions_car",
      color: "3b82f6",
    ),
    Vehicle(
      title: "Hatchback",
      subtitle: "Compact Car with Rear Door",
      icon: "directions_car",
      color: "f97316",
    ),
  ];

  void handleNavigate() {
    final selected = categoryMap[selectedVehicle]!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigureNodes(
          categoryId: selected["id"] as int,
          carName: selected["model"] as String,
          carType: selectedVehicle,
        ),
      ),
    );
  }

  Color hexToColor(String hex) {
    return Color(int.parse("0xff$hex"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f4f6),

      // ================= HEADER =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text("A", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Dashboard", style: TextStyle(color: Colors.black)),
                Text(
                  "Configure Sensors",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                );
              },
              child: const Icon(Icons.logout, color: Colors.black),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                "Select Vehicle",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              Text(
                "Choose a vehicle type and model to configure sensors",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 15),

              // VEHICLE LIST
              ...vehicles.map((v) {
                final isSelected = selectedVehicle == v.title;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicle = v.title ?? "";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: hexToColor(
                              v.color ?? "000000",
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: hexToColor(v.color ?? "000000"),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.title ?? "",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                v.subtitle ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 15),

              // SELECTED MODEL BOX
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Model",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      categoryMap[selectedVehicle]!["model"] as String,
                      style: TextStyle(color: Colors.grey),
                    ),

                    SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.all(14),
                        ),
                        child: Text("Configure Sensors"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Vehicle {
  String? title;
  String? subtitle;
  String? icon;
  String? color;

  Vehicle({this.title, this.subtitle, this.icon, this.color});

  Vehicle copyWith({
    String? title,
    String? subtitle,
    String? icon,
    String? color,
  }) {
    return Vehicle(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'subtitle': subtitle, 'icon': icon, 'color': color};
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      title: map['title'] as String?,
      subtitle: map['subtitle'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) =>
      Vehicle.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vehicle(title: $title, subtitle: $subtitle, icon: $icon, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        runtimeType == other.runtimeType &&
        title == other.title &&
        subtitle == other.subtitle &&
        icon == other.icon &&
        color == other.color;
  }

  @override
  int get hashCode {
    return title.hashCode ^ subtitle.hashCode ^ icon.hashCode ^ color.hashCode;
  }
}
