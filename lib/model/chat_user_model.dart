import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserModel{
  String? id;
  String? followingName;
  String? followerName;
  String? followingImageLink;
  String? followerImageLink;
  String? followerNumber;
  String? followingNumber;
  String? lastMessage;
  Timestamp? lastMessageTime;
  bool? isSeen;

  ChatUserModel({this.id,this.followingName,this.followerName, this.followingImageLink,this.followerImageLink,this.followerNumber,this.followingNumber,this.lastMessage, this.lastMessageTime,this.isSeen});
}