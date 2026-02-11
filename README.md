# SplitStack

A Flutter Flow application for managing split expenses.

## Prerequisites

- Flutter SDK (stable channel) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Xcode (for iOS development on macOS)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies) - `sudo gem install cocoapods`

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/SplitStack-Git/splitstack-backend.git
cd splitstack-backend
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install iOS Dependencies (macOS only)
```bash
cd ios
pod install
cd ..
```

### 4. Verify Setup
```bash
flutter doctor
```

Make sure all required tools are installed and configured.

### 5. Firebase Configuration

The app uses Firebase for authentication and backend services. Firebase configuration files are already included:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Web**: Configured in `lib/backend/firebase/firebase_config.dart`

### 6. Run the App

#### Run on iOS Simulator/Device
```bash
flutter run -d ios
```

#### Run on Android Emulator/Device
```bash
flutter run -d android
```

#### Run on Web
```bash
flutter run -d chrome
```

#### Run on macOS
```bash
flutter run -d macos
```

## Project Structure

```
lib/
├── auth/              # Authentication logic
├── backend/           # Backend services and Firebase configuration
├── components/        # Reusable UI components
├── custom_code/       # Custom code implementations
├── flutter_flow/      # Flutter Flow generated code
├── pages/             # App pages/screens
├── app_state.dart     # Global app state
└── main.dart          # App entry point
```

## Features

- Firebase Authentication (Email, Google Sign-In, Apple Sign-In)
- Firestore Database
- Payment integration
- Expense splitting functionality

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### iOS Build Issues
If you encounter CocoaPods issues:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Android License Issues
If Android licenses are not accepted:
```bash
flutter doctor --android-licenses
```

### Clean Build
If you encounter build issues, try cleaning:
```bash
flutter clean
flutter pub get
```

## Notes

- FlutterFlow projects are built to run on the Flutter _stable_ release
- Make sure you're using Flutter stable channel: `flutter channel stable`
