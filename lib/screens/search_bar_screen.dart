import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/screens/profile_screen.dart';
import 'package:flutter/material.dart';
class SearchBarScreen extends StatefulWidget {
  const SearchBarScreen({Key? key}) : super(key: key);

  @override
  State<SearchBarScreen> createState() => _SearchBarScreenState();
}

class _SearchBarScreenState extends State<SearchBarScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Form(
            child: TextFormField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Search for a user'),
              onFieldSubmitted: (String_) {
                setState(() {
                  isShowUsers = true;
                });
              },
            ),
          ),
        ),
        body: isShowUsers
            ? FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('Users')
              .where('username',
              isGreaterThanOrEqualTo:
              searchController.text.toUpperCase())
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: (snapshot.data! as dynamic).docs[index]['uid'],
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          (snapshot.data! as dynamic).docs[index]
                          ['photoURL']),
                    ),
                    title: Text((snapshot.data! as dynamic).docs[index]
                    ['username']),
                  ),
                );
              },
            );
          },
        )
            : Text(''),
      ),
    );
  }
}

