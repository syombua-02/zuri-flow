# Zuri Flow

Zuri Flow is a Flutter app for tracking workouts, diet, and overall health progress, with Firebase-backed authentication and data sync.

## Features

- Email/password and Google sign-in (Firebase Auth), with email verification
- Onboarding flow to capture user profile data
- Personalized diet and workout recommendations
- Progress tracking dashboard
- Cloud Firestore for persisting user, workout, and diet data

## Tech Stack

- [Flutter](https://flutter.dev/) (Dart SDK ^3.11.3)
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`
- `google_sign_in` for Google authentication
- `image_picker`, `url_launcher`, `intl`

## Project Structure

```
lib/
  models/        # Data models (user, workout, diet plan)
  screens/       # App screens (auth, onboarding, dashboard, recommendations, etc.)
  services/      # Firebase, auth, notification, and recommendation logic
  main.dart      # App entry point
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- A Firebase project with Authentication (Email/Password + Google) and Cloud Firestore enabled
- Platform-specific Firebase config files in place (`google-services.json` for Android, `GoogleService-Info.plist` for iOS), and `lib/firebase_options.dart` generated via `flutterfire configure`

### Setup

```bash
flutter pub get
flutter run
```

### Useful Commands

```bash
flutter analyze     # static analysis / lints
flutter test        # run tests
flutter build apk    # build an Android release
```

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [FlutterFire documentation](https://firebase.flutter.dev/)
