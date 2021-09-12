import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/model/chat_user_model.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/chat_page.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class ChatNav extends StatefulWidget {
  @override
  _ChatNavState createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> {
  TextEditingController _searchController = TextEditingController();
  int _numberOfFollowers = 0;
  List<ChatUserModel> filteredChats = [];
  List<ChatUserModel> chatList = [];
  int _counter = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AnimalProvider animalProvider =
        Provider.of<AnimalProvider>(context, listen: false);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    animalProvider.getAllChatUser(userProvider);

    if (_counter == 0) {
      setState(() {
        _isLoading = true;
      });
      animalProvider.getAllChatUser(userProvider).then((value) {
        setState(() {
          chatList = animalProvider.chatUserList;
          filteredChats = chatList;
          _counter++;
          _isLoading = false;
        });
      });
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: size.width,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(size.width * .04, size.width * .03,
                    size.width * .03, size.width * .02),
                child: Container(
                  width: size.width,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(size.width * .025,
                        size.width * .01, size.width * .02, size.width * .01),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: size.width * .02,
                        ),
                        Container(
                          width: size.width * .7,
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(fontSize: size.width * .038),
                              isDense: true,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            onChanged: (string) {
                              setState(() {
                                filteredChats = chatList
                                    .where((u) => (u.followingName!
                                        .toLowerCase()
                                        .contains(string.toLowerCase())))
                                    .toList();
                              });
                            },
                            cursorColor: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(size.width * .04)),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: () async {
                  await animalProvider
                      .getAllChatUser(userProvider)
                      .then((value) {
                    setState(() {
                      chatList = animalProvider.chatUserList;
                      filteredChats = chatList;
                      _searchController.clear();
                    });
                  });
                },
                child: _isLoading
                    ? Padding(
                        padding: EdgeInsets.only(top: size.width * .3),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final user = filteredChats[index];
                          DateTime t =
                              filteredChats[index].lastMessageTime!.toDate();
                          return ListTile(
                            onLongPress: () async {
                              user.followerNumber ==
                                      userProvider.currentUserMap['mobileNo']
                                  ? await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'UnFollow this User',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              'Do you want to unfollow this user?',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: Text('No',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await animalProvider.unfollow(
                                                      user.followerNumber!,
                                                      user.followingNumber!,
                                                      userProvider,
                                                      index);

                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )
                                            ],
                                          ))
                                  : null;
                            },
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  followingName: user.followingName,
                                  followingNumber: user.followingNumber,
                                  followerName: user.followerName,
                                  followerNumber: user.followerNumber,
                                  followingImage: user.followingImageLink,
                                  followerImage: user.followerImageLink,
                                ),
                              ))
                                  .then((value) async {
                                await animalProvider
                                    .getAllChatUser(userProvider)
                                    .then((value) {
                                  setState(() {
                                    chatList = animalProvider.chatUserList;
                                    filteredChats = chatList;
                                    _searchController.clear();
                                  });
                                });
                              });
                            },
                            leading: user.followingNumber ==
                                    userProvider.currentUserMap['mobileNo']
                                ? CircleAvatar(
                                    backgroundImage: user.followerImageLink ==
                                            ''
                                        ? AssetImage(
                                            'assets/profile_image_demo.png')
                                        : NetworkImage(user.followerImageLink!)
                                            as ImageProvider,
                                    radius: size.width * .05,
                                  )
                                : CircleAvatar(
                                    backgroundImage: user.followingImageLink ==
                                            ''
                                        ? AssetImage(
                                            'assets/profile_image_demo.png')
                                        : NetworkImage(user.followingImageLink!)
                                            as ImageProvider,
                                    radius: size.width * .05,
                                  ),
                            title: user.isSeen != false
                                ? user.followingNumber ==
                                        userProvider.currentUserMap['mobileNo']
                                    ? Text(user.followerName!,
                                        style: TextStyle(
                                            fontSize: size.width * .038,
                                            color: Colors.black))
                                    : Text(user.followingName!,
                                        style: TextStyle(
                                            fontSize: size.width * .038,
                                            color: Colors.black))
                                : user.followingNumber ==
                                        userProvider.currentUserMap['mobileNo']
                                    ? Text(user.followerName!,
                                        style: TextStyle(
                                            fontSize: size.width * .038,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange))
                                    : Text(user.followingName!,
                                        style: TextStyle(
                                            fontSize: size.width * .038,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange)),
                            subtitle: user.isSeen != false
                                ? Text(user.lastMessage!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        fontSize: size.width * .033,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black))
                                : Text(user.lastMessage!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        fontSize: size.width * .033,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange)),
                            trailing: user.isSeen != false
                                ? Text(DateFormat.yMMMd().add_jm().format(t),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: size.width * .025))
                                : Text(DateFormat.yMMMd().add_jm().format(t),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                        fontSize: size.width * .025)),
                          );
                        },
                      ),
              )
            ],
          ),
        ));
  }
}
