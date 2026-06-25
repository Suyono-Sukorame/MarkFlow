import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/folder.dart';
import '../models/markdown_file.dart';
import '../data/initial_data.dart';

enum ActiveView {
  dashboard,
  files,
  search,
  favorites,
  settings,
  reader,
  editor,
}

class AppProvider with ChangeNotifier {
  List<Folder> _folders = [];
  List<MarkdownFile> _files = [];
  ActiveView _activeView = ActiveView.dashboard;
  String? _currentFolderId = 'study';
  String? _selectedFileId;
  
  List<Folder> get folders => _folders;
  List<MarkdownFile> get files => _files;
  ActiveView get activeView => _activeView;
  String? get currentFolderId => _currentFolderId;
  String? get selectedFileId => _selectedFileId;
  
  MarkdownFile? get selectedFile => 
      _selectedFileId != null 
          ? _files.firstWhere((f) => f.id == _selectedFileId, orElse: () => _files.first)
          : null;
  
  List<MarkdownFile> get favoriteFiles => _files.where((f) => f.isFavorite).toList();
  
  final uuid = const Uuid();

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final foldersJson = prefs.getString('markflow_folders');
    final filesJson = prefs.getString('markflow_files');
    
    if (foldersJson != null && filesJson != null) {
      _folders = (jsonDecode(foldersJson) as List)
          .map((item) => Folder.fromJson(item))
          .toList();
      _files = (jsonDecode(filesJson) as List)
          .map((item) => MarkdownFile.fromJson(item))
          .toList();
    } else {
      _folders = initialFolders;
      _files = initialFiles;
      await _saveData();
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'markflow_folders',
      jsonEncode(_folders.map((f) => f.toJson()).toList()),
    );
    await prefs.setString(
      'markflow_files',
      jsonEncode(_files.map((f) => f.toJson()).toList()),
    );
  }

  void setActiveView(ActiveView view, {String? fileId, String? folderId}) {
    _activeView = view;
    if (fileId != null) _selectedFileId = fileId;
    if (folderId != null) _currentFolderId = folderId;
    notifyListeners();
  }

  void setCurrentFolder(String? folderId) {
    _currentFolderId = folderId;
    notifyListeners();
  }

  Future<void> addFolder(String name, String? parentId) async {
    final newFolder = Folder(
      id: 'folder-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      parentId: parentId,
      updatedAt: 'Just now',
    );
    _folders.insert(0, newFolder);
    await _saveData();
    notifyListeners();
  }

  Future<void> addFile(String name, String? folderId) async {
    final newFile = MarkdownFile(
      id: 'file-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      content: '# ${name.replaceAll('.md', '')}\n\nStart writing notes here...',
      folderId: folderId,
      tags: [],
      isFavorite: false,
      updatedAt: 'Just now',
      size: '0.1kb',
    );
    _files.insert(0, newFile);
    await _saveData();
    
    // Navigate to editor
    setActiveView(ActiveView.editor, fileId: newFile.id);
  }

  Future<void> renameFile(String fileId, String newName) async {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(
        name: newName,
        updatedAt: 'Just now',
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> renameFolder(String folderId, String newName) async {
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      _folders[index] = _folders[index].copyWith(
        name: newName,
        updatedAt: 'Just now',
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteFile(String fileId) async {
    _files.removeWhere((f) => f.id == fileId);
    await _saveData();
    notifyListeners();
  }

  Future<void> deleteFolder(String folderId) async {
    // Get all subfolder IDs recursively
    List<String> getSubfolderIds(String id) {
      List<String> ids = [id];
      for (var folder in _folders.where((f) => f.parentId == id)) {
        ids.addAll(getSubfolderIds(folder.id));
      }
      return ids;
    }

    final targetFolderIds = getSubfolderIds(folderId);
    _folders.removeWhere((f) => targetFolderIds.contains(f.id));
    _files.removeWhere((f) => f.folderId != null && targetFolderIds.contains(f.folderId));
    
    if (targetFolderIds.contains(_currentFolderId)) {
      _currentFolderId = null;
    }
    
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleFavorite(String fileId) async {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(
        isFavorite: !_files[index].isFavorite,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> updateFileContent(String fileId, String newContent, {String? newName}) async {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      final sizeInKb = '${(newContent.length / 1024).toStringAsFixed(1)}kb';
      _files[index] = _files[index].copyWith(
        content: newContent,
        name: newName,
        size: sizeInKb,
        updatedAt: 'Just now',
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> resetDatabase() async {
    _folders = initialFolders;
    _files = initialFiles;
    _currentFolderId = 'study';
    _activeView = ActiveView.dashboard;
    await _saveData();
    notifyListeners();
  }

  // Export database to JSON
  Future<Map<String, dynamic>> exportDatabase() async {
    try {
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'folders': _folders.map((f) => f.toJson()).toList(),
        'files': _files.map((f) => f.toJson()).toList(),
      };

      return {
        'success': true,
        'data': exportData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error exporting: $e',
      };
    }
  }

  // Import database from JSON
  Future<Map<String, dynamic>> importDatabase(Map<String, dynamic> importData) async {
    try {
      // Validate data structure
      if (!importData.containsKey('folders') || !importData.containsKey('files')) {
        return {
          'success': false,
          'message': 'Invalid backup file format',
        };
      }

      // Parse folders
      final folders = (importData['folders'] as List)
          .map((item) => Folder.fromJson(item))
          .toList();

      // Parse files
      final files = (importData['files'] as List)
          .map((item) => MarkdownFile.fromJson(item))
          .toList();

      // Replace current data
      _folders = folders;
      _files = files;
      _currentFolderId = folders.isNotEmpty ? folders.first.id : null;
      
      await _saveData();
      notifyListeners();

      return {
        'success': true,
        'foldersCount': folders.length,
        'filesCount': files.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error importing: $e',
      };
    }
  }

  // Merge imported data with existing data
  Future<Map<String, dynamic>> mergeDatabase(Map<String, dynamic> importData) async {
    try {
      if (!importData.containsKey('folders') || !importData.containsKey('files')) {
        return {
          'success': false,
          'message': 'Invalid backup file format',
        };
      }

      // Parse folders
      final importedFolders = (importData['folders'] as List)
          .map((item) => Folder.fromJson(item))
          .toList();

      // Parse files
      final importedFiles = (importData['files'] as List)
          .map((item) => MarkdownFile.fromJson(item))
          .toList();

      int foldersAdded = 0;
      int filesAdded = 0;
      int duplicates = 0;

      // Merge folders (skip if ID already exists)
      for (var folder in importedFolders) {
        if (!_folders.any((f) => f.id == folder.id)) {
          _folders.add(folder);
          foldersAdded++;
        } else {
          duplicates++;
        }
      }

      // Merge files (skip if ID already exists)
      for (var file in importedFiles) {
        if (!_files.any((f) => f.id == file.id)) {
          _files.add(file);
          filesAdded++;
        } else {
          duplicates++;
        }
      }

      await _saveData();
      notifyListeners();

      return {
        'success': true,
        'foldersAdded': foldersAdded,
        'filesAdded': filesAdded,
        'duplicates': duplicates,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error merging: $e',
      };
    }
  }

  // Import folder from device storage
  Future<Map<String, dynamic>> importFolderFromDevice() async {
    try {
      // Use Storage Access Framework (SAF) for reliable file picking
      // This works on all Android versions and handles permissions automatically
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown'],
        dialogTitle: 'Select Markdown Files',
      );
      
      if (result == null || result.files.isEmpty) {
        return {'success': false, 'message': 'No files selected'};
      }

      int filesImported = 0;
      String? rootFolderId;

      // Create a folder for imported files
      final now = DateTime.now();
      final folderName = 'Imported ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final rootFolder = Folder(
        id: 'imported-${now.millisecondsSinceEpoch}',
        name: folderName,
        parentId: _currentFolderId,
        updatedAt: 'Just now',
      );
      _folders.add(rootFolder);
      rootFolderId = rootFolder.id;

      // Import each selected file
      for (var file in result.files) {
        if (file.path != null) {
          try {
            final fileObj = File(file.path!);
            final content = await fileObj.readAsString();
            
            final markdownFile = MarkdownFile(
              id: 'imported-file-${now.millisecondsSinceEpoch}-$filesImported',
              name: file.name,
              content: content,
              folderId: rootFolderId,
              tags: [],
              isFavorite: false,
              updatedAt: 'Just now',
              size: '${(file.size / 1024).toStringAsFixed(1)}kb',
            );

            _files.add(markdownFile);
            filesImported++;
            
            // Small delay to prevent UI freezing
            if (filesImported % 5 == 0) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          } catch (e) {
            debugPrint('Error importing file ${file.name}: $e');
          }
        }
      }

      await _saveData();
      notifyListeners();

      return {
        'success': true,
        'filesImported': filesImported,
        'foldersImported': 1,
        'folderName': folderName,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Import single markdown file
  Future<Map<String, dynamic>> importSingleFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'message': 'No file selected'};
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final fileName = path.basename(file.path);
      final stat = await file.stat();
      final sizeInKb = '${(stat.size / 1024).toStringAsFixed(1)}kb';

      final markdownFile = MarkdownFile(
        id: 'imported-file-${DateTime.now().millisecondsSinceEpoch}',
        name: fileName,
        content: content,
        folderId: _currentFolderId,
        tags: ['imported'],
        isFavorite: false,
        updatedAt: 'Just now',
        size: sizeInKb,
      );

      _files.add(markdownFile);
      await _saveData();
      notifyListeners();

      return {
        'success': true,
        'fileName': fileName,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Import multiple markdown files
  Future<Map<String, dynamic>> importMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'message': 'No files selected'};
      }

      int importedCount = 0;

      for (var platformFile in result.files) {
        try {
          final file = File(platformFile.path!);
          final content = await file.readAsString();
          final fileName = path.basename(file.path);
          final stat = await file.stat();
          final sizeInKb = '${(stat.size / 1024).toStringAsFixed(1)}kb';

          final markdownFile = MarkdownFile(
            id: 'imported-file-${DateTime.now().millisecondsSinceEpoch}-$importedCount',
            name: fileName,
            content: content,
            folderId: _currentFolderId,
            tags: ['imported'],
            isFavorite: false,
            updatedAt: 'Just now',
            size: sizeInKb,
          );

          _files.add(markdownFile);
          importedCount++;
        } catch (e) {
          debugPrint('Error importing file ${platformFile.name}: $e');
        }
      }

      await _saveData();
      notifyListeners();

      return {
        'success': true,
        'filesImported': importedCount,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
