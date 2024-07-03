// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:demo/main.dart';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String image_path;
  const ImageDisplay({super.key, required this.image_path});

  @override
  Widget build(BuildContext context) {
    File file = File(image_path);
    return Scaffold(
      body: Image.file(file),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => {},
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => { File(image_path).delete(), Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst)), Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()))
                }),
            ],
          ),
        )
      )
    );

  }
}