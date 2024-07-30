import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:translator/core/navigation/navigation_service.dart';
import 'package:translator/data/dbhelper.dart';
import 'package:translator/features/translation/widget/widget.dart';
import 'package:translator/firebase_options.dart';
import 'package:translator/routes/app_pages.dart';
import 'package:translator/routes/pages_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await TranslationDb.initializeHive();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // Determine Superwall API Key for platform
    // String apiKey = Platform.isIOS
    //     ? "pk_cc3505fb05232088a80c1499a0d4c6c0fa92cf37e0d94743"
    //     : "pk_97403595bd1640c024f34495e484a0d4cf46807f44b60bdb";
    Superwall.configure('pk_cc3505fb05232088a80c1499a0d4c6c0fa92cf37e0d94743');
  }

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

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final SpeechToText _speechToText = SpeechToText();

//   bool _speechEnabled = false;
//   String _wordsSpoken = "";
//   double _confidenceLevel = 0;

//   @override
//   void initState() {
//     super.initState();
//     initSpeech();
//   }

//   void initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }

//   void _startListening() async {
//     await _speechToText.listen(onResult: _onSpeechResult);
//     setState(() {
//       _confidenceLevel = 0;
//     });
//   }

//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {});
//   }

//   void _onSpeechResult(result) {
//     setState(() {
//       _wordsSpoken = "${result.recognizedWords}";
//       _confidenceLevel = result.confidence;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text(
//           'Speech Demo',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 _speechToText.isListening
//                     ? "listening..."
//                     : _speechEnabled
//                         ? "Tap the microphone to start listening..."
//                         : "Speech not available",
//                 style: TextStyle(fontSize: 20.0),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   _wordsSpoken,
//                   style: const TextStyle(
//                     fontSize: 25,
//                     fontWeight: FontWeight.w300,
//                   ),
//                 ),
//               ),
//             ),
            
//               Padding(
//                 padding: const EdgeInsets.only(
//                   bottom: 100,
//                 ),
//                 child: Text(
//                   "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w200,
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _speechToText.isListening ? _stopListening : _startListening,
//         tooltip: 'Listen',
//         child: Icon(
//           _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
//           color: Colors.white,
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }


// // class navbar extends StatelessWidget {
// //   const navbar({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       bottomNavigationBar: ,
// //     );
// //   }
// // }