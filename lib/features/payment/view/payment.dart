

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:translator/features/payment/controller/con.dart';

// class MyWidget extends StatelessWidget {
//    MyWidget({super.key});
//   final SuperwallController superwallController = Get.put(SuperwallController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const Text('Running'),
//               ElevatedButton(
//                 onPressed: superwallController.onRegisterTapped,
//                 child: const Text('Register event'),
//               ),
//               ElevatedButton(
//                 onPressed: superwallController.performAction,
//                 child: const Text('Perform action'),
//               ),
//               Obx(() {
//                 final subscriptionStatus = superwallController.subscriptionStatus.value;
//                 return Text('Subscription Status: $subscriptionStatus');
//               }),
//             ],
//           ),
//         ),
//       );
//   }
// }





import 'package:flutter/material.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';


// class payment extends StatelessWidget {
//    payment({super.key});

//  @override
//   Widget build(BuildContext context) {
//     // Register the event when the widget is built
//     _showPaywall();

//     return Scaffold(
//       body: Container(),
//     );
//   }

//   void _showPaywall() {
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
//     Superwall.shared.registerEvent("paywall_decline", handler: handler, feature: () {
//       // Feature logic goes here, but in this case, we're only interested in displaying the paywall
//     });
//   }
// }