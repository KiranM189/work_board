import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:demo/gallery.dart';
import 'package:demo/upload.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late File? selectedImage;
  late File? enhancedImage;
  bool isFlashOn = false;
  int state = 0;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void set(DragUpdateDetails details) {
    setState(() {
      state = 1 - state;
    });
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
        if (mounted) {
          Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
          const snackBar = SnackBar(
            content: Text('Image processing unsuccessful!!! Try Again',
              style: TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            margin: EdgeInsets.only(bottom: 40, left: 20, right: 20)
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
          Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
          const snackBar = SnackBar(
            content: Text('Image processing unsuccessful!!! Try Again',
              style: TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            margin: EdgeInsets.only(bottom: 40, left: 20, right: 20)
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: state == 0 ? MediaQuery.of(context).size.height: 0,
            child: GestureDetector(
              onVerticalDragUpdate: set,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: state == 0 ?  Container(): const Gallery()
              )
            )
          ),
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned.fill(
            left: MediaQuery.of(context).size.width / 6,
            right: MediaQuery.of(context).size.width / 6,
            top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).size.width / 3,
            bottom: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).size.width / 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50.0))
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 30.0),
            child: const Text('Chalk',
              style: TextStyle(
                fontFamily: 'Monospace',
                color: Colors.white,
                fontSize: 24.0
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height - 100,
            right: MediaQuery.of(context).size.width - 100,
            child: IconButton(
                  icon: const Icon(Icons.collections, size: 50.0),
                  color: Colors.white,
                  onPressed: () => { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Gallery())) }
                ),
          ),
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height - 100,
            right: MediaQuery.of(context).size.width - 175,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => { Navigator.pop(context) }
                ),
                IconButton(
                  icon: Icon(isFlashOn? Icons.flash_on : Icons.flash_off),
                  color: Colors.white,
                  onPressed: () => { 
                    setState(() {
                      _controller.setFlashMode(isFlashOn? FlashMode.off:FlashMode.torch);
                      isFlashOn = !isFlashOn;
                    })
                  }
                ),
              ]
            )
          ),
          
        ]
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!context.mounted) return;
            CroppedFile? cropped = await ImageCropper().cropImage(sourcePath: image.path);
            /*Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LoadingPage(
                  image: File(image.path),
                  flag: 0,
                ),
              ),
            );*/
            if(cropped != null) {
              await _uploadImage(File(cropped.path));
            }
          } 
          catch (e) {
            debugPrint('Error');
          }
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}