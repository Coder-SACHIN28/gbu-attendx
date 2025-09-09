# 🎯 GBU AttendX - Smart Attendance Management System

A comprehensive, enterprise-grade Flutter application for managing attendance at Gautam Buddha University (GBU).

## ✨ Features

- **🔐 Secure Authentication** - Firebase Auth with GBU email verification
- **📍 Location-Based Attendance** - GPS validation with campus geo-fencing  
- **📸 Biometric Verification** - Advanced face recognition and image processing
- **⏰ Real-time Tracking** - Live attendance monitoring and notifications
- **📊 Analytics Dashboard** - Interactive charts and attendance insights
- **👥 Multi-Role Support** - Student, Teacher, and Admin interfaces
- **🔒 Enterprise Security** - Advanced Firestore rules and data protection
- **📱 Modern UI/UX** - Material Design 3 with smooth animations

## 🏗️ Architecture

- **Frontend**: Flutter with Provider state management
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **Real-time**: Firestore streams and Firebase Cloud Messaging
- **Security**: Multi-layer validation and encrypted data storage

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase CLI
- Android Studio / Xcode
- Firebase project with the following services enabled:
  - Authentication
  - Firestore Database
  - Cloud Functions
  - Cloud Storage
  - Cloud Messaging

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gbu_attendx_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase project
   firebase init
   
   # Deploy Firestore rules and indexes
   firebase deploy --only firestore:rules,firestore:indexes
   ```

4. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Create `lib/firebase_options.dart` using Firebase CLI

5. **Update Configuration**
   - Modify campus coordinates in `lib/utils/constants.dart`
   - Configure your university-specific settings

6. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Progressive Web App)

## 🔧 Configuration

### Campus Location Setup
Update the campus coordinates in `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const double campusLatitude = 28.xxxx;  // Your campus latitude
  static const double campusLongitude = 77.xxxx; // Your campus longitude
  static const double allowedRadius = 500.0;     // Radius in meters
}
```

### Firebase Project Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication with Email/Password
3. Create Firestore database
4. Set up Firebase Functions for backend logic
5. Configure Cloud Storage for image uploads

## 🏫 University Customization

This app is specifically designed for **Gautam Buddha University** but can be adapted for other institutions by:

1. Updating email validation patterns in authentication
2. Modifying campus coordinates and geo-fencing rules
3. Customizing branding and color schemes
4. Adapting timetable and schedule structures

## 📋 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── student/             # Student dashboard & features
│   └── teacher/             # Teacher dashboard & features
├── services/                # Backend services
├── providers/               # State management
├── utils/                   # Utilities and constants
└── widgets/                 # Reusable UI components
```

## 🔐 Security Features

- **Email Verification**: Mandatory GBU email verification
- **Location Validation**: GPS-based campus boundary checking
- **Biometric Verification**: Face recognition for attendance
- **Time-based Codes**: Expiring verification codes
- **Role-based Access**: Different permissions for users
- **Audit Trail**: Comprehensive logging and monitoring

## 📊 Analytics & Reporting

- Real-time attendance statistics
- Individual student progress tracking
- Class-wise attendance reports
- Exportable data in multiple formats
- Interactive charts and visualizations

## 🛠️ Development & Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Building for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- 📧 Email: sachinkumar.official28@gmail.com
- 📱 GitHub Issues: [Create an issue](../../issues)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Gautam Buddha University for requirements and testing
- Firebase team for excellent backend services
- Flutter community for amazing packages and support

---

**Made with ❤️ for Gautam Buddha University**
