import 'package:flutter/material.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({Key? key}) : super(key: key);

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  TextEditingController _searchController = TextEditingController();
  String _username = '';
  String _profileImageLink = '';
  bool _isLoading = false;

  Future<bool> _onBackPressed(UserProvider userProvider) async {
    userProvider.makeSearchedUsersClear();
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return WillPopScope(
      onWillPop: () => _onBackPressed(userProvider),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search user",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              userProvider.makeSearchedUsersClear();
              Navigator.pop(context);
            },
          ),
        ),
        body: _bodyUi(context, size, userProvider),
      ),
    );
  }

  Widget _bodyUi(BuildContext context, Size size, UserProvider userProvider) {
    return Container(
        width: size.width,
        child: Column(
          children: [
            SizedBox(height: size.width * .04),
            searchBar(context, userProvider),
            SizedBox(height: size.width * .04),
            Expanded(
              child: Container(
                width: size.width,
                child: ListView.builder(
                    itemCount: userProvider.searchedUsers.length,
                    itemBuilder: (context, index) {
                      _username = userProvider.searchedUsers[index].username;
                      _profileImageLink =
                          userProvider.searchedUsers[index].profileImageLink;
                      return _isLoading
                          ? Padding(
                              padding: EdgeInsets.all(size.width * .3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            )
                          : ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OtherUserProfile(
                                            userId: userProvider
                                                .searchedUsers[index]
                                                .mobileNo)));
                              },
                              leading: CircleAvatar(
                                backgroundImage: _profileImageLink == ''
                                    ? AssetImage(
                                        'assets/profile_image_demo.png')
                                    : NetworkImage(_profileImageLink)
                                        as ImageProvider,
                              ),
                              title: Text(
                                _username,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            );
                    }),
              ),
            )
          ],
        ));
  }

  Widget searchBar(BuildContext context, UserProvider userProvider) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .25),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.fromLTRB(
                  0, size.width * .02, size.width * .02, size.width * .02),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'username',
                  hintStyle: TextStyle(color: Colors.grey),
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
            onTap: () async {
              if (_searchController.text.isEmpty) {
                Toast().showToast(context, 'Write a username to search');
                return;
              } else {
                setState(() {
                  _isLoading = true;
                });
                await userProvider.searchUser(_searchController.text);
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                size.width * .04,
                size.width * .02,
                size.width * .04,
                size.width * .02,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * .25),
                  color: Colors.grey[300]),
              child: Text(
                'Search',
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
