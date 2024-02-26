import 'package:concord/model/persist_nav_bar.dart';
import 'package:concord/screens/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_painter/image_painter.dart';
class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _imageKey = GlobalKey<ImagePainterState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Can I have Your sign")),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImagePainter.signature(
            height: 200,
            width: MediaQuery.of(context).size.width*0.9,
            key: _imageKey,
            signatureBgColor: Colors.grey,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chevron_right_outlined),
        onPressed:  (){
          // Navigate to the main content of your app.
          // You can replace 'MainScreen()' with your desired destination screen.
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(builder: (context) => PersistNavBar()),
          );
        },
      ),
    );
  }
}
