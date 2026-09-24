# Cədvəl – Tam hazırlıq və Play Store

## A) APK çıxarmaq (5 dəqiqə)

```bash
unzip CedvelApp.zip && cd CedvelApp
flutter create . --project-name cedvel --org com.nibrascode
flutter pub get
flutter run
flutter build apk --release
```

APK yolu: `build/app/outputs/flutter-apk/app-release.apk`

> `flutter create .` yalnız çatışmayan platform fayllarını (gradlew və s.) tamamlayır. `lib/` silinmir.

## B) Play Store AAB (imzalı)

```bash
keytool -genkey -v -keystore nibras-cedvel.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cedvel
cp android/key.properties.example android/key.properties
# key.properties içini doldur
flutter build appbundle --release
```

## C) Play Console

1. App adı: **Cədvəl – Plan & Cədvəl**
2. Təsvirlər → `STORE_LISTING.md`
3. Privacy Policy URL → `privacy_policy.md` public link
4. Data safety → **No data collected**
5. Feature Graphic 1024×500
6. Screenshot-lar
7. AAB yüklə → Review

Package: `com.nibrascode.cedvel`
