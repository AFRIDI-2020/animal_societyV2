import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/token_search_show.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';

class TokenSearch extends StatefulWidget {
  const TokenSearch({Key? key}) : super(key: key);

  @override
  _TokenSearchState createState() => _TokenSearchState();
}

class _TokenSearchState extends State<TokenSearch> {
  TextEditingController _searchController = TextEditingController();
  bool? _loading;
  bool isVisible = true;
  bool _tokenExists = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search Token",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              postProvider.setSearchTokenListEmpty();
              Navigator.pop(context);
            },
          ),
        ),
        body: _bodyUi(context, size, postProvider, userProvider));
  }

  Widget _bodyUi(BuildContext context, Size size, PostProvider postProvider,
      UserProvider userProvider) {
    return Container(
        width: size.width,
        child: Column(
          children: [
            SizedBox(height: size.width * .04),
            searchBar(context, postProvider, userProvider),
            SizedBox(height: size.width * .04),
            Expanded(
              child: Container(
                  width: size.width,
                  child: _loading == true
                      ? Center(child: CircularProgressIndicator())
                      : _tokenExists == false
                          ? Center(child: Text('No such token.'))
                          : ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: postProvider.searchedTokenList.length,
                              itemBuilder: (context, index) {
                                return TokenSearchPost(
                                    post:
                                        postProvider.searchedTokenList[index]);
                              })),
            )
          ],
        ));
  }

  Widget searchBar(BuildContext context, PostProvider postProvider,
      UserProvider userProvider) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
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
                  hintText: 'Token',
                  hintStyle: TextStyle(color: Colors.grey),
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
            onTap: () async {
              setState(() {
                _loading = true;
              });
              _tokenExists = await postProvider.searchToken(
                  _searchController.text, userProvider);
              setState(() {
                _loading = false;
              });
            },
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
