import 'package:concord/model/image_card.dart';
import 'package:concord/resources/firestore.dart';
import 'package:concord/screens/profile_screen.dart';
import 'package:concord/screens/search_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> { 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 3,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: const Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 52,
                      fontFamily: 'Josefin',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: const Size.fromHeight(50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchBarScreen())),
                child: Container(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Row(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.search)
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 10.0),
                          child: const Text(
                            "Search Cords",
                            style: TextStyle(fontSize: 20.0,),
                          )
                      )
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Posts').orderBy(
                    'datePublished', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<
                    QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return MasonryGridView.count(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    physics: const ScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 0),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemBuilder: (context, index) =>
                        ImageCard(
                          snap: snapshot.data!.docs[index].data(),
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



}
