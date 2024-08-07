import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:translator/core/controller/remortConfigController.dart';
import 'package:translator/core/navigation/navigation_service.dart';
import 'package:translator/data/dbhelper.dart';
import 'package:translator/features/payment/controller/payment_controller.dart';
import 'package:translator/firebase_options.dart';
import 'package:translator/routes/app_pages.dart';
import 'package:translator/routes/pages_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final RemoteConfigController remoteConfigController = Get.put(RemoteConfigController()); // Initialize GetX controller
  await TranslationDb.initializeHive();
  await remoteConfigController.initializeRemoteConfig();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  // void initState() {
  //   // Determine Superwall API Key for platform
  //   String apiKey = Platform.isIOS
  //       ? "pk_cc3505fb05232088a80c1499a0d4c6c0fa92cf37e0d94743"
  //       : "pk_97403595bd1640c024f34495e484a0d4cf46807f44b60bdb";
  //   Superwall.configure(apiKey);
  // }
  void initState(){
    // TODO: implement initState
    super.initState();
    RCPurchaseController rcPurchaseController = RCPurchaseController();
    String apiKey = Platform.isIOS
        ? "pk_cc3505fb05232088a80c1499a0d4c6c0fa92cf37e0d94743"
        : "pk_97403595bd1640c024f34495e484a0d4cf46807f44b60bdb";
    Superwall.configure(apiKey, purchaseController: rcPurchaseController);
  }


  // void callRcPurchaseController ()async{
  //   RCPurchaseController rcPurchaseController = RCPurchaseController();
  //   Superwall.shared.registerEvent('StartWorkout', feature: () {
  //     // navigation.startWorkout();
  //     print("the paywall");
  //   });
  //   await rcPurchaseController.syncSubscriptionStatus();
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: PagesName.navbar,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: test(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }




// class translation_home extends StatefulWidget {
//   translation_home({super.key});

//   @override
//   State<translation_home> createState() => _translation_homeState();
// }

// class _translation_homeState extends State<translation_home> {
//   final TranslationController translationController =
//       Get.put(TranslationController());
//      final   TranslationControllerOnline translatOnline =Get.put(TranslationControllerOnline());

//   // final TextEditingController translateTextController = TextEditingController();printSupportedLanguages()
//   // final WidgetController widgetController = Get.put(WidgetController());

//   final TTSController ttsController = Get.put(TTSController());
//   final SttController sttController = Get.put(SttController());
//   final SpeechToText speech = SpeechToText();
//   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

//   bool _speechEnabled = false;
//   String _wordsSpoken = "";
//   double _confidenceLevel = 0;
//   bool _isListeningComplete = false;

//   @override
//   void initState() {
//     super.initState();
//     initSpeech();
//     analytics.logEvent(name: "Open first app");
//   }

//   void initSpeech() async {
//     _speechEnabled = await speech.initialize();

//     setState(() {});
//   }

//   void _startListening() async {
//     setState(() {
//       _isListeningComplete = true;
//       print(
//           'STT Language selected:- ${sttController.selectedLanguageSource.value}');
//     });
//     await speech.listen(
//       onResult: _onSpeechResult,
//       localeId: sttController.selectedLanguageSource.value,
//     );

//     // setState(() {
//     //   _confidenceLevel = 0;
//     // });
//   }

//   void _stopListening() async {
//     await speech.stop();
//     setState(() {
//       _isListeningComplete = false;
//       callpb();
//     });
//   }

//   void _onSpeechResult(result) async {
//     setState(() {
//       _wordsSpoken = "${result.recognizedWords}";
//       translatOnline.localTranslationEnable.value?translationController.translateTextController.value.text:translatOnline.translateTextController.value.text = _wordsSpoken;
//       _confidenceLevel = result.confidence;

//       if (result.finalResult) {
//         setState(() {
//           _isListeningComplete = false;
//           callpb();
//         });
//       }
//     });
//   }

