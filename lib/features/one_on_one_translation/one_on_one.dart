import 'package:flutter/material.dart';
import 'package:flutter_ripple_animation/ripple_animation.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/core/controller/sttController.dart';
import 'package:translator/core/controller/ttsController.dart';
import 'package:translator/core/utils/color.dart';
import 'package:translator/features/translation/controllers/translation_controller.dart';
import 'package:translator/features/translation/controllers/widgetController.dart';

class OneOnOneCommunicationPage extends StatefulWidget {
  @override
  State<OneOnOneCommunicationPage> createState() =>
      _OneOnOneCommunicationPageState();
}

class _OneOnOneCommunicationPageState extends State<OneOnOneCommunicationPage> {
  // final WidgetController widgetController = Get.put(WidgetController());
  final TranslationController translationController =
      Get.put(TranslationController());
  final TTSController ttsController = Get.put(TTSController());
  final SttController sttController = Get.put(SttController());
  final SpeechToText speech = SpeechToText();

  bool speechEnabled = false;
  String wordsSpoken = "";
  double confidenceLevel = 0;
  bool isListeningComplete = false;
  bool startListeningaudio = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled = await speech.initialize();
    setState(() {});
  }

  void startListening(bool isSource) async {
    setState(() {
      if (isSource) {
        startListeningaudio = true;
      } else {
        isListeningComplete = true;
      }
    });

    if (isSource) {
      await speech.listen(
        onResult: (result) {
          onSpeechResult(result, isSource);
        },
        localeId: sttController.selectedLanguageSource.value,
      );
    } else {
      await speech.listen(
        onResult: (result) {
          onSpeechResult(result, isSource);
        },
        localeId: sttController.selectedLanguageTarget.value,
      );
    }
  }

  void stopListening(bool isSource) async {
    await speech.stop();
    setState(() {
      if (isSource) {
        startListeningaudio = false;
      } else {
        isListeningComplete = false;
      }
      callpb(isSource);
    });
  }

  void onSpeechResult(result, bool isSource) async {
    setState(() {
      if (isSource) {
        translationController.translatedTextSource.value =
            result.recognizedWords;
      } else {
        wordsSpoken = "${result.recognizedWords}";
        translationController.translatedTextTarget.value = wordsSpoken;
      }

      confidenceLevel = result.confidence;

      if (result.finalResult) {
        setState(() {
          if (isSource) {
            startListeningaudio = false;
          } else {
            isListeningComplete = false;
          }
          callpb(isSource);
        });
      }
    });
  }

  void callpb(bool isSource) async {
    // translationController.translatedTextSource.value='';
    // translationController.translateTextController.value.text='';

    translationController.focusNodeFromTextField.value.unfocus();
    if (isSource) {
      print("source translate display");
      translationController.translatedTextTarget.value =
          await translationController.translateText(context, isSource, false);
    } else {
      print("Tearget translate display");
      translationController.translatedTextSource.value =
          await translationController.translateText(context, isSource ,false);
    }
    // translationController.translatedTextSource.value =
    //     await translationController.translateText(context ,isSource);

    print(isSource
        ? translationController.translatedTextSource.value
        : translationController.translatedTextSource.value);
  }

