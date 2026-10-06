// import 'package:flutter/material.dart';

// class AddNewVehicle extends StatefulWidget {
//   final String UserId;
//   const AddNewVehicle({super.key, required this.UserId});

//   @override
//   _AddNewVehicleState createState() => _AddNewVehicleState();
// }

// class _AddNewVehicleState extends State<AddNewVehicle> {
//   String? selectedCarType;
//   String? selectedCarModel;
//   String? driverSide;
//   final TextEditingController plateController = TextEditingController();

//   // Sample Data

//   final List<String> carTypes = ["SUV", "Sedan", "Hatchback"];
//   final Map<String, List<String>> carModels = {
//     "SUV": ["Honda CR-V", "Toyota Fortuner", "Kia Sportage"],
//     "Sedan": ["Honda Civic", "Toyota Corolla", "Hyundai Elantra"],
//     "Hatchback": ["Suzuki Alto", "Suzuki Swift", "Kia Picanto"],
//   };

//   double wScale(BuildContext context, double size) {
//     return MediaQuery.of(context).size.width / 375 * size;
//   }

//   double hScale(BuildContext context, double size) {
//     return MediaQuery.of(context).size.height / 667 * size;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(wScale(context, 20)),
//         child: Column(
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             Text(
//               "Add New Vehicle",
//               style: TextStyle(
//                 // fontSize: wScale(context, 22),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             SizedBox(height: 5),

//             Text(
//               "Enter your vehicle details",
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),

//             // Car Type Dropdown
//             SizedBox(height: 20),
//             label("Car Type", context),
//             dropdownBox(
//               context,
//               value: selectedCarType,
//               hint: "Select car type",
//               items: carTypes,
//               onChanged: (value) {
//                 setState(() {
//                   selectedCarType = value;
//                   selectedCarModel = null; // reset model when type changes
//                 });
//               },
//             ),

//             // Car Model Dropdown
//             SizedBox(height: hScale(context, 15)),
//             label("Car Model", context),
//             dropdownBox(
//               context,
//               value: selectedCarModel,
//               hint: "Select car model",
//               items: selectedCarType != null
//                   ? carModels[selectedCarType!]!
//                   : [],
//               onChanged: (value) {
//                 setState(() {
//                   selectedCarModel = value;
//                 });
//               },
//             ),

//             // Plate Number
//             // SizedBox(height: hScale(context, 15)),
//             // label("Plate Number", context),
//             // TextField(
//             //   controller: plateController,
//             //   decoration: inputDecoration(context, "ABC-1234"),
//             //   keyboardType: TextInputType.text,
//             // ),
//             //
//             SizedBox(height: hScale(context, 15)),
//             label("Plate Number", context),

//             TextFormField(
//               controller: plateController,
//               keyboardType: TextInputType.text,
//               textCapitalization: TextCapitalization.characters,
//               decoration: inputDecoration(context, "ABC-1234"),
//               autofocus: true,

//               // VALIDATION
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return "Plate number is required";
//                 }

//                 final regex = RegExp(r'^[A-Z]{3}-\d{4}$');

//                 if (!regex.hasMatch(value)) {
//                   return "Format must be ABC-1234";
//                 }

//                 return null;
//               },

//               onChanged: (value) {
//                 plateController.value = plateController.value.copyWith(
//                   text: value.toUpperCase(),
//                   selection: TextSelection.collapsed(offset: value.length),
//                 );
//               },
//             ),

//             // Buttons
//             SizedBox(height: hScale(context, 30)),
//             Row(
//               children: [
//                 // Add Button
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: EdgeInsets.symmetric(
//                         vertical: hScale(context, 12),
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           wScale(context, 10),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       if (!isValidPlate(plateController.text)) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               "Invalid plate format (Use ABC-1234)",
//                             ),
//                           ),
//                         );
//                         return;
//                       }
//                       print(selectedCarType);
//                       print(selectedCarModel);
//                       print(plateController.text);
//                     },
//                     child: Text(
//                       "+ Add Car",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),

//                 SizedBox(width: wScale(context, 10)),

//                 // Cancel Button
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Cancel"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Dropdown Widget
//   Widget dropdownBox(
//     BuildContext context, {
//     required String? value,
//     required String hint,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: wScale(context, 12)),
//       decoration: BoxDecoration(
//         color: Color(0xfff9f9f9),
//         borderRadius: BorderRadius.circular(wScale(context, 10)),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           hint: Text(hint),
//           isExpanded: true,
//           items: items.map((item) {
//             return DropdownMenuItem(value: item, child: Text(item));
//           }).toList(),
//           onChanged: items.isEmpty ? null : onChanged,
//         ),
//       ),
//     );
//   }

//   // Label
//   Widget label(String text, BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         top: hScale(context, 15),
//         bottom: hScale(context, 5),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: wScale(context, 14),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   // Input Decoration
//   InputDecoration inputDecoration(BuildContext context, String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Color(0xfff9f9f9),
//       contentPadding: EdgeInsets.symmetric(
//         horizontal: wScale(context, 12),
//         vertical: hScale(context, 12),
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(wScale(context, 10)),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//     );
//   }

//   // Validate Plate Number
//   bool isValidPlate(String plate) {
//     final regex = RegExp(r'^[A-Z]{3}-\d{4}$');
//     return regex.hasMatch(plate);
//   }
// }
