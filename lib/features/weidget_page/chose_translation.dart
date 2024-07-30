

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:translator/core/utils/color.dart';
import 'package:translator/data/dbhelper.dart';
import 'package:translator/features/translation/controllers/translation_controller.dart';

class ChooseLanguage extends StatelessWidget {
  final bool isSource;
  ChooseLanguage({super.key, required this.isSource});
  
  final TranslationController translationController = Get.put(TranslationController());
  final modelManager = OnDeviceTranslatorModelManager();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    print('Language Support:- ${TranslateLanguage.values.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Languages'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Done', style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Recents'),
                  ...TranslateLanguage.values.map((language) {
                    return _buildLanguageTile(context, language, isSource);
                  }).toList(),
                  // _buildSectionTitle(context, 'Popular'),
                  // ...TranslateLanguage.values.map((language) {
                  //   return _buildLanguageTile(context, language, isSource);
                  // }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

Widget _buildLanguageTile(BuildContext context, TranslateLanguage language, bool isSource) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  return Obx(() {
    bool isDownloading = translationController.downloadStates[language.bcpCode] ?? false;
    bool isDeleting = translationController.deletionStates[language.bcpCode] ?? false;
    bool isSelected = isSource
        ? translationController.selectedLanguageSource.value == language
        : translationController.selectedLanguageTarget.value == language;

    return FutureBuilder<bool>(
      future: modelManager.isModelDownloaded(language.bcpCode),
      builder: (context, snapshot) {
        bool isDownloaded = snapshot.data ?? false;

        return Container(
          height: height * 0.06,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: height * 0.0005, color: Colors.black12))
              ),
              child: InkWell(
                onTap: () {
                  if (isSource) {
                    translationController.selectedLanguageSource.value = language;
                    TranslationDb.sourceLanguage = language;
                  } else {
                    translationController.selectedLanguageTarget.value = language;
                    TranslationDb.targetLanguage = language;
                  }
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          translationController.getLanguageName(language),
                          style: TextStyle(color: isSelected ? Colors.blue : null),
                        ),
                        isSelected 
                            ? Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Icon(Icons.check, color: Colors.blue),
                              ) 
                            : Container(),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                       isDownloaded?
                       Icon(Icons.wifi_off_outlined ,size: height*0.02, color: blueColor,):Container(),
                      
                        !isDownloaded
                            ? isDownloading
                                ? Padding(
                                    padding: EdgeInsets.only(right: width*0.03),
                                    child: SizedBox(width: width*0.06, height: height*0.027, child: CircularProgressIndicator(strokeWidth: width*0.007,)),
                                  )
                                : IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(Icons.downloading_rounded, color: greyColor),
                                    onPressed: () async {
                                      translationController.setDownloadState(language.bcpCode, true);
                                      await modelManager.downloadModel(language.bcpCode);
                                      translationController.setDownloadState(language.bcpCode, false);
                                      translationController.setDownloadState(language.bcpCode, true); // Trigger rebuild
                                    },
                                  )
                            : isDeleting
                                ? Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  )
                                : IconButton(
                                    onPressed: () async {
                                      translationController.setDeletionState(language.bcpCode, true);
                                      final bool isModelDeleted = await modelManager.deleteModel(language.bcpCode);
                                      if (isModelDeleted) {
                                        translationController.setDeletionState(language.bcpCode, false);
                                        translationController.setDownloadState(language.bcpCode, false);
                                        translationController.setDownloadState(language.bcpCode, true); // Trigger rebuild
                                      }
                                    },
                                    icon: Icon(Icons.more_vert, color: greyColor),
                                  ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}



}

