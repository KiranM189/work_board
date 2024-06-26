import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PageUpload extends StatefulWidget {
  PageUpload({super.key});

  @override
  _PageUploadState createState() => _PageUploadState();
}

class _PageUploadState extends State<PageUpload> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // SizedBox(height: 20),
          _selectedImage != null
              ? Column(
                children: [
                  Image.file(_selectedImage!),
                  Center(
                  child: ElevatedButton(
                    onPressed: () => _uploadImage(_selectedImage!),
                    child:const Text('Upload Image'),
                  ),
                  ),
                ]
              ):Center(
                child:ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          child:const Text('Pick Image from Gallery'),
                        ),
              ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }
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
      } else {
        print('Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
}