# Google Play Store Yükləmə Checklist – Cədvəl

## ✅ Artıq hazır olanlar

- [x] Tətbiq adı və təsvirlər → `STORE_LISTING.md`
- [x] Məxfilik Siyasəti (Privacy Policy) → `privacy_policy.md` + tətbiq daxilində ekran
- [x] App icon
- [x] Screenshot materialları
- [x] Data safety cavabları (heç nə toplanmır)
- [x] Content rating üçün məlumat (Everyone / 3+)

---

## 🔲 Sənin etməli olduğun işlər

### 1. Developer hesabı
- [ ] Google Play Console hesabı aç (birdəfəlik $25)
- [ ] Developer adı: **Nibras Code**

### 2. Məxfilik Siyasəti linki
Play Console **Privacy Policy** sahəsinə link lazımdır.
Seçimlər:
- GitHub Pages ilə `privacy_policy.md`-ni HTML-ə çevirib host et
- Və ya sadə Google Sites / Notion public page yarat
- Və ya öz domainində yerləşdir

### 3. Feature Graphic (1024 × 500 px)
- [x] `assets/images/feature_graphic.png`

### 4. Screenshot-lar
- [ ] Telefon ekran görüntüləri (ən azı 2–8 ədəd)
- Mövcud collage-dan kəsib ayrı-ayrı screenshot etmək olar
- 16:9 və ya 9:16

### 5. APK / AAB
```bash
flutter build appbundle --release   # Play Store üçün tövsiyə olunan
# və ya
flutter build apk --release
```

### 6. Play Console formları
- [ ] Store listing (ad, təsvir, screenshot)
- [ ] Data safety → **No data collected**
- [ ] Content rating questionnaire
- [ ] Target audience & content
- [ ] News app? → No
- [ ] COVID-19? → No

### 7. İmza (Signing)
- [x] Keystore hazırdır: `android/nibras-cedvel.jks`
- [x] `android/key.properties` doldurulub
- Parol: `android/KEYSTORE_SECRET.txt` — itirməyin, GitHub-a atmayın

---

## Vacib linklər

- Play Console: https://play.google.com/console
- Data safety help: https://support.google.com/googleplay/android-developer/answer/10787469
- Privacy Policy generator (əlavə): https://app-privacy-policy-generator.firebaseapp.com/

---

**Nibras Code** – Hər şey hazırdır, sadəcə yüklə!
