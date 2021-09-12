import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/showPost.dart';
import 'package:pet_lover/model/post.dart';
import 'package:video_player/video_player.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Post> _searchList = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            width: size.width,
            child: Column(
              children: [
                searchBar(context),
                ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _searchList.length,
                    itemBuilder: (context, index) {
                      return Container();
                      // return ShowPost(
                      //   index: index,
                      //   post: _searchList[index],
                      //   videoPlayerController: VideoPlayerController.network(
                      //       _searchList[index].video),
                      //   looping: true,
                      // );
                    }),
              ],
            )));
  }

  Widget searchBar(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .25),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.fromLTRB(
                  0, size.width * .02, size.width * .02, size.width * .02),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: TextStyle(color: Colors.black),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: size.width * .04),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * .02,
          ),
          InkWell(
            onTap: () {
              _search(_searchController.text);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                size.width * .04,
                size.width * .02,
                size.width * .04,
                size.width * .02,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * .25),
                  color: Colors.grey[300]),
              child: Text(
                'Search',
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  _search(String text) async {
    if (text.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('Animals')
        .doc(text)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Post post = Post(
            postId: snapshot['postId'],
            postOwnerId: snapshot['postOwnerId'],
            postOwnerMobileNo: snapshot['postOwnerMobileNo'],
            postOwnerName: snapshot['postOwnerName'],
            postOwnerImage: snapshot['postOwnerImage'],
            date: snapshot['date'],
            status: snapshot['status'],
            photo: snapshot['photo'],
            video: snapshot['video'],
            animalToken: snapshot['animalToken'],
            animalName: snapshot['animalName'],
            animalColor: snapshot['animalColor'],
            animalAge: snapshot['animalAge'],
            animalGender: snapshot['animalGender'],
            animalGenus: snapshot['animalGenus'],
            totalFollowers: snapshot['totalFollowers'],
            totalComments: snapshot['totalComments'],
            totalShares: snapshot['totalShares'],
            groupId: snapshot['groupId'],
            shareId: snapshot['shareId']);
        _searchList.add(post);
      }
    });
  }
}
