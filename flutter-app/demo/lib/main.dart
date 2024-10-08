import 'package:demo/scan.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark(brightness: Brightness.dark)),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}