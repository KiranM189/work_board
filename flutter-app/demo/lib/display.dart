import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Image image;
  const ImageDisplay({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return image;
  }
}