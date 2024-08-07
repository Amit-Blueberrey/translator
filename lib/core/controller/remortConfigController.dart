import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:translator/data/dbhelper.dart';

class RemoteConfigController extends GetxController {
  static RemoteConfigController get to => Get.put(RemoteConfigController());

  // Reactive variable for paywall as a string
  RxString paywall = ''.obs;
  RxString paywall_2nd = ''.obs;

  FirebaseRemoteConfig? _remoteConfig;

  @override
  void onInit() {
    super.onInit();
    // initializeRemoteConfig();
  }

  Future<void> initializeRemoteConfig() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Set default values
    await _remoteConfig?.setDefaults(<String, dynamic>{
      'paywall': '${TranslationDb.paywallOld}', // Default value
    });

    // Set config settings with minimumFetchInterval to zero for testing purposes
    await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration(minutes: 1), // For testing: always fetch fresh data
    ));

    try {
      // Fetch and activate values
      bool updated = await _remoteConfig?.fetchAndActivate() ?? false;

      if (updated) {
        // Update the paywall value
        paywall.value = _remoteConfig!.getString('paywall');
        paywall_2nd.value = _remoteConfig!.getString('paywall');
        // paywall_lander
        TranslationDb.paywallOld = paywall.value;
        print('Paywall fetched: ${paywall.value}');
      } else {
        print('No new values available or fetch failed.');
      }
    } catch (e) {
      print('Error fetching remote config: $e');
    }

    // Use the fetched value or fallback
    if (paywall.value.isEmpty) {
      paywall.value = TranslationDb.paywallOld;
      print('Using default paywall value: ${TranslationDb.paywallOld}');
    }
  }
}
