import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:divergent/screens/color_blind/screens/image_color.dart';

class ColorBlindHome extends StatefulWidget {
  const ColorBlindHome({Key? key}) : super(key: key);

  @override
  _ColorBlindHomeState createState() => _ColorBlindHomeState();
}

class _ColorBlindHomeState extends State<ColorBlindHome> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);

      if (pickedImage != null) {
        setState(() => _image = File(pickedImage.path));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageColor(path: _image!.path)),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Widget _buildImagePickerButton(String text, ImageSource source) {
    return InkWell(
      onTap: () => getImage(source),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(color: Color(0xff375079), fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text('Select an option', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            color: Color(0xff375079),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildImagePickerButton('From Gallery', ImageSource.gallery),
              const SizedBox(height: 20),
              _buildImagePickerButton('From Camera', ImageSource.camera),
            ],
          ),
        ),
      ),
    );
  }
}
