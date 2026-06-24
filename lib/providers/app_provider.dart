import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
}
