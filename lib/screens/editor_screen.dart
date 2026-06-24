import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _contentController;
  late TextEditingController _nameController;
  late TabController _tabController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    final file = provider.selectedFile;
    
    _contentController = TextEditingController(text: file?.content ?? '');
    _nameController = TextEditingController(text: file?.name ?? '');
    
    _contentController.addListener(_onContentChanged);
    _nameController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveContent(AppProvider provider) async {
    final file = provider.selectedFile;
    if (file != null) {
      await provider.updateFileContent(
        file.id,
        _contentController.text,
        newName: _nameController.text,
      );
      setState(() => _hasUnsavedChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully')),
        );
      }
    }
  }

  void _insertFormatting(String type) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);

    String replacement = '';
    int cursorOffset = 0;

    switch (type) {
      case 'bold':
        replacement = '**$selectedText**';
        cursorOffset = selectedText.isEmpty ? 2 : replacement.length;
        break;
      case 'italic':
        replacement = '*$selectedText*';
        cursorOffset = selectedText.isEmpty ? 1 : replacement.length;
        break;
      case 'link':
        replacement = '[$selectedText](https://url.com)';
        cursorOffset = selectedText.isEmpty ? 1 : replacement.length;
        break;
      case 'list':
        replacement = '\n- [ ] ${selectedText.isNotEmpty ? selectedText : 'Task'}';
        cursorOffset = replacement.length;
        break;
      case 'code':
        replacement = '\n```javascript\n${selectedText.isNotEmpty ? selectedText : '// code here'}\n```\n';
        cursorOffset = replacement.length;
        break;
      case 'table':
        replacement = '\n| Header 1 | Header 2 |\n| :--- | :--- |\n| Cell 1 | Cell 2 |\n';
        cursorOffset = replacement.length;
        break;
    }

    final newText = text.substring(0, start) + replacement + text.substring(end);
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: start + cursorOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final file = provider.selectedFile;
        
        if (file == null) {
          return const Scaffold(
            body: Center(child: Text('No file selected')),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surfaceContainerLow,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => provider.setActiveView(ActiveView.dashboard),
            ),
            title: SizedBox(
              width: 200,
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            actions: [
              if (_hasUnsavedChanges)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveContent(provider),
                color: _hasUnsavedChanges ? colorScheme.primary : null,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Editor'),
                Tab(text: 'Preview'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Editor tab
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Start writing markdown content...',
                      ),
                    ),
                    
                    // Preview tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: MarkdownBody(
                        data: _contentController.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          h2: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          h3: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          p: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                          code: TextStyle(
                            backgroundColor: colorScheme.surfaceVariant,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Formatting toolbar
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _buildFormatButton(Icons.format_bold, 'Bold', () => _insertFormatting('bold')),
                    _buildFormatButton(Icons.format_italic, 'Italic', () => _insertFormatting('italic')),
                    _buildFormatButton(Icons.link, 'Link', () => _insertFormatting('link')),
                    const VerticalDivider(),
                    _buildFormatButton(Icons.checklist, 'List', () => _insertFormatting('list')),
                    _buildFormatButton(Icons.table_chart, 'Table', () => _insertFormatting('table')),
                    _buildFormatButton(Icons.code, 'Code', () => _insertFormatting('code')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormatButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