//   void callpb() async {
//     translatOnline.localTranslationEnable.value ?translationController.focusNodeFromTextField.value.unfocus():translatOnline.focusNodeFromTextField.value.unfocus();
//      if (translatOnline.localTranslationEnable.value) {
//        translationController.translatedTextTarget.value = await translationController.translateText(context, true, true);
//        print(translationController.translatedTextSource.value);
//      }else{
//         translatOnline.sourceTranslateText.value= await translatOnline.translateText();
//         print(translatOnline.sourceTranslateText.value);
//      }
//   }

//   void showPaywall() {
//     // Create a PaywallPresentationHandler
//     PaywallPresentationHandler handler = PaywallPresentationHandler();
//     handler.onPresent((paywallInfo) async {
//       String name = await paywallInfo.name;
//       print("Handler (onPresent): $name");
//     });
//     handler.onDismiss((paywallInfo) async {
//       String name = await paywallInfo.name;
//       print("Handler (onDismiss): $name");
//     });
//     handler.onError((error) {
//       print("Handler (onError): ${error}");
//     });
//     handler.onSkip((skipReason) async {
//       String description = await skipReason.description;

//       if (skipReason is PaywallSkippedReasonHoldout) {
//         print("Handler (onSkip): $description");

//         final experiment = await skipReason.experiment;
//         final experimentId = await experiment.id;
//         print("Holdout with experiment: ${experimentId}");
//       } else if (skipReason is PaywallSkippedReasonNoRuleMatch) {
//         print("Handler (onSkip): $description");
//       } else if (skipReason is PaywallSkippedReasonEventNotFound) {
//         print("Handler (onSkip): $description");
//       } else if (skipReason is PaywallSkippedReasonUserIsSubscribed) {
//         print("Handler (onSkip): $description");
//       } else {
//         print("Handler (onSkip): Unknown skip reason");
//       }
//     });

