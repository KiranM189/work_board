import 'dart:io';
import 'package:demo/display.dart';
import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key});

  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  late Future<List<FileSystemEntity>> _imageListFuture;

  @override
  void initState() {
    super.initState();
    _imageListFuture = _loadImageList();
  }

  Future<List<FileSystemEntity>> _loadImageList() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.listSync().where((item) => item.path.endsWith('.jpg')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _imageListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading images'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images found'));
          } else {
            var imageList = snapshot.data!;
            return ListView.builder(              
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                File file = File(imageList[index].path);
                String imageName = file.path.split('/').last; // Get the image name
                String imageDateTime = file.lastModifiedSync().toString(); // Get the last modified date and time
                return Card(
                  child: ListTile(
                    leading: Image.file(file, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(imageName),
                    subtitle: Text(imageDateTime),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () => { 
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageDisplay(image: Image.file(file))))
      }
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
