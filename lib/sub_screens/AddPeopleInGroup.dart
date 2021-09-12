import 'package:flutter/material.dart';
import 'package:pet_lover/model/follower.dart';
import 'package:pet_lover/model/followerDemo.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';

class AddPeopleInGroup extends StatefulWidget {
  String groupId;
  AddPeopleInGroup({Key? key, required this.groupId}) : super(key: key);

  @override
  _AddPeopleInGroupState createState() => _AddPeopleInGroupState(groupId);
}

class _AddPeopleInGroupState extends State<AddPeopleInGroup> {
  String groupId;
  _AddPeopleInGroupState(this.groupId);
  TextEditingController _mobileNoController = TextEditingController();
  String _errorText = '';
  bool _errorTextVisibility = false;
  Map<String, String>? _peopleInfo;
  bool? _isUserExits;
  String _personProfileImage = '';
  String _personName = '';
  String _personMobileNo = '';
  bool _isMember = false;
  bool _adding = false;
  List<Follower> peopleList = [];
  int _count = 0;
  bool _loading = false;
  bool _searching = false;

  _searchPeople(UserProvider userProvider, String mobileNo,
      GroupProvider groupProvider) async {
    _isMember = false;
    await userProvider.getSpecificUserInfo(mobileNo).then((value) {
      setState(() {
        _isUserExits = userProvider.isUserExists;
        if (_isUserExits == true) {
          setState(() {
            _peopleInfo = userProvider.specificUserMap;
            _personName = _peopleInfo!['username']!;
            _personMobileNo = _peopleInfo!['mobileNo']!;
            _personProfileImage = _peopleInfo!['profileImageLink']!;
          });
        }
      });
    });
  }

  Future _isMemberOrNot(GroupProvider groupProvider, String mobileNo) async {
    await groupProvider.isGroupMemberOrNot(groupId, mobileNo).then((value) {
      setState(() {
        _isMember = groupProvider.isGroupMember;
      });
    });
  }

  Future _addMember(GroupProvider groupProvider, String mobileNo, String date,
      UserProvider userProvider, PostProvider postProvider, int index) async {
    await postProvider.addMember(groupId, mobileNo, date, userProvider, index,
        postProvider, groupProvider);
  }

  _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$_personName has been added successfully.'),
      ),
    );
  }

  Future<void> _customInit(PostProvider postProvider, UserProvider userProvider,
      GroupProvider groupProvider, String groupId) async {
    setState(() {
      _count++;
      _loading = true;
    });
    await postProvider
        .getPeopleList(userProvider.currentUserMobile, userProvider,
            groupProvider, groupId)
        .then((value) {
      setState(() {
        _loading = false;
      });
    });

    print('number of people = ${postProvider.peopleList.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add People',
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
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0)
      _customInit(postProvider, userProvider, groupProvider, groupId);

    return Container(
      width: size.width,
      padding: EdgeInsets.only(
          top: size.width * .05,
          left: size.width * .05,
          right: size.width * .05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchGroupField(context),
          Padding(
            padding:
                EdgeInsets.only(left: size.width * .04, top: size.width * .01),
            child: Visibility(
              visible: _errorTextVisibility,
              child: Text(
                _errorText,
                style:
                    TextStyle(color: Colors.red, fontSize: size.width * .038),
              ),
            ),
          ),
          SizedBox(
            height: size.width * .06,
          ),
          Visibility(
            visible: _searching,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: Container(
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundImage: _personProfileImage == ''
                              ? AssetImage('assets/profile_image_demo.png')
                              : NetworkImage(_personProfileImage)
                                  as ImageProvider,
                          radius: size.width * .06),
                      SizedBox(width: size.width * .04),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _personName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * .04,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _personMobileNo,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .035,
                              ),
                            )
                          ]),
                    ],
                  ),
                )),
                _isMember == true
                    ? Text('added')
                    : ElevatedButton(
                        child: Text('+ Add'),
                        onPressed: () {
                          setState(() {
                            _adding = true;
                            String date = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            groupProvider
                                .addMember(
                              groupId,
                              _personMobileNo,
                              date,
                              userProvider,
                              postProvider,
                            )
                                .then((value) {
                              setState(() {
                                _isMember = true;
                              });
                              _showToast(context);
                            });
                          });
                        },
                      )
              ],
            ),
          ),
          SizedBox(
            height: size.width * .06,
          ),
          Text(
            'Suggestions',
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.width * .06,
          ),
          _loading
              ? Center(child: CircularProgressIndicator())
              : postProvider.peopleList.isEmpty
                  ? Text('Nothing to suggest!')
                  : ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: postProvider.peopleList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Container(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                      backgroundImage: postProvider
                                                  .peopleList[index].photo ==
                                              ''
                                          ? AssetImage(
                                              'assets/profile_image_demo.png')
                                          : NetworkImage(postProvider
                                              .peopleList[index]
                                              .photo) as ImageProvider,
                                      radius: size.width * .06),
                                  SizedBox(width: size.width * .04),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postProvider.peopleList[index].name,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * .04,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          postProvider
                                              .peopleList[index].mobileNo,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * .035,
                                          ),
                                        )
                                      ]),
                                ],
                              ),
                            )),
                            ElevatedButton(
                              child: Text('+ Add'),
                              onPressed: () {
                                setState(() {
                                  _adding = true;
                                  String date = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  _addMember(
                                          groupProvider,
                                          postProvider
                                              .peopleList[index].mobileNo,
                                          date,
                                          userProvider,
                                          postProvider,
                                          index)
                                      .then((value) {
                                    setState(() {
                                      _adding = false;
                                    });
                                    _showToast(context);
                                  });
                                });
                              },
                            )
                          ],
                        );
                      }),
        ],
      ),
    );
  }

  Widget searchGroupField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    return Row(
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
              controller: _mobileNoController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Mobile number',
                hintStyle: TextStyle(color: Colors.black),
                isDense: true,
                contentPadding: EdgeInsets.only(left: size.width * .04),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * .02,
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (_mobileNoController.text.isEmpty ||
                  _mobileNoController.text.length != 11) {
                _errorTextVisibility = true;
                _errorText = 'Invalid mobile number!';
                return;
              }
              _errorText = '';
              _errorTextVisibility = false;
              _isMemberOrNot(groupProvider, _mobileNoController.text);
              setState(() {
                _searching = true;
              });
              _searchPeople(
                  userProvider, _mobileNoController.text, groupProvider);
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(
              size.width * .04,
              size.width * .02,
              size.width * .04,
              size.width * .02,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .05),
                color: Colors.grey[300]),
            child: Text(
              'Search',
              style: TextStyle(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
