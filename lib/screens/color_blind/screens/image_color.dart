import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:colornames/colornames.dart';
import 'package:divergent/screens/color_blind/screens/indicator.dart';

class ImageColor extends StatefulWidget {
  final String? path;

  const ImageColor({Key? key, this.path}) : super(key: key);

  @override
  _ImageColorState createState() => _ImageColorState();
}

class _ImageColorState extends State<ImageColor> {
  final GlobalKey imageKey = GlobalKey();
  final GlobalKey paintKey = GlobalKey();
  final StreamController<Color> _stateController = StreamController<Color>.broadcast();

  bool useSnapshot = true;
  late GlobalKey currentKey;
  img.Image? photo;
  Offset position = const Offset(10, 10);
  Color selectedColor = Colors.green;

  @override
  void initState() {
    super.initState();
    currentKey = useSnapshot ? paintKey : imageKey;
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Image Color Picker",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: Color(0xff375079),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<Color>(
        initialData: selectedColor,
        stream: _stateController.stream,
        builder: (context, snapshot) {
          selectedColor = snapshot.data ?? Colors.green;

          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Stack(
              children: <Widget>[
                RepaintBoundary(
                  key: paintKey,
                  child: GestureDetector(
                    onPanDown: (details) => _handleTouch(details.globalPosition),
                    onPanUpdate: (details) => _handleTouch(details.globalPosition),
                    child: SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Card(
                        color: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: widget.path != null
                            ? Image.file(
                                File(widget.path!),
                                key: imageKey,
                                fit: BoxFit.contain,
                              )
                            : const Center(child: Text("No image selected")),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: position.dy - 25 / 2,
                  left: position.dx - 25 / 2,
                  child: ColorIndicator(
                    currentColor: selectedColor,
                    show: true,
                    below: true,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 130,
                      width: double.infinity,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                          ),
                        ),
                        elevation: 1,
                        color: Colors.black26,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              const Text(
                                "Color Info",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedColor,
                                      border: Border.all(width: 2.0, color: Colors.white),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    ColorNames.guess(selectedColor),
                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTouch(Offset globalPosition) async {
    setState(() {
      position = globalPosition;
    });
    await _searchPixel(globalPosition);
  }

  Future<void> _searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await (useSnapshot ? _loadSnapshotBytes() : _loadImageBundleBytes());
    }
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox? box = currentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || photo == null) return;

    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    if (!useSnapshot) {
      double widgetScale = box.size.width / photo!.width;
      px = px / widgetScale;
      py = py / widgetScale;
    }

    // Extract RGB values correctly from the pixel
    img.Pixel pixel = photo!.getPixelSafe(px.toInt(), py.toInt()); // FIX: Use img.Pixel

    int a = pixel.a.toInt();
    int r = pixel.r.toInt();
    int g = pixel.g.toInt();
    int b = pixel.b.toInt();
    
    _stateController.add(Color.fromARGB(a, r, g, b));
  }

  Future<void> _loadImageBundleBytes() async {
    if (widget.path == null) return;
    ByteData imageBytes = await rootBundle.load(widget.path!);
    _setImageBytes(imageBytes);
  }

  Future<void> _loadSnapshotBytes() async {
    RenderRepaintBoundary? boxPaint = paintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boxPaint == null) return;

    ui.Image capture = await boxPaint.toImage();
    ByteData? imageBytes = await capture.toByteData(format: ui.ImageByteFormat.png);
    if (imageBytes != null) {
      _setImageBytes(imageBytes);
    }
    capture.dispose();
  }

  void _setImageBytes(ByteData imageBytes) {
    Uint8List values = imageBytes.buffer.asUint8List();
    photo = img.decodeImage(values);
  }
}
