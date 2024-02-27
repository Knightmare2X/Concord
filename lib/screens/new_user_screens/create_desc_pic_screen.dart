import 'dart:io';
import 'dart:typed_data';

import 'package:concord/screens/new_user_screens/create_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../resources/firestore.dart';

class CreateDescPicScreen extends StatefulWidget {
  const CreateDescPicScreen({Key? key}) : super(key: key);

  @override
  State<CreateDescPicScreen> createState() => _CreateDescPicScreen();
}

class _CreateDescPicScreen extends State<CreateDescPicScreen> {
  List<String> placeholder = [
    "assets/placeholders/placeholder1.png",
    "assets/placeholders/placeholder2.png",
    "assets/placeholders/placeholder3.png",
    "assets/placeholders/placeholder4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Create Description Pic",
          style: TextStyle(
              fontFamily: "Pacifico",
              fontSize: 30,
              decoration: TextDecoration.underline),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateProfileScreen()));
            },
            child: Opacity(
              opacity: 0.2,
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black87,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Tell us something about yourself in 4 pics",
                  style: TextStyle(fontSize: 35, fontFamily: 'Josefin'),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
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
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

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
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      List<Uint8List> selectedImages = placeholder
                          .where((path) => !path.startsWith("assets"))
                          .map((path) => File(path).readAsBytesSync())
                          .toList();

                      if (selectedImages.length == 4) {
                        final User user = FirebaseAuth.instance.currentUser!;
                        await FirestoreMethods()
                            .uploadFourPhotos(selectedImages, user.uid);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Images uploaded successfully."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Optionally, navigate to the next screen or perform other actions.
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select exactly 4 images."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (error) {
                      print("Error uploading images: $error");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("An error occurred while uploading images."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateProfileScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade200,
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        fontSize: 21,
                        color: Colors.white70,
                        fontFamily: 'Josefin',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
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
}
