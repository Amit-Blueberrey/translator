import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/features/camera_translation/controller/cammera_controller.dart';

class camera_recognition extends StatefulWidget {
  const camera_recognition ({super.key});

  @override
  State<camera_recognition> createState() => _camera_recognitionState();
}

class _camera_recognitionState extends State<camera_recognition> {
  File? _image;
  String _recognizedText = '';
  String _recognizedLanguage = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
        _recognizeTextFromImage(croppedFile);
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<void> _recognizeTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final String language = await languageIdentifier.identifyLanguage(recognizedText.text);

    setState(() {
      _recognizedText = recognizedText.text;
      _recognizedLanguage = language;
    });

    textRecognizer.close();
    languageIdentifier.close();
  }
  

  void _reCropImage() async {
    if (_image != null) {
      final croppedFile = await _cropImage(_image!);
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
        _recognizeTextFromImage(croppedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Recognition'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: _image == null
                ? Text('No image selected.')
                : Stack(
                    children: [
                      Image.file(
                        _image!,
                        width: 150,
                        height: 150,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: _reCropImage,
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            child: Text('Take a Picture'),
          ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: Text('Pick from Gallery'),
          ),
          SizedBox(height: 20),
          Text(
            'Recognized Text:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recognizedText,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Recognized Language:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _recognizedLanguage,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}