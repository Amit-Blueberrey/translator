import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:locale/locale.dart' as locale;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:archive/archive.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:translator/core/controller/sttController.dart';
import 'package:translator/core/controller/ttsController.dart';
import 'package:translator/core/dialog/dialog_loading.dart';
import 'package:translator/core/navigation/navigation_service.dart';
import 'package:translator/data/dbhelper.dart';

class TranslationController extends GetxController {
  final TTSController ttsController = Get.put(TTSController());
  
  
  final modelManager = OnDeviceTranslatorModelManager();
  Rx<TranslateLanguage> selectedLanguageSource =
      TranslationDb.sourceLanguage.obs;
  Rx<TranslateLanguage> selectedLanguageTarget =
      TranslationDb.targetLanguage.obs;
  // Observable (obs) TextEditingController for translated text:
  final Rx<TextEditingController> translateTextController =
      TextEditingController().obs;
  
  // Define an observable FocusNode
  final Rx<FocusNode> focusNodeFromTextField = FocusNode().obs;

  RxList<TranslateLanguage> languagesTranslate = <TranslateLanguage>[].obs;
   RxString selectedLanguage = "en-GB".obs;
  
  var downloadStates = <String, bool>{}.obs;
  var deletionStates = <String, bool>{}.obs;
  // Getter to check if the TextField is focused
  bool get isTextFieldFocused => focusNodeFromTextField.value.hasFocus;
  RxBool localTranslationEnable = TranslationDb.isOffline.obs;
  RxString translatedTextSource = ''.obs;
  RxString translatedTextTarget = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchLanguages();
    // Add a listener to the FocusNode to update the state
    focusNodeFromTextField.value.addListener(() {
      // This triggers the reactive updates in the UI
      focusNodeFromTextField.refresh();
      languagesTranslate.value=TranslateLanguage.values;
    });
  }

  @override
  void onClose() {
    // Dispose of the FocusNode when the controller is closed
    focusNodeFromTextField.value.dispose();
    super.onClose();
  }


  // void fetchLanguages() async {
  //   languagesTranslate.value = TranslateLanguage.values.map((language) {
  //     final languageName = getLanguageName(language);
  //     final readableName = getLanguageCode(languageName);
  //     // print(readableName);
  //     return TranslateLanguage.values.byName(readableName); // Use byName for case-insensitive matching
  //   }).toList();
  //   print(languagesTranslate.value);
  // }

   

  void setDownloadState(String bcpCode, bool isDownloading) {
    downloadStates[bcpCode] = isDownloading;
  }
  
  void setDeletionState(String bcpCode, bool isDeleting) {
    deletionStates[bcpCode] = isDeleting;
  }


  // check language available or not 
   
   void checkLanguageAvailability() {
    final availableLanguage = languagesTranslate.value.firstWhereOrNull((lang) => lang == selectedLanguage.value);

    if (availableLanguage == null) {
      selectedLanguage.value = 'en-GB'; // Set default if not found
    } else {
      // Language is already set to the available one
    }
  }


  // download mlkit translation model
  Future<bool> downloadTranslationModel(
      TranslateLanguage languageBcpCode, BuildContext context) async {
    MyDialogs.showLoadingDialog(context);
    bool isModelDownloaded = false;
    final bool modelDownloaded =
        await modelManager.isModelDownloaded(languageBcpCode.bcpCode);
    if (modelDownloaded == false) {
      isModelDownloaded =
          await modelManager.downloadModel(languageBcpCode.bcpCode);
      NavigationService.goBack();
    } else {
      isModelDownloaded = true;
      NavigationService.goBack();
    }
    return isModelDownloaded;
  }

//====================================================================================================
// Compress JSON data using gzip
Uint8List compressData(Map<String, String> data) {
  final jsonString = jsonEncode(data);
  final bytes = utf8.encode(jsonString);
  final compressedBytes = GZipEncoder().encode(bytes);
  return Uint8List.fromList(compressedBytes!);
}

// Decompress data
Map<String, String> decompressData(Uint8List compressedBytes) {
  final decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
  final jsonString = utf8.decode(decompressedBytes);
  return Map<String, String>.from(jsonDecode(jsonString));
}

