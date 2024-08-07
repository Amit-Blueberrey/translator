import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/core/utils/color.dart';
import 'package:translator/core/utils/image_recognization_language.dart';
import 'package:translator/features/camera_translation/controller/cammera_controller.dart';
import 'package:translator/features/translation/controllers/translation_controller_offline.dart';

class camera_recognition extends StatefulWidget {
  const camera_recognition({super.key});

  @override
  State<camera_recognition> createState() => _camera_recognitionState();
}

class _camera_recognitionState extends State<camera_recognition> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final CameraController cammeraController = Get.put(CameraController());
  final TranslationController translationController = Get.put(TranslationController());

   void analytics_send() async {
    await analytics.logEvent(name: "camera_use",parameters: {
      'source_language':'${cammeraController.selectedLanguage.value}',
      'target_language':'${translationController.getLanguageName(translationController.selectedLanguageTarget.value)}',
      'os_type':'${Platform.isIOS? 'IOS':'Android'}',
    });
    print("camera analytics send to firebase ");
    
  }
  

 
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    analytics_send();
    return Scaffold(
      
      body: Obx(() => SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: width*0.035),
          child: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        // translationController.showLanguageSelectionDialog(
                        //     context, true);
                        cammeraController.showLanguageSelectionDialog(context ,true);
                      },
                      child: Container(
                        height: height * 0.06,
                        width: width * 0.37,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02, vertical: height * 0.01),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                        child: Center(
                          child: Obx(() => Text(
                              cammeraController.selectedLanguage.value,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: height * 0.020,
                                  fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz,
                          size: height * 0.035, color: Colors.blue),
                      onPressed: () {
                        // translationController.swapTranslation();
              
                      },
                    ),
                    InkWell(
                      onTap: () {
                        // translationController.showLanguageSelectionDialog(
                        //     context, false);
                        // showBottomSheetForLanguageSelection(context, false);
                        cammeraController.showLanguageSelectionDialog(context ,false);
                      },
                      child: Container(
                        height: height * 0.06,
                        width: width * 0.37,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02, vertical: height * 0.01),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                        child: Center(
                          child: Obx(() => Text(
                              translationController.getLanguageName(translationController.selectedLanguageTarget.value),
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: height * 0.020,
                                  fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height*0.02,),
              
              InkWell(
                onTap: () {
                   cammeraController.showBottomSheet(context);
                   analytics_send();
                },
                child: Center(
                  child: cammeraController.image == null
                      ? Container(
                          height: height * 0.35,
                          width: width * 0.9,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 0, 0, 0),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // BoxShadow(
                              //   color: const Color.fromARGB(55, 158, 158, 158),
                              //   spreadRadius: 5,
                              //   blurRadius: 7,
                              //   offset: Offset(0, 3), // changes position of shadow
                              // ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_search,
                                  size: height * 0.18,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Choose or Pick Image',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                cammeraController.image!,
                                width: width * 0.85,
                                height: height * 0.35,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Color.fromARGB(255, 162, 233, 245)),
                                onPressed:() {
                                  cammeraController.reCropImage(context);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () => cammeraController.pickImage(ImageSource.camera),
              //   child: Text('Take a Picture'),
              // ),
              // ElevatedButton(
              //   onPressed: () => cammeraController.pickImage(ImageSource.gallery),
              //   child: Text('Pick from Gallery'),
              // ),
              SizedBox(height: height*0.02),
              Text(
                'Recognized Text:',
                style: TextStyle(fontSize: height*0.0225, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height*0.01),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    //  cammeraController.translateText.value == '' ? " wait ...":"${cammeraController.translateText.value}",
                    '${cammeraController.recognizedText.value}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
