import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/commentSection.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class SpecificPost extends StatefulWidget {
  Post post;
  int index;
  SpecificPost({required this.post, required this.index});

  @override
  _SpecificPostState createState() => _SpecificPostState();
}

class _SpecificPostState extends State<SpecificPost> {
  String _groupName = '';
  String _previousOwnerOfPost = '';
  VideoPlayerController? _controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;
  bool _isFollowed = false;
  int _count = 0;
  bool _isSharing = false;
  String _profileImage = '';

  Future<void> _customInit(String postId, UserProvider userProvider,
      PostProvider postProvider) async {
    setState(() {
      _count++;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _profileImage = userProvider.currentUserMap['profileImageLink'];
      });
    });

    if (widget.post.groupId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.post.groupId)
          .get()
          .then((snapshot) {
        setState(() {
          _groupName = snapshot['groupName'];
          print('$_groupName');
        });
      });
    }
    if (widget.post.shareId.isNotEmpty) {
      await userProvider.getSpecificUserInfo(widget.post.shareId).then((value) {
        if (mounted) {
          setState(() {
            _previousOwnerOfPost = userProvider.specificUserMap['username'];
          });
        }
      });
    }

    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(widget.post.postId)
        .collection('followers')
        .doc(userProvider.currentUserMobile)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _isFollowed = true;
        });
      } else {
        setState(() {
          _isFollowed = false;
        });
      }
    });
    print(widget.post.postId);
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
      );

  @override
  void initState() {
    super.initState();
    if (widget.post.video != '') {
      _controller = VideoPlayerController.network(widget.post.video)
        ..addListener(() => mounted ? setState(() {}) : true)
        ..setLooping(true)
        ..initialize().then((_) {
          _controller!.pause();
          _controller!.setVolume(1);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0)
      _customInit(widget.post.postId, userProvider, postProvider);
    Size size = MediaQuery.of(context).size;
    DateTime miliDate =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(widget.post.date));
    var format = new DateFormat("yMMMd").add_jm();
    String finalDate = format.format(miliDate);

    return Container(
        width: size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: size.width * .04,
          ),
          ListTile(
            onTap: () {},
            leading: CircleAvatar(
              backgroundImage: widget.post.postOwnerImage == ''
                  ? AssetImage('assets/profile_image_demo.png')
                  : NetworkImage(widget.post.postOwnerImage) as ImageProvider,
              radius: size.width * .05,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtherUserProfile(
                                    userId: widget.post.postOwnerId)));
                      },
                      child: Text(
                        widget.post.postOwnerName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * .04,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Visibility(
                      visible:
                          widget.post.groupId != '' && widget.post.shareId == ''
                              ? true
                              : false,
                      child: Text(
                        ' posted on ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      widget.post.groupId != '' && widget.post.shareId == ''
                          ? true
                          : false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupDetail(
                                      groupId: widget.post.groupId)));
                        },
                        child: Container(
                          child: Text(
                            widget.post.groupId != '' &&
                                    widget.post.shareId == ''
                                ? _groupName
                                : '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .04,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.shareId != '' ? true : false,
                  child: Row(
                    children: [
                      Text(
                        'shared a post of  ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                      userId: widget.post.shareId)));
                        },
                        child: Container(
                          child: Text(
                            _previousOwnerOfPost,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .04,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * .01),
                Text(
                  finalDate,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .035,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.width * .01,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                size.width * .02, size.width * .01),
            child: Text(
                widget.post.status == '' && widget.post.animalToken != ''
                    ? 'Token: ${widget.post.animalToken}'
                    : widget.post.status,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * .038)),
          ),
          SizedBox(
            height: size.width * .02,
          ),
          Visibility(
            visible: widget.post.photo == '' && widget.post.video == ''
                ? false
                : true,
            child: InkWell(
              onDoubleTap: () {
                setState(() {
                  _isFollowed = !_isFollowed;
                });
                if (_isFollowed) {
                  postProvider.addFollowers(
                      widget.post.postId,
                      userProvider.currentUserMap['mobileNo'],
                      postProvider.allPosts[widget.index].postOwnerId,
                      postProvider.allPosts[widget.index].postOwnerName,
                      userProvider.currentUserMap['username'],
                      null,
                      null,
                      null,
                      null,
                      null,
                      widget.index);
                  postProvider.setFollowingAndFollower(
                    userProvider.currentUserMap['mobileNo'],
                    postProvider.allPosts[widget.index].postOwnerId,
                    postProvider.allPosts[widget.index].postOwnerName,
                    userProvider.currentUserMap['username'],
                    postProvider.allPosts[widget.index].postOwnerImage,
                    userProvider.currentUserMap['profileImageLink'],
                    widget.post.postId,
                    userProvider,
                  );
                }
                if (_isFollowed == false) {
                  postProvider.removeFollower(widget.post.postId,
                      userProvider.currentUserMobile, widget.index, null, null);
                }
              },
              child: Container(
                  width: size.width,
                  child: widget.post.photo == '' && widget.post.video == ''
                      ? Container()
                      : widget.post.photo != ''
                          ? Center(
                              child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageView(
                                            imageLink: widget.post.photo)));
                              },
                              child: Image.network(
                                widget.post.photo,
                                fit: BoxFit.fill,
                              ),
                            ))
                          : Container(
                              width: size.width,
                              height: size.width,
                              child: Center(
                                child: _controller!.value.isInitialized
                                    ? Stack(
                                        children: [
                                          AspectRatio(
                                            aspectRatio:
                                                _controller!.value.aspectRatio,
                                            child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isVisible = !isVisible;
                                                  });

                                                  if (!_controller!
                                                      .value.isInitialized) {
                                                    return;
                                                  }
                                                  if (_controller!
                                                      .value.isPlaying) {
                                                    videoStatusAnimation =
                                                        FadeAnimation(
                                                            child: Container(
                                                      width: size.width * .2,
                                                      height: size.width * .2,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .grey.shade800),
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: size.width * .2,
                                                      ),
                                                    ));
                                                    _controller!.pause();
                                                  } else {
                                                    videoStatusAnimation =
                                                        FadeAnimation(
                                                            child: Container(
                                                                width:
                                                                    size.width *
                                                                        .2,
                                                                height:
                                                                    size.width *
                                                                        .2,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade800),
                                                                child: Icon(
                                                                  Icons.pause,
                                                                  color: Colors
                                                                      .white,
                                                                  size:
                                                                      size.width *
                                                                          .2,
                                                                )));
                                                    _controller!.play();
                                                  }
                                                },
                                                child:
                                                    VideoPlayer(_controller!)),
                                          ),
                                          Positioned.fill(
                                              child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: videoStatusAnimation),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: buildIndicator(),
                                              ),
                                            ],
                                          ))
                                        ],
                                      )
                                    : Padding(
                                        padding:
                                            EdgeInsets.all(size.width * .3),
                                        child: CircularProgressIndicator(),
                                      ),
                              ),
                            )),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * .02),
                child: Text(
                  postProvider.specificPost[widget.index].totalFollowers,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isFollowed = !_isFollowed;
                  });
                  if (_isFollowed) {
                    postProvider.addFollowers(
                        widget.post.postId,
                        userProvider.currentUserMap['mobileNo'],
                        postProvider.allPosts[widget.index].postOwnerId,
                        postProvider.allPosts[widget.index].postOwnerName,
                        userProvider.currentUserMap['username'],
                        null,
                        null,
                        null,
                        null,
                        null,
                        widget.index);
                    postProvider.setFollowingAndFollower(
                      userProvider.currentUserMap['mobileNo'],
                      postProvider.allPosts[widget.index].postOwnerId,
                      postProvider.allPosts[widget.index].postOwnerName,
                      userProvider.currentUserMap['username'],
                      postProvider.allPosts[widget.index].postOwnerImage,
                      userProvider.currentUserMap['profileImageLink'],
                      widget.post.postId,
                      userProvider,
                    );
                  }
                  if (_isFollowed == false) {
                    postProvider.removeFollower(
                        widget.post.postId,
                        userProvider.currentUserMobile,
                        widget.index,
                        null,
                        null);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(size.width * .02),
                  child: _isFollowed == false
                      ? Icon(
                          FontAwesomeIcons.heart,
                          size: size.width * .06,
                          color: Colors.black,
                        )
                      : Icon(
                          FontAwesomeIcons.solidHeart,
                          size: size.width * .06,
                          color: Colors.red,
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: size.width * .04),
                child: Text(
                  postProvider.specificPost[widget.index].totalComments,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommetPage(
                                id: widget.post.postId,
                                animalOwnerMobileNo: widget.post.postOwnerId,
                                allPostIndex: null,
                                groupPostIndex: null,
                                favouriteIndex: null,
                                myPostIndex: null,
                                otherUserPostIndex: null,
                                specificPostIndex: widget.index,
                              )));
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * .02,
                      size.width * .02, size.width * .02, size.width * .02),
                  child: Icon(
                    FontAwesomeIcons.comment,
                    color: Colors.black,
                    size: size.width * .06,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: size.width * .04),
                child: Text(
                  postProvider.specificPost[widget.index].totalShares,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * .02,
                      size.width * .02, size.width * .02, size.width * .02),
                  child: Icon(
                    Icons.share,
                    color: Colors.black,
                    size: size.width * .06,
                  ),
                ),
              )
            ],
          ),
          Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                  size.width * .02, size.width * .01),
              child: Column(children: [
                Visibility(
                  visible: widget.post.animalName == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Animal name: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalName,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalColor == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Color: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalColor,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGenus == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Genus: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGenus,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGender == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Gender: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGender,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalAge == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Age: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalAge,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                )
              ])),
          ListTile(
            title: Text(
              'Add comment...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: _profileImage == ''
                  ? AssetImage('assets/profile_image_demo.png')
                  : NetworkImage(_profileImage) as ImageProvider,
              radius: size.width * .04,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommetPage(
                            id: widget.post.postId,
                            animalOwnerMobileNo: widget.post.postOwnerId,
                            allPostIndex: null,
                            groupPostIndex: null,
                            favouriteIndex: null,
                            myPostIndex: null,
                            otherUserPostIndex: null,
                            specificPostIndex: widget.index,
                          )));
            },
          ),
          Container(
            padding:
                EdgeInsets.fromLTRB(size.width * .02, 0, size.width * .02, 0),
            child: Divider(
              color: Colors.grey.shade300,
              height: size.width * .002,
            ),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();

    if (_controller != null) {
      _controller!.dispose();
    }
  }
}
