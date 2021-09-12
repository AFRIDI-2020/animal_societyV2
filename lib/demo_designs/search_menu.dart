import 'package:pet_lover/model/search_menu_item.dart';

class SearchMenu {
  static const List<SearchMenuItem> searchMenuList = [
    userSearch,
    tokenSearch,
    animalNameSearch,
  ];
  static const userSearch = SearchMenuItem(text: 'User');
  static const tokenSearch = SearchMenuItem(text: 'Token');
  static const animalNameSearch = SearchMenuItem(text: 'Animal name');
}
