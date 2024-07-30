
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:superwallkit_flutter/superwallkit_flutter.dart';

// class SuperwallController extends GetxController implements SuperwallDelegate {
//   final Rx<SubscriptionStatus> subscriptionStatus = Rx<SubscriptionStatus>(SubscriptionStatus.notSubscribed);
  
//   //   late final RCPurchaseController purchaseController;
//   // late final SuperwallOptions options;

//   @override
//   void onInit() {
//     super.onInit();
//     configureSuperwall(true);
//   }

//   Future<void> configureSuperwall(bool useRevenueCat) async {
//     try {
//       final purchaseController = RCPurchaseController();
//       String apiKey = Platform.isIOS
//           ? "pk_5f6d9ae96b889bc2c36ca0f2368de2c4c3d5f6119aacd3d2"
//           : "pk_d1f0959f70c761b1d55bb774a03e22b2b6ed290ce6561f85";

//       final logging = Logging()..level = LogLevel.warn..scopes = {LogScope.all};
//       final options = SuperwallOptions()..paywalls.shouldPreload = false;

//       Superwall.configure(apiKey,
//           purchaseController: useRevenueCat ? purchaseController : null,
//           options: options,
//           completion: () {
//             print('Executing Superwall configure completion block');
//           });

//       Superwall.shared.setDelegate(this);

//       if (useRevenueCat) {
//         await purchaseController.configureAndSyncSubscriptionStatus();
//       }
//     } catch (e) {
//       print('Failed to configure Superwall: $e');
//     }
//   }

//   Future<void> onRegisterTapped() async {
//     try {
//       final handler = PaywallPresentationHandler()
//         ..onPresent((paywallInfo) async {
//           final name = await paywallInfo.name;
//           print('Handler (onPresent): $name');
//         })
//         ..onDismiss((paywallInfo) async {
//           final name = await paywallInfo.name;
//           print('Handler (onDismiss): $name');
//         })
//         ..onError((error) {
//           print('Handler (onError): $error');
//         })
//         ..onSkip(handleSkipReason);

//       Superwall.shared.registerEvent('flutter', handler: handler, feature: () {
//         print('Executing feature block');
//         performFeatureBlockActions();
//       });
//       print('Register method called successfully.');
//     } catch (e) {
//       print('Failed to call register method: $e');
//     }
//   }

//   Future<void> performFeatureBlockActions() async {
//     final paywallInfo = await Superwall.shared.getLatestPaywallInfo();

//     if (paywallInfo != null) {
//       final identifier = await paywallInfo.identifier;
//       print('Identifier: $identifier');

//       // Add more print statements for other properties if needed
//     } else {
//       print('Paywall Info is null');
//     }
//   }

//   Future<void> performAction() async {
//     try {
//       await Superwall.shared.identify('123456');
//       final userId = await Superwall.shared.getUserId();
//       print(userId);

//       await Superwall.shared.setUserAttributes({'someAttribute': 'someValue'});
//       final attributes1 = await Superwall.shared.getUserAttributes();
//       print(attributes1);

//       await Superwall.shared
//           .setUserAttributes({'jack': 'lost', 'kate': 'antman'});
//       final attributes2 = await Superwall.shared.getUserAttributes();
//       print(attributes2);

//       await Superwall.shared.setUserAttributes({
//         'jack': '123',
//         'kate': {'tv': 'series'}
//       });
//       final attributes3 = await Superwall.shared.getUserAttributes();
//       print(attributes3);

//       await Superwall.shared.reset();
//       final attributes4 = await Superwall.shared.getUserAttributes();
//       print(attributes4);

//       Superwall.shared.setLogLevel(LogLevel.error);
//       final logLevel = await Superwall.shared.getLogLevel();
//       print('Log Level: $logLevel');
//     } catch (e) {
//       print('Failed perform action: $e');
//     }
//   }

//   Future<void> handleSkipReason(PaywallSkippedReason skipReason) async {
//     final description = await skipReason.description;

//     if (skipReason is PaywallSkippedReasonHoldout) {
//       final experiment = await skipReason.experiment;
//       final experimentId = await experiment.id;
//       print('Holdout with experiment: $experimentId');
//       print('Handler (onSkip): $description');
//     } else if (skipReason is PaywallSkippedReasonNoRuleMatch) {
//       print('Handler (onSkip): $description');
//     } else if (skipReason is PaywallSkippedReasonEventNotFound) {
//       print('Handler (onSkip): $description');
//     } else if (skipReason is PaywallSkippedReasonUserIsSubscribed) {
//       print('Handler (onSkip): $description');
//     } else {
//       print('Handler (onSkip): Unknown skip reason');
//     }
//   }

//   @override
//   void didDismissPaywall(PaywallInfo paywallInfo) {
//     print('didDismissPaywall: $paywallInfo');
//   }

//   @override
//   void didPresentPaywall(PaywallInfo paywallInfo) {
//     print('didPresentPaywall: $paywallInfo');
//   }

//   @override
//   void handleCustomPaywallAction(String name) {
//     print('handleCustomPaywallAction: $name');
//   }

//   @override
//   void handleLog(String level, String scope, String? message,
//       Map<dynamic, dynamic>? info, String? error) {
//     // print("handleLog: $level, $scope, $message, $info, $error");
//   }

//   @override
//   void handleSuperwallEvent(SuperwallEventInfo eventInfo) async {
//     // This delegate function is noisy. Uncomment to debug.
//     return;

//     print('handleSuperwallEvent: $eventInfo');

//     switch (eventInfo.event.type) {
//       case EventType.appOpen:
//         print('appOpen event');
//       case EventType.deviceAttributes:
//         print('deviceAttributes event: ${eventInfo.event.deviceAttributes} ');
//       case EventType.paywallOpen:
//         final paywallInfo = eventInfo.event.paywallInfo;
//         print('paywallOpen event: $paywallInfo ');

//         if (paywallInfo != null) {
//           final identifier = await paywallInfo.identifier;
//           print('paywallInfo.identifier: $identifier ');

//           final productIds = await paywallInfo.productIds;
//           print('paywallInfo.productIds: $productIds ');
//         }
//       default:
//         break;
//     }
//   }

//   @override
//   void paywallWillOpenDeepLink(Uri url) {
//     print('paywallWillOpenDeepLink: $url');
//   }

//   @override
//   void paywallWillOpenURL(Uri url) {
//     print('paywallWillOpenURL: $url');
//   }

//   @override
//   void subscriptionStatusDidChange(SubscriptionStatus newValue) {
//     subscriptionStatus.value = newValue;
//     print('subscriptionStatusDidChange: $newValue');
//   }

//   @override
//   void willDismissPaywall(PaywallInfo paywallInfo) {
//     print('willDismissPaywall: $paywallInfo');
//   }

//   @override
//   void willPresentPaywall(PaywallInfo paywallInfo) {
//     printSubscriptionStatus();
//     print('willPresentPaywall: $paywallInfo');
//   }

//   Future<void> printSubscriptionStatus() async {
//     final status = await Superwall.shared.getSubscriptionStatus();
//     final description = await status.description;

//     print('Status: $description');
//   }
// }
