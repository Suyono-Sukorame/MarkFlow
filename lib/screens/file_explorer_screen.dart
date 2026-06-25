import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_provider.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _isFabOpen = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final currentFolderId = provider.currentFolderId;
        
        final currentFolders = provider.folders
            .where((f) => f.parentId == currentFolderId)
            .toList();
        final currentFiles = provider.files
            .where((f) => f.folderId == currentFolderId)
            .toList();

        // Build breadcrumbs
        final breadcrumbs = _buildBreadcrumbs(provider);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surfaceContainerLow,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: breadcrumbs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final crumb = entry.value;
                      return Row(
                        children: [
                          if (index > 0)
                            Icon(Icons.chevron_right, size: 14, color: colorScheme.outlineVariant),
                          TextButton(
                            onPressed: () => provider.setCurrentFolder(crumb['id']),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 30),
                            ),
                            child: Row(
                              children: [
                                if (crumb['id'] == null)
                                  Icon(Icons.home, size: 14, color: colorScheme.primary),
                                if (crumb['id'] == null)
                                  const SizedBox(width: 4),
                                Text(
                                  crumb['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: index == breadcrumbs.length - 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: index == breadcrumbs.length - 1
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Header with title and sort button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentFolderId != null
                          ? '${provider.folders.firstWhere((f) => f.id == currentFolderId).name} Notes'
                          : 'Files',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () {},
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: currentFolders.isEmpty && currentFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 48,
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This folder is empty',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use the FAB button below to add content!',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Folders
                          ...currentFolders.map((folder) => _buildFolderItem(
                                context,
                                provider,
                                folder,
                              )),
                          
                          // Divider if both exist
                          if (currentFolders.isNotEmpty && currentFiles.isNotEmpty)
                            Divider(color: colorScheme.outlineVariant.withOpacity(0.3)),
                          
                          // Files
                          ...currentFiles.map((file) => _buildFileItem(
                                context,
                                provider,
                                file,
                              )),
                          
                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isFabOpen) ...[
                _buildSmallFab(
                  context,
                  icon: Icons.create_new_folder,
                  label: 'New Folder',
                  onPressed: () {
                    setState(() => _isFabOpen = false);
                    _showNewFolderDialog(context, provider);
                  },
                ),
                const SizedBox(height: 12),
                _buildSmallFab(
                  context,
                  icon: Icons.upload_file,
                  label: 'Import Files',
                  onPressed: () {
                    setState(() => _isFabOpen = false);
                    _showImportDialog(context, provider);
                  },
                ),
                const SizedBox(height: 12),
                _buildSmallFab(
                  context,
                  icon: Icons.note_add,
                  label: 'New File',
                  onPressed: () {
                    setState(() => _isFabOpen = false);
                    _showNewFileDialog(context, provider);
                  },
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton(
                onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
                child: AnimatedRotation(
                  turns: _isFabOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallFab(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(icon, size: 16, color: colorScheme.secondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderItem(BuildContext context, AppProvider provider, folder) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.folder,
            color: colorScheme.onSecondaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          folder.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Updated ${folder.updatedAt}',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, size: 18),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Rename'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              provider.deleteFolder(folder.id);
            }
          },
        ),
        onTap: () => provider.setCurrentFolder(folder.id),
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, AppProvider provider, file) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description,
            color: colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          file.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: file.tags.isNotEmpty
            ? Wrap(
                spacing: 4,
                children: file.tags.map<Widget>((tag) => Chip(
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 10),
                  visualDensity: VisualDensity.compact,
                )).toList(),
              )
            : Text(
                '${file.size} • Last edited ${file.updatedAt}',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                file.isFavorite ? Icons.star : Icons.star_outline,
                color: file.isFavorite ? colorScheme.primary : null,
                size: 18,
              ),
              onPressed: () => provider.toggleFavorite(file.id),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Read File'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit File'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'read') {
                  provider.setActiveView(ActiveView.reader, fileId: file.id);
                } else if (value == 'edit') {
                  provider.setActiveView(ActiveView.editor, fileId: file.id);
                } else if (value == 'delete') {
                  provider.deleteFile(file.id);
                }
              },
            ),
          ],
        ),
        onTap: () => provider.setActiveView(ActiveView.reader, fileId: file.id),
      ),
    );
  }

  List<Map<String, dynamic>> _buildBreadcrumbs(AppProvider provider) {
    final crumbs = <Map<String, dynamic>>[{'id': null, 'name': 'Root'}];
    
    if (provider.currentFolderId == null) return crumbs;

    final path = <Map<String, dynamic>>[];
    String? currId = provider.currentFolderId;
    
    while (currId != null) {
      final folder = provider.folders.firstWhere(
        (f) => f.id == currId,
        orElse: () => provider.folders.first,
      );
      path.insert(0, {'id': folder.id, 'name': folder.name});
      currId = folder.parentId;
    }
    
    return [...crumbs, ...path];
  }

  void _showNewFolderDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                provider.addFolder(name, provider.currentFolderId);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showNewFileDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'File name (e.g., Notes.md)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              var fileName = controller.text.trim();
              if (fileName.isNotEmpty) {
                if (!fileName.toLowerCase().endsWith('.md')) {
                  fileName += '.md';
                }
                provider.addFile(fileName, provider.currentFolderId);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Markdown Files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to import your markdown files',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // Import Files
            _buildImportOption(
              context,
              icon: Icons.file_copy_outlined,
              title: 'Import Files',
              description: 'Select multiple markdown files from any folder on your device',
              onTap: () {
                Navigator.pop(context);
                _importFolder(context, provider);
              },
            ),
            
            const SizedBox(height: 12),
            
            // Import Multiple Files
            _buildImportOption(
              context,
              icon: Icons.file_copy,
              title: 'Import Multiple Files',
              description: 'Select and import multiple markdown files at once',
              onTap: () {
                Navigator.pop(context);
                _importMultipleFiles(context, provider);
              },
            ),
            
            const SizedBox(height: 12),
            
            // Import Single File
            _buildImportOption(
              context,
              icon: Icons.insert_drive_file,
              title: 'Import Single File',
              description: 'Import one markdown file',
              onTap: () {
                Navigator.pop(context);
                _importSingleFile(context, provider);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFolder(BuildContext context, AppProvider provider) async {
    // Check and request storage permission
    final hasPermission = await _checkStoragePermission(context);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to import folders'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Small delay to ensure permission is fully granted
    await Future.delayed(const Duration(milliseconds: 300));

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening file picker...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Import folder
    final result = await provider.importFolderFromDevice();

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Check if folder picker returned null (not available or cancelled)
    if (result['success'] == false && result['message'] == 'No folder selected') {
      // Show fallback options dialog
      if (mounted) {
        _showFolderPickerFallbackDialog(context, provider);
      }
      return;
    }

    // Show result
    if (mounted) {
      _showResultSnackBar(context, result);
    }
  }

  Future<void> _showFolderPickerFallbackDialog(BuildContext context, AppProvider provider) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.info_outline,
          color: colorScheme.primary,
          size: 48,
        ),
        title: const Text('Folder Picker Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The folder picker is not available on your device. You have these options:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildFallbackOption(
              context,
              icon: Icons.file_copy,
              title: '1. Select Multiple Files',
              description: 'Choose multiple markdown files at once',
            ),
            const SizedBox(height: 12),
            _buildFallbackOption(
              context,
              icon: Icons.settings,
              title: '2. Grant All Files Access',
              description: 'Enable full storage access in Settings',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Settings'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _importMultipleFiles(context, provider);
            },
            icon: const Icon(Icons.file_copy, size: 18),
            label: const Text('Select Files'),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _importSingleFile(BuildContext context, AppProvider provider) async {
    // Check permission
    final hasPermission = await _checkStoragePermission(context);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to import files'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Small delay to ensure permission is fully granted
    await Future.delayed(const Duration(milliseconds: 300));

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening file picker...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Import file
    final result = await provider.importSingleFile();

    // Close loading
    if (mounted) Navigator.pop(context);

    // Show result
    if (mounted) {
      _showResultSnackBar(context, result);
    }
  }

  Future<void> _importMultipleFiles(BuildContext context, AppProvider provider) async {
    // Check permission
    final hasPermission = await _checkStoragePermission(context);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to import files'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Small delay to ensure permission is fully granted
    await Future.delayed(const Duration(milliseconds: 300));

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening file picker...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Import files
    final result = await provider.importMultipleFiles();

    // Close loading
    if (mounted) Navigator.pop(context);

    // Show result
    if (mounted) {
      _showResultSnackBar(context, result);
    }
  }

  Future<bool> _checkStoragePermission(BuildContext context) async {
    // Skip permission check on web - not needed for file picker
    if (kIsWeb) {
      return true;
    }
    
    // With Storage Access Framework (SAF), we don't need complex permissions
    // The system handles permissions automatically when user selects files
    // We only check if basic permissions are needed for older Android versions
    
    // For Android 10 and below, check storage permission
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Show explanation dialog before requesting permission
    if (mounted) {
      final shouldRequest = await _showPermissionExplanationDialog(context);
      if (!shouldRequest) return false;
    }

    // Request storage permission (mainly for Android 10 and below)
    var status = await Permission.storage.request();
    
    if (status.isGranted) {
      return true;
    }

    // If permission denied but we're on Android 11+, SAF will still work
    // So we return true to allow the file picker to open
    if (status.isDenied) {
      // Show info that file picker will still work
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You can still select files using the file picker'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true; // Allow SAF to work
    }

    // Only if permanently denied, show settings dialog
    if (status.isPermanentlyDenied) {
      if (mounted) {
        final shouldOpenSettings = await _showManualPermissionDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      }
      // Still return true because SAF works without storage permission
      return true;
    }

    return true; // Default to true to allow SAF
  }

  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.folder_open,
          color: colorScheme.primary,
          size: 48,
        ),
        title: const Text('Select Your Files'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MarkFlow will open a file picker where you can:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildPermissionReason(
              context,
              icon: Icons.touch_app,
              text: 'Select multiple markdown files at once',
            ),
            const SizedBox(height: 8),
            _buildPermissionReason(
              context,
              icon: Icons.folder,
              text: 'Browse any folder on your device',
            ),
            const SizedBox(height: 8),
            _buildPermissionReason(
              context,
              icon: Icons.security,
              text: 'Your files stay on your device (no cloud upload)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open File Picker'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showManualPermissionDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.settings_suggest,
          color: colorScheme.tertiary,
          size: 48,
        ),
        title: const Text('Manual Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For Android 11+, you need to manually enable storage access:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStep(context, '1.', 'Open Settings (tap button below)'),
                  const SizedBox(height: 6),
                  _buildStep(context, '2.', 'Find "Permissions" or "Storage"'),
                  const SizedBox(height: 6),
                  _buildStep(context, '3.', 'Enable "All files access" or "Manage storage"'),
                  const SizedBox(height: 6),
                  _buildStep(context, '4.', 'Return to MarkFlow and try again'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Note: You can also use "Import Multiple Files" option which works without special permission.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildPermissionReason(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showResultSnackBar(BuildContext context, Map<String, dynamic> result) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (result['success'] == true) {
      String message;
      if (result.containsKey('filesImported')) {
        final fileCount = result['filesImported'];
        final folderName = result['folderName'] ?? 'folder';
        message = 'Successfully imported $fileCount file${fileCount == 1 ? '' : 's'} into "$folderName"';
      } else if (result.containsKey('fileName')) {
        message = 'Imported: ${result['fileName']}';
      } else {
        message = 'Import successful!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: colorScheme.onPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: colorScheme.onError),
              const SizedBox(width: 12),
              Expanded(child: Text(result['message'] ?? 'Import failed')),
            ],
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: colorScheme.onError,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
