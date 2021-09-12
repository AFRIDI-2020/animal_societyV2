import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/adminPowerDemo.dart';
import 'package:pet_lover/model/adminPower.dart';
import 'package:pet_lover/model/member.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class AllGroupMembers extends StatefulWidget {
  String groupId;
  AllGroupMembers({Key? key, required this.groupId}) : super(key: key);

  @override
  _AllGroupMembersState createState() => _AllGroupMembersState(groupId);
}

class _AllGroupMembersState extends State<AllGroupMembers> {
  String groupId;
  _AllGroupMembersState(this.groupId);
  List<Member> _allMembers = [];
  int count = 0;
  Map<String, String> _currentUserInfo = {};
  Map<String, String> _groupInfo = {};
  TextEditingController _usernameController = TextEditingController();
  List<Member> _searchedMembers = [];

  _customInit(GroupProvider groupProvider, String groupId,
      UserProvider userProvider) async {
    _getAllMembers(groupProvider, groupId);
    setState(() {
      _currentUserInfo = userProvider.currentUserMap;
      _groupInfo = groupProvider.groupInfo;
      print('${_currentUserInfo['mobileNo']} & ${_groupInfo['admin']}');
      count = 1;
    });
  }

  _getAllMembers(GroupProvider groupProvider, String groupId) async {
    await groupProvider.getAllMembers(groupId).then((value) {
      setState(() {
        _allMembers = groupProvider.members;
      });
    });
  }

