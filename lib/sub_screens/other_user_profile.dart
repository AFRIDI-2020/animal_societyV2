import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/demo_designs/showPost.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:pet_lover/sub_screens/otherUserProfilePost.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

class OtherUserProfile extends StatefulWidget {
  String userId;
  OtherUserProfile({required this.userId});
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  int _count = 0;
  Map<String, String> _currentUserInfoMap = {};
  String userProfileImage = '';
  String username = '';
  String address = '';
  String about = '';
  int _totalAnimals = 0;
  int _totalFollowers = 0;
  int _totalFollowing = 0;
  bool _loading = false;
  int _itemCount = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _customInit(AnimalProvider animalProvider, UserProvider userProvider,
      PostProvider postProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });
    print('getting id : ${widget.userId}');

    await userProvider.getSpecificUserInfo(widget.userId).then((value) {
      setState(() {
        userProfileImage = userProvider.specificUserMap['profileImageLink'];
        username = userProvider.specificUserMap['username'];
        address = userProvider.specificUserMap['address'];
        about = userProvider.specificUserMap['about'];
      });
    });
    await postProvider.getOtherUserPosts(widget.userId);
    await postProvider.getOtherUserAnimalsNumber(widget.userId);
    await userProvider.getOtherUserFollowersNumber(widget.userId);
    await userProvider.getOtherUserFollowingsNumber(widget.userId);
    setState(() {
      _loading = false;
    });
  }

  void _onRefresh(PostProvider postProvider, UserProvider userProvider) async {
    await postProvider.getOtherUserPosts(widget.userId);
    await postProvider.getOtherUserAnimalsNumber(widget.userId).then((value) {
      setState(() {
        _totalAnimals = postProvider.otherUserAnimalNumber;
      });
    });
    await userProvider.getOtherUserFollowersNumber(widget.userId).then((value) {
      setState(() {
        _totalFollowers = userProvider.otherUserFollower;
      });
    });
    await userProvider
        .getOtherUserFollowingsNumber(widget.userId)
        .then((value) {
      _totalFollowing = userProvider.otherUserFollowing;
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading(PostProvider postProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    await postProvider.getOtherUserMorePosts(widget.userId);

    _refreshController.loadComplete();
  }

  Future<bool> _onBackPress(PostProvider postProvider) async {
    await postProvider.makeOtherUserPostListEmpty();
    postProvider.setOtherUserVideoPlaying();
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    return WillPopScope(
      onWillPop: () => _onBackPress(postProvider),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () async {
              await postProvider.makeOtherUserPostListEmpty();
              postProvider.setOtherUserVideoPlaying();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0.0,
        ),
        body: _bodyUI(context),
      ),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(animalProvider, userProvider, postProvider);

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: () => _onRefresh(postProvider, userProvider),
      onLoading: () => _onLoading(postProvider),
      child: ListView(
        children: [
          SizedBox(height: size.width * .06),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (userProfileImage != '') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImageView(imageLink: userProfileImage)));
                  }
                },
                child: Container(
                  height: size.width * .5,
                  width: size.width * .5,
                  child: CircleAvatar(
                      backgroundColor: Colors.deepOrange,
                      child: CircleAvatar(
                        radius: size.width * .245,
                        backgroundColor: Colors.white,
                        backgroundImage: userProfileImage == ''
                            ? AssetImage('assets/profile_image_demo.png')
                            : NetworkImage(userProfileImage) as ImageProvider,
                      )),
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * .02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * .07,
                  fontFamily: 'MateSC',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size.width * .8,
                child: Text(
                  about,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .032,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * .1,
              ),
              Text(
                address,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * .032,
                ),
              ),
            ],
          ),
          Container(
              width: size.width,
              child: Padding(
                padding: EdgeInsets.fromLTRB(size.width * .04, size.width * .01,
                    size.width * .04, size.width * .01),
                child: Card(
                  color: Colors.white,
                  elevation: size.width * .01,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * .04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              postProvider.otherUserAnimalNumber.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .075,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Animals',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: size.width * .032,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              userProvider.otherUserFollower.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .075,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: size.width * .032,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              userProvider.otherUserFollowing.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .075,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: size.width * .032,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          SizedBox(
            height: size.width * .04,
          ),
          Container(
            width: size.width,
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : postProvider.otherUserPosts.isEmpty
                    ? Center(child: Text('No post available'))
                    : ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postProvider.otherUserPosts.length,
                        itemBuilder: (context, index) {
                          return OtherUserProfilePost(
                            index: index,
                            post: postProvider.otherUserPosts[index],
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
