import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
  bool isFlashOn = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
            left: MediaQuery.of(context).size.width / 4,
            right: MediaQuery.of(context).size.width / 4,
            top: MediaQuery.of(context).size.height / 4,
            bottom: MediaQuery.of(context).size.height / 4,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50.0))
              ),
            ),
          ),
          Positioned.fill(
            right: MediaQuery.of(context).size.width - 175,
            bottom: MediaQuery.of(context).size.height - 100,
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
                )
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
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}