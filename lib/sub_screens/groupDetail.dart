import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/group_menu_demo.dart';
import 'package:pet_lover/demo_designs/showGroupPost.dart';
import 'package:pet_lover/model/group_menu_item.dart';
import 'package:pet_lover/model/group_post.dart';
import 'package:pet_lover/model/member.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/AddPeopleInGroup.dart';
import 'package:pet_lover/sub_screens/allGroupMembers.dart';
import 'package:pet_lover/sub_screens/create_group.dart';
import 'package:pet_lover/sub_screens/group_post_add.dart';
import 'package:pet_lover/sub_screens/groups.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class GroupDetail extends StatefulWidget {
  String groupId;
  GroupDetail({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState(groupId);
}

class _GroupDetailState extends State<GroupDetail> {
  String groupId;
  _GroupDetailState(this.groupId);

  Map<String, String> _groupInfo = {};
  Map<String, String> _currentUserInfo = {};
  int count = 0;
  String _groupName = '';
  String _groupImage = '';
  String _privacy = '';
  String _description = '';
  String _currentUserProfileImage = '';
  List<Member> _members = [];
  bool? _isMember;
  String _admin = '';
  String _currentUserMobileNo = '';
  bool _loading = false;
  List<GroupPost> _groupPostLists = [];
  String? finalDate;
  Map<String, String> _currentUserInfoMap = {};
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future _customInit(String groupId, GroupProvider groupProvider,
      UserProvider userProvider, PostProvider postProvider) async {
    _getGroupDetail(groupId, groupProvider);
    _isMemberOrNot(groupProvider, userProvider);
    _getCurrentUserDetail(userProvider);
    _getMembers(groupId, groupProvider, userProvider);
    setState(() {
      count++;
    });
    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
    });

    if (postProvider.allGroupPost.isEmpty) {
      _loading = true;
      await postProvider.getAllGroupPosts(groupId);
      setState(() {
        _loading = false;
      });
    }

    _getGroupDetail(groupId, groupProvider);
    _isMemberOrNot(groupProvider, userProvider);
    _getCurrentUserDetail(userProvider);
    _getMembers(groupId, groupProvider, userProvider);
    setState(() {
      count++;
    });
  }

  void _onRefresh(PostProvider postProvider, UserProvider userProvider,
      GroupProvider groupProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    _getMembers(groupId, groupProvider, userProvider);
    await postProvider.getAllGroupPosts(groupId);
    _refreshController.refreshCompleted();
  }

  void _onLoading(PostProvider postProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    await postProvider.getMoreGroupPosts(groupId);
    _refreshController.loadComplete();
  }

  _isMemberOrNot(GroupProvider groupProvider, UserProvider userProvider) async {
    String currentUserMobileNo = await userProvider.currentUserMobile;
    await groupProvider
        .isGroupMemberOrNot(groupId, currentUserMobileNo)
        .then((value) {
      setState(() {
        _isMember = groupProvider.isGroupMember;
      });
    });
  }

  _getMembers(String groupId, GroupProvider groupProvider,
      UserProvider userProvider) async {
    await groupProvider.getAllMembers(groupId).then((value) {
      setState(() {
        _members = groupProvider.members;
      });
    });
  }

  _getCurrentUserDetail(UserProvider userProvider) async {
    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserInfo = userProvider.currentUserMap;
        _currentUserProfileImage = _currentUserInfo['profileImageLink']!;
      });
    });
  }

  _getGroupDetail(String groupId, GroupProvider groupProvider) async {
    await groupProvider.getGroupInfo(groupId).then((value) {
      setState(() {
        _groupInfo = groupProvider.groupInfo;
        _groupName = _groupInfo['groupName']!;
        _groupImage = _groupInfo['groupImage']!;
        _privacy = _groupInfo['privacy']!;
        _description = _groupInfo['description']!;
        _admin = _groupInfo['admin']!;
      });
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Group Details',
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Groups()));
            },
          ),
          elevation: 0.0,
        ),
        resizeToAvoidBottomInset: false,
        body: _bodyUI(context),
      ),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (count == 0)
      _customInit(groupId, groupProvider, userProvider, postProvider);
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      onRefresh: () => _onRefresh(postProvider, userProvider, groupProvider),
      onLoading: () => _onLoading(postProvider),
      child: ListView(
        children: [
          Container(
            height: size.height * .35,
            color: Colors.grey.shade200,
            child: Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height * .35,
                  child: _groupImage == ''
                      ? Center(
                          child: Text(
                          _groupName,
                          style: TextStyle(fontSize: size.width * .05),
                        ))
                      : Image.network(
                          _groupImage,
                          fit: BoxFit.fill,
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.width * .04),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: size.width * .04),
                width: size.width * .8,
                child: Text(
                  _groupName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * .06),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                width: size.width * .2,
                child: PopupMenuButton<MenuItem>(
                    onSelected: (item) => onSelectedMenuItem(context, item,
                        userProvider, groupProvider, _groupImage),
                    itemBuilder: (context) {
                      return _admin == userProvider.currentUserMobile
                          ? MenuItems.adminGroupMenuItems
                              .map(buildItem)
                              .toList()
                          : MenuItems.groupMenuItems.map(buildItem).toList();
                    }),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                left: size.width * .04, right: size.width * .04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.security, size: size.width * .042),
                SizedBox(width: size.width * .01),
                Text(
                  _privacy,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .04),
                ),
                SizedBox(width: size.width * .05),
                Icon(Icons.group, size: size.width * .042),
                SizedBox(width: size.width * .01),
                Text(
                  groupProvider.totalGroupMembers.toString(),
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .04),
                ),
                Text(
                  groupProvider.totalGroupMembers < 2 ? ' Member' : ' Members',
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .04),
                ),
                SizedBox(width: size.width * .04),
                Visibility(
                  visible: _isMember == true ? true : false,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddPeopleInGroup(groupId: groupId)));
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ))),
                      child: Row(
                        children: [Icon(Icons.add), Text('Add')],
                      )),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: size.width * .04,
              right: size.width * .04,
            ),
            width: size.width,
            child: Text(
              _description,
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .04,
              ),
            ),
          ),
          SizedBox(height: size.width * .02),
          _isMember == null
              ? Container(
                  width: size.width,
                  child: Center(child: CircularProgressIndicator()))
              : _isMember == true
                  ? forMemberOfGroup(context, postProvider)
                  : Container(
                      width: size.width,
                      height: size.width * .1,
                      padding: EdgeInsets.only(
                          left: size.width * .04, right: size.width * .04),
                      child: _loading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                String date = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                _joinGroup(
                                    groupProvider,
                                    groupId,
                                    userProvider.currentUserMobile,
                                    date,
                                    userProvider);
                              },
                              child: Text(
                                'Join $_groupName',
                                style: TextStyle(
                                  fontSize: size.width * .04,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                    )
        ],
      ),
    );
  }

  Widget forMemberOfGroup(BuildContext context, PostProvider postProvider) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * .04),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: _currentUserProfileImage == ''
                      ? AssetImage('assets/profile_image_demo.png')
                      : NetworkImage(_currentUserProfileImage) as ImageProvider,
                  radius: size.width * .05,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupPostAdd(
                                groupId: groupId,
                                postId: '',
                              )),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * .04),
                    child: Container(
                      width: size.width * .75,
                      padding: EdgeInsets.fromLTRB(size.width * .03,
                          size.width * .02, size.width * .03, size.width * .02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * .05),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * .01),
                        child: Text(
                          'Write something...',
                          style: TextStyle(
                            fontSize: size.width * .035,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
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
                            builder: (context) =>
                                GroupPostAdd(groupId: groupId, postId: '')),
                      );
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
                            builder: (context) =>
                                GroupPostAdd(groupId: groupId, postId: '')),
                      );
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
          Container(
            width: size.width,
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: postProvider.allGroupPost.length,
              itemBuilder: (context, index) {
                return ShowGroupPost(
                  index: index,
                  post: postProvider.allGroupPost[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
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

  onSelectedMenuItem(
    BuildContext context,
    MenuItem item,
    UserProvider userProvider,
    GroupProvider groupProvider,
    String groupImage,
  ) {
    switch (item) {
      case MenuItems.allMembers:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AllGroupMembers(groupId: groupId)));
        break;
      case MenuItems.itemLeaveGroup:
        groupProvider.leaveGroup(userProvider, groupId);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Groups()));
        break;
      case MenuItems.deleteGroup:
        groupProvider.deleteGroup(context, groupId, groupImage, userProvider);
        break;
      case MenuItems.editGroup:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateGroup(groupId: groupId)));
        break;
    }
  }

  _joinGroup(GroupProvider groupProvider, String groupId, String mobileNo,
      String date, UserProvider userProvider) async {
    setState(() {
      _loading = true;
    });
    await groupProvider
        .joinGroup(groupId, mobileNo, date, userProvider)
        .then((value) {
      setState(() {
        _loading = false;
      });
      _showToast(context, 'You have been aded successfully.');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => GroupDetail(groupId: groupId)),
          (route) => false);
    });
  }

  _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
