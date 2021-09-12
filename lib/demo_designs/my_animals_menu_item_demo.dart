import 'package:flutter/material.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';

class MyAnimalsMenu {
  static const List<MyAnimalItemMenu> MyAnimalsMenuList = [
    editAnimalPost,
    deleteAnimalPost
  ];
  static const editAnimalPost =
      MyAnimalItemMenu(text: 'Edit', iconData: Icons.edit);

  static const deleteAnimalPost =
      MyAnimalItemMenu(text: 'Delete', iconData: Icons.delete);
}
