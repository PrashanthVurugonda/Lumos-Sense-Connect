import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class CurrPage {
  static File? currImage; // Make currImage nullable
  static BuildContext? context;

  static List _output = []; // Keeping _output as a list to store results
  static final FlutterTts flutterTts = FlutterTts();

  static void currencyDetect(BuildContext buildContext, File img) {
    context = buildContext;
    currImage = img; // currImage will now hold the passed image
    loadModel().then((value) {
      // Now the model is loaded, proceed with currency detection
      speakCurrencyValue();
    });
  }

  static classifyCurrency(File image) async {
    if (image.path.isEmpty) {
      return; // Just return if the image path is empty (shouldn't happen if image is valid)
    }
    
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 7,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("This is the $output");

    // Check if output is not empty
    if (output != null && output.isNotEmpty) {
      String label = output[0]['label'];
      print("Detected label: $label");

      // Handle vibration and speech
      _vibrate();
      _speak(label);
      
      _output = output; // Storing the output in the _output field

      // Show caption dialog with result and image
      showCaptionDialog(label, image);
    } else {
      _speak("Unable to detect currency");
    }
  }

  static loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/cash_model_unquant.tflite',
        labels: 'assets/cash_labels.txt',
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  static speakCurrencyValue() {
    if (currImage != null) {
      _stopTts(); // Stop any ongoing TTS before starting a new one
      classifyCurrency(currImage!); // Safely unwrap currImage
    }
  }

  static Future _speak(String output) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    await flutterTts.speak(output);
  }

  static Future<void> showCaptionDialog(String text, File picture) async {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text('Currency Identification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 300.0,
                      height: 420.0,
                      child: ElevatedButton(
                        onPressed: () {
                          _speak(text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffe56b6f),
                          padding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: const Text(
                          'Replay',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.file(picture),
                    SizedBox(width: 20),
                    Text("$text"),

                    // Displaying the output list directly in the dialog
                    Text(
                      "Currency Detected: ${_output.isNotEmpty ? _output[0]['label'] : 'No result'}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
      context: context!,
      pageBuilder: (context, animation1, animation2) {return SizedBox.shrink();},
    );
  }

  static void _stopTts() {
    flutterTts.stop();  // Stop any ongoing TTS
  }

  // Vibration helper function
  static Future _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
  }
}
