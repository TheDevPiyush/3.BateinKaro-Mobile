import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl; // Image URL passed as a parameter

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Hero(
            tag: 'imageTag',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  alignment: Alignment.center,
                  child: PhotoView(
                    imageProvider: NetworkImage(
                      imageUrl,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    errorBuilder: (context, error, stackTrace) {
                      return SelectableText(
                        imageUrl,
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            fontSize: 17,
                            color: Color.fromARGB(255, 8, 0, 255),
                            fontWeight: FontWeight.w500,
                            backgroundColor: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
