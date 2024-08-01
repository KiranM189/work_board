import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:demo/camera.dart';
import 'package:camera/camera.dart';
import 'package:demo/default_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  var heading = ['Upload', 'Digitize', 'Analyze', 'Share'];
  var text = ['Take a photo or upload from Files', 'Convert your image to digital format', 'Get info about your image', 'Share your image'];
  var imagePath = ['assets/icons/take-a-photo.png', 'assets/icons/printer.png', 'assets/icons/converter.png', 'assets/icons/share.png'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.fromLTRB(50.0, 100.0, 50.0, 20.0),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Chalk",
                    style: GoogleFonts.grandHotel(
                      color: Colors.white,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Center(
                    child: Text(
                      'from scribbles to pixels.....',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic
                      ),
                    )
                  ),
                ],
              )
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 3,
                aspectRatio: 16/9,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: false,
                scrollDirection: Axis.horizontal,
              ),
              items: [0, 1, 2, 3].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 50),
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 20, vertical: MediaQuery.of(context).size.height / 40),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 237, 236, 236),
                        border: Border.all(width: 12.0, color: const Color.fromARGB(255, 166, 186, 196)),
                        borderRadius: const BorderRadius.all(Radius.circular(16.0))
                      ),
                      child: Column(
                        children: [
                          Text(
                            heading[i],
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 32, 4, 248),
                              fontFamily: 'Monospace',
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 80),
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  text[i],
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 32, 4, 248),
                                    fontFamily: 'Poppins',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400
                                  )
                                )
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 80, horizontal: MediaQuery.of(context).size.width / 40),
                                child: Image(image: AssetImage(imagePath[i]), width: 75.0, height: 75.0)
                              )
                            ]
                          )
                        ]
                      )
                    );
                  },
                );
              }).toList(),
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0))
              ),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 24),
              margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 8, MediaQuery.of(context).size.height / 12, MediaQuery.of(context).size.width / 8, MediaQuery.of(context).size.height / 60),
              child: GestureDetector(
                onTap: () async {
                  cameras = await availableCameras();
                  firstCamera = cameras.first;
                  if (!context.mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_forward_ios_rounded,
                      color: Color.fromARGB(255, 32, 4, 248),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 40.0, 0.0),
                      child: const Text('Capture an image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 32, 4, 248),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                )
              )
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0))
              ),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 24),
              margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 8, MediaQuery.of(context).size.height / 24, MediaQuery.of(context).size.width / 8, 0.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DefaultPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_forward_ios_rounded,
                      color: Color.fromARGB(255, 32, 4, 248),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 40.0, 0.0),
                      child: const Text('View recent images',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 32, 4, 248),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                )
              )
            ),
          ]
        ),
      )
    );
  }
}