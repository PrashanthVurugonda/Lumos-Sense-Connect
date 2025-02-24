import 'dart:async';
import 'package:camera/camera.dart';
import 'package:divergent/screens/deaf/models/result.dart';
import 'package:tflite/tflite.dart';
import 'app_helper.dart';

class TFLiteHelper {
  static final StreamController<List<Result>> tfLiteResultsController =
      StreamController<List<Result>>.broadcast();

  static List<Result> _outputs = [];
  static bool modelLoaded = false;

  // Load the TFLite model
  static Future<void> loadModel() async {
    AppHelper.log("TFLiteHelper", "Loading model...");

    try {
      String? result = await Tflite.loadModel(
        model: "assets/tflite/model_unquant.tflite",
        labels: "assets/tflite/labels.txt",
      );

      if (result == "success") {
        modelLoaded = true;
        AppHelper.log("TFLiteHelper", "Model loaded successfully.");
      } else {
        AppHelper.log("TFLiteHelper", "Model failed to load.");
      }
    } catch (e) {
      AppHelper.log("TFLiteHelper", "Error loading model: $e");
    }
  }

  // Classify an image using the TFLite model
  static Future<void> classifyImage(CameraImage image) async {
    if (!modelLoaded) {
      AppHelper.log("TFLiteHelper", "Model is not loaded. Cannot classify.");
      return;
    }

    try {
      List<dynamic>? recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        numResults: 1, // Adjust this value for more predictions
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        AppHelper.log("TFLiteHelper", "Results received: ${recognitions.length}");

        _outputs.clear();

        for (var element in recognitions) {
          _outputs.add(
            Result(
              element['confidence'],
              element['index'],
              element['label'],
            ),
          );

          AppHelper.log(
            "TFLiteHelper",
            "Confidence: ${element['confidence']}, Label: ${element['label']}",
          );
        }

        // Sort results by confidence (highest first)
        _outputs.sort((a, b) => b.confidence.compareTo(a.confidence));

        // Send results to the stream
        tfLiteResultsController.sink.add(_outputs);
      }
    } catch (e) {
      AppHelper.log("TFLiteHelper", "Error classifying image: $e");
    }
  }

  // Dispose the model and stream
  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
    modelLoaded = false;
    AppHelper.log("TFLiteHelper", "Model disposed and stream closed.");
  }
}
