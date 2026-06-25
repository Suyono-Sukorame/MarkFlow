Export apk minim size

32bit
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter clean && flutter pub get.
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info.

64bit
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter clean && flutter build apk --release --target-platform android-arm64,android-arm --split-per-abi

===

Perfect! Sekarang saya sudah memahami fitur yang ada. Mari saya berikan analisa lengkap dan opsi saran:

📊 ANALISA FITUR SAAT INI:
✅ Yang Sudah Ada:
📝 Editor - Basic dengan formatting toolbar
👁️ Reader - Markdown viewer dengan styling
📁 File Explorer - Browse folder & files
🔍 Search - Search by name, content, tags
⭐ Favorites - Mark files as favorite
⚙️ Settings - Basic settings
📥 Import - Import files/folder dari storage
💾 Storage - Local storage dengan SharedPreferences
🎯 OPSI FITUR UNTUK DIPERDALAM / DITAMBAH:
KATEGORI A: PRODUCTIVE FEATURES ⭐ HIGH IMPACT
1. 📱 SYNC & BACKUP
Masalah: Data hanya di local, jika HP hilang/rusak = data hilang

Opsi Solusi:

A1. Export/Import Database

Export semua data ke single .zip file
Import untuk restore
Share via email/drive
✅ Simple, no cloud dependency
⚠️ Manual process
A2. Google Drive Sync ⭐ RECOMMENDED

Auto-sync ke Google Drive
Multi-device support
Conflict resolution
✅ Industry standard
⚠️ Butuh Google auth
A3. GitHub Sync

Sync files sebagai git repo
Version control built-in
Collaboration ready
✅ Power user friendly
⚠️ Complex untuk casual user
Priority: 🔥 HIGH
Impact: User data safety + Multi-device

2. 🏷️ TAG MANAGEMENT & FILTERING
Masalah: Tags exists tapi tidak ada UI untuk manage

Opsi Fitur:

Add/remove tags dari editor
Tag autocomplete
Filter files by multiple tags
Tag cloud view
Recent tags quick access
Tag rename (bulk update)
Priority: 🔥 MEDIUM
Impact: Better organization

3. 📸 IMAGE & ATTACHMENT SUPPORT
Masalah: Markdown support images tapi tidak ada cara upload/attach

Opsi Solusi:

A1. Camera Integration

Take photo → insert ke markdown
Image saved di app folder
✅ Quick note with photos
A2. Image Picker

Pick dari gallery
Compress & optimize
Thumbnail preview
A3. File Attachments

Attach PDF, docs, etc
List attachments per note
Open dengan external app
Priority: 🔥 MEDIUM-HIGH
Impact: Rich note-taking experience

4. 🔗 INTERNAL LINKING (Wiki-style)
Masalah: Tidak ada cara untuk link antar notes

Opsi Fitur:

