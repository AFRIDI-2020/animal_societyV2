import 'package:flutter/material.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';

class CommentEditDelete {
  static const List<MyAnimalItemMenu> commentEditDeleteList = [
    editComment,
    deleteComment
  ];

  static const editComment =
      MyAnimalItemMenu(text: 'Edit', iconData: Icons.edit);

  static const deleteComment =
      MyAnimalItemMenu(text: 'Delete', iconData: Icons.delete);
}
