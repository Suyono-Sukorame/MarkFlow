# MarkFlow Flutter

<div align="center">
<img src="https://img.shields.io/badge/Flutter-3.24+-blue?logo=flutter" alt="Flutter"/>
<img src="https://img.shields.io/badge/Material-3-purple?logo=material-design" alt="Material 3"/>
<img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green" alt="Platform"/>
</div>

## 📱 Tentang Aplikasi

**MarkFlow Flutter** adalah aplikasi mobile markdown editor yang powerful dan indah, menggunakan Material Design 3. Aplikasi ini merupakan migrasi lengkap dari versi React/TypeScript ke Flutter untuk pengalaman mobile yang native dan performa yang lebih baik.

### ✨ Fitur Utama

- 📝 **Markdown Editor** - Editor markdown lengkap dengan syntax highlighting dan preview real-time
- 📂 **File Explorer** - Manajemen file dan folder yang intuitif dengan breadcrumb navigation
- 🔍 **Smart Search** - Pencarian cepat berdasarkan nama file, konten, atau tags
- ⭐ **Favorites** - Tandai file favorit untuk akses cepat
- 📊 **Dashboard** - Statistik dan overview workspace Anda
- 🎨 **Material Design 3** - Interface modern dengan dynamic color scheme
- 💾 **Local Storage** - Data tersimpan secara lokal dengan SharedPreferences
- 🌗 **Light/Dark Mode** - Otomatis mengikuti sistem (coming soon)

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── folder.dart
│   └── markdown_file.dart
├── providers/                # State management (Provider)
│   └── app_provider.dart
├── screens/                  # UI Screens
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── file_explorer_screen.dart
│   ├── reader_screen.dart
│   ├── editor_screen.dart
│   ├── search_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
├── data/                     # Initial data
│   └── initial_data.dart
└── widgets/                  # Reusable widgets (future)
```

## 🚀 Instalasi & Menjalankan

### Prerequisites

- Flutter SDK 3.24 atau lebih baru
- Dart 3.9.2 atau lebih baru
- Android Studio / Xcode (untuk emulator)
- VS Code atau editor pilihan Anda

### Langkah Instalasi

1. **Clone atau navigate ke folder project**
   ```bash
   cd markflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   # Untuk iOS Simulator
   flutter run -d "iPhone 15 Pro"
   
   # Untuk Android Emulator
   flutter run -d emulator-5554
   
   # Atau pilih device
   flutter devices
   flutter run -d <device-id>
   ```

## 📦 Dependencies Utama

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.2              # State management
  shared_preferences: ^2.3.3    # Local storage
  flutter_markdown: ^0.7.4+1    # Markdown rendering
  markdown: ^7.2.2              # Markdown parsing
  intl: ^0.20.1                 # Internationalization
  uuid: ^4.5.1                  # ID generation
  url_launcher: ^6.3.1          # Open URLs
```

## 🎯 Komponen Utama

### 1. State Management (Provider)

Aplikasi menggunakan **Provider** untuk state management yang efisien dan mudah digunakan:

```dart
// Mengakses state
Consumer<AppProvider>(
  builder: (context, provider, child) {
    return Text(provider.files.length.toString());
  },
)

// Memanggil methods
provider.addFile('New Note.md', currentFolderId);
provider.setActiveView(ActiveView.reader, fileId: fileId);
```

### 2. Local Storage

Data disimpan menggunakan **SharedPreferences**:
- Files dan folders tersimpan dalam format JSON
- Auto-save ketika ada perubahan
- Reset ke default data tersedia di Settings

### 3. Markdown Rendering

Menggunakan **flutter_markdown** package:
- Preview real-time
- Support code syntax highlighting
- Interactive checkboxes
- Clickable links

## 🎨 Material Design 3

Aplikasi ini sepenuhnya menggunakan Material Design 3 dengan:
- Dynamic color scheme
- Surface containers dengan elevation
- Filled buttons & chips
- Modern navigation bar
- Smooth transitions

## 📱 Screenshots

### Dashboard
Menampilkan overview file dan folder dengan statistik, menggunakan logo MarkFlow

### File Explorer
Browse dan manage file/folder dengan breadcrumb navigation

### Editor
Split view dengan markdown editor dan live preview

### Reader
View markdown dengan rendering yang indah

### Search
Pencarian cepat dengan filter berdasarkan nama, konten, atau tags

## 🎨 Branding

Aplikasi ini menggunakan logo MarkFlow dari `assets/logo.png`:
- ✅ App icon untuk Android
- ✅ App icon untuk iOS  
- ✅ App icon untuk macOS
- ✅ Header logo di Dashboard
- ✅ Profile picture di Settings

Logo telah di-generate untuk semua platform menggunakan `flutter_launcher_icons`.

## 🔄 Migrasi dari React

Aplikasi ini adalah hasil migrasi lengkap dari React/TypeScript ke Flutter dengan:

### Yang Dipertahankan:
- ✅ Semua fitur utama
- ✅ UI/UX design (Material Design 3)
- ✅ Data structure
- ✅ Business logic

### Yang Ditingkatkan:
- 🚀 Performa lebih baik (native)
- 📱 Better mobile experience
- 🎨 Smooth animations
- 💾 Lebih efisien dalam storage

### Perbedaan Teknis:

| Aspect | React Version | Flutter Version |
|--------|--------------|-----------------|
| State Management | useState, useEffect | Provider |
| Storage | LocalStorage API | SharedPreferences |
| Styling | Tailwind CSS | Material 3 Theme |
| Navigation | React state-based | Navigator + Provider |
| Animations | Framer Motion | AnimatedBuilder/Hero |

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building Release
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release
```

### Code Generation (jika diperlukan)
```bash
flutter pub run build_runner build
```

## 🎯 Roadmap

- [ ] Cloud sync dengan backend API
- [ ] Dark mode manual toggle
- [ ] Export to PDF
- [ ] Collaboration features
- [ ] Voice-to-text
- [ ] Advanced markdown features (mermaid, math equations)
- [ ] Themes customization
- [ ] Multi-language support

## 🐛 Known Issues

- Saat ini menggunakan `flutter_markdown` yang discontinued, akan migrate ke `flutter_markdown_plus`
- Beberapa package memiliki versi lebih baru yang belum compatible

## 👨‍💻 Author

**Suyono**
- Email: suyono@aqj.or.id
- Organization: AQJ

## 📄 License

Aplikasi ini dibuat untuk keperluan demo dan portfolio.

## 🙏 Acknowledgments

- Desain original dari versi React/TypeScript
- Material Design 3 Guidelines
- Flutter Community
- Google AI Studio (untuk initial scaffolding)

---

**Happy Coding! 🚀**
