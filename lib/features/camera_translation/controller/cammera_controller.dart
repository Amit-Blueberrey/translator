// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
// class CameraRecognitionController extends GetxController {
//   late CameraController cameraController;
//   late TextRecognizer textRecognizer;
//   late OnDeviceTranslator translator;
//   var isDetecting = false.obs;
//   var translatedText = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     initializeCamera();
//     initializeTextRecognizer();
//     initializeTranslator();
//   }

//   void initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.high,
//     );

//     await cameraController.initialize();
//     cameraController.startImageStream((CameraImage image) {
//       if (isDetecting.value) return;

//       isDetecting.value = true;
//       // processCameraImage(image);
//     });

//     update();
//   }

//   void initializeTextRecognizer() {
//     textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//   }

//   void initializeTranslator() {
//     translator = OnDeviceTranslator(
//       sourceLanguage: TranslateLanguage.english,
//       targetLanguage: TranslateLanguage.spanish,
//     );
//   }

//   // void processCameraImage(CameraImage image) async {
//   //   final WriteBuffer allBytes = WriteBuffer();
//   //   image.planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
//   //   final bytes = allBytes.done().buffer.asUint8List();

//   //   final InputImage inputImage = InputImage.fromBytes(
//   //     bytes: bytes, metadata: null,
//   //   );

//   //   final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//   //   translateText(recognizedText.text);
//   //   isDetecting.value = false;
//   // }

//   void translateText(String text) async {
//     final translation = await translator.translateText(text);
//     translatedText.value = translation;
//   }

//   @override
//   void onClose() {
//     cameraController.dispose();
//     textRecognizer.close();
//     translator.close();
//     super.onClose();
//   }
// }