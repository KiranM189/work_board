import 'dart:io';
import 'package:demo/display.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key});

  @override
  DefaultPageState createState() => DefaultPageState();
}

class DefaultPageState extends State<DefaultPage> {
  late Future<List<FileSystemEntity>> _imageListFuture;
  late File? selectedImage;
  late File? enhancedImage;

  @override
  void initState() {
    super.initState();
    _imageListFuture = _loadImageList();
  }

  Future<List<FileSystemEntity>> _loadImageList() async {
    var directory = await getApplicationDocumentsDirectory();
    directory = Directory('${directory.path}/enhanced/');
    return directory.listSync().where((item) => item.path.endsWith('.jpg')).toList();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _imageListFuture = _loadImageList();
    });
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover
        )
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recents",
            style: TextStyle(
              fontFamily: 'Monospace'
            )),
        ),
        body: FutureBuilder<List<FileSystemEntity>>(
          future: _imageListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('No images found'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No images found'));
            } else {
              var imageList = snapshot.data!;
              return ListView.separated(
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  File file = File(imageList[index].path);
                  String imageName = file.path.split('/').last.split('.').first;
                  String imageDateTime = file.lastModifiedSync().toLocal().toString().split('.').first.split('.').first;
                  return Card(
                    child: ListTile(
                      leading: Image.file(file, width: 75, height: 75, fit: BoxFit.fill),
                      title: Text(imageName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0
                        )),
                      subtitle: Text(imageDateTime,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0
                        )),
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ImageDisplay(image_path: imageList[index].path)),
                        )
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(
                  color: Colors.black,
                  thickness: 1.5,
                ),
              );
            }
          },
        ),
      )
    );
  }
}