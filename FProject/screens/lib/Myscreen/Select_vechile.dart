// //new
// import 'package:flutter/material.dart';
// import 'package:screens/Api/Api.dart';
// import 'package:screens/Model/CarModel.dart';
// import 'package:screens/Myscreen/newscreen.dart';
// import 'package:screens/Myscreen/alert_screen.dart';
// import 'package:screens/Myscreen/family_members_screen.dart';

// class VehicleScreen extends StatefulWidget {
//   const VehicleScreen({super.key, required this.email});
//   final String email;

//   @override
//   State<VehicleScreen> createState() => _VehicleScreenState();
// }

// class _VehicleScreenState extends State<VehicleScreen> {
//   final TextEditingController plateController = TextEditingController();

//   List<Cars> allVehicle = [];

//   bool isExpanded = false;
//   int carid = 0;

//   @override
//   void initState() {
//     super.initState();
//     loadVehicles();
//   }

//   void loadVehicles() async {
//     try {
//       allVehicle = await ApiInterface.ShowVechile(widget.email);
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint("Error loading vehicles: $e");
//     }
//   }

//   final List<String> carTypes = ["SUV", "Hatchback", "Sedan"];
//   final List<String> driverSides = ["Left-Hand", "Right-Hand"];

//   final Map<String, List<String>> carModels = {
//     "SUV": ["Honda CR-V", "Toyota Fortuner", "Kia Sportage"],
//     "Sedan": ["Honda Civic", "Toyota Corolla", "Hyundai Elantra"],
//     "Hatchback": ["Suzuki Alto", "Suzuki Swift", "Kia Picanto"],
//   };

//   String? selectedCarType;
//   String? selectedCarModel;
//   String? selectedDriverSide;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff5f5f5),
//       appBar: AppBar(
//         title: const Text("Select Vehicle"),
//         backgroundColor: const Color(0xFFFC840D),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.group_outlined),
//             tooltip: "Family Members & Guardians",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => FamilyMembersScreen(email: widget.email),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications_active_outlined),
//             tooltip: "Emergency Alerts",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       AlertScreen(isRescue: false, uid: widget.email),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // ================= GUARDIAN & EMERGENCY ALERT SHORTCUTS =================
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 FamilyMembersScreen(email: widget.email),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.orange.shade300),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.person_add_alt_1_rounded,
//                               color: Colors.orange.shade800,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 6),
//                             const Flexible(
//                               child: Text(
//                                 "Add Guardian",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 AlertScreen(isRescue: false, uid: widget.email),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.red.shade300),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.warning_amber_rounded,
//                               color: Colors.red.shade700,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 6),
//                             const Flexible(
//                               child: Text(
//                                 "Family Alerts",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                   color: Colors.red,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ShowVehicle(),
//               const SizedBox(height: 20),
//               buildAddVehicleForm(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// ================= CAR CARD =================
//   Widget buildCarCard({
//     required String title,
//     required String subtitle,
//     required String plate,
//     required int index,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: const BoxDecoration(
//                   color: Colors.orange,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.directions_car, color: Colors.white),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(subtitle, style: const TextStyle(color: Colors.grey)),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 onPressed: () async {
//                   carid = allVehicle[index].carId;
//                   try {
//                     var response = await ApiInterface.DeleteVehicle(carid);
//                     if (!mounted) return;

