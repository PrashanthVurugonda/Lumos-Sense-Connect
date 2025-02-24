import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Updated for FontAwesome icons
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart'; // Using google_ml_kit for OCR
import 'package:vibration/vibration.dart';

class OcrDialog {
  final FlutterTts flutterTts = FlutterTts();
  bool isVibrationAvailable = false;

  OcrDialog() {
    _checkVibrationAvailability();
  }

  Future<void> _checkVibrationAvailability() async {
    isVibrationAvailable = await Vibration.hasVibrator();
  }

  Future<void> showOCRDialog(
      String text, XFile picture, BuildContext context) async {
    final pngByteData = await picture.readAsBytes();
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Text Detected'),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          onPressed: _stopTts,
                          child: const Text('Stop',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFb56576),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            _speakOCR(text);
                          },
                          child: const Text('Replay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffb56576),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          onPressed: _pauseTts,
                          child: const Text('Pause',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffb56576),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Image.memory(pngByteData),
                      SizedBox(width: 20),
                      Text("$text"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {return Container();});
  }

  Future _stopTts() async {
    if (isVibrationAvailable) {
      Vibration.vibrate(amplitude: 100, duration: 200);
    }
    flutterTts.stop();
  }

  void _pauseTts() {
    flutterTts.pause();
  }

  Future _speakOCR(String text) async {
    if (isVibrationAvailable) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    await flutterTts.speak(text);
  }

  Future<void> optionsDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            child: Icon(FontAwesomeIcons.camera), // Updated to FontAwesome
                          ),
                        ),
                        TextSpan(
                          text: 'Choose mode',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text('Take a picture'),
                    onTap: () {
                      openCamera(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text('Select from gallery'),
                    onTap: () {
                      openGallery(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> openCamera(BuildContext context) async {
    ImagePicker ip = ImagePicker();
    XFile? picture = await ip.pickImage(
      source: ImageSource.camera,
    );
    if (picture != null) {
      var _extractText = await _performOCR(picture.path); // Replaced with google_ml_kit
      _speakOCR(_extractText);
      showOCRDialog(_extractText, picture, context);
    }
  }

  Future<void> openGallery(BuildContext context) async {
    ImagePicker ip = ImagePicker();
    XFile? picture = await ip.pickImage(
      source: ImageSource.gallery,
    );
    if (picture != null) {
      var _extractText = await _performOCR(picture.path); // Replaced with google_ml_kit
      _speakOCR(_extractText);
      showOCRDialog(_extractText, picture, context);
    }
  }

  // Using google_ml_kit for OCR
  Future<String> _performOCR(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);
    String detectedText = recognizedText.text;
    textDetector.close();
    return detectedText;
  }
}
