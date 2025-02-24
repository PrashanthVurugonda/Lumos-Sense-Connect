import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:divergent/screens/deaf/screens/landing_screen.dart';

class DeafHome extends StatefulWidget {
  const DeafHome({Key? key}) : super(key: key); // Fixed null safety issue

  @override
  _DeafHomeState createState() => _DeafHomeState();
}

class _DeafHomeState extends State<DeafHome> {
  @override
  void initState() {
    super.initState();

    // Locking the screen to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASL Detection',
      theme: ThemeData(
        primaryColor: Color(0xff375079),
      ),
      home: SplashScreenView(
        navigateRoute: LandingPage(),
        duration: 3000,
        imageSize: 130,
        imageSrc: "assets/logo.png", // Replace with your actual splash logo
        backgroundColor: Colors.white,
      ),
    );
  }
}
