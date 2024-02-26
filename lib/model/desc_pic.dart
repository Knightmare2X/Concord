/*
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DescPic extends StatefulWidget {
  const DescPic({Key? key}) : super(key: key);

  @override
  State<DescPic> createState() => _DescPicState();
}

class _DescPicState extends State<DescPic> {

  List<String> placeholder = [
    "assets/placeholders/placeholder1.png",
    "assets/placeholders/placeholder2.png",
    "assets/placeholders/placeholder3.png",
    "assets/placeholders/placeholder4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return  Expanded(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: placeholder.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final imageUrl = placeholder[index];

              return GestureDetector(
                onLongPress: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    // Update the placeholder list with the selected image path
                    setState(() {
                      placeholder[index] = pickedFile.path;
                    });

                    // Navigate to FullScreenImage and pass the picked image path
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          placeholder: pickedFile.path,
                          updateAssetImage: (newImagePath) {
                            setState(() {
                              // Update the placeholder list with the new image path
                              placeholder[index] = newImagePath;
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
                onTap: () async{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        placeholder: imageUrl,
                        updateAssetImage: imageUrl,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: getImageWidget(imageUrl),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(String imageUrl) {
    if (imageUrl.startsWith("assets")) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
        errorWidget: (context, url, error) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
      );
    }
  }

}
class FullScreenImage extends StatelessWidget {
  final String placeholder;
  final Function(String) updateAssetImage;

  const FullScreenImage({
    required this.placeholder,
    required this.updateAssetImage,
  });

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
}*/
