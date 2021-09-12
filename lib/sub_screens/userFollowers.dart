import 'package:flutter/material.dart';
import 'package:pet_lover/model/follower.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class UserFollowers extends StatefulWidget {
  String userMobileNo;
  String username;
  UserFollowers({Key? key, required this.userMobileNo, required this.username})
      : super(key: key);

  @override
  _UserFollowersState createState() =>
      _UserFollowersState(userMobileNo, username);
}

class _UserFollowersState extends State<UserFollowers> {
  String userMobileNo;
  String username;
  _UserFollowersState(this.userMobileNo, this.username);
  int _count = 0;

  bool _loading = false;

  Future _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });

    await userProvider.getAllFollowers(userMobileNo).then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Followers of $username',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (_count == 0) _customInit(userProvider);
    return _loading
        ? Center(child: CircularProgressIndicator())
        : userProvider.followerList.isEmpty
            ? Center(
                child: Text(
                  '$username has no followers!',
                  style: TextStyle(fontSize: size.width * .04),
                ),
              )
            : ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: userProvider.followerList.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(
                      left: size.width * .02,
                      right: size.width * .02,
                    ),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => OtherUserProfile(
                          //             userMobileNo: userProvider
                          //                 .followerList[index].mobileNo,
                          //             username: userProvider
                          //                 .followerList[index].name)));
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              userProvider.followerList[index].photo == ''
                                  ? AssetImage('assets/profile_image_demo.jpg')
                                  : NetworkImage(userProvider
                                      .followerList[index]
                                      .photo) as ImageProvider,
                        ),
                        title: Text(
                          userProvider.followerList[index].name,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                });
  }
}
