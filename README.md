# Aquarium Simulator

A Flutter and Flame Android aquarium simulator with a pure Dart simulation
engine and a Flutter HUD overlay.

## Run on Android

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Build a release APK with:

```sh
flutter build apk --release
```

The Android Gradle project is already included under `android/`.
