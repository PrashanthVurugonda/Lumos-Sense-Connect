import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:telephony/telephony.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';
import 'package:divergent/screens/blind/live_labelling/bndbox.dart';
import 'package:divergent/screens/blind/live_labelling/camera.dart';
import 'package:divergent/screens/blind/currency_detection/currency.dart';
import 'package:divergent/screens/blind/ocr/dialog_ocr.dart';
import 'package:divergent/screens/blind/sos/sos_dialog.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomePage(this.cameras, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0, _imageWidth = 0;
  String _model = "SSD MobileNet";
  File? _currImage;
  final FlutterTts flutterTts = FlutterTts();
  final Telephony telephony = Telephony.instance;
  late PageController _controller;
  int sosCount = 0;
  DateTime? initTime;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    smsPermission();
    loadModel();
    _initializeShakeDetector();
  }

  void _initializeShakeDetector() {
    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      if (sosCount == 0) {
        initTime = DateTime.now();
        sosCount++;
      } else if (DateTime.now().difference(initTime!).inSeconds < 4) {
        sosCount++;
        if (sosCount == 6) {
          sendSms();
          sosCount = 0;
        }
      } else {
        sosCount = 0;
      }
    });
    detector.startListening();
  }

  Future<void> getCurrImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _currImage = File(pickedFile.path);
      });
      CurrPage.currencyDetect(context, _currImage!);
    }
  }

  Future<void> sendSms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? n1 = prefs.getString('n1');
    String? n2 = prefs.getString('n2');
    String? n3 = prefs.getString('n3');
    String? name = prefs.getString('name');

    if (n1 == null || n2 == null || n3 == null || name == null) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    String message =
        "$name needs your help! Last seen at:\nLatitude: ${position.latitude}, Longitude: ${position.longitude}, Altitude: ${position.altitude}, Speed: ${position.speed}";

    telephony.sendSms(to: n1, message: message);
    telephony.sendSms(to: n2, message: message);
    telephony.sendSms(to: n3, message: message);
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
    print("MODEL LOADED: ${res ?? 'Error loading model'}");
  }

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  Future<void> _speakPage(int index) async {
    List<String> messages = [
      "Live object detection",
      "Image Captioning",
      "Text Extraction from Images",
      "Currency Identifier",
      "SOS Settings"
    ];

    if (index < messages.length) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 800 + (index * 400));
      }
      await flutterTts.speak(messages[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    OcrDialog od = OcrDialog();

    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: _speakPage,
        children: <Widget>[
          Stack(
            children: [
              CameraWidget(cameras:widget.cameras,model: _model,setRecognitions: setRecognitions),
              BndBox(
                _recognitions ?? [],
                math.max(_imageHeight, _imageWidth),
                math.min(_imageHeight, _imageWidth),
                screen.height,
                screen.width,
                _model,
              ),
            ],
          ),
          _buildPage(
            context,
            color: const Color(0xffb56576),
            text: "Text Extraction from Images",
            onPressed: () => od.optionsDialogBox(context),
          ),
          _buildPage(
            context,
            color: const Color(0xffe56b6f),
            text: "Currency Identifier",
            onPressed: getCurrImage,
          ),
          _buildPage(
            context,
            color: Colors.blueGrey,
            text: "SOS Settings",
            onPressed: () => SosDialog().sosDialogBox(context),

          ),
        ],
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildPage(BuildContext context,
      {required Color color, required String text, required VoidCallback onPressed}) {
    return Container(
      color: color,
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(fontSize: 27.0)),
        ),
      ),
    );
  }

  void smsPermission() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == false) {
      print("SMS Permission Denied!");
    }
  }
}