//     // Register the event and attach the handler
//     Superwall.shared.registerEvent("paywall_decline", handler: handler,
//         feature: () {
//       // Feature logic goes here, but in this case, we're only interested in displaying the paywall
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Translator',
//           style: TextStyle(
//               color: textColor,
//               fontSize: height * 0.0235,
//               fontWeight: FontWeight.w700),
//         ),
//         leading: IconButton(
//             icon: Icon(Icons.menu,
//                 color: Colors.blue), // Use Icons.history for history icon
//             onPressed: () {
//               // Superwall.shared.registerEvent('paywall_decline', feature: () {
//               //   // navigation.startWorkout();
//               // });
//               sttController.printSupportedLanguages();
//             }),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.settings, color: Colors.blue),
//             onPressed: () {
//               ttsController.printSupportedLanguages();
//             },
//           ),
//         ],
//         centerTitle: true,
//       ),
//       body: UpgradeAlert(
//         showIgnore: false,
//         showReleaseNotes: false,
//         dialogStyle: Platform.isIOS
//             ? UpgradeDialogStyle.cupertino
//             : UpgradeDialogStyle.material,
//         upgrader: Upgrader(
//           durationUntilAlertAgain: Duration(hours: 6),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.03),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       // translationController.showLanguageSelectionDialog(
//                       //     context, true);
//                       showBottomSheetForLanguageSelection(context, true);
//                     },
//                     child: Container(
//                       height: height * 0.06,
//                       width: width * 0.37,
//                       padding: EdgeInsets.symmetric(
//                           horizontal: width * 0.02, vertical: height * 0.01),
//                       decoration: BoxDecoration(
//                         color: fieldColor,
//                         borderRadius: BorderRadius.circular(width * 0.02),
//                       ),
//                       child: Center(
//                         child: Obx(() => Text(
//                             translatOnline.localTranslationEnable.value? translationController.getLanguageName(
//                                 translationController
//                                     .selectedLanguageSource.value):translatOnline.sourceLanguage.value,
//                             style: TextStyle(
//                                 color: textColor,
//                                 fontSize: height * 0.020,
//                                 fontWeight: FontWeight.w700))),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.swap_horiz,
//                         size: height * 0.035, color: Colors.blue),
//                     onPressed: () {
//                       translatOnline.localTranslationEnable.value? translationController.swapTranslation():translatOnline.swapTranslation();
//                     },
//                   ),
//                   InkWell(
//                     onTap: () {
//                       // translationController.showLanguageSelectionDialog(
//                       //     context, false);
//                       showBottomSheetForLanguageSelection(context, false);
//                     },
//                     child: Container(
//                       height: height * 0.06,
//                       width: width * 0.37,
//                       padding: EdgeInsets.symmetric(
//                           horizontal: width * 0.02, vertical: height * 0.01),
//                       decoration: BoxDecoration(
//                         color: fieldColor,
//                         borderRadius: BorderRadius.circular(width * 0.02),
//                       ),
//                       child: Center(
//                         child: Obx(() => Text(
//                             translatOnline.localTranslationEnable.value?translationController.getLanguageName(
//                                 translationController
//                                     .selectedLanguageTarget.value):translatOnline.targetLanguage.value,
//                             style: TextStyle(
//                                 color: textColor,
//                                 fontSize: height * 0.020,
//                                 fontWeight: FontWeight.w700))),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: height * 0.02),
//               Obx(
//                 () => Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: width * 0.04, vertical: height * 0.013),
//                     decoration: BoxDecoration(
//                       color: fieldColor,
//                       borderRadius: BorderRadius.circular(width * 0.02),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.only(top: height * 0.01),
//                               child: Text(
//                                  translatOnline.localTranslationEnable.value? translationController.getLanguageName(
//                                       translationController
//                                           .selectedLanguageSource.value):translatOnline.sourceLanguage.value,
//                                   style: TextStyle(
//                                       color: textColor,
//                                       fontWeight: FontWeight.w600)),
//                             ),
//                            translatOnline.localTranslationEnable.value? translationController: translatOnline.isTextFieldFocused == true
//                                 ? InkWell(
//                                     onTap: () {
//                                      translatOnline.localTranslationEnable.value? translationController
//                                           .focusNodeFromTextField.value
//                                           .unfocus():translatOnline.focusNodeFromTextField.value.unfocus();
//                                     },
//                                     child: Icon(
//                                       Icons.close,
//                                       color: Color.fromARGB(255, 53, 53, 53),
//                                     ))
//                                 : Container()
//                           ],
//                         ),
//                         // SizedBox(height: height * 0.01),
//                         Expanded(
//                           child: TextField(
//                             controller: translatOnline.localTranslationEnable.value? translationController
//                                 .translateTextController.value:translatOnline.translateTextController.value,
//                             maxLines: null,
//                             focusNode: translatOnline.localTranslationEnable.value? translationController
//                                 .focusNodeFromTextField.value: translatOnline.focusNodeFromTextField.value,
//                             style: TextStyle(
//                                 color: textTranslatorColor,
//                                 fontSize: height * 0.025),
//                             decoration: InputDecoration(
//                               hintText: 'Enter your text',
//                               hintStyle: TextStyle(color: Colors.grey),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                         // Container(
//                         //     child: widgetController.getWidget(
//                         //         translationController.focusNodeFromTextField.value.hasFocus,
//                         //         translationController.translateTextController.value,
//                         //         context),
//                         //   ),
//                         Obx(() => translatOnline.localTranslationEnable.value?translationController : translatOnline.isTextFieldFocused ==
//                                 true
//                             ? Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Container(),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.only(bottom: height * 0.008),
//                                     child: InkWell(
//                                       onTap: () async {

//                                         if (translatOnline.localTranslationEnable.value) {
//                                           translationController.focusNodeFromTextField.value.unfocus();
//                                           translationController.translatedTextTarget.value =
//                                             await translationController.translateText(context, true, true);
//                                                     print(translationController.translatedTextTarget.value);
                                          
