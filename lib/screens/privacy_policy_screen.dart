import 'package:flutter/material.dart';
import '../theme/poppins.dart';
import '../l10n/tr.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Məxfilik Siyasəti', 'Privacy Policy'), style: poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cədvəl – Məxfilik Siyasəti',
              style: poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Son yenilənmə: 19 Sentyabr 2026',
              style: poppins(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _section(
              '1. Giriş',
              'Cədvəl (Nibras Code) sizin məxfiliyinizə hörmət edir. Tətbiq lokal işləyir. Ad, plan, cədvəl və bildiriş ayarlarınız bu cihazın yaddaşında qalır və serverə göndərilmir.',
            ),
            _section(
              '2. Hansı məlumatları saxlayırıq?',
              'Yalnız sizin daxil etdiyiniz məlumatlar: ad, dərs və planlar, kateqoriyalar, həftənin başlanğıcı, tema, xəbərdarlıq vaxtı.\n\nE-poçt, telefon, yer, kontakt və ödəniş məlumatı toplanmır.',
            ),
            _section(
              '3. Bildirişlər',
              'Dərs xəbərdarlığı üçün bildiriş icazəsi istəyə bilərik. Bildirişlər yalnız bu cihazda, seçdiyiniz vaxtda göstərilir. Səs eyni cihazda oxunur. Heç bir bildiriş mətni kənara ötürülmür.',
            ),
            _section(
              '4. Məlumatların istifadəsi',
              'Lokal məlumatlar yalnız cədvəli göstərmək, statistika hesablamaq və xəbərdarlıq vermək üçündür.',
            ),
            _section(
              tr(context, '5. Üçüncü tərəflər', '5. Third parties'),
              tr(
                context,
                'Reklam və analitika yoxdur. Planlar serverə getmir. Premium ödənişi Google Play vasitəsilə olur; kart nömrəsi tətbiqə gəlmir.',
                'There are no ads or analytics. Plans never leave the device. Premium is billed by Google Play; card numbers never reach the app.',
              ),
            ),
            _section(
              '6. Məlumatların silinməsi',
              'Planları tətbiq daxilində silə, «Bütün planları sil» ilə hamısını təmizləyə və ya tətbiqi silməklə bütün lokal qeydləri silə bilərsiniz.',
            ),
            _section(
              '7. Uşaqlar',
              'Tətbiq ümumi istifadə üçündür. 13 yaşdan kiçik uşaqların şəxsi məlumatını toplamırıq.',
            ),
            _section(
              '8. Əlaqə',
              'Nibras Code\nSuallar üçün tərtibatçı ilə əlaqə saxlayın.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                'Nibras Code © 2026',
                style: poppins(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
