class Post {
  String postId;
  String postOwnerId;
  String postOwnerMobileNo;
  String postOwnerName;
  String postOwnerImage;
  String date;
  String status;
  String photo;
  String video;
  String animalToken;
  String animalName;
  String animalColor;
  String animalAge;
  String animalGender;
  String animalGenus;
  String totalFollowers;
  String totalComments;
  String totalShares;
  String groupId;
  String shareId;

  Post(
      {required this.postId,
      required this.postOwnerId,
      required this.postOwnerMobileNo,
      required this.postOwnerName,
      required this.postOwnerImage,
      required this.date,
      required this.status,
      required this.photo,
      required this.video,
      required this.animalToken,
      required this.animalName,
      required this.animalColor,
      required this.animalAge,
      required this.animalGender,
      required this.animalGenus,
      required this.totalFollowers,
      required this.totalComments,
      required this.totalShares,
      required this.groupId,
      required this.shareId});
}
