import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImage extends StatelessWidget {
  final String placeholder;
  final Function(String) updateAssetImage;

  const FullScreenImage({
    Key? key,
    required this.placeholder,
    required this.updateAssetImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: placeholder,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: getImageWidget(placeholder),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(String imageUrl) {
    if (imageUrl.startsWith("assets")) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            placeholder,
            fit: BoxFit.fill,
          ),
        ),
        errorWidget: (context, url, error) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            placeholder,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
      );
    }
  }
}
