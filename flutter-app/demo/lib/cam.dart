import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class CameraUpload extends StatefulWidget {
  const CameraUpload({super.key});

  @override
  _CameraUploadState createState() => _CameraUploadState();
}

class _CameraUploadState extends State<CameraUpload> {
  File? _selectedImage;
  File? _uploadedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: Column(
        children: [
          if (_selectedImage != null)
            Column(
              children: [
                if(_uploadedImage != null)
                  Image.file(_uploadedImage!)
                else
                  Image.file(_selectedImage!)
              ],
            )
          else
            Center(
              child: ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: const Text('Take a picture'),
              ),
            ),
        ],
      )
      )
    );
  }

  Future<void> _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    _uploadImage(_selectedImage!);  
  }

  Future<void> _uploadImage(File image) async {
    String uploadUrl = 'http://10.0.2.2:5000/upload'; // Use emulator-specific address

    final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]), // Use MediaType from http_parser
    );

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        print('Image uploaded successfully');

         final tempDir = await getApplicationDocumentsDirectory();
        final tempFile = File('${tempDir.path}/uploaded_image.jpg');
        debugPrint(tempDir.path);
        await tempFile.writeAsBytes(response.bodyBytes);
        setState(() {
          _uploadedImage = tempFile;
        });
      } else {
        print('Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
