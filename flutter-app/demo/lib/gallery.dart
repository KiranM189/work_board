import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:croppy/croppy.dart';
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
  late File? selectedImage;
  late File? enhancedImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return;
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );
    if (mounted) {
      setState(() => assets = recentAssets);
    }
  }

  Future<int> _uploadImage(File image) async {
    String uploadUrl = 'http://10.20.204.33:5000/upload';
    final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
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
        if (!await enhancedDir.exists()) {
          await enhancedDir.create(recursive: true);
        }
        await File(enhancedPath).writeAsBytes(response.bodyBytes);
        enhancedImage = File(enhancedPath);
        return 200;
      } else {
        debugPrint('Image upload failed with status code ${response.statusCode}');
        return 400;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return 500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: const Color.fromRGBO(21, 21, 21, 0.0),
            child: const Center(
              child: Text(
                'Chalk',
                style: TextStyle(fontFamily: 'Monospace', color: Colors.white, fontSize: 24.0),
              ),
            ),
          ),
          Expanded(
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
                        final result = await showMaterialImageCropper(
                          context,
                          imageProvider: MemoryImage(bytes),
                          initialData: CroppableImageData.initial(
                            cropShape: CropShape.aabb(
                              Aabb2.minMax(
                                Vector2(0, 0),
                                Vector2(1080, 1080),
                              ),
                            ),

                            imageSize: const Size(1080, 1080),// Added crop shape
                          ),
                        );

                        if (result != null && context.mounted) {
                          // Handle the result of the cropping
                          var status = await _uploadImage(File(enhancedPath));
                          // Handle status here (omitted for brevity)
                        }
                        file.delete();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Colors.grey,
                        ),
                        child: Image.memory(bytes, fit: BoxFit.cover),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}