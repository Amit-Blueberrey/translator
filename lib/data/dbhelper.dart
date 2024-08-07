
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translator/features/translation/controllers/translation_controller_offline.dart';
import 'package:translator/features/translation/controllers/translation_controller_online.dart';

class TranslationDb {
  static late Box _box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TranslateLanguageAdapter()); // Register the adapter
    _box = await Hive.openBox('data');
  }

  // for storing theme data
  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  static set isDarkMode(bool v) => _box.put('isDarkMode', v);

  // for storing translation source Language for offline
  static TranslateLanguage get sourceLanguage => _box.get('sourceLanguage') ?? TranslateLanguage.english;
  static set sourceLanguage(TranslateLanguage v) {
    _box.put('sourceLanguage', v);
    Get.find<TranslationController>().selectedLanguageSource.value = v;
  }

  // for storing translation target Language for offline
  static TranslateLanguage get targetLanguage => _box.get('targetLanguage') ?? TranslateLanguage.spanish;
  static set targetLanguage(TranslateLanguage v) {
    _box.put('targetLanguage', v);
    Get.find<TranslationController>().selectedLanguageTarget.value = v;
  }

  // for storing translation target Language for online
  static String get targetLanguageOnline => _box.get('targetLanguageOnline') ?? 'en';
  static set targetLanguageOnline(String v) {
    _box.put('targetLanguageOnline', v);
    Get.find<TranslationControllerOnline>().targetLanguage.value = v;
  }

  // for storing translation target Language for online
  static String get sourceLanguageOnline => _box.get('sourceLanguageOnline') ?? "es";
  static set sourceLanguageOnline(String v) {
    _box.put('sourceLanguageOnline', v);
    Get.find<TranslationControllerOnline>().targetLanguage.value = v;
  }

    // for storing theme data
  static String get paywallOld => _box.get('paywallOld') ?? 'default app';
  static set paywallOld(String v) => _box.put('paywallOld', v);

  // for storing first time app open
  static bool get isOffline => _box.get('isOffline') ?? false;
  static set isOffline(bool v) => _box.put('isOffline', v);

  // for storing user is paid or not
  static bool get isPaid => _box.get('isPaid') ?? false;
  static set isPaid(bool v) => _box.put('isPaid', v);

  // for storing user aut token
  static String get token => _box.get('token') ?? '';
  static set token(String v) => _box.put('token', v);
}





class TranslateLanguageAdapter extends TypeAdapter<TranslateLanguage> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  TranslateLanguage read(BinaryReader reader) {
    final String name = reader.readString();
    return TranslateLanguage.values.firstWhere((lang) => lang.name == name);
  }

  @override
  void write(BinaryWriter writer, TranslateLanguage obj) {
    writer.writeString(obj.name);
  }
}