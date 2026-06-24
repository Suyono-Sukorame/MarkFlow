# MarkFlow Flutter - Quick Start Guide

## 🚀 Menjalankan Aplikasi dalam 5 Menit

### Prerequisites
Pastikan Anda sudah install:
- ✅ Flutter SDK 3.24+
- ✅ Dart 3.9+
- ✅ Xcode (untuk iOS) atau Android Studio (untuk Android)

### Step 1: Install Dependencies
```bash
cd markflow
flutter pub get
```

### Step 2: Check Available Devices
```bash
flutter devices
```

### Step 3: Run the App

#### Option A: macOS Desktop
```bash
flutter run -d macos
```

#### Option B: iOS Simulator
```bash
# List available simulators
flutter emulators

# Launch specific simulator
flutter emulators --launch <simulator-id>

# Run app
flutter run -d "iPhone 15 Pro"
```

#### Option C: Android Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run -d emulator-5554
```

#### Option D: Chrome (Web)
```bash
flutter run -d chrome
```

### Step 4: Explore the App! 🎉

## 📱 Fitur yang Bisa Dicoba

1. **Dashboard** - Lihat overview file dan statistik
2. **Create New File** - Tap tombol FAB (+) untuk membuat file baru
3. **Edit Markdown** - Buka file, lalu tap icon edit
4. **Live Preview** - Di editor, switch antara Editor dan Preview tab
5. **Search** - Cari file berdasarkan nama, konten, atau tags
6. **Favorite** - Tap icon star untuk menandai file favorit
7. **File Explorer** - Browse folder dan organize file
8. **Settings** - Reset database ke data default

## 🔥 Hot Reload

Saat aplikasi berjalan, Anda bisa:
- Tekan `r` untuk hot reload (reload perubahan code tanpa restart)
- Tekan `R` untuk hot restart (restart aplikasi)
- Tekan `q` untuk quit

## 🛠️ Build for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Kemudian open dengan Xcode untuk archive dan upload
```

### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/markflow_flutter.app
```

## 🐛 Troubleshooting

### Issue: CocoaPods not installed
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### Issue: Android licenses not accepted
```bash
flutter doctor --android-licenses
```

### Issue: Xcode command line tools
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Issue: Build failed
```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run
```

## 📚 Project Structure

```
lib/
├── main.dart              # Entry point
├── models/                # Data models
├── providers/             # State management (Provider)
├── screens/               # UI screens
├── data/                  # Initial data
└── widgets/               # Reusable widgets (future)
```

## 🎯 Development Tips

1. **Use Hot Reload** - Save file untuk otomatis reload UI
2. **Flutter DevTools** - Debug performance dan state
3. **Widget Inspector** - Lihat widget tree secara visual
4. **Provider DevTools** - Monitor state changes

## 📖 Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Markdown](https://pub.dev/packages/flutter_markdown)

## 💡 Next Steps

1. Explore kode di `lib/screens/` untuk melihat implementasi
2. Coba modifikasi theme di `lib/main.dart`
3. Tambahkan fitur baru atau customize UI
4. Deploy ke device fisik untuk testing performa

---

**Happy Coding! 🚀**

Jika ada pertanyaan, silakan buka issue atau hubungi suyono@aqj.or.id
