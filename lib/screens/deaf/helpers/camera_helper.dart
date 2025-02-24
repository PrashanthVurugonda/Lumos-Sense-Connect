import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:divergent/screens/deaf/helpers/app_helper.dart';
import 'package:divergent/screens/deaf/helpers/tflite_helper.dart';

class CameraHelper {
  static late CameraController camera;
  static bool isDetecting = false;
  static CameraLensDirection _direction = CameraLensDirection.back;
  static late Future<void> initializeControllerFuture;

  // Get the camera description based on lens direction
  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      return cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      );
    } catch (e) {
      AppHelper.log("CameraHelper", "Error getting camera: $e");
      rethrow;
    }
  }

  // Initialize the camera
  static Future<void> initializeCamera() async {
    AppHelper.log("CameraHelper", "Initializing camera...");

    try {
      CameraDescription selectedCamera = await _getCamera(_direction);
      camera = CameraController(
        selectedCamera,
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.low
            : ResolutionPreset.high,
        enableAudio: false,
      );

      initializeControllerFuture = camera.initialize().then((_) {
        AppHelper.log("CameraHelper", "Camera initialized, starting stream...");
        _startImageStream();
      });
    } catch (e) {
      AppHelper.log("CameraHelper", "Camera initialization failed: $e");
    }
  }

  // Start image stream for object detection
  static void _startImageStream() {
    if (!camera.value.isInitialized) {
      AppHelper.log("CameraHelper", "Camera not initialized, cannot start stream.");
      return;
    }

    camera.startImageStream((CameraImage image) {
      if (!TFLiteHelper.modelLoaded) return;
      if (isDetecting) return;
      
      isDetecting = true;
      try {
        TFLiteHelper.classifyImage(image);
      } catch (e) {
        AppHelper.log("CameraHelper", "Error processing image: $e");
      } finally {
        isDetecting = false;
      }
    });
  }

  // Dispose camera resources
  static Future<void> disposeCamera() async {
    try {
      if (camera.value.isStreamingImages) {
        await camera.stopImageStream();
      }
      await camera.dispose();
      AppHelper.log("CameraHelper", "Camera disposed.");
    } catch (e) {
      AppHelper.log("CameraHelper", "Error disposing camera: $e");
    }
  }
}
