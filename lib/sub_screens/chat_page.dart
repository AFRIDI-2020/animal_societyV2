import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:pet_lover/utils/message_stream.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  String? followingName,
      followingNumber,
      followerName,
      followerNumber,
      followingImage,
      followerImage;

  ChatPage(
      {this.followingName,
      this.followingNumber,
      this.followerName,
      this.followerNumber,
      this.followingImage,
      this.followerImage});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageTextController = TextEditingController();
  String? messageText;
  bool _isLoading = false;
  // @override
  // void initState() {
  //   super.initState();
  //   messageTextController.text = '';
  //   messageText = messageTextController.text;
  // }

  @override
  void dispose() {
    super.dispose();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return _onBackPressed(animalProvider, userProvider);
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                  Navigator.pop(context, true);
                }),
            toolbarHeight: size.height * .08,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.followingNumber ==
                        userProvider.currentUserMap['mobileNo']
                    ? InkWell(
                        onTap: () {
                          if (widget.followerImage != '') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageView(
                                        imageLink: widget.followerImage!)));
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: widget.followerImage == ''
                              ? AssetImage('assets/profile_image_demo.png')
                              : NetworkImage(widget.followerImage!)
                                  as ImageProvider,
                          radius: size.width * .05,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          if (widget.followingImage != '') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageView(
                                        imageLink: widget.followingImage!)));
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: widget.followingImage == ''
                              ? AssetImage('assets/profile_image_demo.png')
                              : NetworkImage(widget.followingImage!)
                                  as ImageProvider,
                          radius: size.width * .05,
                        ),
                      ),
                SizedBox(width: 15),
                widget.followingNumber ==
                        userProvider.currentUserMap['mobileNo']
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                      userId: widget.followerNumber!)));
                        },
                        child: Text(widget.followerName!,
                            style: TextStyle(color: Colors.black)),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                      userId: widget.followingNumber!)));
                        },
                        child: Text(widget.followingName!,
                            style: TextStyle(color: Colors.black)),
                      ),
              ],
            )),
        body: Stack(
          children: [
            _bodyUi(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _bodyUi() {
    final size = MediaQuery.of(context).size;
    AnimalProvider animalProvider =
        Provider.of<AnimalProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Container(
      child: Stack(
        children: [
          RechargeMessageStream(
              followingName: widget.followingName,
              followingNumber: widget.followingNumber,
              followerName: widget.followerName,
              followerNumber: widget.followerNumber,
              sender: userProvider.currentUserMap['mobileNo']),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: size.width * .17,
              alignment: Alignment.center,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: size.width * .02,
                  ),
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: messageTextController,
                        autocorrect: true,
                        enableSuggestions: true,
                        maxLines: 2,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Write your message...',
                          contentPadding:
                              EdgeInsets.only(left: size.width * .03),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * .04),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * .04),
                              borderSide: BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: TextField(
                  //     keyboardType: TextInputType.multiline,
                  //     maxLines: 3,
                  //     //expands: true,
                  //     controller: messageTextController,
                  //     style: TextStyle(color: Colors.black),
                  //     //textCapitalization: TextCapitalization.sentences,
                  //     autocorrect: true,
                  //     enableSuggestions: true,
                  //     decoration: InputDecoration(
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.all(5),
                  //       hintStyle: TextStyle(color: Colors.blueGrey),
                  //       hintText: 'Write your message..',
                  //       enabledBorder: const OutlineInputBorder(
                  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  //         borderSide: const BorderSide(
                  //           color: Color(0xFF4A8789),
                  //           width: 0.5,
                  //         ),
                  //       ),
                  //     ),
                  // onChanged: (value) {
                  //   messageText = value;
                  // },
                  //   ),
                  // ),
                  SizedBox(
                    width: size.width * .04,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: size.width * .04),
                    child: IconButton(
                      onPressed: () {
                        if (messageTextController.text != '') {
                          animalProvider
                              .uploadMessage(
                                  messageText!,
                                  userProvider.currentUserMap['username'],
                                  userProvider.currentUserMap['mobileNo'],
                                  widget.followerNumber!,
                                  widget.followingNumber!,
                                  widget.followingName!,
                                  widget.followerName!)
                              .then((value) async {
                            final String notificationId = Uuid().v4();
                            await FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(notificationId)
                                .set({
                              'notificationId': notificationId,
                              'date': DateTime.now(),
                              'senderId':
                                  userProvider.currentUserMap['mobileNo'],
                              'receiverId': widget.followingNumber!,
                              'title': 'Animal Society',
                              'body':
                                  '${userProvider.currentUserMap['username']} sent you a message',
                              'senderName':
                                  userProvider.currentUserMap['username'],
                              'receiverName': widget.followingName!,
                              'status': 'unclicked',
                              'postId': '',
                              'groupId': ''
                            });
                          }).then((value) async {
                            await animalProvider.updateSeen(
                                widget.followerNumber!,
                                widget.followingNumber!);
                          });
                        }
                        messageTextController.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.deepOrange,
                        size: size.width * .08,
                      ),
                      // backgroundColor: Colors.deepOrange,
                      // elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed(
      AnimalProvider animalProvider, UserProvider userProvider) {
    Navigator.pop(context); // Navigator.pop(context, true);
    return Future.value(true);
  }
}
