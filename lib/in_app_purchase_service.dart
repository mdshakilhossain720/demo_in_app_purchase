import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  InAppPurchaseService._privateConstructor();
  static InAppPurchaseService instance =
      InAppPurchaseService._privateConstructor();
  ValueNotifier<List<ProductDetails>> productsNotifier = ValueNotifier([]);
  ValueNotifier<Set<String>> purchasedProductIds = ValueNotifier(
    {},
  ); // ✅ Track purchased products

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false; // Checks if in-app purchases are available

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      getProducts();
      listenToPurchaseUpdates();
    } else {
      print("In-app purchases not available");
    }
  }

  Future<void> getProducts() async {
    Set<String> kIds = Platform.isAndroid
        ? <String>{
            '', //place weekly id for android
            '', //place monthly id for android
            '', //place yearly id for android
          }
        : <String>{
            '', //place weekly id for ios
            '', //place monthly id for ios
            '', //place yearly id for ios
          };
    final ProductDetailsResponse response = await _iap.queryProductDetails(
      kIds,
    );
    if (response.notFoundIDs.isNotEmpty) {
      print("Products not found");
      return;
    }
    productsNotifier.value = response.productDetails;
  }

  Future<void> buySubscription(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      print('PlatForm Exception: $e');
    }
  }

  void listenToPurchaseUpdates() {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _iap.completePurchase(purchase);
          purchasedProductIds.value = {
            ...purchasedProductIds.value,
            purchase.productID,
          };
        } else if (purchase.status == PurchaseStatus.error) {
          print("Purchase error: ${purchase.error}");
        } else if (purchase.status == PurchaseStatus.canceled) {
          _iap.completePurchase(purchase);
          print("Purchase canceled: ${purchase.error}");
        } else if (purchase.status == PurchaseStatus.pending) {
          print('Purchased status : Pending');
        } else if (purchase.status == PurchaseStatus.restored) {
          print('Purchased status : Restored');
        }
      }
    });
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
