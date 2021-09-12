import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/notificationPreview.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
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

  @override
  void dispose() {
    super.dispose();
    if(widget.isPush){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
    }else Navigator.pop(context);
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
            if(widget.isPush){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
            }else Navigator.pop(context);
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