//                                         }else{
//                                           translatOnline.focusNodeFromTextField.value.unfocus();
//                                           translatOnline.targetLanguage.value= await translatOnline.translateText();
//                                           print(translatOnline.targetLanguage.value);
//                                         }


                                        

                                        
                                        
//                                       },
//                                       child: Container(
//                                         height: height * 0.04,
//                                         width: width * 0.26,
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(25),
//                                             border: Border.all(
//                                                 width: width * 0.004,
//                                                 color: blueColor)),
//                                         child: Center(
//                                           child: Text(
//                                             "Translate",
//                                             style: TextStyle(
//                                                 fontSize: height * 0.018,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: blueColor),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Container()),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Obx(
//                 () => translatOnline.localTranslationEnable.value? translationController : translatOnline.isTextFieldFocused == false
//                     ? SizedBox(height: height * 0.02)
//                     : SizedBox(),
//               ),
//               Obx(
//                 () => translatOnline.localTranslationEnable.value? translationController:translatOnline
//                         .translateTextController.value.text.isEmpty
//                     ? translatOnline.localTranslationEnable.value?translationController:translatOnline.isTextFieldFocused == false
//                         ? Container(
//                             height: height * 0.075,
//                             decoration: BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.circular(width * 0.02),
//                                 color: fieldColor),
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: width * 0.03),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.wifi_off_outlined,
//                                         size: height * 0.033,
//                                         color: iconColor,
//                                       ),
//                                       SizedBox(
//                                         width: width * 0.03,
//                                       ),
//                                       Text('Offline translation',
//                                           style: TextStyle(
//                                               fontSize: height * 0.02,
//                                               color: textColor,
//                                               fontWeight: FontWeight.w700)),
//                                     ],
//                                   ),
//                                   Obx(
//                                     () => Switch(
//                                       value: translatOnline.localTranslationEnable.value,
//                                       onChanged: (bool value) {
//                                         translatOnline
//                                             .localTranslationEnable
//                                             .value = value;

//                                        translatOnline.localTranslationEnable.value? translationController :translatOnline
//                                             .focusNodeFromTextField.value
//                                             .unfocus();
//                                             TranslationDb.isOffline = value;
//                                         print(
//                                             'Local Translation Enable ${translatOnline.localTranslationEnable.value}');
//                                       },
//                                       activeColor: iconColor,
//                                       thumbColor: WidgetStateProperty.all(
//                                           Color.fromARGB(255, 255, 255, 255)),
//                                       inactiveTrackColor:
//                                           Color.fromARGB(255, 219, 219, 219),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         : Container()
//                     : translatOnline.localTranslationEnable.value?translationController:translatOnline.isTextFieldFocused == false
//                         ? Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(width * 0.03),
//                             decoration: BoxDecoration(
//                                 color: fieldColor,
//                                 borderRadius:
//                                     BorderRadius.circular(width * 0.02)),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         translatOnline.localTranslationEnable.value?translationController.getLanguageName(
//                                             translationController
//                                                 .selectedLanguageTarget.value):translatOnline.targetLanguage.value,
//                                         style: TextStyle(
//                                             color: textColor,
//                                             fontWeight: FontWeight.w600)),
//                                     translatOnline.localTranslationEnable.value?translationController.translateTextController.value : translatOnline.targetLanguage.value!=''
//                                         ? InkWell(
//                                             onTap: () {
//                                               // initSpeech();

