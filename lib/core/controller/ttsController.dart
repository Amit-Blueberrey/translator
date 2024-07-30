import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// const Map<String, String> languageNames = {
//   'nl-NL': 'Dutch (Netherlands)',
//   'el-GR': 'Greek (Greece)',
//   'hr-HR': 'Croatian (Croatia)',
//   'en-ZA': 'English (South Africa)',
//   'nl-BE': 'Dutch (Belgium)',
//   'ca-ES': 'Catalan (Spain)',
//   'pt-PT': 'Portuguese (Portugal)',
//   'zh-HK': 'Chinese (Hong Kong)',
//   'ar-001': 'Arabic (World)',
//   'da-DK': 'Danish (Denmark)',
//   'hu-HU': 'Hungarian (Hungary)',
//   'bg-BG': 'Bulgarian (Bulgaria)',
//   'ko-KR': 'Korean (South Korea)',
//   'zh-TW': 'Chinese (Taiwan)',
//   'uk-UA': 'Ukrainian (Ukraine)',
//   'en-AU': 'English (Australia)',
//   'vi-VN': 'Vietnamese (Vietnam)',
//   'fr-FR': 'French (France)',
//   'en-IE': 'English (Ireland)',
//   'en-US': 'English (United States)',
//   'en-GB': 'English (United Kingdom)',
//   'ru-RU': 'Russian (Russia)',
//   'es-MX': 'Spanish (Mexico)',
//   'hi-IN': 'Hindi (India)',
//   'de-DE': 'German (Germany)',
//   'ms-MY': 'Malay (Malaysia)',
//   'nb-NO': 'Norwegian (Norway)',
//   'pl-PL': 'Polish (Poland)',
//   'tr-TR': 'Turkish (Turkey)',
//   'pt-BR': 'Portuguese (Brazil)',
//   'zh-CN': 'Chinese (China)',
//   'it-IT': 'Italian (Italy)',
//   'fr-CA': 'French (Canada)',
//   'id-ID': 'Indonesian (Indonesia)',
//   'ja-JP': 'Japanese (Japan)',
//   'fi-FI': 'Finnish (Finland)',
//   'en-IN': 'English (India)',
//   'cs-CZ': 'Czech (Czech Republic)',
//   'he-IL': 'Hebrew (Israel)',
//   'ro-RO': 'Romanian (Romania)',
//   'sv-SE': 'Swedish (Sweden)',
//   'th-TH': 'Thai (Thailand)',
//   'es-ES': 'Spanish (Spain)',
//   'sk-SK': 'Slovak (Slovakia)',
//   'mai-IN': 'Maithili (India)',
//   'mr-IN': 'Marathi (India)',
//   'as-IN': 'Assamese (India)',
//   'sw-KE': 'Swahili (Kenya)',
//   'sd-IN': 'Sindhi (India)',
//   'ks-IN': 'Kashmiri (India)',
//   'doi-IN': 'Dogri (India)',
//   'ur-PK': 'Urdu (Pakistan)',
//   'et-EE': 'Estonian (Estonia)',
//   'sat-IN': 'Santali (India)',
//   'sq-AL': 'Albanian (Albania)',
//   'ar': 'Arabic',
//   'sr-RS': 'Serbian (Serbia)',
//   'su-ID': 'Sundanese (Indonesia)',
//   'bs-BA': 'Bosnian (Bosnia and Herzegovina)',
//   'bn-BD': 'Bengali (Bangladesh)',
//   'mni-IN': 'Manipuri (India)',
//   'gu-IN': 'Gujarati (India)',
//   'kn-IN': 'Kannada (India)',
//   'bn-IN': 'Bengali (India)',
//   'km-KH': 'Khmer (Cambodia)',
//   'lv-LV': 'Latvian (Latvia)',
//   'ml-IN': 'Malayalam (India)',
//   'si-LK': 'Sinhala (Sri Lanka)',
//   'is-IS': 'Icelandic (Iceland)',
//   'fil-PH': 'Filipino (Philippines)',
//   'lt-LT': 'Lithuanian (Lithuania)',
//   'ne-NP': 'Nepali (Nepal)',
//   'en-NG': 'English (Nigeria)',
//   'ta-IN': 'Tamil (India)',
//   'cy-GB': 'Welsh (United Kingdom)',
//   'or-IN': 'Odia (India)',
//   'brx-IN': 'Bodo (India)',
//   'sa-IN': 'Sanskrit (India)',
//   'yue-HK': 'Cantonese (Hong Kong)',
//   'es-US': 'Spanish (United States)',
//   'kok-IN': 'Konkani (India)',
//   'jv-ID': 'Javanese (Indonesia)',
//   'sl-SI': 'Slovenian (Slovenia)',
//   'te-IN': 'Telugu (India)',
//   'pa-IN': 'Punjabi (India)',
//   'af-ZA': 'Afrikaans (South Africa)',
//   'ar-EG': 'Arabic (Egypt)',
//   'be-BY': 'Belarusian (Belarus)',
//   'eo-EO': 'Esperanto (no specific country)',
//   'fa-IR': 'Persian (Iran)',
//   'ga-IE': 'Irish (Ireland)',
//   'gl-ES': 'Galician (Spain)',
//   'ht-HT': 'Haitian Creole (Haiti)',
//   'ka-GE': 'Georgian (Georgia)',
//   'mk-MK': 'Macedonian (Macedonia)',
//   'mt-MT': 'Maltese (Malta)',
//   'no-NO': 'Norwegian (Norway)',
// };

