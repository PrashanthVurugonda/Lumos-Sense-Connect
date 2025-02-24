import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SOSActivate extends StatefulWidget {
  const SOSActivate({Key? key}) : super(key: key); // ✅ Fixed Key constructor

  @override
  _SOSActivateState createState() => _SOSActivateState();
}

class _SOSActivateState extends State<SOSActivate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1c4257), // ✅ Moved `color` up for readability
      child: Center(
        child: SizedBox.expand(
          child: TextButton( // ✅ Replaced deprecated FlatButton with TextButton
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff1c4257), // ✅ Set button color
              foregroundColor: Colors.white, // ✅ Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // ✅ Optional: Adds rounded corners
              ),
            ),
            onPressed: () {
              Fluttertoast.showToast(
                msg: "SOS sent successfully",
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.redAccent, // ✅ Optional: Improves visibility
                textColor: Colors.white,
              );
            },
            child: const Text(
              "Send SOS",
              style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
