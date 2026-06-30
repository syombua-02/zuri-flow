# Zuri Flow

Zuri Flow is a premium Flutter mobile application that delivers personalized Pilates and nutrition recommendations, and tracks user progress using Firebase Authentication and Cloud Firestore.

The application focuses on creating a calm, feminine, and beginner-friendly wellness experience rather than a traditional fitness tracker.

## Features

- Email/password and Google sign-in (Firebase Auth), with email verification
- Onboarding flow to capture user profile data
- Personalized Diet recommendations
- Personalized Pilates and Yoga recommendations
- Progress tracking dashboard
- Cloud Firestore for secure user profile, recommendation, and progress data storage

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

## Project Goals

- Promote sustainable wellness habits
- Deliver personalized fitness recommendations
- Track body progress over time
- Encourage consistency through an elegant user experience

## Recommendation Engine

Recommendations are generated using user profile information:

- Fitness goal
- Height
- Weight
- Activity level
- Progress history
- Wellness notes
  
These inputs are processed to generate personalized Pilates workouts and nutrition recommendations tailored to each user's wellness goals

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
## Planned Features

- Weekly wellness reports
- Push notifications
- Water intake tracking
- Branded email notifications
  
## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [FlutterFire documentation](https://firebase.flutter.dev/)
## Developer

Christine Syombua

Bachelor of Science in Software Development

KCA University

GitHub: @syombua-02

## License
This project was developed for academic and portfolio purposes.
