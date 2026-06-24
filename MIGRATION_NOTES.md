# Migration Notes: React/TypeScript → Flutter

## Overview

Dokumen ini menjelaskan proses migrasi aplikasi MarkFlow dari React/TypeScript ke Flutter, termasuk perubahan arsitektur, pemetaan komponen, dan keputusan desain.

## Architecture Comparison

### React Version
```
src/
├── components/          # React Components
│   ├── DashboardView.tsx
│   ├── EditorView.tsx
│   ├── FileExplorerView.tsx
│   ├── MarkdownRenderer.tsx
│   ├── ReaderView.tsx
│   └── SearchView.tsx
├── types.ts            # TypeScript interfaces
├── data.ts             # Initial data
├── App.tsx             # Main app component
└── main.tsx            # Entry point
```

### Flutter Version
```
lib/
├── models/             # Dart models (Data classes)
│   ├── folder.dart
│   └── markdown_file.dart
├── providers/          # State management
│   └── app_provider.dart
├── screens/            # Full-page screens
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── file_explorer_screen.dart
│   ├── reader_screen.dart
│   ├── editor_screen.dart
│   ├── search_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
├── data/               # Initial data
│   └── initial_data.dart
└── main.dart           # Entry point
```

## Component Mapping

| React Component | Flutter Equivalent | Notes |
|----------------|-------------------|-------|
| `App.tsx` | `main.dart` + `home_screen.dart` | Split into entry point and main navigation |
| `DashboardView.tsx` | `dashboard_screen.dart` | Full screen instead of component |
| `EditorView.tsx` | `editor_screen.dart` | Uses TabBarView for editor/preview |
| `FileExplorerView.tsx` | `file_explorer_screen.dart` | Similar structure, FAB for actions |
| `ReaderView.tsx` | `reader_screen.dart` | Uses flutter_markdown |
| `SearchView.tsx` | `search_screen.dart` | Same logic, Material 3 UI |
| `MarkdownRenderer.tsx` | Built-in `MarkdownBody` | flutter_markdown package |

## State Management

### React (useState + useEffect)
```tsx
const [files, setFiles] = useState<MarkdownFile[]>([]);
const [activeView, setActiveView] = useState<ActiveView>('DASHBOARD');

useEffect(() => {
  localStorage.setItem('markflow_files', JSON.stringify(files));
}, [files]);
```

### Flutter (Provider)
```dart
class AppProvider with ChangeNotifier {
  List<MarkdownFile> _files = [];
  ActiveView _activeView = ActiveView.dashboard;
  
  Future<void> addFile(String name, String? folderId) async {
    // ... add logic
    await _saveData();
    notifyListeners();
  }
}
```

**Benefits:**
- ✅ Centralized state management
- ✅ Automatic UI updates via `notifyListeners()`
- ✅ Easier testing
- ✅ Better separation of concerns

## Data Persistence

### React
```typescript
// LocalStorage API
localStorage.setItem('markflow_files', JSON.stringify(files));
const data = localStorage.getItem('markflow_files');
```

### Flutter
```dart
// SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setString('markflow_files', jsonEncode(files));
final data = prefs.getString('markflow_files');
```

**Differences:**
- Flutter requires async operations
- More type-safe with JSON serialization
- Platform-independent storage

## UI Framework

### React (Tailwind CSS + Motion)
```tsx
<motion.div
  whileTap={{ scale: 0.98 }}
  className="bg-surface-container-low p-4 rounded-2xl hover:bg-surface-container-high"
>
  {content}
</motion.div>
```

### Flutter (Material 3)
```dart
Card(
  color: colorScheme.surfaceContainerLow,
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    ),
  ),
)
```

**Changes:**
- Tailwind classes → Material 3 properties
- Framer Motion → AnimatedBuilder/Hero
- CSS → Dart styling

## Navigation

### React (State-based)
```tsx
const [activeView, setActiveView] = useState<ActiveView>('DASHBOARD');

// Navigation
<button onClick={() => setActiveView('FILES')}>
  Go to Files
</button>

// Conditional rendering
{activeView === 'DASHBOARD' && <DashboardView />}
{activeView === 'FILES' && <FileExplorerView />}
```

### Flutter (Provider + Stack)
```dart
// In Provider
void setActiveView(ActiveView view, {String? fileId}) {
  _activeView = view;
  if (fileId != null) _selectedFileId = fileId;
  notifyListeners();
}

// In UI
Consumer<AppProvider>(
  builder: (context, provider, child) {
    switch (provider.activeView) {
      case ActiveView.dashboard:
        return const DashboardScreen();
      case ActiveView.files:
        return const FileExplorerScreen();
      // ...
    }
  },
)
```

## Markdown Rendering

