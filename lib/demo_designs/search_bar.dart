import 'package:flutter/material.dart';

class SearchBar {
  Widget showSearchBar(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * .8,
      padding: EdgeInsets.only(left: size.width * .02, right: size.width * .04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .25),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.fromLTRB(
                  0, size.width * .02, size.width * .02, size.width * .02),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  hintStyle: TextStyle(color: Colors.black),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: size.width * .04),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * .02,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.fromLTRB(
                size.width * .04,
                size.width * .02,
                size.width * .04,
                size.width * .02,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * .25),
                  color: Colors.grey[300]),
              child: Text(
                'Search',
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
