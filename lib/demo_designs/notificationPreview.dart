import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/model/Notification.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/sub_screens/specificPost.dart';
import 'package:pet_lover/sub_screens/specificPostShow.dart';
import 'package:provider/provider.dart';

class NotificationPreview extends StatelessWidget {
  MyNotification notification;
  int index;
  NotificationPreview({required this.notification, required this.index});

  @override
  Widget build(BuildContext context) {
    DateTime miliDate =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(notification.date));
    var format = new DateFormat("yMMMd").add_jm();
    String finalDate = format.format(miliDate);
    Size size = MediaQuery.of(context).size;
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    return InkWell(
      onTap: () {
        postProvider
            .setChecked(notification.notificationId, index);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SpecificPostShow(
                        postId: notification.postId,
                        title: notification.receiverName,
                      )));

      },
      child: Container(
          width: size.width,
          color: notification.status == 'unclicked'
              ? Colors.grey.shade200
              : Colors.white,
          padding: EdgeInsets.only(
            top: size.width * .02,
            left: size.width * .04,
            right: size.width * .04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * .04,
                ),
              ),
              SizedBox(
                height: size.width * .01,
              ),
              Text(
                finalDate,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: size.width * .02,
              ),
              Divider(
                  thickness: size.width * .001,
                  color: Colors.grey,
                  height: size.width * .01),
            ],
          )),
    );
  }
}
