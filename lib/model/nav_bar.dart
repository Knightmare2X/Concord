/*
import 'package:concord/screens/explore_screen.dart';
import 'package:concord/screens/music_screen.dart';
import 'package:concord/screens/search_screen.dart';
import 'package:concord/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            const ExploreScreen(),
            const MusicScreen(),
            const SearchScreen(),
            Container(color: Colors.blue),
            ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
          ],
        ),
      ),
      bottomNavigationBar:BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'explore'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'music'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'profile'),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).primaryColor,
        backgroundColor:
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.black
            : Colors.white, // Use colors.white for light mode
        onTap: onTapped,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
      ),

    );
  }
}
*/