// ====================================
  final Map<String, String> data = {
    "mac_address": "M:M:M:S:S:S",
    "total_channels": "4",
    "speed_control_channels": "1",
    "product_id": "2812ER44",
  };

  final String encryptionKey = 'your-encryption-key-here';

  //=============================================

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Translate',
          style: TextStyle(
              color: textColor,
              fontSize: height * 0.0235,
              fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
            icon: Icon(Icons.menu_outlined,
                color: Colors.blue), // Use Icons.history for history icon
            onPressed: () async {
              // sttController.printSupportedLanguages();
              // Encrypt the data
              String encryptedData =
                  await translationController.encryptText(data, encryptionKey);
              print('Encrypted Data: $encryptedData');
              // Decrypt the data
              Map<String, String> decryptedData = await translationController
                  .decryptText(encryptedData, encryptionKey);
              print('Decrypted Data: $decryptedData');
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              ttsController.printSupportedLanguages();
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: Column(
          children: [
            Obx(
              () => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04, vertical: height * 0.013),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                translationController.getLanguageName(
                                    translationController
                                        .selectedLanguageSource.value),
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600)),
                            // translationController.isTextFieldFocused == true
                            //     ? Padding(
                            //         padding:
                            //             EdgeInsets.only(top: height * 0.005),
                            //         child: InkWell(
                            //             onTap: () {
                            //               translationController
                            //                   .focusNodeFromTextField.value
                            //                   .unfocus();
                            //             },
                            //             child: Icon(
                            //               Icons.close,
                            //               color: Color.fromARGB(
                            //                   255, 159, 159, 159),
                            //             )),
                            //       )
                            //     : Container()
                          ],
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),

                        Text(
                          translationController
                              .translatedTextSource.value,
                          style: TextStyle(
                              color: textTranslatorColor,
                              fontSize: height * 0.025),
                        ),

                        // SizedBox(height: height * 0.01),
                        // TextField(
                        //   controller: translationController
                        //       .translateTextController.value,
                        //   maxLines: null,
                        //   focusNode: translationController
                        //       .focusNodeFromTextField.value,
                        //   style: TextStyle(
                        //       color: Colors.white, fontSize: height * 0.025),
                        //   decoration: InputDecoration(
                        //     hintText: 'Enter your text',
                        //     hintStyle: TextStyle(color: Colors.grey),
                        //     border: InputBorder.none,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.02),

            //  translationController
            //         .translateTextController.value.text.isEmpty
            Obx(
              () => Expanded(
                child: Container(
                  // height: height*0.29,
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(width * 0.02)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                translationController.getLanguageName(
                                    translationController
                                        .selectedLanguageTarget.value),
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600)),
                            translationController.translatedTextTarget.value !=
                                    ''
                                ? InkWell(
                                    onTap: () {
                                      // initSpeech();sttController1.selectedLanguageTarget.value
                                      // if (getReadableLanguageName(sttController
                                      //         .selectedLanguageTarget.value) ==
                                      //     getReadableLanguageName(ttsController
                                      //         .selectedLanguage.value)) {
                                      //   ttsController.setLanguage(sttController
                                      //       .selectedLanguageTarget.value);
                                      // } else {
                                      //   ttsController.setLanguage('en-US');
                                      // }

                                      if (ttsController.isSpeaking == true) {
                                        // sttController.stopListening();
                                        ttsController.stop();
                                      } else {
                                        // sttController.startListening();
                                        ttsController.speak(
                                            translationController
                                                .translatedTextTarget.value);
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: width * 0.06),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: height * 0.037,
                                          width: width * 0.1,
                                          decoration: BoxDecoration(
                                            color: speakerColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            ttsController.isSpeaking == false
                                                ? Icons.play_arrow
                                                : Icons.pause,
                                            color: micColor,
                                            size: height * 0.025,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Container(
                          child: translationController
                                  .translatedTextTarget.value.isNotEmpty
                              ? Text(
                                  translationController
                                      .translatedTextTarget.value,
                                  style: TextStyle(
                                      color: textTranslatorColor,
                                      fontSize: height * 0.025),
                                )
                              : translationController.translatedTextSource
                                      .value.isNotEmpty
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Shimmer.fromColors(
                                          period: Duration(milliseconds: 1000),
                                          baseColor: Colors.grey[100]!,
                                          highlightColor: Colors.grey[400]!,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: height * 0.01,
                                                  width: double.infinity),
                                              // Add any other widget that you want to show the shimmer effect
                                              Container(
                                                height: height * 0.01,
                                                width: double.infinity,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                  height: height * 0.01,
                                                  width: double.infinity),
                                              Container(
                                                height: height * 0.01,
                                                width: double.infinity,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                  height: height * 0.01,
                                                  width: double.infinity),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    translationController.showLanguageSelectionDialog(
                        context, true);
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
                          translationController.getLanguageName(
                              translationController
                                  .selectedLanguageSource.value),
                          style: TextStyle(
                              color: textColor,
                              fontSize: height * 0.020,
                              fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz, color: Colors.blue),
                  onPressed: () {
                    translationController.swapTranslation();
                  },
                ),
                InkWell(
                  onTap: () {
                    translationController.showLanguageSelectionDialog(
                        context, false);
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
                          translationController.getLanguageName(
                              translationController
                                  .selectedLanguageTarget.value),
                          style: TextStyle(
                              color: textColor,
                              fontSize: height * 0.020,
                              fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    // initSpeech();
                    sttController.initializeSpeechForNewLanguage();
                    if (isListeningComplete == false) {
                      if (startListeningaudio) {
                        // sttController.stopListening();
                        stopListening(true);
                      } else {
                        // sttController.startListening();
                        startListening(true);
                      }
                    } else {
                      print('null');
                    }
                  },
                  child: Container(
                    // color: Colors.black45,
                    height: height * 0.09,
                    child: startListeningaudio == true
                        ? RipplesAnimation(
                            // reverse: false,
                            color: speakerColor,
                            // speakerColor,
                            size: height * 0.029,
                            child: Icon(Icons.mic,
                                size: height * 0.032, color: micColor),
                          )
                        : Container(
                            // height: height * 0.02,
                            width: width * 0.2,
                            decoration: BoxDecoration(
                                color: speakerColor, shape: BoxShape.circle),
                            child: Icon(Icons.mic_off_outlined,
                                size: height * 0.032, color: micColor),
                          ),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     initSpeech();
                //     if (speech.isListening) {
                //       // sttController.stopListening();
                //       _stopListening();
                //     } else {
                //       // sttController.startListening();
                //       _startListening('hi-IN');
                //     }
                //   },
                //   child: Container(
                //     // color: Colors.black45,
                //     height: height * 0.145,
                //     width: width * 0.31,
                //     // color: Color.fromARGB(255, 209, 130, 130),
                //     child: Stack(
                //       children: [
                //         RipplesAnimation(
                //           // reverse: false,
                //           color: startListeningaudio == true
                //               ? Color.fromARGB(255, 223, 143, 31)
                //               : Color.fromARGB(255, 137, 134, 134),
                //           // size: height * 0.03,
                //         ),
                //         Align(
                //           alignment: Alignment.center,
                //           child: Icon(
                //               speech.isListening
                //                   ? Icons.mic
                //                   : Icons.mic_off,
                //               color: speech.isListening == false
                //                   ? Color.fromARGB(255, 253, 253, 253)
                //                   : Color.fromARGB(255, 70, 214, 135)),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: width * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    sttController.initializeSpeechForNewLanguage();
                    if (startListeningaudio == false) {
                      if (isListeningComplete) {
                        // sttController.stopListening();
                        stopListening(false);
                      } else {
                        // sttController.startListening();
                        startListening(false);
                      }
                    } else {
                      print("null");
                    }
                  },
                  child: Container(
                    // color: Colors.black45,
                    height: height * 0.09,
                    child: isListeningComplete == true
                        ? RipplesAnimation(
                            // reverse: false,
                            color: speakerColor,
                            // speakerColor,
                            size: height * 0.029,
                            child: Icon(Icons.mic,
                                size: height * 0.032, color: micColor),
                          )
                        : Container(
                            // height: height * 0.02,
                            width: width * 0.2,
                            decoration: BoxDecoration(
                                color: speakerColor, shape: BoxShape.circle),
                            child: Icon(Icons.mic_off_outlined,
                                size: height * 0.032, color: micColor),
                          ),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     initSpeech();
                //     if (speech.isListening) {
                //       // sttController.stopListening();
                //       _stopListening();
                //     } else {
                //       // sttController.startListening();
                //       _startListening(
                //           sttController2.selectedLanguage.value);
                //     }
                //   },
                //   child: Container(
                //     // color: Colors.black45,
                //     height: height * 0.145,
                //     width: width * 0.31,
                //     // color: Color.fromARGB(255, 209, 130, 130),
                //     child: Stack(
                //       children: [
                //         RipplesAnimation(
                //           // reverse: false,
                //           color: speech.isListening == true
                //               ? Color.fromARGB(255, 223, 143, 31)
                //               : Color.fromARGB(255, 137, 134, 134),
                //           // size: height * 0.03,
                //         ),
                //         Align(
                //           alignment: Alignment.center,
                //           child: Icon(
                //               speech.isListening
                //                   ? Icons.mic
                //                   : Icons.mic_off,
                //               color: speech.isListening == false
                //                   ? Color.fromARGB(255, 253, 253, 253)
                //                   : Color.fromARGB(255, 51, 161, 101)),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // InkWell(
                //   onTap: () async {
                //     translationController.focusNodeFromTextField.value
                //         .unfocus();
                //     translationController.translatedText.value =
                //         await translationController.translateText(context);
                //     print(translationController.translatedText.value);
                //   },
                //   child: Container(
                //     height: height * 0.04,
                //     width: width * 0.30,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(25),
                //       color: const Color.fromARGB(255, 57, 122, 175),
                //     ),
                //     child: Center(
                //       child: Text(
                //         "Translate",
                //         style: TextStyle(
                //             fontSize: height * 0.020,
                //             fontWeight: FontWeight.w700,
                //             color: Colors.white),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
