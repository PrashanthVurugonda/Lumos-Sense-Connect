library image_picker_gallery_camera;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerGC {
  static Future<XFile?> pickImage({
    required BuildContext context,
    required ImgSource source,
    bool enableCloseButton = false,
    double? maxWidth,
    double? maxHeight,
    Icon? cameraIcon,
    Icon? galleryIcon,
    Widget? cameraText,
    Widget? galleryText,
    bool barrierDismissible = false,
    Icon? closeIcon,
    int? imageQuality,
  }) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    final ImagePicker picker = ImagePicker();

    switch (source) {
      case ImgSource.Camera:
        return await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      case ImgSource.Gallery:
        return await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      case ImgSource.Both:
        return await showDialog<XFile?>(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (enableCloseButton)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: closeIcon ?? const Icon(Icons.close, size: 14),
                      ),
                    ),
                  InkWell(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        imageQuality: imageQuality,
                      );
                      Navigator.pop(context, image);
                    },
                    child: ListTile(
                      title: galleryText ?? const Text("Gallery"),
                      leading: galleryIcon ?? const Icon(Icons.image, color: Colors.deepPurple),
                    ),
                  ),
                  Divider(height: 1, color: Colors.black12),
                  InkWell(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        imageQuality: imageQuality,
                      );
                      Navigator.pop(context, image);
                    },
                    child: ListTile(
                      title: cameraText ?? const Text("Camera"),
                      leading: cameraIcon ?? const Icon(Icons.camera, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
  }
}

enum ImgSource { Camera, Gallery, Both }
