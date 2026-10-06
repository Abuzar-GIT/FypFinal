// import 'package:flutter/material.dart';
// import 'package:screens/Api/AdminApi.dart';

// class VehicleSelectionScreen extends StatefulWidget {
//   const VehicleSelectionScreen({super.key});

//   @override
//   _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
// }

// class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
//   String selectedType = "SUV";
//   bool isLoading = true;

//   List<Map<String, dynamic>> types = [];
//   @override
//   void initState() {
//     super.initState();
//     //  fetchTypes();
//   }

//   Future<void> fetchTypes() async {
//     final fetchedTypes = await AdminApi.ShowTypes();
//     setState(() {
//       types = fetchedTypes;
//       isLoading = false;
//     });
//   }

//   final vehicleTypes = ["SUV", "Sedan", "Hatchback"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Vehicle")),
//       body: Column(
//         children: [
//           ListView.builder(
//             itemCount: types.length,
//             itemBuilder: (context, index) {
//               final type = types[index];
//               return ListTile(
//                 title: Text(type['Name']),
//                 onTap: () {
//                   setState(() => selectedType = type['Name']);
//                 },
//               );
//             },
//           ),
//           if (isLoading)
//             Center(child: CircularProgressIndicator())
//           else
//             ...vehicleTypes.map((type) {
//               bool isSelected = selectedType == type;

//               return GestureDetector(
//                 onTap: () {
//                   setState(() => selectedType = type);
//                 },
//                 child: Container(
//                   margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isSelected ? Colors.red : Colors.grey,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.directions_car,
//                         color: isSelected ? Colors.green : Colors.blue,
//                       ),
//                       SizedBox(width: 10),
//                       Text(type),
//                       Spacer(),
//                       if (isSelected) Text("✓ Selected"),
//                     ],
//                   ),
//                 ),
//               );
//             }),

//           ElevatedButton(
//             onPressed: () {
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (_) => DashboardPage(),
//               //     //n(vehicleType: selectedType),
//               //   ),
//               // );
//             },
//             child: Text("Configure Sensors"),
//           ),
//         ],
//       ),
//     );
//   }
// }
