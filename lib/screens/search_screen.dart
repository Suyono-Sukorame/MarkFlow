import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _searchByName = true;
  bool _searchByContent = false;
  bool _searchByTags = false;
  List _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, List files) {
    if (query.trim().length <= 2) {
      setState(() => _searchResults = []);
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    final filtered = files.where((file) {
      bool match = false;
      
      if (_searchByName && file.name.toLowerCase().contains(lowerQuery)) {
        match = true;
      }
      
      if (_searchByContent && file.content.toLowerCase().contains(lowerQuery)) {
        match = true;
      }
      
      if (_searchByTags && file.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
        match = true;
      }

      // Default fallback if no search category is toggled
      if (!_searchByName && !_searchByContent && !_searchByTags) {
        match = file.name.toLowerCase().contains(lowerQuery) ||
                file.content.toLowerCase().contains(lowerQuery) ||
                file.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }

      return match;
    }).toList();

    setState(() => _searchResults = filtered);
  }

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
            title: const Text('Search'),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _performSearch(value, provider.files),
                  decoration: InputDecoration(
                    hintText: 'Search your markdown...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  autofocus: true,
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('File Name'),
                      selected: _searchByName,
                      onSelected: (value) {
                        setState(() => _searchByName = value);
                        _performSearch(_searchController.text, provider.files);
                      },
                      selectedColor: colorScheme.secondaryContainer,
                    ),
                    FilterChip(
                      label: const Text('Content'),
                      selected: _searchByContent,
                      onSelected: (value) {
                        setState(() => _searchByContent = value);
                        _performSearch(_searchController.text, provider.files);
                      },
                      selectedColor: colorScheme.secondaryContainer,
                    ),
                    FilterChip(
                      label: const Text('Tags'),
                      selected: _searchByTags,
                      onSelected: (value) {
                        setState(() => _searchByTags = value);
                        _performSearch(_searchController.text, provider.files);
                      },
                      selectedColor: colorScheme.secondaryContainer,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Results
              Expanded(
                child: _buildResults(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = _searchController.text.trim();

    if (query.length <= 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 100,
              color: colorScheme.primary.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'No search performed yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a keyword above to scan your markdown files',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 100,
              color: colorScheme.error.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                children: [
                  const TextSpan(text: 'We couldn\'t find any file matching '),
                  TextSpan(
                    text: '"$query"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const TextSpan(text: '.\nTry adjusting your search filters.'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Found ${_searchResults.length} Matches',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        ..._searchResults.map((file) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.description, color: colorScheme.primary),
            title: Text(
              file.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSnippet(file.content, query),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (file.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: file.tags.map<Widget>((tag) => Chip(
                        label: Text('#$tag'),
                        labelStyle: const TextStyle(fontSize: 10),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ),
              ],
            ),
            trailing: Text(
              file.updatedAt,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            onTap: () => provider.setActiveView(ActiveView.reader, fileId: file.id),
          ),
        )),
        const SizedBox(height: 100), // Space for bottom nav
      ],
    );
  }

  String _getSnippet(String content, String keyword) {
    if (keyword.isEmpty) {
      return content.length > 120 ? '${content.substring(0, 120)}...' : content;
    }
    
    final lowerContent = content.toLowerCase();
    final lowerKeyword = keyword.toLowerCase().trim();
    final index = lowerContent.indexOf(lowerKeyword);
    
    if (index == -1) {
      return content.length > 120 ? '${content.substring(0, 120)}...' : content;
    }

    final start = (index - 40).clamp(0, content.length);
    final end = (index + lowerKeyword.length + 80).clamp(0, content.length);
    var snippet = content.substring(start, end);
    
    if (start > 0) snippet = '...$snippet';
    if (end < content.length) snippet = '$snippet...';

    return snippet;
  }
}
