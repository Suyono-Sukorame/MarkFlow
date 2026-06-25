import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Manage preferences and local markdown content state.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Account Profile Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCOUNT PROFILE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Suyono',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'suyono@aqj.or.id',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Backup & Restore Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BACKUP & RESTORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Export your data to keep it safe or import from a previous backup.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _exportBackup(context, provider),
                              icon: const Icon(Icons.file_download, size: 18),
                              label: const Text('Export'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _importBackup(context, provider),
                              icon: const Icon(Icons.file_upload, size: 18),
                              label: const Text('Import'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Workspace Actions Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WORKSPACE ACTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Resetting the workspace database will clear all your custom changes and restore default directories and study guides.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _showResetDialog(context, provider),
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Restore Demo Database'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Workspace Diagnostics Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WORKSPACE DIAGNOSTICS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDiagnosticItem('Folders Count', '${provider.folders.length}'),
                      _buildDiagnosticItem('Files Count', '${provider.files.length}'),
                      _buildDiagnosticItem('Active Layout', 'Corporate Modern (MD3)'),
                      _buildDiagnosticItem('Status', 'Local-First Persistent'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All databases synchronized & secure',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text(
          'This will restore all default folders and files. Your custom changes will be lost. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.resetDatabase();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database reset successfully')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, AppProvider provider) async {
    try {
      // Show loading
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
                  Text('Creating backup...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Export data
      final result = await provider.exportDatabase();
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        final exportData = result['data'];
        final jsonString = jsonEncode(exportData);
        
        // Create temp file
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
        final fileName = 'markflow_backup_$timestamp.json';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);

        // Share file
        if (context.mounted) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'MarkFlow Backup',
            text: 'MarkFlow backup created on ${DateTime.now().toString().split('.')[0]}',
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup exported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Export failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, AppProvider provider) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      if (!context.mounted) return;

      // Show import options dialog
      final importMode = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How do you want to import the backup?'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Replace All'),
                subtitle: const Text('Delete current data and replace with backup'),
                onTap: () => Navigator.pop(context, 'replace'),
              ),
              ListTile(
                leading: const Icon(Icons.merge),
                title: const Text('Merge'),
                subtitle: const Text('Keep current data and add from backup'),
                onTap: () => Navigator.pop(context, 'merge'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (importMode == null || !context.mounted) return;

      // Show loading
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
                  Text('Importing backup...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Read file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Import data
      Map<String, dynamic> importResult;
      if (importMode == 'replace') {
        importResult = await provider.importDatabase(importData);
      } else {
        importResult = await provider.mergeDatabase(importData);
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      if (importResult['success'] == true) {
        String message;
        if (importMode == 'replace') {
          message = 'Imported ${importResult['foldersCount']} folders and ${importResult['filesCount']} files';
        } else {
          message = 'Added ${importResult['foldersAdded']} folders and ${importResult['filesAdded']} files';
          if (importResult['duplicates'] > 0) {
            message += '\n${importResult['duplicates']} items skipped (duplicates)';
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(importResult['message'] ?? 'Import failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
