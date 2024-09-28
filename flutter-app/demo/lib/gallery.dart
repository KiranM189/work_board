import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:demo/upload.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  List<AssetEntity> assets = [];
  bool isVisible = true;
  late File? selectedImage;
  late File? enhancedImage;

  @override
  void initState() {
    super.initState();
    assets = [];
    _loadImages();
  }
  
  void _loadImages() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if(!permitted.isAuth) return;
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );
    setState(() => 
      assets = recentAssets
    );
  }

  Future<void> _uploadImage(File image) async {
    String uploadUrl = 'http://10.20.203.158:5000/upload';

    final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]), // Use MediaType from http_parser
    );
    String imageName = image.path.split('/').last;

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        debugPrint('Image uploaded successfully');

        final tempDir = await getApplicationDocumentsDirectory();
        final enhancedDir = Directory('${tempDir.path}/enhanced/');
        final enhancedPath = '${tempDir.path}/enhanced/$imageName.jpg';
        if(await enhancedDir.exists())
        { 
          final enhancedFile = File(enhancedPath);
          await enhancedFile.writeAsBytes(response.bodyBytes);
          enhancedImage = File(enhancedPath); 
        }
        else
        {
          await enhancedDir.create(recursive: true);
          final enhancedFile = File(enhancedPath);
          await enhancedFile.writeAsBytes(response.bodyBytes);
          enhancedImage = File(enhancedPath);
        }
        final originalDir = Directory('${tempDir.path}/original/');
        final originalPath = '${tempDir.path}/original/$imageName.jpg';
        final bytes = await selectedImage!.readAsBytes();
        if(await originalDir.exists())
        { 
          File originalFile = File(originalPath);
          await originalFile.writeAsBytes(bytes);
        }
        else
        {
          await originalDir.create(recursive: true);
          File originalFile = File(originalPath);
          await originalFile.writeAsBytes(bytes);
        }
        
        if (mounted) {
          Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoadingPage(image: enhancedImage!, flag: 1)),
          );
        }
      } else {
        debugPrint('Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Visibility(
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              color: const Color.fromRGBO(21, 21, 21, 0.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        padding: const EdgeInsets.only(top: 30),
                        color: Colors.white,
                        onPressed: () => { Navigator.pop(context) }
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 25, right: 40),
                          child: const Text('Chalk',
                            style: TextStyle(
                              fontFamily: 'Monospace',
                              color: Colors.white,
                              fontSize: 24.0
                            ),
                          ),
                        )
                      ),
                    ]
                  ),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Icon(
                            Icons.photo_camera_rounded, 
                            size: 60.0,
                          )
                        ),
                        Text('Search with your camera',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                      ]
                    )
                  )
                ],
              )
            ),
          ),
          Container(
            height: 2 * MediaQuery.of(context).size.height / 3,
            color: const Color.fromRGBO(0, 0, 0, 1.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: assets.length,
              itemBuilder: (_, index) {
                return FutureBuilder<Uint8List?>(
                  future: assets[index].thumbnailData,
                  builder: (_, snapshot) {
                    final bytes = snapshot.data;
                    if (bytes == null) return const CircularProgressIndicator(color: Colors.black);
                    return GestureDetector(
                      onTap: () async {
                        final tempDir = await getApplicationDocumentsDirectory();
                        final enhancedPath = '${tempDir.path}/temp.jpg';
                        File file = File(enhancedPath);
                        await file.writeAsBytes(bytes);
                        if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LoadingPage(
                                image: file,
                                flag: 0,
                              ),
                            ),
                          );
                        await _uploadImage(file);
                        file.delete();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50.0))
                        ),
                        child: Image.memory(bytes, fit: BoxFit.cover),
                      )
                    );
                  }
                );
              },
            ),
          ),
        ]
      )
    );
  }
}