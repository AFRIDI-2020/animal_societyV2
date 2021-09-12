import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/demo_designs/my_animals_demo.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/EditProfile.dart';
import 'package:pet_lover/sub_screens/addAnimal.dart';
import 'package:pet_lover/sub_screens/create_post.dart';
import 'package:pet_lover/sub_screens/myFollowers.dart';
import 'package:pet_lover/sub_screens/myFollowing.dart';
import 'package:pet_lover/sub_screens/my_animals.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

class AccountNav extends StatefulWidget {
  @override
  _AccountNavState createState() => _AccountNavState();
}

class _AccountNavState extends State<AccountNav> {
  int _count = 0;
  Map<String, String> _currentUserInfoMap = {};
  String userProfileImage = '';
  String username = '';
  String address = '';
  String about = '';
  int _totalAnimals = 0;
  int _totalFollowers = 0;
  int _mFollowing = 0;
  bool _loading = false;
  int _itemCount = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _customInit(AnimalProvider animalProvider, UserProvider userProvider,
      PostProvider postProvider) async {
    setState(() {
      _count++;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
      setState(() {
        userProfileImage = _currentUserInfoMap['profileImageLink']!;
        username = _currentUserInfoMap['username']!;
        address = _currentUserInfoMap['address']!;
        about = _currentUserInfoMap['about']!;
      });
    }).then((value) async {
      if (postProvider.userPosts.isEmpty) {
        setState(() {
          _loading = true;
        });
        await postProvider
            .getUserPosts(userProvider.currentUserMap['mobileNo']);
        setState(() {
          _loading = false;
        });
      }
    });

    await userProvider.getMyFollowingsNumber();

    await userProvider.getMyFollowersNumber();

    await postProvider.getMyAnimalsNumber(userProvider);

    if (_itemCount <= postProvider.userPosts.length) {
      setState(() {
        _itemCount = postProvider.userPosts.length;
      });
    }
  }

  void _onRefresh(PostProvider postProvider, UserProvider userProvider) async {
    _totalAnimals = 0;
    await Future.delayed(Duration(milliseconds: 1000));
    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
      setState(() {
        userProfileImage = _currentUserInfoMap['profileImageLink']!;
        username = _currentUserInfoMap['username']!;
        address = _currentUserInfoMap['address']!;
        about = _currentUserInfoMap['about']!;
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMobile)
        .collection('myAnimals')
        .get()
        .then((snapshot) {
      if (snapshot.docs.length != 0) {
        setState(() {
          _totalAnimals = snapshot.docs.length;
        });
      }
    });
    await postProvider.getUserPosts(userProvider.currentUserMobile);
    _refreshController.refreshCompleted();
  }

  void _onLoading(PostProvider postProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _bodyUI(context),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileUser()));
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
          Container(
            width: size.width,
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: size.width * .04, right: size.width * .04),
            child: Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .07,
                fontFamily: 'MateSC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: size.width * .03,
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.only(
                left: size.width * .04, right: size.width * .04),
            alignment: Alignment.center,
            child: Text(
              about,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .038,
              ),
            ),
          ),
          SizedBox(
            height: size.width * .02,
          ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyAnimals()));
            },
            leading: Icon(FontAwesomeIcons.paw, color: Colors.deepOrange),
            title: Row(
              children: [
                Text(
                  'You have ${postProvider.numberOfMyAnimals.toString()} ',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Text(
                  _totalAnimals > 1 ? 'animals' : 'animal',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.black),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyFollowers()));
            },
            leading: Icon(FontAwesomeIcons.users, color: Colors.deepOrange),
            title: Text(
              'You have ${userProvider.myFollowers.toString()} followers',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.black),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyFollowing()));
            },
            leading:
                Icon(FontAwesomeIcons.userFriends, color: Colors.deepOrange),
            title: Text(
              'You are following ${userProvider.mFollowing.toString()} people',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.black),
          ),
          ListTile(
            leading: Icon(Icons.location_on_sharp, color: Colors.deepOrange),
            title: Text(
              address,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
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
                        builder: (context) => CreatePost(
                              postId: '',
                            )));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/profile_image_demo.png'),
                    radius: size.width * .05,
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
                              builder: (context) => CreatePost(
                                    postId: '',
                                  )));
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
                              builder: (context) => CreatePost(
                                    postId: '',
                                  )));
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
                ? Center(child: CircularProgressIndicator())
                : postProvider.userPosts.isEmpty
                    ? Center(child: Text('No post available'))
                    : ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postProvider.userPosts.length,
                        itemBuilder: (context, index) {
                          return MyAnimalsDemo(
                            index: index,
                            post: postProvider.userPosts[index],
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
