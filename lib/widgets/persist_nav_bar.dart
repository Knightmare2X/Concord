import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/screens/music_screen/music_screen.dart';
import 'package:concord/screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../screens/explore_screen/explore_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen/search_screen.dart';

class PersistNavBar extends StatefulWidget {
  const PersistNavBar({Key? key}) : super(key: key);

  @override
  State<PersistNavBar> createState() => _PersistNavBarState();
}

class _PersistNavBarState extends State<PersistNavBar> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);
  ScrollController scrollController = ScrollController();
  bool hideNavBar = false;

  Future<String> getUserPhotoURL() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userSnapshot.data()?['photoURL'] ?? '';
  }

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
            const SearchScreen(),
            const MusicScreen(),
            const NotificationsScreen(),
            ProfileScreen(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ],
          items: <PersistentBottomNavBarItem>[
            PersistentBottomNavBarItem(
                icon: const Icon(
                  Icons.image,
                  size: 30,
                ),
                title: 'explore',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: const Icon(
                  Icons.search,
                  size: 30,
                ),
                title: 'search',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),

            PersistentBottomNavBarItem(
                icon: const Icon(
                  Icons.music_note,
                  size: 30,
                ),
                title: 'music',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
                icon: const Icon(
                  Icons.notifications,
                  size: 30,
                ),
                title: 'notifications',
                activeColorPrimary: Theme.of(context).primaryColor,
                inactiveColorPrimary: Colors.grey),
            PersistentBottomNavBarItem(
              icon: FutureBuilder<String>(
                future: getUserPhotoURL(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Return a loading indicator while fetching the URL
                    return const CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // Return the user's photo if available
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                        radius: 15,
                      );
                    } else {
                      // Return the default account circle icon if user photo is not available
                      return const Icon(
                        Icons.account_circle,
                        size: 30,
                      );
                    }
                  }
                },
              ),
              title: 'profile',
              activeColorPrimary: Theme.of(context).primaryColor,
              inactiveColorPrimary: Colors.grey,
            ),
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
