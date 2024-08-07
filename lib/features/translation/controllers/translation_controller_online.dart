import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:translator/data/dbhelper.dart';
import 'package:translator_plus/translator_plus.dart';

class TranslationControllerOnline extends GetxController {
  final GoogleTranslator translator = GoogleTranslator();

  // Observable variables for source and target languages
  RxString sourceLanguage = TranslationDb.sourceLanguageOnline.obs;
  RxString targetLanguage = TranslationDb.targetLanguageOnline.obs;
  RxString sourceTranslateText = ''.obs;
  final Rx<TextEditingController> translateTextController =
      TextEditingController().obs;
  // Define an observable FocusNode
  final Rx<FocusNode> focusNodeFromTextField = FocusNode().obs;
  bool get isTextFieldFocused => focusNodeFromTextField.value.hasFocus;
  RxBool localTranslationEnable = TranslationDb.isOffline.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchLanguages();
    // Add a listener to the FocusNode to update the state
    focusNodeFromTextField.value.addListener(() {
      // This triggers the reactive updates in the UI
      focusNodeFromTextField.refresh();
    });
  }

  // Method to set source language
  void setSourceLanguage(String language) {
    sourceLanguage.value = language;
  }

  // Method to set target language
  void setTargetLanguage(String language) {
    targetLanguage.value = language;
  }

  // Method to translate text
  Future<String> translateText() async {
    try {
      var translated = await translator.translate(translateTextController.value.text, from: sourceLanguage.value, to: targetLanguage.value);
      return translated.text;
    } catch (e) {
      return 'Error in translation';
    }
  }
  void swapTranslation() {
    var stor;
    String stortext;
    stor = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    TranslationDb.sourceLanguageOnline = targetLanguage.value;
    targetLanguage.value = stor;
    TranslationDb.targetLanguageOnline = stor;

    stortext = sourceTranslateText.value;
    sourceTranslateText = RxString(translateTextController.value.text);
    translateTextController.value.text = stortext.toString();
    HapticFeedback.vibrate();
  } 
  void showLanguageSelectionPopup(BuildContext context, bool isSourceLanguage) {
  Get.defaultDialog(
    title: isSourceLanguage ? 'Select Source Language' : 'Select Target Language',
    content: Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (isSourceLanguage) {
              setSourceLanguage('en');
            } else {
              setTargetLanguage('en');
            }
            Get.back();
          },
          child: Text('English'),
        ),
        ElevatedButton(
          onPressed: () {
            if (isSourceLanguage) {
              setSourceLanguage('es');
            } else {
              setTargetLanguage('es');
            }
            Get.back();
          },
          child: Text('Spanish'),
        ),
        // Add more languages as needed
      ],
    ),
  );
}

}

