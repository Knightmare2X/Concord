import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class UploadSong extends StatefulWidget {
  const UploadSong({Key? key}) : super(key: key);

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  String? selectedImagePath;
  Uint8List? selectedImageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /*_file == null ?*/ _buildUploadButton() /*: _buildSongPreview()*/,
    );
  }

  Widget _buildUploadButton() {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    /*Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Albumart',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),*/
                    //ALBUMART


                    InkWell(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9, // Adjust width as needed
                            height: MediaQuery.of(context).size.width * 0.9, // Adjust height as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white, // Border color
                                width: 2, // Border width
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: selectedImageBytes == null
                                ? Center(
                                  child: Text(
                              'Upload Albumart',
                              style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 20,
                                fontWeight: FontWeight.bold// Text size
                              ),
                            ),
                                )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(10), // Match border radius
                              child: Image.memory(
                                selectedImageBytes!,
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.width * 0.9,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (selectedImageBytes == null && selectedImagePath != null)
                            CircularProgressIndicator(), // Show loading indicator if image is being loaded
                        ],
                      ),
                    ),


                    SizedBox(height: 20,),


                    // MASTER FILE

                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Master file',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Performed by',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Written by',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Produced by',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ));
  }


}

/*Widget _buildUploadButton() {
    return Scaffold(
        body: Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white, // Border color
                width: 2, // Border width
              ),
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: TextButton(
              onPressed: () => imagePick(),
              child: const Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 20, // Text size
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }*/

/*Widget _buildImagePreview() {
  return FutureBuilder<DocumentSnapshot>(
    future:
    FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Text('User not found'); // handle if user not found
      }

      Map<String, dynamic> userData =
      snapshot.data!.data() as Map<String, dynamic>;
      String username = userData['username'];
      String photoURL = userData['photoURL'];

      return Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            clearImage();
            Navigator.pop(context);
            return false;
          },
          child: SafeArea(
            child: ListView(children: [
              Column(
                children: [
                  _isLoading ? const LinearProgressIndicator() : Container(),
                  Container(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.memory(
                      _file!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            color: Colors.white24,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(DateTime.now()),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(photoURL),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption...',
                            border: InputBorder.none,
                          ),
                          maxLines: 4,
                        ),
                      ),
                      // OutlinedButton
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: OutlinedButton(
                      onPressed: () {
                        // This is what you should add in your code
                        if (_isClicked) {
                          _isClicked = false;
                          postImage(user.uid, username, photoURL);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        side: const BorderSide(color: Colors.lightBlue),
                      ),
                      child: const Text('Post'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ],
            ),
          ),
        ),
      );
    },
  );
}*/