  _searchMember(String searchItem) {
    setState(() {
      if (searchItem == '') {
        searchItem = 'dfsdghsodhfdson';
      }
      _searchedMembers = _allMembers
          .where((element) => (element.username
              .toLowerCase()
              .contains(searchItem.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group members',
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
      body: _bodyUi(context),
    );
  }

  Widget _bodyUi(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    if (count == 0) _customInit(groupProvider, groupId, userProvider);
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        searchMemberField(context),
        SizedBox(
          height: size.width * .03,
        ),
        Container(
          width: size.width,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _searchedMembers.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          _searchedMembers[index].profileImageLink == ''
                              ? AssetImage('assets/profile_image_demo.png')
                              : NetworkImage(
                                      _searchedMembers[index].profileImageLink)
                                  as ImageProvider,
                    ),
                    title: Text(_searchedMembers[index].username),
                    trailing: ((_searchedMembers[index].mobileNo !=
                                _groupInfo['admin']) &&
                            (_groupInfo['admin'] ==
                                _currentUserInfo['mobileNo']))
                        ? TextButton(onPressed: () {}, child: Text('Remove'))
                        : null);
              }),
        ),
        SizedBox(
          height: size.width * .03,
        ),
        Padding(
          padding: EdgeInsets.only(left: size.width * .04),
          child: Text(
            'Group Members',
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .045,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: size.width * .03,
        ),
        Container(
          width: size.width,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _allMembers.length,
              itemBuilder: (context, index) {
                return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtherUserProfile(
                                  userId: _allMembers[index].mobileNo)));
                    },
                    leading: CircleAvatar(
                      backgroundImage: _allMembers[index].profileImageLink == ''
                          ? AssetImage('assets/profile_image_demo.png')
                          : NetworkImage(_allMembers[index].profileImageLink)
                              as ImageProvider,
                    ),
                    title: Row(
                      children: [
                        Text(_allMembers[index].username),
                        SizedBox(
                          width: size.width * .03,
                        ),
                        Text('('),
                        Text(_allMembers[index].memberRole),
                        Text(')'),
                      ],
                    ),
                    trailing:
                        ((_allMembers[index].mobileNo != _groupInfo['admin']) &&
                                (_groupInfo['admin'] ==
                                    _currentUserInfo['mobileNo']))
                            ? PopupMenuButton<AdminPower>(
                                onSelected: (item) => onSelectedMenuItem(
                                    context,
                                    item,
                                    _allMembers[index].username,
                                    groupProvider,
                                    userProvider,
                                    _allMembers[index].mobileNo),
                                itemBuilder: (context) => [
                                      ...AdminPowers.powerOfAdmin
                                          .map(buildItem)
                                          .toList()
                                    ])
                            : null);
              }),
        )
      ],
    ));
  }

  Widget searchMemberField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(size.width * .04, size.width * .04,
          size.width * .04, size.width * .02),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .05),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.fromLTRB(
                  0, size.width * .02, size.width * .02, size.width * .02),
              child: TextFormField(
                onChanged: _searchMember,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Group member\'s name',
                  hintStyle: TextStyle(color: Colors.black),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: size.width * .04),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<AdminPower> buildItem(AdminPower item) =>
      PopupMenuItem<AdminPower>(value: item, child: Text(item.power));

  onSelectedMenuItem(
      BuildContext context,
      AdminPower item,
      String memberName,
      GroupProvider groupProvider,
      UserProvider userProvider,
      String memberMobileNo) {
    switch (item) {
      case AdminPowers.promoteMember:
        showPromotetDialog(
            context, memberName, groupProvider, userProvider, memberMobileNo);
        break;
      case AdminPowers.demoteMember:
        showDemoteDialog(
            context, memberName, groupProvider, userProvider, memberMobileNo);
        break;
      case AdminPowers.removeMember:
        showRemoveDialog(
            context, memberName, groupProvider, userProvider, memberMobileNo);
        break;
    }
  }

  _showPromoteToast(BuildContext context, String memberName) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$memberName has been promoted to Moderator'),
      ),
    );
  }

  _makeModerator(GroupProvider groupProvider, UserProvider userProvider,
      String memberMobileNo, String groupId, String memberName) async {
    await groupProvider
        .makeModerator(groupId, memberMobileNo, userProvider)
        .then((value) {
      setState(() {
        count = 0;
      });
      _showPromoteToast(context, memberName);
      Navigator.pop(context);
    });
  }

  showPromotetDialog(
      BuildContext context,
      String memberName,
      GroupProvider groupProvider,
      UserProvider userProvider,
      String memberMobileNo) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: Text("Promote"),
        onPressed: () {
          _makeModerator(
              groupProvider, userProvider, memberMobileNo, groupId, memberName);
        });

    AlertDialog alert = AlertDialog(
      title: Text("Promote member"),
      content:
          Text('Are you sure to make $memberName moderator of this group?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showDemoteToast(BuildContext context, String memberName) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$memberName has been Demoted'),
      ),
    );
  }

  _demoteToMember(GroupProvider groupProvider, UserProvider userProvider,
      String memberMobileNo, String groupId, String memberName) async {
    await groupProvider.DemoteToMember(groupId, memberMobileNo, userProvider)
        .then((value) {
      setState(() {
        count = 0;
      });
      _showDemoteToast(context, memberName);
      Navigator.pop(context);
    });
  }

  showDemoteDialog(
      BuildContext context,
      String memberName,
      GroupProvider groupProvider,
      UserProvider userProvider,
      String memberMobileNo) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: Text("Demote"),
        onPressed: () {
          setState(() {
            _demoteToMember(groupProvider, userProvider, memberMobileNo,
                groupId, memberName);
          });
        });

    AlertDialog alert = AlertDialog(
      title: Text("Demote member"),
      content: Text('Are you sure to Demote $memberName?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _removeMember(GroupProvider groupProvider, String memberMobileNo,
      String groupId, String memberName) async {
    await groupProvider.RemoveFromGroup(groupId, memberMobileNo).then((value) {
      setState(() {
        count = 0;
      });
      _showRemoveToast(context, memberName);
      Navigator.pop(context);
    });
  }

  _showRemoveToast(BuildContext context, String memberName) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$memberName has been removed from group.'),
      ),
    );
  }

  showRemoveDialog(
      BuildContext context,
      String memberName,
      GroupProvider groupProvider,
      UserProvider userProvider,
      String memberMobileNo) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: Text("Remove"),
        onPressed: () {
          setState(() {
            _removeMember(groupProvider, memberMobileNo, groupId, memberName);
          });
        });

    AlertDialog alert = AlertDialog(
      title: Text("Remove member"),
      content: Text('Are you sure to Remove $memberName?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
