# Momo Timer Setup Guide

## Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or Xcode for mobile development
- Firebase account

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/dingcodingco/momo_timer.git
cd momo_timer
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Copy the example environment file and configure it with your values:
```bash
cp .env.example .env
```

Edit `.env` with your actual configuration values.

### 4. Firebase Setup

#### Android
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing one
3. Add an Android app with package name: `com.dingcodingco.momotimer`
4. Download `google-services.json`
5. Place it in `android/app/` directory

#### iOS
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory
4. Run `cd ios && pod install`

### 5. Generate Firebase Options
```bash
flutterfire configure
```

This will generate `lib/firebase_options.dart` file.

### 6. Build and Run

#### Debug Mode
```bash
flutter run
```

#### Release Build
Android:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## Important Security Notes

⚠️ **Never commit these files to version control:**
- `google-services.json`
- `GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `.env`
- Any keystore files (*.jks, *.keystore)

These files contain sensitive API keys and should be obtained individually by each developer.

## Troubleshooting

### Common Issues

1. **Pod install fails on iOS**
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

2. **Build fails with Firebase errors**
   - Ensure all Firebase configuration files are in place
   - Check that package names match in Firebase Console

3. **Android build fails**
   - Check minimum SDK version in `android/app/build.gradle`
   - Ensure gradle version is compatible

## Contributing
Please read the contributing guidelines before submitting pull requests.

## License
This project is licensed under the MIT License.