const Map<String, String> languageNames = {
  'nl-NL': 'Dutch ',
  'el-GR': 'Greek',
  'hr-HR': 'Croatian',
  'en-ZA': 'English',
  'nl-BE': 'Dutch',
  'ca-ES': 'Catalan',
  'pt-PT': 'Portuguese',
  'zh-HK': 'Chinese',
  'ar-001': 'Arabic',
  'da-DK': 'Danish',
  'hu-HU': 'Hungarian',
  'bg-BG': 'Bulgarian',
  'ko-KR': 'Korean',
  'zh-TW': 'Chinese',
  'uk-UA': 'Ukrainian',
  'en-AU': 'English',
  'vi-VN': 'Vietnamese',
  'fr-FR': 'French',
  'en-IE': 'English',
  'en-US': 'English',
  'en-GB': 'English',
  'ru-RU': 'Russian',
  'es-MX': 'Spanish',
  'hi-IN': 'Hindi',
  'de-DE': 'German',
  'ms-MY': 'Malay',
  'nb-NO': 'Norwegian',
  'pl-PL': 'Polish',
  'tr-TR': 'Turkish',
  'pt-BR': 'Portuguese',
  'zh-CN': 'Chinese',
  'it-IT': 'Italian',
  'fr-CA': 'French',
  'id-ID': 'Indonesian',
  'ja-JP': 'Japanese',
  'fi-FI': 'Finnish',
  'en-IN': 'English',
  'cs-CZ': 'Czech',
  'he-IL': 'Hebrew',
  'ro-RO': 'Romanian',
  'sv-SE': 'Swedish',
  'th-TH': 'Thai',
  'es-ES': 'Spanish',
  'sk-SK': 'Slovak',
  'mai-IN': 'Maithili',
  'mr-IN': 'Marathi',
  'as-IN': 'Assamese',
  'sw-KE': 'Swahili',
  'sd-IN': 'Sindhi',
  'ks-IN': 'Kashmiri',
  'doi-IN': 'Dogri',
  'ur-PK': 'Urdu',
  'et-EE': 'Estonian',
  'sat-IN': 'Santali',
  'sq-AL': 'Albanian',
  'ar': 'Arabic',
  'sr-RS': 'Serbian',
  'su-ID': 'Sundanese',
  'bs-BA': 'Bosnian',
  'bn-BD': 'Bengali',
  'mni-IN': 'Manipuri',
  'gu-IN': 'Gujarati',
  'kn-IN': 'Kannada',
  'bn-IN': 'Bengali',
  'km-KH': 'Khmer',
  'lv-LV': 'Latvian',
  'ml-IN': 'Malayalam',
  'si-LK': 'Sinhala',
  'is-IS': 'Icelandic',
  'fil-PH': 'Filipino',
  'lt-LT': 'Lithuanian',
  'ne-NP': 'Nepali',
  'en-NG': 'English',
  'ta-IN': 'Tamil',
  'cy-GB': 'Welsh',
  'or-IN': 'Odia',
  'brx-IN': 'Bodo',
  'sa-IN': 'Sanskrit',
  'yue-HK': 'Cantonese',
  'es-US': 'Spanish',
  'kok-IN': 'Konkani',
  'jv-ID': 'Javanese',
  'sl-SI': 'Slovenian',
  'te-IN': 'Telugu',
  'pa-IN': 'Punjabi',
  'af-ZA': 'Afrikaans',
  'ar-EG': 'Arabic',
  'be-BY': 'Belarusian',
  'eo-EO': 'Esperanto',
  'fa-IR': 'Persian',
  'ga-IE': 'Irish',
  'gl-ES': 'Galician',
  'ht-HT': 'Haitian Creole',
  'ka-GE': 'Georgian',
  'mk-MK': 'Macedonian',
  'mt-MT': 'Maltese',
  'no-NO': 'Norwegian',
};

String getReadableLanguageName(String code) {
  return languageNames[code] ?? code;
}

class TTSController extends GetxController {
  late FlutterTts flutterTts;
  var isSpeaking = false.obs;
  var isStopped = true.obs;
  var languages = <String>[].obs;
  final RxString selectedLanguage = 'en-US'.obs;

  @override
  void onInit() {
    super.onInit();
    flutterTts = FlutterTts();
    initTTS();
  }

  Future<void> initTTS() async {
    List<dynamic> langs = await flutterTts.getLanguages;
    languages.value = langs.map((lang) => lang.toString()).toList();
    print('TTS Language support:- ${languages.length}');

    flutterTts.setStartHandler(() {
      isSpeaking.value = true;
      isStopped.value = false;
    });

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
      isStopped.value = true;
    });

    flutterTts.setCancelHandler(() {
      isSpeaking.value = false;
      isStopped.value = true;
    });
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
    flutterTts.setLanguage(lang);
  }

  void speak(String text) async {
    if (selectedLanguage.value.isNotEmpty) {
      isSpeaking.value = true;
      await flutterTts.speak(text);
    }
  }

  void stop() async {
    await flutterTts.stop();
    isSpeaking.value = false;
  }

  void printSupportedLanguages() {
    Get.defaultDialog(
      title: 'Language for text to speech',
      content: Container(
        height: 450,
        child: SingleChildScrollView(
          child: Column(
            children: languages.map((lang) {
              print('${lang}');
              return ListTile(
                title: Text(getReadableLanguageName(lang)),
                onTap: () {
                  setLanguage(lang);
                  Get.back();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
