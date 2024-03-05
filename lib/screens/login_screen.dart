import 'package:flutter/material.dart';

import '../resources/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade100,
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.5, 0.99],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 34),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.lightBlue.shade200, // Border color
                  width: 3.0, // Border width
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Top-left corner radius
                  topRight: Radius.circular(20.0), // Top-right corner radius
                ),
              ),
              child: ShaderMask(
                blendMode:
                    BlendMode.srcATop, // Blend the gradient with the image
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.center, // Start the gradient at the top
                    end: Alignment
                        .bottomCenter, // End the gradient at the bottom
                    colors: [
                      Colors.transparent, // Transparent at the top
                      Colors
                          .lightBlue.shade200, // Background color at the bottom
                    ],
                    stops: [0.0, 20], // Adjust the stop values as needed
                  ).createShader(bounds);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17.0),
                    topRight: Radius.circular(17.0),
                  ),
                  child: Image.asset(
                    'assets/images/mockup_ui.png',
                    fit: BoxFit
                        .cover, // Crop the image to fill the available space
                  ),
                ),
              ),
            ),

            //png image
            FittedBox(
              child: Image.asset('assets/icons/icon_white.png',
                  height: 120, width: 120, fit: BoxFit.contain),
            ),

            //concord text
            const Text(
              'CONCORD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontFamily: 'Pacifico',
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            //google signin
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(34)),
                ),
              ),
              onPressed: () {
                signUp(
                  context,
                );
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 17,
                  ),
                  Image.asset(
                    'assets/icons/icon_google.png',
                    height: 34,
                    width: 34,
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            //continue with apple
          ],
        ),
      ),
    );
  }
}