### React (Custom Parser)
```tsx
// Custom markdown parser with regex
function inlineFormatter(text: string): React.ReactNode[] {
  // Parse bold, italic, links, code...
}

// Manual rendering
<div className="prose-markdown">
  {renderedElements}
</div>
```

### Flutter (flutter_markdown)
```dart
// Built-in package with customization
MarkdownBody(
  data: content,
  selectable: true,
  styleSheet: MarkdownStyleSheet(
    h1: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    p: TextStyle(fontSize: 16, height: 1.6),
    // ...
  ),
  onTapLink: (text, href, title) {
    launchUrl(Uri.parse(href!));
  },
)
```

**Benefits:**
- ✅ No need for custom parser
- ✅ Better performance
- ✅ Standard markdown support
- ✅ Easy customization

## Key Differences & Considerations

### 1. Async Operations
**React:** Mostly synchronous with LocalStorage
```tsx
localStorage.setItem('key', value); // Sync
```

**Flutter:** Async-first approach
```dart
await prefs.setString('key', value); // Async
```

### 2. Type System
**React/TypeScript:** Optional typing with interfaces
```typescript
interface MarkdownFile {
  id: string;
  name: string;
  // ...
}
```

**Flutter/Dart:** Null-safety built-in
```dart
class MarkdownFile {
  final String id;
  final String name;
  final String? folderId; // Nullable
  // ...
}
```

### 3. Styling Approach
**React:** Utility-first (Tailwind)
- Rapid prototyping
- Consistent spacing
- Responsive by default

**Flutter:** Widget-based (Material 3)
- Type-safe styling
- Theme-aware colors
- Platform-adaptive

### 4. Build System
**React:** Vite/webpack
- Hot Module Replacement
- Fast refresh
- Tree shaking

**Flutter:** Flutter build
- Hot reload (faster)
- Hot restart
- Native compilation

## Performance Improvements

### React Web App
- Bundle size: ~2-3MB
- Initial load: ~1-2s
- Runtime: V8/JavaScript

### Flutter App
- APK size: ~15-20MB (includes runtime)
- Initial load: <1s (native)
- Runtime: Dart VM (AOT compiled)

**Mobile Performance:**
- ✅ 60 FPS by default
- ✅ Native scrolling
- ✅ Better memory management
- ✅ Smaller runtime overhead

## Migration Challenges & Solutions

### 1. HTML/CSS to Widgets
**Challenge:** No direct HTML/CSS equivalent
**Solution:** Learn Widget tree composition, use Material 3 components

### 2. Event Handling
**Challenge:** Different event model
```tsx
// React
onChange={(e) => setValue(e.target.value)}
```
```dart
// Flutter
onChanged: (value) => setValue(value)
```

### 3. State Updates
**Challenge:** No useEffect equivalent
**Solution:** Use Provider lifecycle + async operations

### 4. Custom Animations
**Challenge:** Framer Motion not available
**Solution:** Use AnimatedBuilder, AnimatedContainer, Hero

## Testing Strategy

### React
```typescript
import { render, screen } from '@testing-library/react';

test('renders dashboard', () => {
  render(<DashboardView {...props} />);
  expect(screen.getByText('Hello')).toBeInTheDocument();
});
```

### Flutter
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(DashboardScreen());
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

## Future Enhancements

### Planned Improvements
- [ ] **Animation parity** - Implement all animations from React version
- [ ] **Custom markdown renderer** - More control over rendering
- [ ] **Platform channels** - Native features integration
- [ ] **State persistence** - Save app state on close
- [ ] **Export features** - PDF, HTML generation

### Not Migrated (Yet)
- ❌ Undo/Redo stack in editor (planned)
- ❌ Table of Contents sidebar (planned)
- ❌ Drag & drop file organization
- ❌ Custom themes/skins

## Lessons Learned

### What Worked Well
1. **Provider** - Excellent for app-wide state
2. **Material 3** - Beautiful out of the box
3. **Hot reload** - Faster than React HMR
4. **Type safety** - Caught many bugs early

### What Could Be Better
1. **Learning curve** - Widget composition takes time
2. **Package ecosystem** - Some packages discontinued
3. **Web support** - Not as mature as mobile
4. **CSS familiarity** - Miss the flexibility

## Conclusion

Migrasi dari React ke Flutter menghasilkan aplikasi mobile yang:
- ✅ Lebih performant (native)
- ✅ Lebih smooth (60 FPS)
- ✅ Lebih maintainable (type-safe)
- ✅ Cross-platform native (iOS + Android + macOS + Windows + Linux)

Meskipun ada learning curve, hasil akhirnya sangat memuaskan untuk pengembangan mobile app.

---

**Migration Date:** June 25, 2026
**Migrated By:** Suyono (suyono@aqj.or.id)
**React Version:** v19.0.1
**Flutter Version:** v3.35.7
