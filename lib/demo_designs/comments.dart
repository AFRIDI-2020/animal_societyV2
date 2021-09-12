import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/comment_edit_delete.dart';
import 'package:pet_lover/model/Comment.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class CommentsDemo extends StatefulWidget {
  String? id;
  // int? index;
  Comment? comment;
  int? allPostIndex;
  int? groupPostIndex;
  int? favouriteIndex;
  int? myPostIndex;
  int? otherUserPostIndex;
  CommentsDemo(
      {this.id,
      // this.index,
      this.comment,
      required this.allPostIndex,
      required this.groupPostIndex,
      required this.favouriteIndex,
      required this.myPostIndex,
      required this.otherUserPostIndex});

  @override
  _CommentsDemoState createState() => _CommentsDemoState();
}

class _CommentsDemoState extends State<CommentsDemo> {
  String? date;
  TextEditingController _editCommentController = TextEditingController();
  bool _editVisibility = false;
  bool _commentVisibility = true;

  String? _commenterImage;
  String? _commenterName;

  Future _getCommenter(String commenter) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(commenter)
        .get()
        .then((snapshot) {
      if (mounted) {
        setState(() {
          _commenterImage = snapshot['profileImageLink'];
          _commenterName = snapshot['username'];
        });
      }
    });
  }

  _getCommentsTime() {
    DateTime now = DateTime.now();
    int commentDurationInSec = now
        .difference(DateTime.fromMillisecondsSinceEpoch(
            int.parse(widget.comment!.date!)))
        .inSeconds;
    int day = commentDurationInSec ~/ (24 * 3600);
    commentDurationInSec = commentDurationInSec % (24 * 3600);
    int hour = commentDurationInSec ~/ 3600;
    commentDurationInSec %= 3600;
    int min = commentDurationInSec ~/ 60;
    commentDurationInSec %= 60;
    int sec = commentDurationInSec;

    if (day == 0 && hour == 0 && min == 0 && sec < 60) {
      date = 'just now';
    } else if (day == 0 && hour == 0 && min != 0 && sec < 60) {
      date = min.toString() + ' min';
    } else if (day == 0 && hour != 0 && min != 0 && sec != 0) {
      date = hour.toString() + ' hour' + ' ' + min.toString() + ' min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    Size size = MediaQuery.of(context).size;
    _getCommenter(widget.comment!.currentUserMobileNo!);
    _getCommentsTime();

    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * .03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ImageView(imageLink: _commenterImage!)));
            },
            child: CircleAvatar(
              backgroundImage: _commenterImage == null || _commenterImage == ''
                  ? AssetImage('assets/profile_image_demo.png')
                  : NetworkImage(_commenterImage!) as ImageProvider,
              radius: size.width * .04,
            ),
          ),
          Container(
            width: size.width * .8,
            padding: EdgeInsets.only(left: size.width * .03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: _commentVisibility,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        top: size.width * .03,
                        bottom: size.width * .03),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(size.width * .02)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            // width: size.width * .6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserProfile(
                                                    userId: widget.comment!
                                                        .currentUserMobileNo!)));
                                  },
                                  child: Container(
                                    child: Text(
                                      _commenterName == null
                                          ? ''
                                          : _commenterName!,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * .04),
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.comment!.comment!,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * .04),
                                ),
                              ],
                            ),
                          ),
                        ),
                        widget.comment!.currentUserMobileNo! ==
                                userProvider.currentUserMap['mobileNo']
                            ? PopupMenuButton<MyAnimalItemMenu>(
                                onSelected: (item) => onSelectedMenuItem(
                                    context,
                                    item,
                                    animalProvider,
                                    postProvider),
                                itemBuilder: (context) => [
                                      ...CommentEditDelete.commentEditDeleteList
                                          .map(buildItem)
                                          .toList()
                                    ])
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _editVisibility,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            controller: _editCommentController,
                            decoration: InputDecoration(),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await postProvider
                                .editComment(
                                    widget.comment!.postId!,
                                    widget.comment!.commentId!,
                                    _editCommentController.text)
                                .then((value) {
                              setState(() {
                                _editVisibility = false;
                                _commentVisibility = true;
                              });
                            });
                          },
                          icon: Icon(Icons.add_circle)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * .01,
                ),
                Padding(
                  padding: EdgeInsets.only(left: size.width * .04),
                  child: Text(
                    date!,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  PopupMenuItem<MyAnimalItemMenu> buildItem(MyAnimalItemMenu item) =>
      PopupMenuItem<MyAnimalItemMenu>(
          value: item,
          child: Row(
            children: [
              Icon(item.iconData),
              SizedBox(
                width: 10,
              ),
              Text(item.text)
            ],
          ));

  onSelectedMenuItem(BuildContext context, MyAnimalItemMenu item,
      AnimalProvider animalProvider, PostProvider postProvider) {
    switch (item) {
      case CommentEditDelete.editComment:
        setState(() {
          _commentVisibility = false;
          _editVisibility = true;
          _editCommentController.text = widget.comment!.comment!;
        });

        break;
      case CommentEditDelete.deleteComment:
        postProvider
            .deleteComment(
                widget.comment!.postId!,
                widget.comment!.commentId!,
                widget.allPostIndex,
                widget.groupPostIndex,
                widget.favouriteIndex,
                widget.myPostIndex,
                widget.otherUserPostIndex)
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(widget.comment!.postId!)
              .get();
        });
        break;
    }
  }
}
