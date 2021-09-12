import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/myAnimalsShow.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MyAnimals extends StatefulWidget {
  @override
  _MyAnimalsState createState() => _MyAnimalsState();
}

class _MyAnimalsState extends State<MyAnimals> {
  bool _loading = false;
  int _count = 0;

  Future<void> _customInit(
      PostProvider postProvider, UserProvider userProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });

    await postProvider.getAllMyAnimals(userProvider).then((value) {
      print('your total animals = ${postProvider.myAnimals.length}');
    });

    setState(() {
      _loading = false;
    });
  }

  Future<bool> _onBackPress(PostProvider postProvider) async {
    postProvider.setOtherUserVideoPlaying();
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(postProvider, userProvider);
    return WillPopScope(
      onWillPop: () => _onBackPress(postProvider),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your Animals",
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
              postProvider.setOtherUserVideoPlaying();
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            width: size.width,
            child: _loading
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: size.width * .08),
                      Text(
                        'Loading animals. Please wait...',
                        style: TextStyle(
                          fontSize: size.width * .04,
                        ),
                      ),
                    ],
                  ))
                : ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postProvider.myAnimals.length,
                    itemBuilder: (context, index) {
                      return MyAnimalsShow(
                          index: index,
                          post: postProvider.myAnimals[index],
                          videoPlayerController: VideoPlayerController.network(
                              postProvider.myAnimals[index].video),
                          looping: true);
                    })),
      ),
    );
  }
}
