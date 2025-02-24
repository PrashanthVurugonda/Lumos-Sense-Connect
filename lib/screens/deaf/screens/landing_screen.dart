import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:divergent/main.dart';
import 'package:divergent/screens/deaf/screens/detectScreen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light, // Fixes brightness issue
        title: const Text(
          'Introduction',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: Color(0xff375079),
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 150.0, left: 35, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello and welcome to",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 25,
                fontFamily: "Roboto",
              ),
            ),
            const Text(
              "ASL Detection.",
              style: TextStyle(
                color: Color(0xff375079),
                fontSize: 25,
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "This app lets you detect letters using Image Detection.",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontFamily: "Roboto",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            _buildFeatureRow(Icons.add_a_photo, "Use our image analyzer to detect letters."),
            const SizedBox(height: 15),
            _buildFeatureRow(Icons.volume_up, "Converts text to speech with a tap."),
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "ASL Detection",
                  style: TextStyle(
                    color: Color(0xff375079),
                    fontFamily: "Roboto",
                    fontSize: 23,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff375079),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DetectScreen(title: 'ASL Detection'),
            ),
          );
        },
      ),
    );
  }

  /// Widget for feature rows
  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff3ACCE1), size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff41A1FF),
              fontSize: 15,
              fontFamily: "Roboto",
            ),
          ),
        ),
      ],
    );
  }
}
