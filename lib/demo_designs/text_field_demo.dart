import 'package:flutter/material.dart';

class TextFieldBuilder {
  Widget showtextFormBuilder(
      BuildContext context,
      String _labelText,
      IconData _prefixIconData,
      TextEditingController _textEditingController,
      String? _errorText,
      bool obscureText,
      FocusNode focusNode,
      Widget? _suffixIconData) {
    Size size = MediaQuery.of(context).size;

    return TextFormField(
      obscureText: obscureText,
      controller: _textEditingController,
      focusNode: focusNode,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(top: size.width * .04, bottom: size.width * .04),
        errorText: _errorText,
        labelText: _labelText,
        prefixIcon: Icon(
          _prefixIconData,
          color: Colors.grey,
        ),
        suffixIcon: _labelText == 'Password' ||
                _labelText == 'Confirm Password' ||
                _labelText == 'Old password' ||
                _labelText == 'New password' ||
                _labelText == 'Confirm password'
            ? _suffixIconData
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(
            color: Colors.deepOrange,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      cursorColor: Colors.black,
    );
  }
}
