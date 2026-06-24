<div align="center">

# MarkFlow

<img src="assets/logo.png" alt="MarkFlow Logo" width="120" />

Material Design 3 Markdown Editor, File Explorer, Reader, dan Dashboard untuk Android & iOS.

Aplikasi mobile yang cantik dan produktif untuk menulis, mengelola, dan mengorganisasi dokumen Markdown dengan mudah.

</div>

---

## ✨ Fitur

### 📝 Editor & Reader
- **Editor Markdown** dengan syntax highlighting
- **Live Preview** dengan rendering markdown lengkap
- **Markdown Reader** untuk membaca dokumen dengan nyaman
- Support **heading, bold, italic, code blocks, lists, links, images**

### 📂 File Management
- **File Explorer** dengan navigasi folder yang intuitif
- **Breadcrumb navigation** untuk navigasi cepat
- **Import folder** dari storage internal (recursive)
- **Import multiple files** atau single file markdown
- **Create, rename, delete** file dan folder
- **Favorites** untuk akses cepat ke dokumen penting

### 🎨 Design
- **Material Design 3** implementation
- **Dynamic Color** support (Material You)
- **Dark mode** dan light mode otomatis
- **Beautiful card-based UI** dengan smooth animations
- **Custom app icon** hasil generate dari logo

### 💾 Storage
- **Local storage** dengan SharedPreferences
- **Auto-save** saat editing
- **Persistent data** - data tidak hilang saat app ditutup
- **Import from device** - baca file markdown dari storage

---

## 📱 Download APK

APK tersedia di folder `release/apk/`:

| File | Size | Deskripsi |
|------|------|-----------|
| `app-arm64-release.apk` | ~20MB | **Recommended** untuk kebanyakan HP modern (64-bit) |
| `app-armv7-release.apk` | ~18MB | Untuk HP lama (32-bit) |
| `app-x86_64-release.apk` | ~21MB | Untuk emulator x86 |
| `app-release.apk` | ~52MB | Universal APK (semua architecture) |

Setiap APK memiliki file `.sha256` untuk verifikasi integrity.

---

## 🚀 Development

### Prasyarat

- Flutter SDK 3.9.2 atau lebih baru
- Dart SDK
- Android Studio / Xcode (untuk iOS)
- Android SDK (untuk Android development)

### Instalasi Dependencies

```bash
flutter pub get
```

### Menjalankan Aplikasi

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### macOS
```bash
flutter run -d macos
```

#### Chrome/Web
```bash
flutter run -d chrome
```

---

## 🛠️ Build Release

### Build APK (Universal)
```bash
flutter build apk --release
```

### Build APK (Per Architecture - Recommended)
```bash
flutter build apk --split-per-abi --release
```

### Build App Bundle (untuk Play Store)
```bash
flutter build appbundle --release
```

### Build iOS
```bash
flutter build ios --release
```

---

## 📁 Struktur Proyek

```text
lib/
├── main.dart                    # Entry point aplikasi
├── models/                      # Data models
│   ├── folder.dart              # Model folder
│   └── markdown_file.dart       # Model markdown file
├── providers/                   # State management (Provider)
│   └── app_provider.dart        # Main app state
├── screens/                     # UI Screens
│   ├── dashboard_screen.dart    # Dashboard utama
│   ├── file_explorer_screen.dart # File explorer
│   ├── editor_screen.dart       # Markdown editor
│   ├── reader_screen.dart       # Markdown reader
│   ├── search_screen.dart       # Search files
│   ├── favorites_screen.dart    # Favorite files
│   └── settings_screen.dart     # Settings
├── data/                        # Initial data
│   └── initial_data.dart        # Sample data
└── assets/                      # Assets
    └── logo.png                 # App logo

android/                         # Android specific
ios/                            # iOS specific
macos/                          # macOS specific
windows/                        # Windows specific
```

---

## 🎯 Fitur Import Markdown

Aplikasi mendukung 3 cara import file markdown dari device:

### 1. Import Folder
- Pilih folder dari storage internal
- Semua file `.md` dan `.markdown` akan di-import
- Support **recursive** - subfolder juga akan di-import
- Struktur folder akan dipertahankan

### 2. Import Multiple Files
- Pilih multiple file markdown sekaligus
- Semua file akan masuk ke folder yang sedang aktif

### 3. Import Single File
- Import satu file markdown
- File akan masuk ke folder yang sedang aktif

### Permissions Required
- `READ_EXTERNAL_STORAGE` (Android < 13)
- `MANAGE_EXTERNAL_STORAGE` (Android 11+)

Permission akan di-request otomatis saat pertama kali import.

---

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.2              # State management
  shared_preferences: ^2.3.3    # Local storage
  flutter_markdown: ^0.7.4      # Markdown rendering
  markdown: ^7.2.2              # Markdown parser
  file_picker: ^8.1.4           # File picker
  permission_handler: ^11.3.1   # Permission handling
  path: ^1.9.0                  # Path utilities
  uuid: ^4.5.1                  # UUID generator
  intl: ^0.20.1                 # Internationalization
```

---

## 🔐 Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to import markdown files</string>
```

---

## 🎨 App Icon

App icon di-generate menggunakan `flutter_launcher_icons`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo.png"
```

Jalankan:
```bash
flutter pub run flutter_launcher_icons
```

---

## 📄 Lisensi

MIT License

---

<div align="center">

**Made with ❤️ using Flutter**

Untuk Markdown enthusiasts yang ingin produktif di mobile

</div>