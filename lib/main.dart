import 'package:flutter/material.dart';
import 'package:ruanchuang/screens/spatial_programming_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpatialProgrammingScreen(),
    );
  }
}

