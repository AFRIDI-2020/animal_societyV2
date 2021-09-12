import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/login.dart';
import 'package:pet_lover/sub_screens/EditProfile.dart';
import 'package:pet_lover/sub_screens/addAnimal.dart';
import 'package:pet_lover/sub_screens/groups.dart';
import 'package:pet_lover/sub_screens/myFollowers.dart';
import 'package:pet_lover/sub_screens/my_animals.dart';
import 'package:pet_lover/sub_screens/reset_password.dart';

class ProfileOption {
  Widget showOption(BuildContext context, String title) {
    Size size = MediaQuery.of(context).size;

    return ListTile(
        title: Text(
          '$title',
          style: TextStyle(color: Colors.black, fontSize: size.width * .04),
        ),
        leading: title == 'Add animals'
            ? Icon(
                Icons.add_circle_outline_sharp,
                color: Colors.deepOrange,
              )
            : title == 'Shared animals'
                ? Icon(
                    Icons.share,
                    color: Colors.deepOrange,
                  )
                : title == 'My followers'
                    ? Icon(
                        FontAwesomeIcons.users,
                        color: Colors.deepOrange,
                      )
                    : title == 'Groups'
                        ? Icon(
                            Icons.group,
                            color: Colors.deepOrange,
                          )
                        : title == 'My animals'
                            ? Icon(
                                FontAwesomeIcons.paw,
                                color: Colors.deepOrange,
                              )
                            : title == 'Update account'
                                ? Icon(
                                    Icons.edit,
                                    color: Colors.deepOrange,
                                  )
                                : title == 'Reset password'
                                    ? Icon(
                                        Icons.vpn_key,
                                        color: Colors.deepOrange,
                                      )
                                    : Icon(
                                        Icons.logout,
                                        color: Colors.deepOrange,
                                      ),
        trailing: title != 'Logout'
            ? Icon(
                Icons.chevron_right,
                color: Colors.black,
              )
            : null,
        onTap: () {
          Future<String> mobileNo;
          title == 'Add animals'
              // ignore: unnecessary_statements
              ? {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAnimal(petId: '')))
                }
              : title == 'Groups'
                  // ignore: unnecessary_statements
                  ? {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Groups()))
                    }
                  : title == 'My animals'
                      // ignore: unnecessary_statements
                      ? {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyAnimals()))
                        }
                      : title == 'Reset password'
                          // ignore: unnecessary_statements
                          ? {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResetPassword()))
                            }
                          : title == 'Update account'
                              // ignore: unnecessary_statements
                              ? {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileUser()))
                                }
                              : title == 'My followers'
                                  // ignore: unnecessary_statements
                                  ? {
                                      mobileNo = DatabaseManager()
                                          .getCurrentMobileNo(),
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MyFollowers()))
                                    }
                                  // ignore: unnecessary_statements
                                  : {
                                      DatabaseManager().clearSharedPref(),
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()),
                                          (route) => false)
                                    };
        });
  }
}
