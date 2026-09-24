import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'plan_service.dart';

/// Google Play subscriptions. Create these product IDs in Play Console.
class BillingService extends ChangeNotifier {
  BillingService(this._plans);

  static const monthlyId = 'cedvel_premium_monthly';
  static const yearlyId = 'cedvel_premium_yearly';

  final PlanService _plans;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool available = false;
  bool loading = true;
  bool buying = false;
  String? error;
  List<ProductDetails> products = [];

  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) {
        error = e.toString();
        buying = false;
        notifyListeners();
      },
    );
    try {
      available = await _iap.isAvailable();
      if (available) {
        final response = await _iap.queryProductDetails({monthlyId, yearlyId});
        products = response.productDetails.toList()
          ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        error = response.error?.message;
        await _iap.restorePurchases();
      }
    } catch (e) {
      available = false;
      error = e.toString();
      debugPrint('billing init: $e');
    }
    loading = false;
    notifyListeners();
  }

  ProductDetails? product(String id) {
    for (final item in products) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> buy(String id) async {
    final details = product(id);
    if (!available || details == null) {
      error = 'unavailable';
      notifyListeners();
      return;
    }
    buying = true;
    error = null;
    notifyListeners();
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
      if (!started) {
        buying = false;
        error = 'unavailable';
        notifyListeners();
      }
    } catch (e) {
      buying = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (!available) return;
    error = null;
    notifyListeners();
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final mine = purchase.productID == monthlyId || purchase.productID == yearlyId;
      if (mine &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        _plans.setPremium(true);
      }
      if (purchase.status == PurchaseStatus.error) {
        error = purchase.error?.message ?? 'error';
      }
      if (purchase.status != PurchaseStatus.pending) {
        buying = false;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
