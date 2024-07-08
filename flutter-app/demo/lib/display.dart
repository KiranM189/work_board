// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:demo/default_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
class ImageDisplay extends StatelessWidget {
  final String image_path;
  ImageDisplay({super.key, required this.image_path});
  final TextEditingController rename_text=TextEditingController();

  @override
  Widget build(BuildContext context) {
    File file = File(image_path);
    final snackBar = SnackBar(
      content: const Text('Image Deleted!'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => {
          Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst)),
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DefaultPage()))
        }));
    return Scaffold(
      appBar: AppBar(
        title: Text(image_path.split('/').last.split('.').first,
          style: const TextStyle(
            fontFamily: 'Monospace',
            fontSize: 16.0
          )
        ),
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        actions: [
          PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: const Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(
                          width: 10
                        ),
                        Text("Share")
                      ]
                    ),
                    onTap: ()=> {Share.shareXFiles([XFile(image_path)])},
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(
                          width: 10
                        ),
                        Text("Rename")
                      ]
                    ),
                    onTap: () => {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Rename the file'),
                            content: TextField(
                              controller: rename_text,
                            ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                String rename_dir="${p.dirname(image_path)}/${rename_text.text}.jpg";
                                file.rename(rename_dir);
                                Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    },
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: const Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(
                          width: 10
                        ),
                        Text("Delete")
                      ]
                    ),
                    onTap: () {
                      File(image_path).delete();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
                    },
                  )
                ]
              ),
        ]
      ),
      body: Center(child: Image.file(file)),
    );

  }
}