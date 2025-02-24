import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:divergent/screens/deaf/helpers/app_helper.dart';
import 'package:divergent/screens/deaf/helpers/camera_helper.dart';
import 'package:divergent/screens/deaf/helpers/tflite_helper.dart';
import 'package:divergent/screens/deaf/models/result.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DetectScreen extends StatefulWidget {
  const DetectScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _DetectScreenState createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  List<Result> outputs = [];
  String prevDetection = '';
  var prevTime = DateTime.now().millisecondsSinceEpoch;
  late AnimationController _colorAnimController;
  late Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _setupAnimation();

    // Load TFLite Model
    TFLiteHelper.loadModel().then((_) {
      setState(() => TFLiteHelper.modelLoaded = true);
    });

    // Initialize Camera
    CameraHelper.initializeCamera();

    // Subscribe to TFLite's Classify events
    TFLiteHelper.tfLiteResultsController.stream.listen((value) {
      if (value.isNotEmpty) {
        _colorAnimController.animateTo(
          value.first.confidence,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 500),
        );
      }

      // Update UI
      setState(() {
        outputs = value;
        CameraHelper.isDetecting = false;
      });

      // Handle Voice Output
      _handleVoiceFeedback();
    }, onError: (error) {
      AppHelper.log("Error in Stream", error);
    });
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera.dispose();
    _colorAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff375079),
        elevation: 4,
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(CameraHelper.camera),
                _buildOverlay(),
                _buildDetectionResults(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
        },
      ),
    );
  }

  // 🔹 Subtle overlay for better visibility
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.1),
      ),
    );
  }

  // 🔹 Displays detected text & animations
  Widget _buildDetectionResults() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: outputs.isNotEmpty
            ? _buildResultText(outputs.first.label.substring(2))
            : const Center(
                child: Text(
                  "Waiting for model to detect...",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  // 🔹 Builds the detected text UI
  Widget _buildResultText(String detectedText) {
    return Column(
      children: [
        const Text(
          'Letter Detected:',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _colorAnimController,
          builder: (context, child) {
            return Text(
              detectedText,
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: _colorTween.value,
              ),
            );
          },
        ),
      ],
    );
  }

  // 🔹 Voice feedback handler
  Future<void> _handleVoiceFeedback() async {
    if (outputs.isNotEmpty) {
      String currentDetection = outputs.first.label.substring(2);
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentDetection != prevDetection && (currentTime - prevTime > 1000)) {
        await flutterTts.setLanguage("en-US");
        await flutterTts.setPitch(1.0);
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.speak(currentDetection);

        prevDetection = currentDetection;
        prevTime = currentTime;
      }
    }
  }

  // 🔹 Setup animation controller for text color
  void _setupAnimation() {
    _colorAnimController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
        .animate(_colorAnimController);
  }
}
