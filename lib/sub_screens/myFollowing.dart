import 'package:flutter/material.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/model/follower.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class MyFollowing extends StatefulWidget {
  const MyFollowing({Key? key}) : super(key: key);

  @override
  _MyFollowingState createState() => _MyFollowingState();
}

class _MyFollowingState extends State<MyFollowing> {
  String mobileNo = '';
  bool _loading = false;

  Future getMyFollowingPeople(UserProvider userProvider) async {
    setState(() {
      _loading = true;
    });
    await userProvider.getAllFollowingPeople(userProvider.currentUserMobile);
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    getMyFollowingPeople(userProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'You\'re following',
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
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return userProvider.followingList.isEmpty
        ? Padding(
            padding: EdgeInsets.all(size.width * .04),
            child: Text(
              'You are follwoing nobody.',
              style: TextStyle(fontSize: size.width * .04),
            ),
          )
        : ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: userProvider.followingList.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(
                  left: size.width * .02,
                  right: size.width * .02,
                ),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtherUserProfile(
                                  userId: userProvider
                                      .followingList[index].mobileNo)));
                    },
                    leading: CircleAvatar(
                      backgroundImage:
                          userProvider.followingList[index].photo == ''
                              ? AssetImage('assets/profile_image_demo.png')
                              : NetworkImage(
                                      userProvider.followingList[index].photo)
                                  as ImageProvider,
                    ),
                    title: Text(
                      userProvider.followingList[index].name,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            });
  }
}
