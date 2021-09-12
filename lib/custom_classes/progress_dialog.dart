import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Color(0xff737373),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.width * .04),
        ),
        padding: EdgeInsets.all(size.width * .1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
            SizedBox(
              width: size.width * .05,
            ),
            Expanded(
              child: Container(
                child: Text(
                  '$message',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .038,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
