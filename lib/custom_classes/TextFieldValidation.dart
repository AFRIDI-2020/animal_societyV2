class TextFieldValidation {
  bool mobileNoValidate(String _mobileNo) {
    if (_mobileNo.length != 11) {
      return false;
    } else {
      return true;
    }
  }

  bool passwordValidation(String _password) {
    if (_password.length < 6) {
      return false;
    } else {
      return true;
    }
  }

  bool usernameValidation(String _username) {
    if (_username.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool addressValidation(String _address) {
    if (_address.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool petNameValidation(String _petName) {
    if (_petName.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
