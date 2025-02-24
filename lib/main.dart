import 'package:divergent/screens/blind/blind_home.dart';
import 'package:divergent/screens/blind/sos/sos_dialog.dart';
import 'package:divergent/screens/color_blind/color_blind_home.dart';
import 'package:divergent/screens/deaf/deaf_home.dart';
import 'package:divergent/sos_activate.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

SosDialog sd = SosDialog();
final Telephony telephony = Telephony.instance;
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MySplash(),
    );
  }
}

// ✅ FIXED: Replaced `SplashScreen` (Old Package Doesn't Support Null Safety)
class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.7],
            colors: [
              Color(0xff1c4257),
              Color(0xff253340),
            ],
          ),
        ),
        child: Center(
          child: Image.asset('assets/icon-circle.png', width: 100, height: 100),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    smsPermission();
    loadModel();

    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SOSActivate()),
      );
    });

    detector.startListening();
  }

  void sendSms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? n1 = prefs.getString('n1');
    String? n2 = prefs.getString('n2');
    String? n3 = prefs.getString('n3');
    String? name = prefs.getString('name');

    if (n1 == null || n2 == null || n3 == null || name == null) {
      print("Error: Contacts or name not set in SharedPreferences.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    String lat = position.latitude.toString();
    String long = position.longitude.toString();
    String alt = position.altitude.toString();
    String speed = position.speed.toString();
    String timestamp = position.timestamp.toIso8601String();

    String message =
        "$name needs your help! Last seen at:\nLatitude: $lat\nLongitude: $long\nAltitude: $alt\nSpeed: $speed\nTime: $timestamp";

    telephony.sendSms(to: n1, message: message);
    telephony.sendSms(to: n2, message: message);
    telephony.sendSms(to: n3, message: message);
  }

  void smsPermission() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted != true) {
      print("SMS Permission not granted.");
    }
  }

  void loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
    print("Model Loaded: $res");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color(0xff375079),
        elevation: 0,
        title: const Text(
          'Select an option',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              sd.sosDialogBox(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildOptionTile(
                title: "Blind",
                imagePath: 'assets/images/blind_image.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlindHome(cameras: [],)),
                ),
              ),
              _buildOptionTile(
                title: "Deaf / Mute",
                imagePath: 'assets/images/deaf_image.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeafHome()),
                ),
              ),
              _buildOptionTile(
                title: "Colour Blind",
                imagePath: 'assets/images/colour_blind_image.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColorBlindHome()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({required String title, required String imagePath, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                    radius: 80.0,
                    backgroundColor: Colors.grey[200],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      title,
                      style: const TextStyle(color: Color(0xff375079), fontSize: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
