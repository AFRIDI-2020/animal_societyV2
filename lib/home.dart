import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/demo_designs/search_menu.dart';
import 'package:pet_lover/login.dart';
import 'package:pet_lover/model/search_menu_item.dart';
import 'package:pet_lover/navigation_bar_screens/account_nav.dart';
import 'package:pet_lover/navigation_bar_screens/chat_nav.dart';
import 'package:pet_lover/navigation_bar_screens/following_nav.dart';
import 'package:pet_lover/navigation_bar_screens/home_nav.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/EditProfile.dart';
import 'package:pet_lover/sub_screens/animal_name_search.dart';
import 'package:pet_lover/sub_screens/groups.dart';
import 'package:pet_lover/sub_screens/maintenanceBreak.dart';
import 'package:pet_lover/sub_screens/notificationList.dart';
import 'package:pet_lover/sub_screens/qr_code_scanning.dart';
import 'package:pet_lover/sub_screens/reset_password.dart';
import 'package:pet_lover/sub_screens/search.dart';
import 'package:pet_lover/sub_screens/searched_users.dart';
import 'package:pet_lover/sub_screens/token_search.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final _tabs = [
    HomeNav(),
    FollowingNav(),
    ChatNav(),
    AccountNav(),
  ];

  String _appbarTitle = 'Home';

  var _pageController = PageController();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Map<String, String> _currentUserInfo = {};
  int _count = 0;

  String _username = '';
  String _finalUsername = '';
  String _mobileNo = '';

  bool db_update = false;
  String current_version = '';
  String running_version = '';

  _customInit(UserProvider userProvider, PostProvider postProvider) async {
    setState(() {
      _count++;
    });
    await postProvider.getNotifications();
    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserInfo = userProvider.currentUserMap;

        _username = _currentUserInfo['username']!;

        if (_username.length > 11) {
          _finalUsername = '${_username.substring(0, 11)}...';
        } else {
          _finalUsername = _username;
        }

        _mobileNo = _currentUserInfo['mobileNo']!;
      });
    });
  }

  Future<bool> _onBackPressed() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Exit App',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  content: Text(
                    'Do you really want to exit the app?',
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () => SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop'),
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ))) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    getCurrentState();
  }

  getCurrentState() async {
    await FirebaseFirestore.instance
        .collection('Developer')
        .doc('123456')
        .get()
        .then((snapshot) {
      db_update = snapshot['DB_update'];
      current_version = snapshot['current_version'];
    });
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      running_version = packageInfo.version;
      print('running version = $running_version');
    });
    if (db_update == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MaintenanceBreak()));
    } else {
      if (running_version != current_version) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MaintenanceBreak()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(userProvider, postProvider);
    Size size = MediaQuery.of(context).size;
    // const minute = Duration(minutes: 5);
    // // Timer.periodic(minute, (Timer t) async {
    // //   await postProvider.countNotifications(userProvider);
    // // });
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: size.width * .08,
                          backgroundImage: userProvider
                                      .currentUserMap['profileImageLink'] ==
                                  null
                              ? AssetImage('assets/profile_image_demo.png')
                              : userProvider
                                          .currentUserMap['profileImageLink'] ==
                                      ''
                                  ? AssetImage('assets/profile_image_demo.png')
                                  : NetworkImage(userProvider
                                          .currentUserMap['profileImageLink'])
                                      as ImageProvider,
                        ),
                        SizedBox(width: size.width * .04),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _finalUsername,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * .06,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _mobileNo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .04,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileUser()));
                  },
                  title: Text(
                    'Update account',
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * .04),
                  ),
                  leading: Icon(
                    Icons.edit,
                    color: Colors.deepOrange,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResetPassword()));
                  },
                  title: Text(
                    'Reset password',
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * .04),
                  ),
                  leading: Icon(
                    Icons.vpn_key,
                    color: Colors.deepOrange,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                ),
                ListTile(
                  onTap: () async {
                    await postProvider.makeAllListsEmpty();
                    DatabaseManager().clearSharedPref();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false);
                  },
                  title: Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * .04),
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: Colors.deepOrange,
                  ),
                )
              ],
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  if (_scaffoldKey.currentState!.isDrawerOpen) {
                    _scaffoldKey.currentState!.openEndDrawer();
                  } else {
                    _scaffoldKey.currentState!.openDrawer();
                  }
                },
                icon: Container(
                  width: size.width * .1,
                  height: size.width * .1,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey.shade200),
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                )),
            title: appBarTitle(context),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MaintenanceBreak()));
                  },
                  icon: Container(
                    width: size.width * .1,
                    height: size.width * .1,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: Icon(
                      Icons.scanner,
                      color: Colors.black,
                    ),
                  )),
              PopupMenuButton<SearchMenuItem>(
                  offset: Offset(0, 50),
                  icon: Container(
                    width: size.width * .1,
                    height: size.width * .1,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                  onSelected: (item) => onSelectedMenuItem(
                        context,
                        item,
                      ),
                  itemBuilder: (context) =>
                      [...SearchMenu.searchMenuList.map(buildItem).toList()]),
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Groups()));
                  },
                  icon: Container(
                    width: size.width * .1,
                    height: size.width * .1,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: Icon(
                      Icons.group_rounded,
                      color: Colors.black,
                    ),
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Notifications(isPush: false)));
                  },
                  icon: Container(
                      width: size.width * .1,
                      height: size.width * .1,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade200),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: size.width * .04,
                              height: size.width * .04,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.deepOrange),
                              child: Text(
                                postProvider.totalNotifications.toString(),
                                style: TextStyle(fontSize: size.width * .02),
                              ),
                            ),
                          )
                        ],
                      ))),
            ],
          ),
          body: PageView(
            children: _tabs,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                if (_currentIndex == 2) {
                  _appbarTitle = 'Chat';
                } else if (_currentIndex == 1) {
                  _appbarTitle = 'Favourite';
                } else if (_currentIndex == 3) {
                  _appbarTitle = 'Account';
                } else {
                  _appbarTitle = 'Home';
                }
              });
            },
            controller: _pageController,
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
                primaryColor: Colors.deepOrange,
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(caption: new TextStyle(color: Colors.grey))),
            child: new BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              items: [
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.home), label: 'Home'),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.favorite_sharp), label: 'Favourite'),
                BottomNavigationBarItem(
                    icon: new Icon(FontAwesomeIcons.solidComment),
                    label: 'Chat'),
                BottomNavigationBarItem(
                    icon: new Icon(Icons.person), label: 'Account'),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  postProvider.setVideoPlaying();
                  print('video playing value = ${postProvider.isVideoPlaying}');
                  if (_currentIndex == 2) {
                    _appbarTitle = 'Chat';
                  } else if (_currentIndex == 0) {
                    _appbarTitle = 'Home';
                  } else if (_currentIndex == 1) {
                    _appbarTitle = 'Favourite';
                  } else if (_currentIndex == 3) {
                    _appbarTitle = 'Account';
                  }
                  _pageController.animateToPage(_currentIndex,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.linear);
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SearchPage()));
      },
      borderRadius: BorderRadius.circular(size.width * .2),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * .2),
            border: Border.all(color: Colors.grey)),
        padding: EdgeInsets.fromLTRB(size.width * .03, size.width * .01,
            size.width * .03, size.width * .01),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey, size: size.width * .06),
            SizedBox(
              width: size.width * .04,
            ),
            Text(
              'Search',
              style: TextStyle(color: Colors.grey, fontSize: size.width * .04),
            )
          ],
        ),
      ),
    );
  }

  Widget appBarTitle(BuildContext context) {
    return Text('$_appbarTitle',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'MateSC',
        ));
  }

  PopupMenuItem<SearchMenuItem> buildItem(SearchMenuItem item) =>
      PopupMenuItem<SearchMenuItem>(value: item, child: Text(item.text));

  onSelectedMenuItem(
    BuildContext context,
    SearchMenuItem item,
  ) {
    switch (item) {
      case SearchMenu.tokenSearch:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TokenSearch()));
        break;
      case SearchMenu.animalNameSearch:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AnimalNameSearch()));
        break;
      case SearchMenu.userSearch:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserSearch()));
        break;
    }
  }
}
