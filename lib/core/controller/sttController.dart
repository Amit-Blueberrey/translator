import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/core/controller/ttsController.dart';
import 'package:translator/features/translation/controllers/translation_controller_offline.dart';

class SttController extends GetxController {
  final TranslationController translationController =
      Get.put(TranslationController());
      final TTSController ttsController =Get.put(TTSController());
  // late stt.SpeechToText speech;
  final SpeechToText speech = SpeechToText();
  RxBool isAvailable = false.obs;
  RxBool isListening = false.obs;
  RxString recognizedText = "Press the button to start speaking".obs;
  List<LocaleName> locales = [];
  RxString selectedLanguageSource = ''.obs;
  RxString selectedLanguageTarget = ''.obs;
  RxBool speechEnabled = false.obs;
  RxString wordsSpoken = "".obs;
  RxBool isLanguageAvalabaleSource = false.obs;
  RxBool isLanguageAvalabaleTarget = false.obs;
  RxBool isListeningComplete = false.obs;
  RxBool startListeningaudio = false.obs;

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled.value = await speech.initialize();
    print("Speech Initialize Enable Status ${speechEnabled.value}");
    if (speechEnabled.value) {
      locales = await speech.locales();
      print("STT language Support ${locales.length}");
      // selectedLanguage.value = 'en-US';
      updateSelectedLanguageSource(translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageSource.value)));
      
      updateSelectedLanguageTarget(translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageTarget.value)));
      print(
          "Initialize Selected Language Source for STT ${selectedLanguageSource.value}");
      print(
          "Initialize Selected Language Target for STT ${selectedLanguageTarget.value}");
    }
    update();
  }

  void startListening(BuildContext context, String localid, bool isSource) async {
    if (isSource) {
      startListeningaudio.value = true;
    } else {
      isListeningComplete.value = true;
    }

    await speech.listen(
      onResult: (result) {
        onSpeechResult(context, result, isSource);
      },
      localeId: localid,
    );
    update();
  }

  void stopListening(BuildContext context, bool isSource) async {
    await speech.stop();

    if (isSource) {
      startListeningaudio.value = false;
    } else {
      isListeningComplete.value = false;
    }
    // callpb(context);

    update();
  }

  void onSpeechResult(BuildContext context, result, bool first) async {
    translationController.translateTextController.value.text =
        result.recognizedWords;
    wordsSpoken = result.recognizedWords;
    // translationController.translateTextController.value.text = wordsSpoken.value;
    // confidenceLevel = result.confidence;

    if (result.finalResult) {
      if (first) {
        startListeningaudio.value = false;
      } else {
        isListeningComplete.value = false;
      }
      // callpb(context);
    }

    update();
  }

  void initializeSpeechForNewLanguage() async {
    updateSelectedLanguageSource(translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageSource.value)));
    updateSelectedLanguageTarget(translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageTarget.value)));
    // selectedLanguageSource.value = translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageSource.value)) ;
    // selectedLanguageTarget.value = translationController.getLanguageCode(translationController.getLanguageName(translationController.selectedLanguageTarget.value));
     speechEnabled.value = await speech.initialize();
     print("Speech Initialize Enable Status ${speechEnabled.value}");
    
    print("Update Selected Language Source for STT ${selectedLanguageSource.value}");
    print("Update Selected Language Target for STT ${selectedLanguageTarget.value}");
  }

  // void callpb(BuildContext context) async {
  //   translationController.focusNodeFromTextField.value.unfocus();
  //   translationController.translatedText.value =
  //       await translationController.translateText(context);
  //   print(translationController.translatedText.value);
  // }

  void printSupportedLanguages() {
    Get.defaultDialog(
      title: 'Language for speech to text',
      content: Container(
        height: 450,
        child: SingleChildScrollView(
          child: Column(
            children: locales.map((locale) {
              print('${locale.name}');

              print('${locale.localeId}');
              return ListTile(
                title: Text(locale.name),
                onTap: () async {
                  updateSelectedLanguageSource(locale.localeId);
                  // selectedLanguageSource.value = locale.localeId;
                  initializeSpeechForNewLanguage();
                  Get.back();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void updateSelectedLanguageSource(String localeId) {
    if (locales.any((locale) => locale.localeId == localeId)) {
      selectedLanguageSource.value = localeId;
    } else {
      // selectedLanguageSource.value = 'es-ES';
      selectedLanguageSource.value = '';
    }
    ttsController.updateTTSLanguageSource(selectedLanguageSource.value);
    print("selected TTS language for source ${ttsController.sourceLanguage}");
  }

  void updateSelectedLanguageTarget(String localeId) {
    if (locales.any((locale) => locale.localeId == localeId)) {
      selectedLanguageTarget.value = localeId;
    } else {
      selectedLanguageTarget.value = '';
      // selectedLanguageTarget.value = 'es-ES';
    }
    ttsController.updateTTSLanguageTarget(selectedLanguageTarget.value);
    print("selected TTS language for target ${ttsController.targetLanguage}");
  }
}




// RxString selectedLanguage = ''.obs;
//   RxBool speechEnabled = false.obs;
//   RxString wordsSpoken = "".obs;
//   double confidenceLevel = 0;
//   RxBool isListeningComplete = false.obs;
//   RxBool startListeningaudio = false.obs;

//    @override
//   void onInit() {
//     super.onInit();
//     initSpeech();
//   }

//   void initSpeech() async {
//     speechEnabled.value = await speech.initialize();
//     if (available) {
//       locales = await speech.locales();
//     }
//     update();
//   }

//   void startListening(BuildContext context, String localid , bool first) async {
    
//       if (first) {
//         startListeningaudio.value = true;
//       }else{
//         isListeningComplete.value = true;
//       }
//       update();
//     await speech.listen(
//       onResult:(result) {
//         onSpeechResult(context, result,first);
//       },
//       localeId: localid,
//     );
//   }

//   void stopListening(BuildContext context, bool first) async {
//     await speech.stop();
    
//       if (first) {
//         startListeningaudio.value = false;
//       }else{
//         isListeningComplete.value = false;
//       }
//       callpb(context);
//     update();
//   }

//   void onSpeechResult(BuildContext context, result ,  bool first) async {
   
//       wordsSpoken.value = "${result.recognizedWords}";
//       translationController.translateTextController.value.text = wordsSpoken.value;
//       confidenceLevel = result.confidence;

//       if (result.finalResult) {
        
//           if (first) {
//         startListeningaudio.value = false;
//       }else{
//         isListeningComplete.value = false;
//       }
//           callpb(context);
        
//       }
//     update();
//   }

// void _initializeSpeechForNewLanguage() async {
//     await speech.initialize();
//     print("initialize Speech new language -${selectedLanguage.value}");
//   }

//   void callpb(BuildContext context) async {
//     translationController.focusNodeFromTextField.value.unfocus();
//     translationController.translatedText.value =
//         await translationController.translateText(context);
//     print(translationController.translatedText.value);
//   }