import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  List<AssetEntity> assets = [];
  bool isVisible = true;

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
                return AssetThumbnail(asset: assets[index]);
              },
            ),
          ),
        ]
      )
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({super.key, required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const CircularProgressIndicator(color: Colors.black);
        return InkWell(
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
  }
}