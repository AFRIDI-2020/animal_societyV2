import 'package:flutter/material.dart';
import 'package:pet_lover/model/group.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:provider/provider.dart';

class SearchGroup extends StatefulWidget {
  const SearchGroup({Key? key}) : super(key: key);

  @override
  _SearchGroupState createState() => _SearchGroupState();
}

class _SearchGroupState extends State<SearchGroup> {
  List<Group> _allGroups = [];
  List<Group> _searchedList = [];
  int count = 0;

  _getAllPublicGroups(GroupProvider groupProvider) async {
    await groupProvider.getAllPublicGroups().then((value) {
      setState(() {
        _allGroups = groupProvider.allPublicGroups;
        print('total groups = ${_allGroups.length}');
      });
    });
  }

  Future _customInit(GroupProvider groupProvider) async {
    setState(() {
      count++;
    });
    _getAllPublicGroups(groupProvider);
  }

  _searchGroup(String searchItem) {
    setState(() {
      _searchedList = _allGroups
          .where((element) => (element.groupName!
              .toLowerCase()
              .contains(searchItem.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Search groups',
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
    if (count == 0) _customInit(groupProvider);
    return Container(
      width: size.width,
      child: Column(
        children: [
          searchGroupField(context),
          SizedBox(
            height: size.width * .04,
          ),
          Container(
            width: size.width,
            child: ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _searchedList.length,
                itemBuilder: (context, index) {
                  String groupId = _searchedList[index].id!;
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GroupDetail(groupId: groupId)));
                    },
                    leading: CircleAvatar(
                        backgroundImage: _searchedList[index].groupImage == ''
                            ? AssetImage('assets/group_icon.png')
                            : NetworkImage(_searchedList[index].groupImage!)
                                as ImageProvider,
                        radius: size.width * .05),
                    title: Text(
                      _searchedList[index].groupName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget searchGroupField(BuildContext context) {
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
                onChanged: _searchGroup,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Write group name here...',
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
}
