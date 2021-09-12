import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pet_lover/demo_designs/showPost.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/addAnimal.dart';
import 'package:pet_lover/sub_screens/create_post.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

class HomeNav extends StatefulWidget {
  @override
  _HomeNavState createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _count = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _loading = false;
  String _currentUserImage = '';
  ScrollController _controller = ScrollController();
  bool isPlay = false;

  Future _customInit(
      PostProvider postProvider, UserProvider userProvider) async {
    setState(() {
      _count++;
    });

    userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserImage = userProvider.currentUserMap['profileImageLink'];
      });
    });

    if (postProvider.allPosts.isEmpty) {
      _loading = true;
      await postProvider.getAllPosts();
      setState(() {
        _loading = false;
      });
    }
  }

  void _onRefresh(PostProvider postProvider, UserProvider userProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    await userProvider.getCurrentUserInfo();
    await postProvider.getAllPosts();
    _refreshController.refreshCompleted();
  }

  void _onLoading(PostProvider postProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));

    if (postProvider.hasNext) {
      await postProvider.getMorePosts();
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (_count == 0) _customInit(postProvider, userProvider);

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: () => _onRefresh(postProvider, userProvider),
      onLoading: () => _onLoading(postProvider),
      child: ListView(
        controller: _controller,
        children: [
          Divider(
            height: size.width * .01,
            thickness: size.width * .002,
            color: Colors.grey.shade300,
          ),
          SizedBox(
            height: size.width * .04,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: size.width * .04,
              right: size.width * .04,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreatePost(postId: '')));
              },
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImageView(imageLink: _currentUserImage)));
                    },
                    child: CircleAvatar(
                      backgroundImage: _currentUserImage == ''
                          ? AssetImage('assets/profile_image_demo.png')
                          : NetworkImage(_currentUserImage) as ImageProvider,
                      radius: size.width * .05,
                    ),
                  ),
                  SizedBox(width: size.width * .04),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(size.width * .03,
                          size.width * .02, size.width * .03, size.width * .02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * .04),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        'Write something...',
                        style: TextStyle(
                          fontSize: size.width * .035,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: size.height * .015),
          Divider(
              thickness: size.width * .002,
              color: Colors.grey,
              height: size.width * .01),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAnimal(petId: '')));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.paw,
                          size: size.width * .05,
                        ),
                        SizedBox(
                          width: size.width * .02,
                        ),
                        Text(
                          'Add animal',
                          style: TextStyle(
                              fontSize: size.width * .04, color: Colors.black),
                        ),
                      ],
                    )),
                Container(
                  height: size.width * .06,
                  child: VerticalDivider(
                    thickness: size.width * .002,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreatePost(postId: '')));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                        ),
                        SizedBox(
                          width: size.width * .02,
                        ),
                        Text(
                          'Photo',
                          style: TextStyle(
                              fontSize: size.width * .04, color: Colors.black),
                        ),
                      ],
                    )),
                Container(
                  height: size.width * .06,
                  child: VerticalDivider(
                    thickness: size.width * .002,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreatePost(postId: '')));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_camera_back_outlined,
                        ),
                        SizedBox(
                          width: size.width * .02,
                        ),
                        Text(
                          'Video',
                          style: TextStyle(
                              fontSize: size.width * .04, color: Colors.black),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          Divider(
              thickness: size.width * .002,
              color: Colors.grey,
              height: size.width * .01),
          SizedBox(
            height: size.width * .02,
          ),
          Container(
            width: size.width,
            child: _loading
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: size.width * .3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ))
                : postProvider.allPosts.isEmpty
                    ? Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: size.width * .3),
                        child: Text(
                          'Nothing has been posted yet!',
                          style: TextStyle(
                            fontSize: size.width * .04,
                          ),
                        ),
                      ))
                    : ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postProvider.allPosts.length,
                        itemBuilder: (context, index) {
                          return ShowPost(
                            index: index,
                            post: postProvider.allPosts[index],
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