//                     if (response.statusCode == 200) {
//                       setState(() {
//                         allVehicle.removeAt(index);
//                       });

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Vehicle deleted successfully"),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Delete failed: ${response.body}"),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     if (!mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Error deleting vehicle: $e")),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text("Plate Number", style: TextStyle(color: Colors.grey)),
//           Text(
//             plate,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),
//           const SizedBox(height: 14),
//           SizedBox(
//             width: double.infinity,
//             child: SelectThisCar(allVehicle[index]),
//           ),
//         ],
//       ),
//     );
//   }

//   ///
//   ///
//   Widget SelectThisCar(Cars car) {
//     return ElevatedButton(
//       onPressed: () {
//         debugPrint("SELECTED CAR ID: ${car.carId}");
//         debugPrint("CAR CATEGORY: ${car.cName}");

//         String carType;

//         final category = car.cName?.toLowerCase().trim() ?? '';

//         if (category == 'suv') {
//           carType = 'SUV';
//         } else if (category == 'hatchback') {
//           carType = 'Hatchback';
//         } else if (category == 'sedan') {
//           carType = 'Sedan';
//         } else {
//           carType = 'Sedan';
//         }

//         debugPrint("SELECTED CAR TYPE: $carType");

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MonitoringScreen(
//               email: widget.email,
//               carId: car.carId,
//               make: car.make,
//               carType: carType,
//               plate: car.registrationNo,
//             ),
//           ),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         backgroundColor: Colors.orange,
//       ),
//       child: const Text("✓ Select This Car"),
//     );
//   }

//   /// ================= ADD VEHICLE FORM =================
//   Widget buildAddVehicleForm() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.orange, width: 1.5),
//         color: Colors.white,
//       ),
//       child: Column(
//         children: [
//           /// 🔴 HEADER BUTTON ONLY
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   isExpanded = !isExpanded;
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(isExpanded ? Icons.close : Icons.add),
//                   Text(isExpanded ? "" : " Add Vehicle"),
//                 ],
//               ),
//             ),
//           ),

//           /// 🔽 FULL FORM EXPAND / COLLAPSE
//           AnimatedCrossFade(
//             firstChild: const SizedBox.shrink(),
//             secondChild: _fullFormContent(),
//             crossFadeState: isExpanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 300),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ================= DROPDOWN TYPE =================
//   Widget dropdownCarType() {
//     return DropdownButtonFormField<String>(
//       initialValue: selectedCarType,
//       hint: const Text("Select car type"),
//       items: carTypes.map((type) {
//         return DropdownMenuItem(value: type, child: Text(type));
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           selectedCarType = value;
//           selectedCarModel = null;
//         });
//       },
//     );

//     /// ================= DROPDOWN MODEL =================
//   }

//   Widget dropdowndriver() {
//     return DropdownButtonFormField<String>(
//       initialValue: selectedDriverSide,
//       hint: const Text("Select driver side"),
//       items: driverSides.map((side) {
//         return DropdownMenuItem(value: side, child: Text(side));
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           selectedDriverSide = value;
//         });
//       },
//     );
//   }

//   /// ================= DROPDOWN MODEL =================
//   Widget dropdownCarModel() {
//     return DropdownButtonFormField<String>(
//       initialValue: selectedCarModel,
//       hint: const Text("Select car model"),
//       items: selectedCarType != null
//           ? carModels[selectedCarType!]!
//                 .map(
//                   (model) => DropdownMenuItem(value: model, child: Text(model)),
//                 )
//                 .toList()
//           : [],
//       onChanged: (value) {
//         setState(() {
//           selectedCarModel = value;
//         });
//       },
//     );
//   }

//   /// ================= ADD VEHICLE =================
//   void addVehicle() async {
//     final plate = plateController.text.trim().toUpperCase();

//     if (selectedCarType == null ||
//         selectedCarModel == null ||
//         selectedDriverSide == null ||
//         plate.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
//       return;
//     }
//     if (!isValidPlate(plate)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Plate format invalid (e.g. ABC-123 or ABC-1234)"),
//         ),
//       );
//       return;
//     }

//     // Database IDs: Sedan = 1, SUV = 2, Hatchback = 3
//     Map<String, int> category = {"Sedan": 1, "SUV": 2, "Hatchback": 3};
//     int categoryId = category[selectedCarType!] ?? 1;

//     try {
//       var data = await ApiInterface.addVehicle(
//         widget.email,
//         plate,
//         categoryId,
//         selectedCarModel!,
//         selectedCarType!,
//         selectedDriverSide!,
//       );
//       debugPrint("Status Code: ${data.statusCode}");
//       debugPrint("Body: ${data.body}");

//       if (!mounted) return;

//       if (data.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Vehicle Added Successfully")),
//         );
//         clearForm();
//         loadVehicles();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed (${data.statusCode}): ${data.body}")),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Network error: $e")));
//     }
//   }

//   /// ================= CLEAR FORM =================
//   void clearForm() {
//     setState(() {
//       selectedCarType = null;
//       selectedCarModel = null;
//       plateController.clear();
//       isExpanded = false;
//     });
//   }

//   ///
//   Widget _fullFormContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),

//         const Text("Car Type"),
//         const SizedBox(height: 6),
//         dropdownCarType(),
//         const SizedBox(height: 14),

//         const Text("Car Model"),
//         const SizedBox(height: 6),
//         dropdownCarModel(),

//         const Text("Steering Side"),
//         const SizedBox(height: 6),
//         dropdowndriver(),

//         const SizedBox(height: 14),

//         const SizedBox(height: 14),

//         const Text("Plate Number"),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: plateController,
//           decoration: InputDecoration(
//             hintText: "e.g. ABC-123 or ABC-1234",
//             filled: true,
//             fillColor: Colors.grey.shade200,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return "Plate number is required";
//             }
//             final regex = RegExp(r'^[A-Za-z]{2,4}[- ]?\d{3,4}$');
//             if (!regex.hasMatch(value.trim())) {
//               return "Format must be e.g. ABC-123 or ABC-1234";
//             }
//             return null;
//           },
//           onChanged: (value) {
//             plateController.value = plateController.value.copyWith(
//               text: value.toUpperCase(),
//               selection: TextSelection.collapsed(offset: value.length),
//             );
//           },
//         ),

//         const SizedBox(height: 16),

//         /// SAVE BUTTON
//         SizedBox(
//           width: double.infinity,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: addVehicle,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(150, 30),
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text(
//                   "Save Vehicle",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               OutlinedButton(
//                 onPressed: clearForm,
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(150, 30),
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// ================= SHOW VEHICLE =================
//   Widget ShowVehicle() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: allVehicle.length,
//       itemBuilder: (context, index) {
//         var car = allVehicle[index];

//         return buildCarCard(
//           title: car.cName ?? "No Name",
//           subtitle: car.make,
//           plate: car.registrationNo,
//           index: index,
//           driverSide: car.driverSide,
//         );
//       },
//     );
//   }

//   bool isValidPlate(String plate) {
//     return RegExp(r'^[A-Za-z]{2,4}[- ]?\d{3,4}$').hasMatch(plate.trim());
//   }
// }
import 'package:flutter/material.dart';
import 'package:screens/Api/Api.dart';
import 'package:screens/Model/CarModel.dart';
import 'package:screens/Myscreen/newscreen.dart';
import 'package:screens/Myscreen/alert_screen.dart';
import 'package:screens/Myscreen/family_members_screen.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key, required this.email});

  final String email;

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final TextEditingController plateController = TextEditingController();

  List<Cars> allVehicle = [];

  bool isExpanded = false;
  int carid = 0;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  void loadVehicles() async {
    try {
      allVehicle = await ApiInterface.ShowVechile(widget.email);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error loading vehicles: $e");
    }
  }

  final List<String> carTypes = ["SUV", "Hatchback", "Sedan"];

  final List<String> driverSides = ["Left-Hand", "Right-Hand"];

  final Map<String, List<String>> carModels = {
    "SUV": ["Honda CR-V", "Toyota Fortuner", "Kia Sportage"],
    "Sedan": ["Honda Civic", "Toyota Corolla", "Hyundai Elantra"],
    "Hatchback": ["Suzuki Alto", "Suzuki Swift", "Kia Picanto"],
  };

  String? selectedCarType;
  String? selectedCarModel;
  String? selectedDriverSide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text("Select Vehicle"),
        backgroundColor: const Color(0xFFFC840D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            tooltip: "Family Members & Guardians",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FamilyMembersScreen(email: widget.email),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: "Emergency Alerts",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AlertScreen(isRescue: false, uid: widget.email),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // ==================================================
              // GUARDIAN & EMERGENCY ALERT SHORTCUTS
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FamilyMembersScreen(email: widget.email),
                          ),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.orange.shade800,
                              size: 20,
                            ),

                            const SizedBox(width: 6),

                            const Flexible(
                              child: Text(
                                "Add Guardian",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AlertScreen(isRescue: false, uid: widget.email),
                          ),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              size: 20,
                            ),

                            const SizedBox(width: 6),

                            const Flexible(
                              child: Text(
                                "Family Alerts",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= VEHICLES =================
              ShowVehicle(),

              const SizedBox(height: 20),

              // ================= ADD VEHICLE =================
              buildAddVehicleForm(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAR CARD
  // ============================================================

  Widget buildCarCard({
    required String title,
    required String subtitle,
    required String plate,
    required int index,
    required String driverSide,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),

                child: const Icon(Icons.directions_car, color: Colors.white),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      subtitle + " - " + driverSide,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // ================= DELETE =================
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),

                onPressed: () async {
                  carid = allVehicle[index].carId;

                  try {
                    var response = await ApiInterface.DeleteVehicle(carid);

                    if (!mounted) return;

                    if (response.statusCode == 200) {
                      setState(() {
                        allVehicle.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vehicle deleted successfully"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Delete failed: ${response.body}"),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting vehicle: $e")),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ================= PLATE =================
          const Text("Plate Number", style: TextStyle(color: Colors.grey)),

          Text(
            plate,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          // ================= STEERING SIDE =================
          const SizedBox(height: 8),

          // const Text("Steering Side", style: TextStyle(color: Colors.grey)),

          // Text(
          //   _formatDriverSide(driverSide),
          //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          // ),
          //const SizedBox(height: 14),

          // ================= SELECT =================
          SizedBox(
            width: double.infinity,
            child: SelectThisCar(allVehicle[index]),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECT THIS CAR
  // ============================================================

  Widget SelectThisCar(Cars car) {
    return ElevatedButton(
      onPressed: () {
        debugPrint("SELECTED CAR ID: ${car.carId}");
        debugPrint("CAR CATEGORY: ${car.cName}, MAKE: ${car.make}");

        final catLower = (car.cName ?? '').toLowerCase().trim();
        final makeLower = car.make.toLowerCase().trim();

        String carType = 'Sedan';
        int categoryId = 1;

        if (catLower.contains('suv') ||
            makeLower.contains('suv') ||
            makeLower.contains('fortuner') ||
            makeLower.contains('cr-v') ||
            makeLower.contains('crv') ||
            makeLower.contains('sportage') ||
            makeLower.contains('prado') ||
            catLower == '2') {
          carType = 'SUV';
          categoryId = 2;
        } else if (catLower.contains('hatchback') ||
            makeLower.contains('hatchback') ||
            makeLower.contains('alto') ||
            makeLower.contains('swift') ||
            makeLower.contains('picanto') ||
            makeLower.contains('vitz') ||
            catLower == '3') {
          carType = 'Hatchback';
          categoryId = 3;
        } else {
          carType = 'Sedan';
          categoryId = 1;
        }

        debugPrint("SELECTED CAR TYPE: $carType (categoryId: $categoryId)");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MonitoringScreen(
              email: widget.email,
              carId: car.carId,
              make: car.make,
              carType: carType,
              categoryId: categoryId,
              plate: car.registrationNo,
              driverSide: _formatDriverSide(car.driverSide),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.orange,
      ),
      child: const Text("✓ Select This Car"),
    );
  }

  // ============================================================
  // ADD VEHICLE FORM
  // ============================================================

  Widget buildAddVehicleForm() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 1.5),
        color: Colors.white,
      ),

      child: Column(
        children: [
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(isExpanded ? Icons.close : Icons.add),

                  Text(isExpanded ? "" : " Add Vehicle"),
                ],
              ),
            ),
          ),

          // ================= EXPAND FORM =================
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),

            secondChild: _fullFormContent(),

            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAR TYPE DROPDOWN
  // ============================================================

  Widget dropdownCarType() {
    return DropdownButtonFormField<String>(
      initialValue: selectedCarType,

      hint: const Text("Select car type"),

      items: carTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedCarType = value;
          selectedCarModel = null;
        });
      },
    );
  }

  // ============================================================
  // DRIVER / STEERING SIDE DROPDOWN
  // ============================================================

  Widget dropdowndriver() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDriverSide,

      hint: const Text("Select driver side"),

      items: driverSides.map((side) {
        return DropdownMenuItem(value: side, child: Text(side));
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedDriverSide = value;
        });
      },
    );
  }

  // ============================================================
  // CAR MODEL DROPDOWN
  // ============================================================

  Widget dropdownCarModel() {
    return DropdownButtonFormField<String>(
      initialValue: selectedCarModel,

      hint: const Text("Select car model"),

      items: selectedCarType != null
          ? carModels[selectedCarType!]!
                .map(
                  (model) => DropdownMenuItem(value: model, child: Text(model)),
                )
                .toList()
          : [],

      onChanged: (value) {
        setState(() {
          selectedCarModel = value;
        });
      },
    );
  }

  // ============================================================
  // ADD VEHICLE
  // ============================================================

  void addVehicle() async {
    final plate = plateController.text.trim().toUpperCase();

    if (selectedCarType == null ||
        selectedCarModel == null ||
        selectedDriverSide == null ||
        plate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));

      return;
    }

    if (!isValidPlate(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plate format invalid (e.g. ABC-123 or ABC-1234)"),
        ),
      );

      return;
    }

    // Database IDs:
    // Sedan = 1
    // SUV = 2
    // Hatchback = 3

    Map<String, int> category = {"Sedan": 1, "SUV": 2, "Hatchback": 3};

    int categoryId = category[selectedCarType!] ?? 1;

    try {
      var data = await ApiInterface.addVehicle(
        widget.email,
        plate,
        categoryId,
        selectedCarModel!,
        selectedCarType!,
        selectedDriverSide!,
      );

      debugPrint("Status Code: ${data.statusCode}");

      debugPrint("Body: ${data.body}");

      if (!mounted) return;

      if (data.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle Added Successfully")),
        );

        clearForm();

        loadVehicles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed (${data.statusCode}): ${data.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    setState(() {
      selectedCarType = null;
      selectedCarModel = null;

      // Reset steering side as well
      selectedDriverSide = null;

      plateController.clear();

      isExpanded = false;
    });
  }

  // ============================================================
  // FULL FORM CONTENT
  // ============================================================

  Widget _fullFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 16),

        // ================= CAR TYPE =================
        const Text("Car Type"),

        const SizedBox(height: 6),

        dropdownCarType(),

        const SizedBox(height: 14),

        // ================= CAR MODEL =================
        const Text("Car Model"),

        const SizedBox(height: 6),

        dropdownCarModel(),

        const SizedBox(height: 14),

        // ================= STEERING SIDE =================
        const Text("Steering Side"),

        const SizedBox(height: 6),

        dropdowndriver(),

        const SizedBox(height: 14),

        // ================= PLATE =================
        const Text("Plate Number"),

        const SizedBox(height: 6),

        TextFormField(
          controller: plateController,

          decoration: InputDecoration(
            hintText: "e.g. ABC-123 or ABC-1234",

            filled: true,

            fillColor: Colors.grey.shade200,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),

              borderSide: BorderSide.none,
            ),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Plate number is required";
            }

            final regex = RegExp(r'^[A-Za-z]{2,4}[- ]?\d{3,4}$');

            if (!regex.hasMatch(value.trim())) {
              return "Format must be e.g. ABC-123 or ABC-1234";
            }

            return null;
          },

          onChanged: (value) {
            plateController.value = plateController.value.copyWith(
              text: value.toUpperCase(),

              selection: TextSelection.collapsed(offset: value.length),
            );
          },
        ),

        const SizedBox(height: 16),

        // ================= BUTTONS =================
        SizedBox(
          width: double.infinity,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              ElevatedButton(
                onPressed: addVehicle,

                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 30),

                  backgroundColor: Colors.green,

                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text(
                  "Save Vehicle",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              OutlinedButton(
                onPressed: clearForm,

                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(150, 30),

                  backgroundColor: Colors.green,

                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHOW VEHICLES
  // ============================================================

  Widget ShowVehicle() {
    return ListView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: allVehicle.length,

      itemBuilder: (context, index) {
        var car = allVehicle[index];

        return buildCarCard(
          title: car.cName ?? "No Name",

          subtitle: car.make,

          plate: car.registrationNo,

          index: index,

          // Steering side from API/model
          driverSide: car.driverSide,
        );
      },
    );
  }

  // ============================================================
  // PLATE VALIDATION
  // ============================================================

  bool isValidPlate(String plate) {
    return RegExp(r'^[A-Za-z]{2,4}[- ]?\d{3,4}$').hasMatch(plate.trim());
  }

  String _formatDriverSide(String side) {
    final s = side.trim().toLowerCase();
    if (s == 'left' || s == 'left-hand') return 'Left-Hand';
    if (s == 'right' || s == 'right-hand') return 'Right-Hand';
    return side.trim().isNotEmpty ? side.trim() : 'Not Specified';
  }
}
