import 'package:demo/default_page.dart';
import 'package:flutter/material.dart';
// import 'package:demo/on_board_page.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark(brightness: Brightness.dark)),
      home: DefaultPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}