//                                               if (ttsController.isSpeaking ==
//                                                   true) {
//                                                 // sttController.stopListening();
//                                                 ttsController.stop();
//                                               } else {
//                                                 // sttController.startListening();
//                                                 ttsController.speak(
//                                                     translatOnline.localTranslationEnable.value?translationController.translatedTextTarget.value:translatOnline.targetLanguage.value);
//                                               }
//                                             },
//                                             child: Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: width * 0.06),
//                                               child: Align(
//                                                 alignment: Alignment.center,
//                                                 child: Container(
//                                                   height: height * 0.037,
//                                                   width: width * 0.1,
//                                                   decoration: BoxDecoration(
//                                                     color: speakerColor,
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                   child: Icon(
//                                                     ttsController.isSpeaking ==
//                                                             false
//                                                         ? Icons.play_arrow
//                                                         : Icons.pause,
//                                                     color: micColor,
//                                                     size: height * 0.025,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Container(),
//                                   ],
//                                 ),
//                                 SizedBox(height: height * 0.01),
//                                 Obx(() => Container(
//                                       child: translatOnline.localTranslationEnable.value?translationController.translatedTextTarget.value.isNotEmpty:translatOnline.targetLanguage.value.isNotEmpty
//                                           ? Text(
//                                               translatOnline.localTranslationEnable.value?translationController.translatedTextTarget.value:translatOnline.targetLanguage.value,
//                                               style: TextStyle(
//                                                   color: textTranslatorColor,
//                                                   fontSize: height * 0.025),
//                                             )
//                                           : Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Shimmer.fromColors(
//                                                   baseColor: Colors.grey[100]!,
//                                                   highlightColor:
//                                                       Colors.grey[400]!,
//                                                   child: Column(
//                                                     children: [
//                                                       SizedBox(
//                                                           height: height * 0.01,
//                                                           width:
//                                                               double.infinity),
//                                                       // Add any other widget that you want to show the shimmer effect
//                                                       Container(
//                                                         height: height * 0.01,
//                                                         width: double.infinity,
//                                                         color: Colors.white,
//                                                       ),
//                                                       SizedBox(
//                                                           height: height * 0.01,
//                                                           width:
//                                                               double.infinity),
//                                                       Container(
//                                                         height: height * 0.01,
//                                                         width: double.infinity,
//                                                         color: Colors.white,
//                                                       ),
//                                                       SizedBox(
//                                                           height: height * 0.01,
//                                                           width:
//                                                               double.infinity),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                     )),
//                               ],
//                             ),
//                           )
//                         : Container(),
//               ),
//               Obx(() => translatOnline.localTranslationEnable.value? translationController: translatOnline.isTextFieldFocused == false
//                   ? SizedBox(
//                       height: height * 0.02,
//                     )
//                   : SizedBox(
//                       height: height * 0.0,
//                     )),
//               Obx(
//                 () =>translatOnline.localTranslationEnable.value? translationController:translatOnline.isTextFieldFocused == false
//                     ? GestureDetector(
//                         onTap: () {
//                           sttController.initializeSpeechForNewLanguage();
//                           if (_isListeningComplete) {
//                             // sttController.stopListening();

//                             _stopListening();
//                           } else {
//                             // sttController.startListening();
//                             _startListening();
//                           }
//                         },
//                         child: Container(
//                           // color: Colors.black45,
//                           height: height * 0.09,
//                           child: _isListeningComplete == true
//                               ? RipplesAnimation(
//                                   // reverse: false,
//                                   color: speakerColor,
//                                   // speakerColor,
//                                   size: height * 0.029,
//                                   child: Icon(Icons.mic,
//                                       size: height * 0.032, color: micColor),
//                                 )
//                               : Container(
//                                   // height: height * 0.02,
//                                   width: width * 0.2,
//                                   decoration: BoxDecoration(
//                                       color: iconColor, shape: BoxShape.circle),
//                                   child: Icon(Icons.mic_off_outlined,
//                                       size: height * 0.032, color: micColor),
//                                 ),
//                         ),
//                       )
//                     : Container(),
//               ),
//               Obx(
//                 () => translatOnline.localTranslationEnable.value?translationController:translatOnline.isTextFieldFocused == false
//                     ? SizedBox(
//                         height: height * 0.02,
//                       )
//                     : SizedBox(),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
