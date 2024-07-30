// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
// import 'package:translator/features/translation/controllers/translation_controller.dart';

// class WidgetController extends GetxController {
//   Widget getWidget(
//       bool hasFocus, TextEditingController? controller, BuildContext context) {
//     final TranslationController translationController =
//         Get.put(TranslationController());

//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     if (hasFocus == true && controller?.text.isNotEmpty == true) {
//       print("Text field is not empty");
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(),
//           Container(
//             height: height * 0.04,
//             width: width * 0.31,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               color: Colors.blue,
//             ),
//             child: Center(
//               child: Text(
//                 "Translate",
//                 style: TextStyle(fontSize: height * 0.015),
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (hasFocus && controller?.text.isEmpty == true) {
//       print("Text field focus function Condition:-(${!hasFocus})");
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: Icon(Icons.mic, color: Colors.blue),
//             onPressed: () async {
//               translationController.focusNodeFromTextField.value.unfocus();
//               String p = await translationController.translateText(context);
//               print(p);
//             },
//           ),
//           InkWell(
//             onTap: () async{
//               translationController.focusNodeFromTextField.value.unfocus();
//               String p = await translationController.translateText(context);
//               print(p);
//             },
//             child: Container(
//               height: height * 0.04,
//               width: width * 0.30,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25),
//                 color: const Color.fromARGB(255, 57, 122, 175),
//               ),
//               child: Center(
//                 child: Text(
//                   "Translate",
//                   style: TextStyle(fontSize: height * 0.020,fontWeight: FontWeight.w700,color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (!hasFocus && controller?.text.isEmpty == true){
//       print("This is a default value function Condition:-(${!hasFocus} && ${controller?.text.isEmpty})");
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: Icon(Icons.group, color: Colors.blue),
//             onPressed: () {},
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.camera_alt, color: Colors.blue),
//                 onPressed: () async {
//                   bool p = await translationController.deleteTranslationModel(
//                     translationController.selectedLanguageSource.value.bcpCode,
//                     context,
//                   );
//                   bool b = await translationController.deleteTranslationModel(
//                     translationController.selectedLanguageTarget.value.bcpCode,
//                     context,
//                   );
//                   print("$b and $p");
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.mic, color: Colors.blue),
//                 onPressed: () async {
//                   translationController.focusNodeFromTextField.value.unfocus();
//                   String p = await translationController.translateText(context ,);
//                   print(p);
//                 },
//               ),
//             ],
//           ),
//         ],
//       );
//     }else{
//       return Container();
//     }
//   }
// }


