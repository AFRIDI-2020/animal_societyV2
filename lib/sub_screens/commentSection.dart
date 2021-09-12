import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/comments.dart';
import 'package:pet_lover/model/Comment.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CommetPage extends StatefulWidget {
  String id;

  String animalOwnerMobileNo;
  int? allPostIndex;
  int? groupPostIndex;
  int? favouriteIndex;
  int? myPostIndex;
  int? otherUserPostIndex;
  int? specificPostIndex;
  CommetPage(
      {Key? key,
      required this.id,
      required this.animalOwnerMobileNo,
      required this.allPostIndex,
      required this.groupPostIndex,
      required this.favouriteIndex,
      required this.myPostIndex,
      required this.otherUserPostIndex,
      required this.specificPostIndex})
      : super(key: key);

  @override
  _CommetPageState createState() => _CommetPageState(id, animalOwnerMobileNo);
}

class _CommetPageState extends State<CommetPage> {
  TextEditingController _commentController = TextEditingController();
  Map<String, String> _currentUserInfoMap = {};

  int _count = 0;
  String id;
  String animalOwnerMobileNo;
  _CommetPageState(this.id, this.animalOwnerMobileNo);

  List<Comment> commentList = [];
  bool _loading = false;
  String postOwnerName = '';
  String currentUserName = '';

  Future<void> _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
    });
    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        currentUserName = userProvider.currentUserMap['username'];

        print('The profile image in comment section = $currentUserName');
      });
    }).then((value) async {
      userProvider
          .getSpecificUserInfo(widget.animalOwnerMobileNo)
          .then((value) {
        setState(() {
          postOwnerName = userProvider.specificUserMap['username'];
        });
      });
    });
  }

  @override
  void initState() {
    print('The post id is $id');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(userProvider);
    Size size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();
    double appbar_height = appBar.preferredSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('allPosts')
                    .doc(id)
                    .collection('comments')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return snapshot.data == null
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var comments = snapshot.data!.docs;

                            Comment comment = Comment(
                                commentId: comments[index]['commentId'],
                                comment: comments[index]['comment'],
                                postOwnerId: comments[index]['postOwnerId'],
                                currentUserMobileNo: comments[index]
                                    ['commenter'],
                                date: comments[index]['date'],
                                postId: id);

                            return CommentsDemo(
                              id: id,
                              comment: comment,
                              allPostIndex: widget.allPostIndex,
                              groupPostIndex: widget.groupPostIndex,
                              favouriteIndex: widget.favouriteIndex,
                              myPostIndex: widget.myPostIndex,
                              otherUserPostIndex: widget.otherUserPostIndex,
                            );
                          });
                }),
            Positioned(
              bottom: 0.0,
              child: Container(
                  width: size.width,
                  height: appbar_height,
                  color: Colors.white,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    elevation: size.width * .04,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * .8,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * .03, 0.0, 0.0, 0.0),
                                child: CircleAvatar(
                                  backgroundImage: (_currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              null ||
                                          _currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              '')
                                      ? AssetImage(
                                          'assets/profile_image_demo.png')
                                      : NetworkImage(_currentUserInfoMap[
                                              'profileImageLink']!)
                                          as ImageProvider,
                                  radius: size.width * .04,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(size.width * .03,
                                    0.0, size.width * .03, 0.0),
                                width: size.width * .6,
                                child: _commentField(context),
                              ),
                            ],
                          ),
                        ),
                        _loading
                            ? CircularProgressIndicator()
                            : TextButton(
                                onPressed: () async {
                                  String comment = '';
                                  print('commenter: $currentUserName');
                                  if (_commentController.text.isEmpty) {
                                    return;
                                  } else {
                                    setState(() {
                                      comment = _commentController.text;
                                      _commentController.clear();
                                    });
                                  }

                                  final _commentId = Uuid().v4();
                                  String date = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();

                                  postProvider.addComment(
                                      postOwnerName,
                                      currentUserName,
                                      id,
                                      _commentId,
                                      comment,
                                      animalOwnerMobileNo,
                                      userProvider.currentUserMobile,
                                      date,
                                      widget.allPostIndex,
                                      widget.groupPostIndex,
                                      widget.favouriteIndex,
                                      widget.myPostIndex,
                                      widget.otherUserPostIndex,
                                      widget.specificPostIndex);
                                },
                                child: Text(
                                  'Post',
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * .038),
                                ),
                              )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // _postComment(
  //     AnimalProvider animalProvider,
  //     String petId,
  //     String commentId,
  //     String comment,
  //     String animalOwnerMobileNo,
  //     String currentUserMobileNo,
  //     String date,
  //     String totalLikes) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   await animalProvider
  //       .addComment(petId, commentId, comment, animalOwnerMobileNo,
  //           currentUserMobileNo, date, totalLikes)
  //       .then((value) async {
  //     await FirebaseFirestore.instance
  //         .collection('Animals')
  //         .doc(petId)
  //         .get()
  //         .then((snapshot) {
  //       animalProvider.animalList[widget.index].totalComments =
  //           snapshot['totalComments'];
  //       setState(() {
  //         _loading = false;
  //       });
  //     });
  //   });

  //   _commentController.clear();
  // }

  Widget _commentField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Add a comment',
        hintStyle: TextStyle(
          fontSize: size.width * .04,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      cursorColor: Colors.black,
    );
  }
}
