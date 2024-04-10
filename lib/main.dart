import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/persist_nav_bar.dart';
import 'package:concord/resources/music_provider.dart';
import 'package:concord/screens/login_screen.dart';
import 'package:concord/screens/new_user_screens/create_account.dart';
import 'package:concord/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget currentPage = const CreateAccountPage();

  //const LoginScreen();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if it's the first time logging in
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // User exists in the database, navigate to PersistNavBar
        setState(() {
          currentPage = const PersistNavBar();
        });
      } else {
        // First login, navigate to LoginScreen
        setState(() {
          currentPage = const LoginScreen();
        });
      }
    } else {
      setState(() {
        currentPage = const LoginScreen();
      });
    }
  }

  LoginScreen currentpage = const LoginScreen();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      title: 'Concord',
      home: currentPage,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
    create: (context) => MusicProvider(),
    child: const MyApp(),
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.black)); //delete for light mode
}
