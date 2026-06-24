import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _isFabOpen = false;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
          ),
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
}
