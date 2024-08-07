import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart' hide LogLevel;

import 'package:translator/features/payment/controller/payment_api_controller.dart';
import 'package:translator/features/translation/views/translation.dart';

class RCPurchaseController extends PurchaseController {
  //BuildContext context = paymentKey.currentState;
  final Paymenthandelcontroller paymenthandelcontroller =
      Get.put(Paymenthandelcontroller());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // MARK: Configure and sync subscription Status
  Future<void> syncSubscriptionStatus() async {
    // Configure RevenueCat
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = Platform.isIOS
        ? PurchasesConfiguration("appl_svdGLBsoyvNKsRHvmEtJiKFnQFr")
        : PurchasesConfiguration("MY_ANDROID_API_KEY");
    await Purchases.configure(configuration);

    // Listen for changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      // Gets called whenever new CustomerInfo is available
      bool hasActiveEntitlementOrSubscription =
          customerInfo.hasActiveEntitlementOrSubscription();
      if (hasActiveEntitlementOrSubscription) {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.active);
      } else {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.inactive);
      }

      // Extract user ID or customer ID
      String userId = customerInfo.originalAppUserId;
      print("User ID: $userId");
      await analytics.logEvent(name: 'customer_info', parameters: {
        'rc_user_id': '$userId',
        'activeSubscription':'$hasActiveEntitlementOrSubscription',
        'configuration':Platform.isIOS?'IOS:- appl_svdGLBsoyvNKsRHvmEtJiKFnQFr':'android:- empty',
      });

      // Sync user ID with Superwall if needed
      // Superwall.shared.setUserId(userId); // Uncomment if Superwall needs user ID
    });
  }

  @override
  Future<PurchaseResult> purchaseFromAppStore(String productId) async {
    BuildContext? context = paymentKey.currentContext!;
    List<StoreProduct> products =
        await PurchasesAdditions.getAllProducts([productId]);
    StoreProduct? storeProduct = products.firstOrNull;

    if (storeProduct == null) {

      return PurchaseResult.failed(
          "Failed to find store product for $productId");
          
    }

    PurchaseResult purchaseResult = await _purchaseStoreProduct(storeProduct);
    handleUserInfoAfterPurchase();
    paymenthandelcontroller.productID.value = productId;
    print("productId : $productId");
    paymenthandelcontroller.currency.value = storeProduct.currencyCode;
    print("currencyCode : ${storeProduct.currencyCode}");
    paymenthandelcontroller.price.value = storeProduct.price;
    print("price : ${storeProduct.price}");
    // paymenthandelcontroller.showCustomDialog(context, () async {
    //   await paymenthandelcontroller.sendPurchaseDataToServer();
    // });

    return purchaseResult;
  }

  @override
  Future<PurchaseResult> purchaseFromGooglePlay(
      String productId, String? basePlanId, String? offerId) async {
    List<StoreProduct> products =
        await PurchasesAdditions.getAllProducts([productId]);
    String storeProductId = "$productId:$basePlanId";
    StoreProduct? matchingProduct;

    for (final product in products) {
      if (product.identifier == storeProductId) {
        matchingProduct = product;
        break;
      }
    }

    StoreProduct? storeProduct =
        matchingProduct ?? (products.isNotEmpty ? products.first : null);
    if (storeProduct == null) {
      return PurchaseResult.failed("Product not found");
    }

    PurchaseResult purchaseResult;
    switch (storeProduct.productCategory) {
      case ProductCategory.subscription:
        SubscriptionOption? subscriptionOption =
            await _fetchGooglePlaySubscriptionOption(
                storeProduct, basePlanId, offerId);
        if (subscriptionOption == null) {
          return PurchaseResult.failed(
              "Valid subscription option not found for product.");
        }
        purchaseResult = await _purchaseSubscriptionOption(subscriptionOption);
        break;
      case ProductCategory.nonSubscription:
        purchaseResult = await _purchaseStoreProduct(storeProduct);
        break;
      case null:
        purchaseResult =
            PurchaseResult.failed("Unable to determine product category");
        break;
    }
    //_handleUserInfoAfterPurchase();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      // Gets called whenever new CustomerInfo is available
      bool hasActiveEntitlementOrSubscription =
          customerInfo.hasActiveEntitlementOrSubscription();
      if (hasActiveEntitlementOrSubscription) {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.active);
      } else {
        Superwall.shared.setSubscriptionStatus(SubscriptionStatus.inactive);
      }

      // Extract user ID or customer ID
      String userId = customerInfo.originalAppUserId;
      print("User ID: $userId");

      // Sync user ID with Superwall if needed
      // Superwall.shareqd.setUserId(userId); // Uncomment if Superwall needs user ID
    });
    return purchaseResult;
  }

  Future<void> handleUserInfoAfterPurchase() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      String userId = customerInfo.originalAppUserId;
      paymenthandelcontroller.app_user_id.value = userId;

      print("User ID after purchase: $userId");

      // Sync user ID with Superwall if needed
      // Superwall.shared.setUserId(userId); // Uncomment if Superwall needs user ID
    } on PlatformException catch (e) {
      print("Error retrieving customer info: ${e.message}");
    }
  }

  Future<SubscriptionOption?> _fetchGooglePlaySubscriptionOption(
      StoreProduct storeProduct, String? basePlanId, String? offerId) async {
    final subscriptionOptions = storeProduct.subscriptionOptions;
    if (subscriptionOptions != null && subscriptionOptions.isNotEmpty) {
      final subscriptionOptionId =
          _buildSubscriptionOptionId(basePlanId, offerId);
      SubscriptionOption? subscriptionOption;

      for (final option in subscriptionOptions) {
        if (option.id == subscriptionOptionId) {
          subscriptionOption = option;
          break;
        }
      }

      subscriptionOption ??= storeProduct.defaultOption;
      return subscriptionOption;
    }
    return null;
  }

  Future<PurchaseResult> _purchaseSubscriptionOption(
      SubscriptionOption subscriptionOption) async {
    BuildContext? context = paymentKey.currentContext!;
    Future<CustomerInfo> performPurchase() async {
      CustomerInfo customerInfo =
          await Purchases.purchaseSubscriptionOption(subscriptionOption);
      print("customerInfo : $customerInfo");
      return customerInfo;
    }

    PurchaseResult purchaseResult =
        await _handleSharedPurchase(performPurchase);
    paymenthandelcontroller.showCustomDialog(context, () async {
      await paymenthandelcontroller.sendPurchaseDataToServer();
    });
    return purchaseResult;
  }

  Future<PurchaseResult> _purchaseStoreProduct(
      StoreProduct storeProduct) async {
    Future<CustomerInfo> performPurchase() async {
      CustomerInfo customerInfo =
          await Purchases.purchaseStoreProduct(storeProduct);
      return customerInfo;
    }

    PurchaseResult purchaseResult =
        await _handleSharedPurchase(performPurchase);
    print("this is the purchaseResult : ${purchaseResult.bridgeId}");
    return purchaseResult;
  }

  Future<PurchaseResult> _handleSharedPurchase(
      Future<CustomerInfo> Function() performPurchase) async {
    try {
      DateTime purchaseDate = DateTime.now();
      CustomerInfo customerInfo = await performPurchase();

      if (customerInfo.hasActiveEntitlementOrSubscription()) {
        DateTime? latestTransactionPurchaseDate =
            customerInfo.getLatestTransactionPurchaseDate();
        bool isNewPurchase = (latestTransactionPurchaseDate == null);
        bool purchaseHappenedInThePast =
            latestTransactionPurchaseDate?.isBefore(purchaseDate) ?? false;

        if (!isNewPurchase && purchaseHappenedInThePast) {
          return PurchaseResult.restored;
        } else {
          return PurchaseResult.purchased;
        }
      } else {
        return PurchaseResult.failed("No active subscriptions found.");
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return PurchaseResult.pending;
      } else if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      } else {
        return PurchaseResult.failed(
            e.message ?? "Purchase failed in RCPurchaseController");
      }
    }
  }

  @override
  Future<RestorationResult> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      handleUserInfoAfterPurchase();
      return RestorationResult.restored;
    } on PlatformException catch (e) {
      return RestorationResult.failed(
          e.message ?? "Restore failed in RCPurchaseController");
    }
  }
}

