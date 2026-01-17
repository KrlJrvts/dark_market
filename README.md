# Dark Market

> When eBay is not enough

A modern auction marketplace application built with Flutter and Firebase.

## Features

- **User Authentication** - Secure login and registration with Firebase Auth
- **Auction Management** - Create, view, and browse auction listings
- **Real-time Updates** - Live auction data synced with Cloud Firestore
- **Image Upload** - Upload and store auction images with Firebase Storage
- **User Profiles** - Personal profile management
- **Responsive UI** - Clean, modern interface with Google Fonts

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod 2.6
- **Navigation**: GoRouter 17.0
- **Backend**: Firebase (Auth, Firestore, Storage)
- **UI**: Material Design with custom theming

## Project Structure

```
lib/
├── data/          # Data models and repositories
├── providers/     # Riverpod state providers
├── theme/         # App theming and styles
└── ui/            # User interface
    ├── screens/   # App screens
    └── widgets/   # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Firebase account and project setup
- Dart 3.9.2 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd dark_market
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `firebase_options.dart` with your Firebase configuration

4. Generate Riverpod code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## Development

### Code Generation

This project uses code generation for Riverpod providers. When you make changes to annotated providers, run:

```bash
flutter pub run build_runner watch
```

### Project Documentation

- [Riverpod Migration Guide](RIVERPOD_MIGRATION_GUIDE.md)
- [Flutter Build Guide](dark_market_flutter_beginner_build_guide_step_by_step_copy_paste_code.md)

## License

This project is private and not published to pub.dev.,