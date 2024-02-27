import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../screens/explore_screen.dart';
import '../screens/music_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';

class PersistNavBar extends StatefulWidget {
  const PersistNavBar({Key? key}) : super(key: key);

  @override
  State<PersistNavBar> createState() => _PersistNavBarState();
}

class _PersistNavBarState extends State<PersistNavBar> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);
  ScrollController scrollController = ScrollController();
  bool hideNavBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PersistentTabView(
          context,
          controller: controller,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          hideNavigationBar: hideNavBar,
          screens: [
            const ExploreScreen(),
            const MusicScreen(),
            const SearchScreen(),
            Container(color: Colors.blue),
            ProfileScreen(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ],
          items: <PersistentBottomNavBarItem>[
            PersistentBottomNavBarItem(
                icon: Icon(
                  Icons.image,
                  size: 30,
                ),
                title: 'explore',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: Icon(
                  Icons.music_note,
                  size: 30,
                ),
                title: 'music',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: Icon(
                  Icons.search,
                  size: 30,
                ),
                title: 'search',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                ),
                title: 'notifications',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: Icon(
                  Icons.account_circle,
                  size: 30,
                ),
                title: 'profile',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
          ],
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? Colors.black
                  : Colors.black,
          navBarStyle: NavBarStyle.neumorphic,
        ),
      ),
    );
  }
}
