# Changelog

## [1.0.0] - 2026-06-25

### ✨ Initial Release - Complete Migration from React to Flutter

#### Added
- 🎨 **Complete UI Migration** - All screens migrated to Flutter with Material Design 3
- 📱 **7 Main Screens**:
  - Dashboard with statistics and recent files
  - File Explorer with breadcrumb navigation
  - Markdown Editor with live preview
  - Reader with beautiful markdown rendering
  - Search with multiple filters
  - Favorites/Starred files view
  - Settings with database reset
  
- 💾 **Local Storage** - Persistent data with SharedPreferences
- 📝 **Full Markdown Support**:
  - Headers (H1, H2, H3)
  - Bold, Italic, Links
  - Code blocks with syntax
  - Tables
  - Blockquotes
  - Checklists (interactive in reader mode)
  - Bullet and numbered lists
  
- 🔍 **Smart Search** - Search by file name, content, or tags
- ⭐ **Favorites System** - Star/unstar files for quick access
- 📂 **File Management**:
  - Create, rename, delete files
  - Create, rename, delete folders
  - Hierarchical folder structure
  - Breadcrumb navigation
  
- 🎨 **Material Design 3**:
  - Dynamic color scheme
  - Surface containers
  - Modern navigation bar
  - Floating action buttons
  - Smooth transitions
  
- 🖼️ **Custom App Icon** - Logo from assets/logo.png
  - Generated for Android
  - Generated for iOS
  - Displayed in app header
  - Used in settings profile

#### Technical Details
- **State Management**: Provider pattern
- **Storage**: SharedPreferences for local-first data
- **Markdown Rendering**: flutter_markdown package
- **Navigation**: Stack-based with Provider
- **Platforms**: iOS, Android, macOS, Windows, Linux, Web

#### Known Issues
- `flutter_markdown` package is discontinued (will migrate to `flutter_markdown_plus`)
- Some deprecated API warnings (`withOpacity`, `surfaceVariant`)

#### Files Created
- 14 Dart source files
- 3 model classes
- 1 provider for state management
- 7 screen widgets
- 1 initial data file
- Complete documentation (README, MIGRATION_NOTES, QUICKSTART)

#### Migration Notes
- Migrated from React 19.0.1 + TypeScript
- Converted from Tailwind CSS to Material Design 3
- Changed from localStorage to SharedPreferences
- Replaced Framer Motion with Flutter animations
- Custom markdown parser → flutter_markdown package

### 🐛 Bug Fixes
- Fixed type casting issue in Wrap children (List<dynamic> → List<Widget>)
- Fixed logo asset integration
- Resolved app icon generation for all platforms

### 📚 Documentation
- ✅ README_FLUTTER.md - Complete project documentation
- ✅ MIGRATION_NOTES.md - Detailed migration guide
- ✅ QUICKSTART.md - Quick start guide
- ✅ CHANGELOG.md - This file

### 🚀 Performance
- Native performance on mobile devices
- 60 FPS smooth animations
- Fast hot reload during development
- Small memory footprint

### 🎯 Next Steps
- [ ] Migrate to flutter_markdown_plus
- [ ] Add dark mode toggle
- [ ] Implement cloud sync
- [ ] Add export to PDF
- [ ] Advanced markdown features (math, mermaid)
- [ ] Multi-language support

---

**Author**: Suyono (suyono@aqj.or.id)  
**Organization**: AQJ  
**Flutter Version**: 3.35.7  
**Dart Version**: 3.9.2