// Encrypt function
String encryptText(Map<String, String> data, String key) {
  final compressedData = compressData(data);
  final keyBytes = utf8.encode(key.padRight(32, '0')); // Ensure key length is 32 bytes
  final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(Uint8List.fromList(keyBytes))));

  final encrypted = encrypter.encryptBytes(compressedData, iv: iv);
  final ivAndEncrypted = iv.bytes + encrypted.bytes; // Prepend IV to the encrypted data
  return base64Url.encode(ivAndEncrypted); // Return the combined IV and encrypted data as base64Url
}

// Decrypt function
Map<String, String> decryptText(String encryptedText, String key) {
  final keyBytes = utf8.encode(key.padRight(32, '0')); // Ensure key length is 32 bytes
  final ivAndEncrypted = base64Url.decode(encryptedText);
  final iv = encrypt.IV(ivAndEncrypted.sublist(0, 16)); // Extract the IV
  final encryptedBytes = ivAndEncrypted.sublist(16); // Extract the encrypted data
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(Uint8List.fromList(keyBytes))));

  final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
  return decompressData(Uint8List.fromList(decryptedBytes)); // Return the decrypted and decompressed data
}
//===================================================================================================
  

  // translate text
  Future<String> translateText(BuildContext context ,bool isSource, bool isOnlyTranslate) async {
    // final bool targetLanguage1 = await modelManager.isModelDownloaded(targetLanguage.bcpCode);
    // final bool sourceLanguage1 = await modelManager.isModelDownloaded(sourceLanguage.bcpCode);
    String translatedTextv = '....';
    // String translatedText = '....';
    final bool lan1 = await downloadTranslationModel(selectedLanguageSource.value, context);
    final bool lan2 = await downloadTranslationModel(selectedLanguageTarget.value, context);
    if (lan1 == true && lan2 == true) {
      final onDeviceTranslator;
     if (isSource) {
       onDeviceTranslator = OnDeviceTranslator(
          sourceLanguage: selectedLanguageSource.value,
          targetLanguage: selectedLanguageTarget.value);
     }else{
      onDeviceTranslator = OnDeviceTranslator(
          sourceLanguage: selectedLanguageTarget.value,
          targetLanguage: selectedLanguageSource.value);
     }
      // if (isSource) {
      //   translatedTextSource.value = await onDeviceTranslator
      //     .translateText(translateTextController.value.text);
      // }else{
      //   translatedTextTarget.value = await onDeviceTranslator
      //     .translateText(translateTextController.value.text);
      // }
      if (isOnlyTranslate) {
        print("Normal translate");
        translatedTextv = await onDeviceTranslator.translateText(translateTextController.value.text);
        ttsController.setLanguage(ttsController.targetLanguage.value);
        ttsController.speak(translatedTextv);
      }else{
        ttsController.setLanguage( isSource == true? ttsController.targetLanguage.value:ttsController.sourceLanguage.value);
        
        print("source translate");
        translatedTextv = await onDeviceTranslator.translateText(isSource == false? translatedTextTarget.value:translatedTextSource.value);
        ttsController.speak(translatedTextv);
      }
      
    } else {
      print('Faild to Translate Text');
      translatedTextv = 'Faild to Translate Text';
    }
    return translatedTextv;
  }

  // delete mlkit translation model
  Future<bool> deleteTranslationModel(
      String languageBcpCode, BuildContext context) async {
    MyDialogs.showLoadingDialog(context);
    final bool isModelDelete = await modelManager.deleteModel(languageBcpCode);
    MyDialogs.hideLoadingDialog(context);
    return isModelDelete;
  }

  // swap language
  void swapTranslation() {
    var stor;
    String stortext;
    stor = selectedLanguageSource.value;
    selectedLanguageSource.value = selectedLanguageTarget.value;
    TranslationDb.sourceLanguage = selectedLanguageTarget.value;
    selectedLanguageTarget.value = stor;
    TranslationDb.targetLanguage = stor;

    stortext = translatedTextSource.value;
    translatedTextSource = RxString(translateTextController.value.text);
    translateTextController.value.text = stortext.toString();
    HapticFeedback.vibrate();
  } 

  // language filter
  String getLanguageName(TranslateLanguage language) {
    // Extract language name and capitalize the first letter
    String formattedName = language.toString().split('.').last;
    formattedName = formattedName[0].toUpperCase() + formattedName.substring(1);
    return formattedName;
  }

