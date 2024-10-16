// ignore_for_file: non_constant_identifier_names
import 'dart:io';
// import 'dart:typed_data';
import 'package:demo/default_page.dart';
import 'package:flutter/material.dart';
//import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;

class ImageDisplay extends StatefulWidget {
  final String image_path;
  ImageDisplay({super.key, required this.image_path});
  final TextEditingController rename_text=TextEditingController();

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  var select = 1;

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_typing_uninitialized_variables
    
    var paths = [widget.image_path, widget.image_path];
    if(widget.image_path.contains('original'))
    {
      paths[0] = widget.image_path;
      paths[1] = paths[0].replaceFirst('original', 'enhanced');
    }
    else
    {
      paths[1] = widget.image_path;
      paths[0] = paths[1].replaceFirst('enhanced', 'original');
    }
    File originalFile = File(paths[0]);
    File enhancedFile = File(paths[1]);

    File file1, file2;
    var bytesOriginal = originalFile.readAsBytesSync(); 
    var bytesEnhanced = enhancedFile.readAsBytesSync();
    final snackBar = SnackBar(
      content: const Text('Image Deleted!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          file1 = File(paths[0]);
          file1.writeAsBytes(bytesOriginal);
          file2 = File(paths[1]);
          file2.writeAsBytes(bytesEnhanced);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
        }));
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.image_path.split('/').last.split('.').first,
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
                      onTap: ()=> {Share.shareXFiles([XFile(paths[select])])},
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
                                controller: widget.rename_text,
                              ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String rename_dir="${p.dirname(paths[1])}/${widget.rename_text.text}.jpg";
                                  enhancedFile.rename(rename_dir);
                                  debugPrint(rename_dir);
                                  rename_dir="${p.dirname(paths[0])}/${widget.rename_text.text}.jpg";
                                  originalFile.rename(rename_dir);
                                  debugPrint(rename_dir);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
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
                        originalFile.delete();
                        enhancedFile.delete();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
                      },
                    )
                  ]
                ),
          ]
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: false,
            minScale: 1.0,
            child: Image.file(File(paths[select])),
          ),
        ),
        bottomNavigationBar: SegmentedButton<int>(
          segments: const[
            ButtonSegment(
              value: 0,
              label: Text('Original')
            ),
            ButtonSegment(
              value: 1,
              label: Text('Enhanced')
            ),
            ButtonSegment(
              value: 2,
              label: Text('Analysis'),
            )
          ],
          selected: {select},
          onSelectionChanged: (selection) {
            if(selection.first == 0 || selection.first == 1) {
              setState(() => 
                select = selection.first
              );
            }
            else {
              showModalBottomSheet(
                context: context, 
                builder: (context) => const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text('The image is a flowchart or flowchart that shows the process of starting a conversation. It consists of three boxes connected by arrows. The first box is labeled "Start", the second box is titled "Dial No", and the third box is labelled "Yes". \n\nThe flowchart is a visual representation of the steps involved in the conversation, with each box representing a step in the process. The steps include "No", "Answer", "Person", "Yes", "Talk", and "Terminate". The flowchart also includes a note that reads "Lu, miss".\n\nAt the bottom of the flowchart, there is a hand pointing to one of the boxes, indicating that the person is in the middle of the conversation.'),
                      ],
                    )
                  )
                ),
                showDragHandle: true,
                useSafeArea: true
              );
            }
          },
        ),
    );
  }
}