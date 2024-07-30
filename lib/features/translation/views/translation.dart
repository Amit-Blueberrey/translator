import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ripple_animation/ripple_animation.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:translator/core/controller/sttController.dart';
import 'package:translator/core/utils/color.dart';
import 'package:translator/core/utils/translatr_popup.dart';
import 'package:translator/features/payment/view/payment.dart';
import 'package:translator/features/translation/controllers/translation_controller.dart';
import 'package:translator/core/controller/ttsController.dart';
import 'package:translator/features/translation/controllers/widgetController.dart';
import 'package:upgrader/upgrader.dart';

class translation_home extends StatefulWidget {
  translation_home({super.key});

  @override
  State<translation_home> createState() => _translation_homeState();
}

class _translation_homeState extends State<translation_home> {
  final TranslationController translationController =
      Get.put(TranslationController());

  // final TextEditingController translateTextController = TextEditingController();printSupportedLanguages()
  // final WidgetController widgetController = Get.put(WidgetController());

  final TTSController ttsController = Get.put(TTSController());
  final SttController sttController = Get.put(SttController());
  final SpeechToText speech = SpeechToText();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  bool _isListeningComplete = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
    analytics.logEvent(name: "Open first app");
  }

  void initSpeech() async {
    _speechEnabled = await speech.initialize();

    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _isListeningComplete = true;
      print(
          'STT Language selected:- ${sttController.selectedLanguageSource.value}');
    });
    await speech.listen(
      onResult: _onSpeechResult,
      localeId: sttController.selectedLanguageSource.value,
    );

    // setState(() {
    //   _confidenceLevel = 0;
    // });
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {
      _isListeningComplete = false;
      callpb();
    });
  }

  void _onSpeechResult(result) async {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      translationController.translateTextController.value.text = _wordsSpoken;
      _confidenceLevel = result.confidence;

      if (result.finalResult) {
        setState(() {
          _isListeningComplete = false;
          callpb();
        });
      }
    });
  }

  void callpb() async {
    translationController.focusNodeFromTextField.value.unfocus();
    translationController.translatedTextTarget.value =
        await translationController.translateText(context, true, true);
    print(translationController.translatedTextSource.value);
  }

  void showPaywall() {
    // Create a PaywallPresentationHandler
    PaywallPresentationHandler handler = PaywallPresentationHandler();
    handler.onPresent((paywallInfo) async {
      String name = await paywallInfo.name;
      print("Handler (onPresent): $name");
    });
    handler.onDismiss((paywallInfo) async {
      String name = await paywallInfo.name;
      print("Handler (onDismiss): $name");
    });
    handler.onError((error) {
      print("Handler (onError): ${error}");
    });
    handler.onSkip((skipReason) async {
      String description = await skipReason.description;

      if (skipReason is PaywallSkippedReasonHoldout) {
        print("Handler (onSkip): $description");

        final experiment = await skipReason.experiment;
        final experimentId = await experiment.id;
        print("Holdout with experiment: ${experimentId}");
      } else if (skipReason is PaywallSkippedReasonNoRuleMatch) {
        print("Handler (onSkip): $description");
      } else if (skipReason is PaywallSkippedReasonEventNotFound) {
        print("Handler (onSkip): $description");
      } else if (skipReason is PaywallSkippedReasonUserIsSubscribed) {
        print("Handler (onSkip): $description");
      } else {
        print("Handler (onSkip): Unknown skip reason");
      }
    });

    // Register the event and attach the handler
    Superwall.shared.registerEvent("paywall_decline", handler: handler,
        feature: () {
      // Feature logic goes here, but in this case, we're only interested in displaying the paywall
    });
  }

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
          'Translator',
          style: TextStyle(
              color: textColor,
              fontSize: height * 0.0235,
              fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
            icon: Icon(Icons.menu,
                color: Colors.blue), // Use Icons.history for history icon
            onPressed: () {
              // Superwall.shared.registerEvent('paywall_decline', feature: () {
              //   // navigation.startWorkout();
              // });
              sttController.printSupportedLanguages();
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
      body: UpgradeAlert(
        showIgnore: false,
        showReleaseNotes: false,
        dialogStyle: Platform.isIOS
            ? UpgradeDialogStyle.cupertino
            : UpgradeDialogStyle.material,
        upgrader: Upgrader(
          durationUntilAlertAgain: Duration(hours: 6),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // translationController.showLanguageSelectionDialog(
                      //     context, true);
                      showBottomSheetForLanguageSelection(context, true);
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
                    icon: Icon(Icons.swap_horiz,
                        size: height * 0.035, color: Colors.blue),
                    onPressed: () {
                      translationController.swapTranslation();
                    },
                  ),
                  InkWell(
                    onTap: () {
                      // translationController.showLanguageSelectionDialog(
                      //     context, false);
                      showBottomSheetForLanguageSelection(context, false);
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
              Obx(
                () => Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: height * 0.013),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(width * 0.02),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.01),
                              child: Text(
                                  translationController.getLanguageName(
                                      translationController
                                          .selectedLanguageSource.value),
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600)),
                            ),
                            translationController.isTextFieldFocused == true
                                ? InkWell(
                                    onTap: () {
                                      translationController
                                          .focusNodeFromTextField.value
                                          .unfocus();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Color.fromARGB(255, 53, 53, 53),
                                    ))
                                : Container()
                          ],
                        ),
                        // SizedBox(height: height * 0.01),
                        Expanded(
                          child: TextField(
                            controller: translationController
                                .translateTextController.value,
                            maxLines: null,
                            focusNode: translationController
                                .focusNodeFromTextField.value,
                            style: TextStyle(
                                color: textTranslatorColor,
                                fontSize: height * 0.025),
                            decoration: InputDecoration(
                              hintText: 'Enter your text',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // Container(
                        //     child: widgetController.getWidget(
                        //         translationController.focusNodeFromTextField.value.hasFocus,
                        //         translationController.translateTextController.value,
                        //         context),
                        //   ),
                        Obx(() => translationController.isTextFieldFocused ==
                                true
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: height * 0.008),
                                    child: InkWell(
                                      onTap: () async {
                                        translationController
                                            .focusNodeFromTextField.value
                                            .unfocus();
                                        translationController
                                                .translatedTextSource.value =
                                            await translationController
                                                .translateText(
                                                    context, true, true);
                                        print(translationController
                                            .translatedTextSource.value);
                                      },
                                      child: Container(
                                        height: height * 0.04,
                                        width: width * 0.26,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                                width: width * 0.004,
                                                color: blueColor)),
                                        child: Center(
                                          child: Text(
                                            "Translate",
                                            style: TextStyle(
                                                fontSize: height * 0.018,
                                                fontWeight: FontWeight.w600,
                                                color: blueColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container()),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(
                () => translationController.isTextFieldFocused == false
                    ? SizedBox(height: height * 0.02)
                    : SizedBox(),
              ),
              Obx(
                () => translationController
                        .translateTextController.value.text.isEmpty
                    ? translationController.isTextFieldFocused == false
                        ? Container(
                            height: height * 0.075,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                                color: fieldColor),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.wifi_off_outlined,
                                        size: height * 0.033,
                                        color: iconColor,
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      Text('Offline translation',
                                          style: TextStyle(
                                              fontSize: height * 0.02,
                                              color: textColor,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  Obx(
                                    () => Switch(
                                      value: translationController
                                          .localTranslationEnable.value,
                                      onChanged: (bool value) {
                                        translationController
                                            .localTranslationEnable
                                            .value = value;
                                        translationController
                                            .focusNodeFromTextField.value
                                            .unfocus();
                                        print(
                                            'Local Translation Enable ${translationController.localTranslationEnable.value}');
                                      },
                                      activeColor: iconColor,
                                      thumbColor: WidgetStateProperty.all(
                                          Color.fromARGB(255, 255, 255, 255)),
                                      inactiveTrackColor:
                                          Color.fromARGB(255, 219, 219, 219),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container()
                    : translationController.isTextFieldFocused == false
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(width * 0.03),
                            decoration: BoxDecoration(
                                color: fieldColor,
                                borderRadius:
                                    BorderRadius.circular(width * 0.02)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        translationController.getLanguageName(
                                            translationController
                                                .selectedLanguageTarget.value),
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600)),
                                    translationController
                                                .translateTextController
                                                .value !=
                                            ''
                                        ? InkWell(
                                            onTap: () {
                                              // initSpeech();

                                              if (ttsController.isSpeaking ==
                                                  true) {
                                                // sttController.stopListening();
                                                ttsController.stop();
                                              } else {
                                                // sttController.startListening();
                                                ttsController.speak(
                                                    translationController
                                                        .translatedTextTarget
                                                        .value);
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: width * 0.06),
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
                                                    ttsController.isSpeaking ==
                                                            false
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
                                Obx(() => Container(
                                      child: translationController
                                              .translatedTextTarget
                                              .value
                                              .isNotEmpty
                                          ? Text(
                                              translationController
                                                  .translatedTextTarget.value,
                                              style: TextStyle(
                                                  color: textTranslatorColor,
                                                  fontSize: height * 0.025),
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey[100]!,
                                                  highlightColor:
                                                      Colors.grey[400]!,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                          height: height * 0.01,
                                                          width:
                                                              double.infinity),
                                                      // Add any other widget that you want to show the shimmer effect
                                                      Container(
                                                        height: height * 0.01,
                                                        width: double.infinity,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                          height: height * 0.01,
                                                          width:
                                                              double.infinity),
                                                      Container(
                                                        height: height * 0.01,
                                                        width: double.infinity,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                          height: height * 0.01,
                                                          width:
                                                              double.infinity),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    )),
                              ],
                            ),
                          )
                        : Container(),
              ),
              Obx(() => translationController.isTextFieldFocused == false
                  ? SizedBox(
                      height: height * 0.02,
                    )
                  : SizedBox(
                      height: height * 0.0,
                    )),
              Obx(
                () => translationController.isTextFieldFocused == false
                    ? GestureDetector(
                        onTap: () {
                          sttController.initializeSpeechForNewLanguage();
                          if (_isListeningComplete) {
                            // sttController.stopListening();

                            _stopListening();
                          } else {
                            // sttController.startListening();
                            _startListening();
                          }
                        },
                        child: Container(
                          // color: Colors.black45,
                          height: height * 0.09,
                          child: _isListeningComplete == true
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
                                      color: iconColor, shape: BoxShape.circle),
                                  child: Icon(Icons.mic_off_outlined,
                                      size: height * 0.032, color: micColor),
                                ),
                        ),
                      )
                    : Container(),
              ),
              Obx(
                () => translationController.isTextFieldFocused == false
                    ? SizedBox(
                        height: height * 0.02,
                      )
                    : SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
