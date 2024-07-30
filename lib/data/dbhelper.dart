
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translator/features/translation/controllers/translation_controller.dart';

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

  // for storing translation source Language 
  static TranslateLanguage get sourceLanguage => _box.get('sourceLanguage') ?? TranslateLanguage.english;
  static set sourceLanguage(TranslateLanguage v) {
    _box.put('sourceLanguage', v);
    Get.find<TranslationController>().selectedLanguageSource.value = v;
  }

  // for storing translation target Language 
  static TranslateLanguage get targetLanguage => _box.get('targetLanguage') ?? TranslateLanguage.spanish;
  static set targetLanguage(TranslateLanguage v) {
    _box.put('targetLanguage', v);
    Get.find<TranslationController>().selectedLanguageTarget.value = v;
  }

  // for storing first time app open
  static bool get ispaid => _box.get('ispaid') ?? false;
  static set ispaid(bool v) => _box.put('ispaid', v);
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