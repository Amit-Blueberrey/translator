import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/core/navigation/navigation_service.dart';
import 'package:translator/features/translation/controllers/translation_controller_offline.dart';

class CameraController extends GetxController {
  File? image;
  RxString recognizedText = ''.obs;
  RxString recognizedLanguage = ''.obs;
  RxString selectedLanguage = 'korean'.obs;
  final ImagePicker _picker = ImagePicker();
  final RxString translateText = ''.obs;
  final TranslationController translationController = Get.put(TranslationController());

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        image = croppedFile;
        recognizeTextFromImage(context, croppedFile);
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
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
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

  Future<void> recognizeTextFromImage(BuildContext context, File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.values.firstWhere(
        (script) => script.name == selectedLanguage.value,
        orElse: () => TextRecognitionScript.latin,
      ),
    );
    final RecognizedText recognizedText_R = await textRecognizer.processImage(inputImage);

    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final String language = await languageIdentifier.identifyLanguage(recognizedText_R.text);

    recognizedText.value = recognizedText_R.text;
    recognizedLanguage.value = language;

    // Translate recognized text
    // translateTextFromRecognized(context, recognizedText_R.text);

    textRecognizer.close();
    languageIdentifier.close();
  }

  Future<void> translateTextFromRecognized(BuildContext context, String text) async {
    translationController.translateTextController.value.text = text;
    final translated = await translationController.translateText(context, true, true);
    translateText.value = translated;
  }

  void reCropImage(BuildContext context) async {
    if (image != null) {
      final croppedFile = await _cropImage(image!);
      if (croppedFile != null) {
        image = croppedFile;
        recognizeTextFromImage(context, croppedFile);
      }
    }
  }

  void showLanguageSelectionDialog(BuildContext context, bool isSource) {
    final TranslationController translationController = Get.put(TranslationController());
    void checkLanguageAvailability(String languageCode) {
      // Check if the language is available in the list
      bool isAvailable = TranslateLanguage.values.any(
        (language) => language.bcpCode == languageCode,
      );

      if (isAvailable) {
        print('Language $languageCode is available.');
      } else {
        print('Language $languageCode is not available.');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select recognize'),
          content: SingleChildScrollView(
            child: isSource
                ? ListBody(
                    children: TextRecognitionScript.values.map((script) {
                      return RadioListTile<String>(
                        title: Text(script.name.capitalizeFirst!),
                        value: script.name,
                        groupValue: selectedLanguage.value,
                        onChanged: (String? value) {
                          if (value != null) {
                            selectedLanguage.value = value;
                            print('${selectedLanguage.value} ${script.name.capitalizeFirst!} ${getLanguageCode(script.name.capitalizeFirst!)}');
                            String bcpCode = getLanguageCode(script.name.capitalizeFirst!);
                            checkLanguageAvailability(bcpCode);

                            // Find the matching TranslateLanguage and set it
                            TranslateLanguage? matchingLanguage =
                                TranslateLanguage.values.firstWhereOrNull(
                              (language) => language.bcpCode == bcpCode,
                            );

                            if (matchingLanguage != null) {
                              translationController.selectedLanguageSource.value = matchingLanguage;
                            }

                             NavigationService.goBack();
                          }
                        },
                      );
                    }).toList(),
                  )
                : ListBody(
                    children: TranslateLanguage.values.map((script) {
                      return RadioListTile<TranslateLanguage>(
                        title: Text(script.name.capitalizeFirst!),
                        value: script,
                        groupValue: translationController.selectedLanguageTarget.value,
                        onChanged: (TranslateLanguage? values) {
                          if (values != null) {
                            translationController.selectedLanguageTarget.value = values;
                            NavigationService.goBack();
                          }
                        },
                      );
                    }).toList(),
                  ),
          ),
        );
      },
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 150,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  reusableCustomIconButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Take a Picture',
                    onClicked: () {
                      pickImage(context, ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  reusableCustomIconButton(
                    context,
                    icon: Icons.photo,
                    label: 'Pick from Gallery',
                    onClicked: () {
                      pickImage(context, ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget reusableCustomIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onClicked,
  }) {
    return GestureDetector(
      onTap: onClicked,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.blueGrey,
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  String getLanguageCode(String countryName) {
    // Map language names to language codes
    const Map<String, String> languageCodes = {
      'Afrikaans': 'af',
      'Albanian': 'sq',
      'Arabic': 'ar',
      'Belarusian': 'be',
      'Bengali': 'bn',
      'Bulgarian': 'bg',
      'Catalan': 'ca',
      'Chinese': 'zh',
      'Croatian': 'hr',
      'Czech': 'cs',
      'Danish': 'da',
      'Dutch': 'nl',
      'English': 'en',
      'Esperanto': 'eo',
      'Estonian': 'et',
      'Finnish': 'fi',
      'French': 'fr',
      'Galician': 'gl',
      'Georgian': 'ka',
      'Devanagiri': 'hi',
      'German': 'de',
      'Greek': 'el',
      'Gujarati': 'gu',
      'Haitian': 'ht',
      'Hebrew': 'he',
      'Hindi': 'hi',
      'Hungarian': 'hu',
      'Icelandic': 'is',
      'Indonesian': 'id',
      'Irish': 'ga',
      'Italian': 'it',
      'Japanese': 'ja',
      'Kannada': 'kn',
      'Khmer': 'km',
      'Korean': 'ko',
      'Lao': 'lo',
      'Latvian': 'lv',
      'Lithuanian': 'lt',
      'Macedonian': 'mk',
      'Malay': 'ms',
      'Malayalam': 'ml',
      'Maltese': 'mt',
      'Marathi': 'mr',
      'Norwegian': 'no',
      'Persian': 'fa',
      'Polish': 'pl',
      'Portuguese': 'pt',
      'Romanian': 'ro',
      'Russian': 'ru',
      'Serbian': 'sr',
      'Slovak': 'sk',
      'Slovenian': 'sl',
      'Spanish': 'es',
      'Swahili': 'sw',
      'Swedish': 'sv',
      'Tamil': 'ta',
      'Telugu': 'te',
      'Thai': 'th',
      'Turkish': 'tr',
      'Ukrainian': 'uk',
      'Urdu': 'ur',
      'Vietnamese': 'vi',
      'Welsh': 'cy',
      'Yiddish': 'yi',
    };

    return languageCodes[countryName] ?? '';
  }
}
