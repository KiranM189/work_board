import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

final _controller = CropController();

class Cropper extends StatefulWidget {
  final Uint8List bytes;

  const Cropper({super.key, required this.bytes});

  @override
  _CropperState createState() => _CropperState();
}

class _CropperState extends State<Cropper> {
  File? selectedImage;
  File? enhancedImage;

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
        if (await enhancedDir.exists()) {
          final enhancedFile = File(enhancedPath);
          await enhancedFile.writeAsBytes(response.bodyBytes);
          setState(() {
            enhancedImage = File(enhancedPath);
          });
        } else {
          await enhancedDir.create(recursive: true);
          final enhancedFile = File(enhancedPath);
          await enhancedFile.writeAsBytes(response.bodyBytes);
          setState(() {
            enhancedImage = File(enhancedPath);
          });
        }
        final originalDir = Directory('${tempDir.path}/original/');
        final originalPath = '${tempDir.path}/original/$imageName.jpg';
        final bytes = await image.readAsBytes();
        if (await originalDir.exists()) {
          File originalFile = File(originalPath);
          await originalFile.writeAsBytes(bytes);
        } else {
          await originalDir.create(recursive: true);
          File originalFile = File(originalPath);
          await originalFile.writeAsBytes(bytes);
        }
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
    return Crop(
      image: widget.bytes,
      controller: _controller,
      onCropped: (image) async {
        final tempDir = await getApplicationDocumentsDirectory();
        final enhancedPath = '${tempDir.path}/temp.jpg';
        File file = File(enhancedPath);
        await file.writeAsBytes(widget.bytes);
        var status = await _uploadImage(file);
        if (status == 200) {
          if (mounted) {
            const snackBar = SnackBar(
              content: Text('Image processing successful!!!', style: TextStyle(color: Colors.black)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.white,
              margin: EdgeInsets.only(bottom: 40, left: 20, right: 20),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else if (status == 400) {
          if (mounted) {
            const snackBar = SnackBar(
              content: Text('Image processing unsuccessful!!! Try Again', style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
              margin: EdgeInsets.only(bottom: 40, left: 20, right: 20),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          if (mounted) {
            const snackBar = SnackBar(
              content: Text('Image upload unsuccessful!!! Try Again', style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
              margin: EdgeInsets.only(bottom: 40, left: 20, right: 20),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
        file.delete();
      },
      aspectRatio: 4 / 3,
      initialRectBuilder: (imageRect, cropRect) => Rect.fromLTRB(
        cropRect.left + 24,
        cropRect.top + 32,
        cropRect.right - 24,
        cropRect.bottom - 32,
      ),
      baseColor: Colors.blue.shade900,
      maskColor: Colors.white.withAlpha(100),
      progressIndicator: const CircularProgressIndicator(),
      radius: 20,
      cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.blue),
      clipBehavior: Clip.none,
      interactive: true,
    );
  }
}
