// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
class ImageDisplay extends StatelessWidget {
  final String image_path;
  const ImageDisplay({super.key, required this.image_path});

  @override
  Widget build(BuildContext context) {
    File file = File(image_path);
    final snackBar = SnackBar(
      content: const Text('Image Deleted!'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => {}));
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
                onPressed: () => {
                  showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                  title: const Text('Are you sure you want to rename the image?'),
                  content: const TextField(
                  ),
                  
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>{File },
                      child: const Text('OK'),
                    ),
                  ],
                    ),
                  ),
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => {
                  Share.share(image_path)
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => {

                  File(image_path).delete(), ScaffoldMessenger.of(context).showSnackBar(snackBar), Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst)), Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()))},

              ), 
            ]
          ),
        ),
      ),
    );

  }
}