[[Note Name]] syntax untuk internal links
Auto-complete saat typing [[
Backlinks (which notes link to this note)
Graph view (visual connections)
Quick note creation dari link
Priority: 🔥 HIGH
Impact: Knowledge base / Second brain system

KATEGORI B: EDITOR ENHANCEMENTS
5. ⌨️ ADVANCED EDITOR FEATURES
Opsi Fitur:

Syntax Highlighting untuk code blocks
Live Markdown Preview (split screen)
Word/Character count
Reading time estimate
Markdown shortcuts (e.g., Ctrl+B for bold)
Undo/Redo dengan history
Find & Replace dalam editor
Auto-save interval (every 30s)
Templates (Daily note, Meeting notes, etc)
Priority: 🔥 MEDIUM
Impact: Better writing experience

6. 📝 SMART MARKDOWN HELPERS
Opsi Fitur:

Table editor with visual grid
Emoji picker 😊
Date/time picker (insert current date)
Checklist quick add
Math equations support (LaTeX)
Diagram support (mermaid.js)
Drawing/Sketch tool
Priority: 🔥 LOW-MEDIUM
Impact: Enhanced content types

KATEGORI C: ORGANIZATION & WORKFLOW
7. 📂 ADVANCED FOLDER FEATURES
Opsi Fitur:

Folder colors (visual differentiation)
Folder icons custom
Move files between folders (drag & drop style)
Bulk operations (select multiple → move/delete)
Folder templates
Pinned folders
Recently accessed folders
Priority: 🔥 MEDIUM
Impact: Better organization

8. 🎯 QUICK ACTIONS & SHORTCUTS
Opsi Fitur:

Quick note (floating button dari anywhere)
Voice to text
Share to MarkFlow (dari app lain)
Widgets (Android home screen)
Recent notes
Quick create
Search widget
Shortcuts (long-press app icon)
Priority: 🔥 MEDIUM-HIGH
Impact: Faster workflow

9. 🔔 REMINDERS & DUE DATES
Opsi Fitur:

Assign due dates to notes
Reminders/notifications
Calendar view
Todo list aggregation
Recurring tasks
Priority levels
Priority: 🔥 MEDIUM
Impact: Task management

KATEGORI D: VIEWING & READING
10. 📖 READING MODE ENHANCEMENTS
Opsi Fitur:

Dark/Light theme toggle (per note)
Reading mode focus (fullscreen, no UI)
Text-to-Speech (read aloud)
Font size adjust (pinch to zoom)
Line spacing options
Highlight text with colors
Annotations / comments
Table of contents (auto-generated from headers)
Priority: 🔥 MEDIUM
Impact: Better reading experience

KATEGORI E: COLLABORATION & SHARING
11. 🤝 SHARING & EXPORT
Opsi Fitur:

Export to PDF with styling
Export to HTML
Export to plain text
Share as link (read-only view)
Print support
Copy markdown to clipboard
Share entire folder
Priority: 🔥 MEDIUM
Impact: Content portability

12. 👥 COLLABORATION (Advanced)
Opsi Fitur:

Real-time co-editing
Comments & discussions
Share workspace dengan team
Permission levels (read/write)
Activity log
Priority: 🔥 LOW (Complex)
Impact: Team collaboration

KATEGORI F: ANALYTICS & INSIGHTS
13. 📊 STATISTICS & INSIGHTS
Opsi Fitur:

Writing stats
Total notes
Total words written
Most active day/time
Writing streak
Most used tags
Note length distribution
Activity heatmap
Search trends
Priority: 🔥 LOW-MEDIUM
Impact: Gamification & motivation

KATEGORI G: TECHNICAL IMPROVEMENTS
14. 🔒 SECURITY FEATURES
Opsi Fitur:

Password lock app
Biometric unlock (fingerprint/face)
Encrypt notes (end-to-end)
Lock individual notes
Private folders
Priority: 🔥 MEDIUM
Impact: Privacy & security

15. ⚡ PERFORMANCE & UX
Opsi Fitur:

Offline-first architecture (sudah ada)
Fast search (indexed)
Lazy loading untuk large folders
Animations polish
Haptic feedback
Pull to refresh
Swipe gestures (swipe to delete, etc)
Keyboard shortcuts (untuk tablet/bluetooth keyboard)
Priority: 🔥 LOW
Impact: Polish & refinement

🎯 REKOMENDASI TOP 5 (Quick Wins):
1. 🔗 Internal Linking (Wiki-style) ⭐⭐⭐⭐⭐
Why: Transform dari note app → knowledge base
Effort: Medium
Impact: Very High
User Value: Second brain system
2. 📱 Export/Import Backup ⭐⭐⭐⭐⭐
Why: Data safety critical
Effort: Low
Impact: High
User Value: Peace of mind
3. 🏷️ Tag Management UI ⭐⭐⭐⭐
Why: Tags sudah ada di data model, tinggal UI
Effort: Low
Impact: Medium
User Value: Better organization
4. 📸 Image Picker Integration ⭐⭐⭐⭐
Why: Rich note-taking
Effort: Medium
Impact: Medium-High
User Value: Visual notes
5. 🎯 Quick Note Widget ⭐⭐⭐⭐
Why: Capture ideas fast
Effort: Low-Medium
Impact: Medium
User Value: Convenience
❓ PERTANYAAN UNTUK ANDA:
Use Case Utama: Untuk apa Anda paling sering gunakan MarkFlow?

Personal notes?
Study/learning?
Project documentation?
Daily journal?
Pain Point: Apa yang paling Anda butuhkan tapi belum ada?

Priority: Dari 15 kategori di atas, mana yang paling menarik untuk Anda?

Timeline: Mau fokus quick wins (1-2 fitur cepat) atau long-term features?

Saya siap implementasi apapun yang Anda pilih! 🚀
