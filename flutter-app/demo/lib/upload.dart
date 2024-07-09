import 'dart:io';
import 'package:demo/default_page.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  final File image;
  final int flag;
  const LoadingPage({super.key, required this.image, required this.flag});
  
  Widget _getLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 6
        )
      ), 
    );
  }

  Widget _getHeading() {
    return const Text(
        'Processing',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24
        ),
        textAlign: TextAlign.center,
    );
  }
  @override
  Widget build(BuildContext context) {
    return [
      PopScope(
        canPop: false,
        child: Stack(
          children: [
            Center(child: SingleChildScrollView(child: Image.file(image,  color: Colors.grey.withOpacity(0.8), // Set the desired opacity value
              colorBlendMode: BlendMode.modulate))),
            Center(child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getLoadingIndicator(),
                  _getHeading(),
                ]
              )
            ))
          ]
        )
      ),
      PopScope(
        canPop: false,
        child: Center(child: Image.file(image)),
        onPopInvoked: (bool didPop) async {
          Navigator.popUntil(context, ((Route<dynamic> route) => route.isFirst));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
        }
      ),
    ][flag];
  }
}