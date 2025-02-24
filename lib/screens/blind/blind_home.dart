import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the available cameras
  final List<CameraDescription> cameras = await availableCameras();

  runApp(BlindHome(cameras: cameras));
}

class BlindHome extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const BlindHome({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helping Hands',
      debugShowCheckedModeBanner: false,
      home: HomePage(cameras),
    );
  }
}
