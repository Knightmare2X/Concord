import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/icon_construct.png',
            height: 98,
            width: 98,
            fit: BoxFit.contain,
            color: Colors.grey,
            ),
            Text(
                'Under construction\ncoming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 49,
                color: Colors.grey,
                fontFamily: 'Josefin',
              ),
            ),
          ],
      ),
    ),
        ));
  }
}
