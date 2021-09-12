import 'package:flutter/material.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/model/group.dart';

import 'package:pet_lover/model/myGroup.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';

import 'package:pet_lover/sub_screens/create_group.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:pet_lover/sub_screens/searchGroup.dart';
import 'package:provider/provider.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  List<MyGroup>? _myGroups;
  List<Group>? _publicGroups;
  int count = 0;
  String? _currentMobileNo;

  Future _customInit(
      GroupProvider groupProvider, UserProvider userProvider) async {
    setState(() {
      count++;
    });

    _currentMobileNo = await userProvider.getCurrentMobileNo();
    await groupProvider.publicGroupSuggessions(_currentMobileNo!).then((value) {
      setState(() {
        _publicGroups = groupProvider.publicGroups;
      });
    });

    print('currentMobileNo = $_currentMobileNo');
    await groupProvider.getMyGroups(_currentMobileNo!).then((value) {
      setState(() {
        _myGroups = groupProvider.myGroups;
        print('total my groups = ${_myGroups!.length}');
      });
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Groups',
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
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          elevation: 0.0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateGroup(groupId: '')));
          },
          child: Icon(Icons.add),
        ),
        body: _bodyUI(context),
      ),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    if (count == 0) _customInit(groupProvider, userProvider);
    return Container(
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(size.width * .05, size.width * .04,
                    size.width * .05, size.width * .03),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchGroup()));
                    },
                    child: searchGroupField(context))),
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * .05,
                  top: size.width * .02,
                  bottom: size.width * .02),
              child: Text(
                'Your groups',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .045,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                width: size.width,
                padding: EdgeInsets.only(top: size.width * .02),
                child: _myGroups == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: size.width * .07,
                              height: size.width * .07,
                              child: CircularProgressIndicator()),
                        ],
                      )
                    : _myGroups!.length == 0
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: size.width * .05,
                              right: size.width * .05,
                            ),
                            child: Text('Currently you have no group.'),
                          )
                        : ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _myGroups!.length,
                            itemBuilder: (context, index) {
                              String groupId = _myGroups![index].id!;
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GroupDetail(groupId: groupId)));
                                },
                                leading: CircleAvatar(
                                    backgroundImage: _myGroups![index]
                                                .groupImage ==
                                            ''
                                        ? AssetImage('assets/group_icon.png')
                                        : NetworkImage(
                                                _myGroups![index].groupImage!)
                                            as ImageProvider,
                                    radius: size.width * .05),
                                title: Text(
                                  _myGroups![index].groupName!,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * .04,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Text(
                                  '(${_myGroups![index].myRole})',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * .04,
                                  ),
                                ),
                              );
                            })),
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * .05,
                  top: size.width * .1,
                  bottom: size.width * .02),
              child: Text(
                'Suggestions',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .045,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: size.width,
              child: _publicGroups == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.width * .02,
                          ),
                          child: Container(
                              width: size.width * .07,
                              height: size.width * .07,
                              child: CircularProgressIndicator()),
                        ),
                      ],
                    )
                  : _publicGroups!.length == 0
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: size.width * .05,
                            right: size.width * .05,
                          ),
                          child:
                              Text('Currently you have no group Suggestion.'),
                        )
                      : ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _publicGroups!.length,
                          itemBuilder: (context, index) {
                            String groupId = _publicGroups![index].id!;
                            return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GroupDetail(groupId: groupId)));
                                },
                                leading: CircleAvatar(
                                    backgroundImage:
                                        _publicGroups![index].groupImage == ''
                                            ? AssetImage(
                                                'assets/group_icon.png',
                                              )
                                            : NetworkImage(_publicGroups![index]
                                                .groupImage!) as ImageProvider,
                                    radius: size.width * .05),
                                title: Text(
                                  _publicGroups![index].groupName!,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * .04,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Container(
                                  child: TextButton(
                                      onPressed: () {
                                        String date = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        setState(() {
                                          _joinGroup(
                                              groupProvider,
                                              groupId,
                                              _currentMobileNo!,
                                              date,
                                              userProvider);
                                        });
                                      },
                                      child: Text('Join')),
                                ));
                          }),
            )
          ],
        ));
  }

  _joinGroup(GroupProvider groupProvider, String groupId, String mobileNo,
      String date, UserProvider userProvider) async {
    await groupProvider
        .joinGroup(groupId, mobileNo, date, userProvider)
        .then((value) {
      _showToast(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupDetail(groupId: groupId)));
    });
  }

  _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('You has been added successfully.'),
      ),
    );
  }

  Widget searchGroupField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * .05),
        color: Colors.grey[300],
      ),
      padding: EdgeInsets.fromLTRB(size.width * .03, size.width * .025,
          size.width * .02, size.width * .025),
      child: Text('Search Group'),
    );
  }
}
