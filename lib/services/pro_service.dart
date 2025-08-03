
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'trial_service.dart';

class ProService {
  static bool isPro = false;
  // Returns true if user is Pro or trial is active
  static Future<bool> isPremium() async {
    if (isPro) return true;
    return await TrialService.isTrialActive();
  }
  static const String _proProductId = 'mindmate_pro';
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static Future<void> init() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;
    _subscription?.cancel();
    _subscription = InAppPurchase.instance.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.productID == _proProductId && purchase.status == PurchaseStatus.purchased) {
          isPro = true;
        }
      }
    });
    await InAppPurchase.instance.restorePurchases();
  }

  static Future<void> buyPro() async {
    final details = await _getProductDetails();
    final purchaseParam = PurchaseParam(productDetails: details);
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static Future<ProductDetails> _getProductDetails() async {
    final response = await InAppPurchase.instance.queryProductDetails({_proProductId});
    return response.productDetails.first;
  }

  static void unlockPro() {
    isPro = true;
  }

  static void dispose() {
    _subscription?.cancel();
  }
}