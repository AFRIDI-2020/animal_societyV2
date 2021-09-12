class Comment {
  String? commentId;
  String? postOwnerId;
  String? currentUserMobileNo;
  String? comment;
  String? date;
  String? postId;

  Comment(
      {this.commentId,
      this.comment,
      this.postOwnerId,
      this.currentUserMobileNo,
      this.date,
      required this.postId});
}
