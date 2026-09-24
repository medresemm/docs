# Cədvəl — Android APK

Bu Flutter Android layihəsidir (veb deyil).

## Tələblər
- Flutter 3.24+ (Flutter 3.32 ilə yoxlanılıb)
- Android SDK platform 34
- Java 17

## APK yığmaq

```bash
unzip Cedvel-Android.zip
cd Cedvel-Android

# Əgər android/ gradle tam deyilsə:
flutter create . --project-name cedvel --org com.nibrascode --platforms=android

flutter pub get
flutter run
flutter build apk --release
```

Nəticə: `build/app/outputs/flutter-apk/app-release.apk`

## GitHub Actions

`.github/workflows/android-apk.yml` workflow-u `workflow_dispatch` ilə və ya
`Cedvel-Android` qovluğuna dəyişiklik göndəriləndə release APK-ni yığır.
Build tamamlandıqdan sonra GitHub Actions səhifəsində `cedvel-release-apk`
artifact-ini endirin.

## Bu versiyada
- Demo plan yoxdur
- Cədvəl şəbəkəsi: günlər solda, saatlar yuxarıda
- Həftənin başlanğıcını seçmək
- Dərs xəbərdarlığı (bildiriş + səs)
- Planı redaktə etmək
- Real statistika
- Məxfilik siyasəti
- Giriş nümunə adı: Rəşad
- Cədvəli şəkil kimi qalereyaya yükləmək / paylaşmaq

Nibras Code © 2026