// Language Selection Pop Up function
  void showLanguageSelectionDialog(BuildContext context, bool isSource) {
  // final SttController sttController = Get.put(SttController());
  final TTSController ttsController =Get.put(TTSController());
  double height = MediaQuery.of(context).size.height;
  print('Language Support:- ${TranslateLanguage.values.length}');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Language'),
        content: Container(
          height: height * 0.35,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: TranslateLanguage.values.map((language) {
                print("${language.bcpCode} :- ${getReadableLanguageName(getLanguageCode(getLanguageName(language)))}");
                return Obx(() {
                  return RadioListTile<TranslateLanguage>(
                    title: Text(getLanguageName(language)),
                    value: language,
                    groupValue: isSource
                        ? selectedLanguageSource.value
                        : selectedLanguageTarget.value,
                    onChanged: (TranslateLanguage? values) {
                      if (isSource) {
                        selectedLanguageSource.value = values!;
                        TranslationDb.sourceLanguage = values;
                        

                      } else {
                        selectedLanguageTarget.value = values!;
                        TranslationDb.targetLanguage = values;
                        // if (getLanguageName(selectedLanguageTarget.value) == getReadableLanguageName(ttsController.selectedLanguage.value)) {
                        //   ttsController.setLanguage(getLanguageCode(getLanguageName(selectedLanguageTarget.value)));
                        // }
                        // ttsController.setLanguage('en-US');
                      }
                      Navigator.of(context).pop();
                    },
                  );
                });
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}

  // ==== country language name to language code converter

  String getLanguageCode(String countryName) {
    // Map language codes to country names
    const Map<String, String> languageCodes = {
      'Afrikaans': 'af-ZA',
      'Albanian': 'sq-AL',
      'Arabic': 'ar-EG', // Egypt is a common Arabic locale
      'Belarusian': 'be-BY',
      'Bengali': 'bn-BD', // Bangladesh is a common Bengali locale
      'Bulgarian': 'bg-BG',
      'Catalan': 'ca-ES',
      'Chinese': 'zh-CN', // China is a common Chinese locale
      'Croatian': 'hr-HR',
      'Czech': 'cs-CZ',
      'Danish': 'da-DK',
      'Dutch': 'nl-NL',
      'English': 'en-US', // US is a common English locale
      'Esperanto': 'eo-EO', // Esperanto has no specific country code
      'Estonian': 'et-EE',
      'Finnish': 'fi-FI',
      'French': 'fr-FR',
      'Galician': 'gl-ES',
      'Georgian': 'ka-GE',
      'German': 'de-DE',
      'Greek': 'el-GR',
      'Gujarati': 'gu-IN', // India is a common Gujarati locale
      'Haitian': 'ht-HT',
      'Hebrew': 'he-IL',
      'Hindi': 'hi-IN', // India is a common Hindi locale
      'Hungarian': 'hu-HU',
      'Icelandic': 'is-IS',
      'Indonesian': 'id-ID',
      'Irish': 'ga-IE',
      'Italian': 'it-IT',
      'Japanese': 'ja-JP',
      'Kannada': 'kn-IN', // India is a common Kannada locale
      'Korean': 'ko-KR',
      'Latvian': 'lv-LV',
      'Lithuanian': 'lt-LT',
      'Macedonian': 'mk-MK',
      'Malay': 'ms-MY', // Malaysia is a common Malay locale
      'Maltese': 'mt-MT',
      'Marathi': 'mr-IN', // India is a common Marathi locale
      'Norwegian': 'no-NO',
      'Persian': 'fa-IR', // Iran is a common Persian locale
      'Polish': 'pl-PL',
      'Portuguese': 'pt-PT', // Portugal is a common Portuguese locale
      'Romanian': 'ro-RO',
      'Russian': 'ru-RU',
      'Slovak': 'sk-SK',
      'Slovenian': 'sl-SI',
      'Spanish': 'es-ES',
      'Swahili': 'sw-KE', // Kenya is a common Swahili locale
      'Swedish': 'sv-SE',
      'Tagalog': 'fil-PH', // Philippines is a common Tagalog locale
      'Tamil': 'ta-IN', // India is a common Tamil locale
      'Telugu': 'te-IN', // India is a common Telugu locale
      'Thai': 'th-TH',
      'Turkish': 'tr-TR',
      'Ukrainian': 'uk-UA',
      'Urdu': 'ur-PK', // Pakistan is a common Urdu locale
      'Vietnamese': 'vi-VN',
      'Welsh': 'cy-GB', // GB is used for Welsh
    };

    // Look up the code by country name
    final code = languageCodes[countryName];
    if (code != null) {
      return code;
    } else {
      // If not found, return an empty string
      return '';
    }
  }

  // ==== country language name to language code converter
}
