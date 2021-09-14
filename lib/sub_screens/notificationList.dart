import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pet_lover/demo_designs/notificationPreview.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/maintenanceBreak.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  bool isPush;
  Notifications({required this.isPush});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int count = 0;
  bool _loading = false;
  bool db_update = false;
  String current_version = '';
  String running_version = '';

  Future _getNotifications(
      PostProvider postProvider, UserProvider userProvider) async {
    setState(() {
      count++;
      _loading = true;
    });
    if (postProvider.notificationList.isEmpty)
      await postProvider.getNotifications();
    setState(() {
      _loading = false;
    });
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
  void initState() {
    super.initState();
    getCurrentState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isPush) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (count == 0) _getNotifications(postProvider, userProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
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
            if (widget.isPush) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            } else
              Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: _bodyUI(postProvider),
    );
  }

  Widget _bodyUI(PostProvider postProvider) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            backgroundColor: Colors.white,
            onRefresh: () async {
              await postProvider.getNotifications();
            },
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              // shrinkWrap: true,
              itemCount: postProvider.notificationList.length,
              itemBuilder: (context, index) {
                return NotificationPreview(
                    notification: postProvider.notificationList[index],
                    index: index);
              },
            ),
          );
  }
}
