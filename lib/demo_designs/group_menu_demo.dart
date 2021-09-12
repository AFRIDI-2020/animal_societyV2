import 'package:flutter/material.dart';

import 'package:pet_lover/model/group_menu_item.dart';

class MenuItems {
  static const List<MenuItem> groupMenuItems = [
    allMembers,
    itemLeaveGroup,
  ];

  static const List<MenuItem> adminGroupMenuItems = [
    allMembers,
    editGroup,
    deleteGroup,
  ];

  static const allMembers =
      MenuItem(text: 'All members', iconData: Icons.group);
  static const itemLeaveGroup =
      MenuItem(text: 'Leave group', iconData: Icons.logout);
  static const deleteGroup =
      MenuItem(text: 'Delete group', iconData: Icons.delete);
  static const editGroup = MenuItem(text: 'Edit group', iconData: Icons.edit);
}
