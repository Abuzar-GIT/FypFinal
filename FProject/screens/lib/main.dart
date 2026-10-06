import 'package:flutter/material.dart';
import 'package:screens/Myscreen/Log_in.dart';

void main() {
  runApp(MyApp());
  // runApp( Container(
  //   color: const Color.fromARGB(255, 228, 119, 3),
  // ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //  color: Colors.amberAccent,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: LogIn(),
    );
  }
}

