class MyNotification {
  String notificationId;
  String date;
  String senderId;
  String receiverId;
  String title;
  String body;
  String senderName;
  String receiverName;
  String status;
  String postId;
  String groupId;

  MyNotification(
      {required this.notificationId,
      required this.date,
      required this.senderId,
      required this.receiverId,
      required this.title,
      required this.body,
      required this.senderName,
      required this.receiverName,
      required this.status,
      required this.postId,
      required this.groupId
      });
}