String _buildSubscriptionOptionId(String? basePlanId, String? offerId) {
  String result = '';
  if (basePlanId != null) {
    result += basePlanId;
  }
  if (offerId != null) {
    if (basePlanId != null) {
      result += ':';
    }
    result += offerId;
  }
  return result;
}

extension CustomerInfoAdditions on CustomerInfo {
  bool hasActiveEntitlementOrSubscription() {
    return (activeSubscriptions.isNotEmpty || entitlements.active.isNotEmpty);
  }

  DateTime? getLatestTransactionPurchaseDate() {
    Map<String, String?> allPurchaseDates = this.allPurchaseDates;
    if (allPurchaseDates.entries.isEmpty) {
      return null;
    }
    DateTime latestDate = DateTime.fromMillisecondsSinceEpoch(0);
    allPurchaseDates.forEach((key, value) {
      DateTime date = DateTime.parse(value!);
      if (date.isAfter(latestDate)) {
        latestDate = date;
      }
    });
    return latestDate;
  }
}

extension PurchasesAdditions on Purchases {
  static Future<List<StoreProduct>> getAllProducts(
      List<String> productIdentifiers) async {
    final subscriptionProducts = await Purchases.getProducts(productIdentifiers,
        productCategory: ProductCategory.subscription);
    final nonSubscriptionProducts = await Purchases.getProducts(
        productIdentifiers,
        productCategory: ProductCategory.nonSubscription);
    final combinedProducts = [
      ...subscriptionProducts,
      ...nonSubscriptionProducts
    ];
    return combinedProducts;
  }
}
