import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../services/billing_service.dart';
import '../l10n/tr.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final billing = context.watch<BillingService>();
    final monthly = billing.product(BillingService.monthlyId);
    final yearly = billing.product(BillingService.yearlyId);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, size: 72, color: Color(0xFFFFD700)),
                      const SizedBox(height: 12),
                      Text(
                        'Cədvəl Premium',
                        style: poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sadə planlama. Güclü nəticə.\nPremium — əsasımızdır.',
                        textAlign: TextAlign.center,
                        style: poppins(color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Free vs Premium comparison
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _compareRow('Plan sayı', '7', 'Limitsiz'),
                            const Divider(color: Colors.white24),
                            _compareRow('Kateqoriya', '4', 'Limitsiz'),
                            const Divider(color: Colors.white24),
                            _compareRow('Təkmil statistika', 'Əsas', 'Tam'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _feature(tr(context, 'Limitsiz plan və tapşırıq', 'Unlimited plans and tasks')),
                      _feature(tr(context, 'Bütün kateqoriyalar', 'All categories')),
                      _feature(tr(context, 'Daha ətraflı statistika', 'Advanced statistics')),
                      _feature(tr(context, 'Həftəlik təkrarlanan dərslər', 'Weekly repeating lessons')),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              if (service.isPremium)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      '✓ ${tr(context, 'Premium aktivdir', 'Premium is active')}',
                      textAlign: TextAlign.center,
                      style: poppins(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      // Simple pricing cards
                      Row(
                        children: [
                          Expanded(
                            child: _priceCard(
                              context,
                              title: tr(context, 'Aylıq', 'Monthly'),
                              price: monthly?.price ?? '2.99 ₼',
                              onTap: billing.available && monthly != null
                                  ? () => billing.buy(BillingService.monthlyId)
                                  : () => _missing(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _priceCard(
                              context,
                              title: tr(context, 'İllik', 'Yearly'),
                              price: yearly?.price ?? '19.99 ₼',
                              badge: tr(context, 'Populyar', 'Popular'),
                              onTap: billing.available && yearly != null
                                  ? () => billing.buy(BillingService.yearlyId)
                                  : () => _missing(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        billing.loading
                            ? tr(context, 'Google Play yoxlanılır…', 'Checking Google Play…')
                            : billing.available
                                ? tr(
                                    context,
                                    'Ödəniş Google Play ilə aparılır. Kart məlumatı tətbiqə gəlmir.',
                                    'Payment goes through Google Play. Card details never reach the app.',
                                  )
                                : tr(
                                    context,
                                    'Bu qurğuda Google Play ödənişi yoxdur. Premium yalnız Play Store versiyasında açılır.',
                                    'Google Play billing is not available on this device. Premium unlocks only from the Play Store build.',
                                  ),
                        textAlign: TextAlign.center,
                        style: poppins(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      TextButton(
                        onPressed: billing.available ? billing.restore : null,
                        child: Text(
                          tr(context, 'Satınalmanı bərpa et', 'Restore purchase'),
                          style: poppins(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _missing(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          trRead(
            context,
            'Play Console-da cedvel_premium_monthly və cedvel_premium_yearly məhsulları yaradın.',
            'Create cedvel_premium_monthly and cedvel_premium_yearly in Play Console.',
          ),
        ),
      ),
    );
  }

  Widget _compareRow(String label, String free, String pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: poppins(color: Colors.white70, fontSize: 13)),
          ),
          Expanded(
            child: Text(free, textAlign: TextAlign.center, style: poppins(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              pro,
              textAlign: TextAlign.center,
              style: poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00B894), size: 20),
          const SizedBox(width: 10),
          Text(text, style: poppins(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _priceCard(
    BuildContext context, {
    required String title,
    required String price,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: badge != null ? const Color(0xFFFFD700) : Colors.white24,
            ),
          ),
          child: Column(
            children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              Text(title, style: poppins(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                price,
                style: poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
