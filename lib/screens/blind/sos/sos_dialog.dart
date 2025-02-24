import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosDialog {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  Future<void> sosDialogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter phone numbers you would like to contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField(_controller4, "Enter your name"),
              _buildTextField(_controller1, "Enter phone number 1",
                  keyboardType: TextInputType.phone),
              _buildTextField(_controller2, "Enter phone number 2",
                  keyboardType: TextInputType.phone),
              _buildTextField(_controller3, "Enter phone number 3",
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setNumbers(
                    _controller1.text,
                    _controller2.text,
                    _controller3.text,
                    _controller4.text,
                  );
                  Navigator.of(context).pop(); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFeaac8b),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  "Save Information",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: labelText),
      ),
    );
  }

  Future<void> setNumbers(String n1, String n2, String n3, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('n1', n1);
    await prefs.setString('n2', n2);
    await prefs.setString('n3', n3);
    await prefs.setString('name', name);
  }

  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
  }
}
